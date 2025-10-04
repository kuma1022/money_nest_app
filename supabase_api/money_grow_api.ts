import { createClient } from 'npm:@supabase/supabase-js@2.31.0';
import pLimit from "npm:p-limit";
const supabase = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", {
  auth: {
    persistSession: false
  }
});
console.info('Edge Function initialized');
Deno.serve(async (req)=>{
  try {
    const url = new URL(req.url);
    const path = url.pathname;
    const method = req.method;
    console.log('Incoming request:', method, path);
    // ------------------- /stock-search GET -------------------
    if (path.endsWith('/stock-search') && method === 'GET') {
      const q = (url.searchParams.get('q') || '').trim();
      const exchange = (url.searchParams.get('exchange') || '').trim() || null;
      const limit = Math.min(Math.max(parseInt(url.searchParams.get('limit') || '20', 10), 1), 200);
      if (!q) return new Response(JSON.stringify({
        error: 'Missing parameter: q'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
      const { data, error } = await supabase.rpc('search_stocks', {
        search_query: q,
        row_limit: limit,
        exchange_filter: exchange
      });
      if (error) return new Response(JSON.stringify({
        error: 'Database error'
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json'
        }
      });
      return new Response(JSON.stringify({
        query: q,
        exchange,
        count: data?.length || 0,
        results: data || []
      }), {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }
    if (path.startsWith('/auth/register') && method === 'POST') {
      return handleRegister(await req.json());
    }
    if (path.startsWith('/auth/login') && method === 'POST') {
      return handleLogin(await req.json());
    }
    if (path.startsWith('/subscriptions')) {
      if (method === 'POST') return handlePurchaseSubscription(await req.json());
      if (method === 'GET') return handleCheckSubscription(await req.json());
      if (method === 'DELETE') return handleCancelSubscription(await req.json());
    }
    // ------------------- 用户相关 -------------------
    const userMatch = path.match(/\/users\/([^/]+)\/(.*)$/);
    if (!userMatch) return new Response(JSON.stringify({
      error: 'Not Found'
    }), {
      status: 404
    });
    const userId = userMatch[1];
    const subPath = userMatch[2];
    // ------------------- 获取指定用户的最新信息（如资产总额、最新持仓、最近交易等） -------------------
    if (subPath === 'latest') {
      if (method === 'GET') return handleGetUserInfoLatest(userId);
    }
    // ------------------- 股票交易 -------------------
    if (subPath === 'stocks/trades') {
      if (method === 'POST') return handleCreateTrade(userId, await req.json());
      if (method === 'PUT') {
        const body = await req.json();
        const tradeId = body.trade_id;
        if (!tradeId) return new Response(JSON.stringify({
          error: 'Missing trade_id'
        }), {
          status: 400
        });
        return handleUpdateTrade(userId, tradeId, body);
      }
      if (method === 'DELETE') {
        const body = await req.json();
        const tradeId = body.trade_id;
        if (!tradeId) return new Response(JSON.stringify({
          error: 'Missing trade_id'
        }), {
          status: 400
        });
        return handleDeleteTrade(userId, tradeId);
      }
    }
    // ------------------- 资产信息 -------------------
    if (subPath === 'assets') {
      const body = await req.json();
      if (method === 'POST') return handleCreateAsset(userId, body);
      if (method === 'PUT') return handleUpdateAsset(userId, body);
      if (method === 'DELETE') return handleDeleteAsset(userId, body);
    }
    // ------------------- 资产金额记录 -------------------
    if (subPath === 'assets/values') {
      const body = await req.json();
      if (method === 'POST') return handleCreateAssetValue(userId, body);
      if (method === 'DELETE') return handleDeleteAssetValue(userId, body);
    }
    // ------------------- 分红记录 -------------------
    if (subPath === 'dividends') {
      const body = await req.json();
      if (method === 'POST') return handleCreateDividend(userId, body);
      if (method === 'PUT') return handleUpdateDividend(userId, body);
      if (method === 'DELETE') return handleDeleteDividend(userId, body);
    }
    // ------------------- 资产走势 -------------------
    if (subPath === 'assets/chart' && method === 'GET') {
      return handleGetAssetChart(userId, url.searchParams);
    }
    return new Response(JSON.stringify({
      error: 'Not Found'
    }), {
      status: 404
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({
      error: 'Internal error'
    }), {
      status: 500
    });
  }
});
// 注册用户
async function handleRegister(body) {
  const { email, password, apple_user_id, name, account_type } = body;
  // 创建 Auth 用户
  const { data: user, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    user_metadata: {
      apple_user_id
    }
  });
  if (authError) return new Response(JSON.stringify({
    error: authError.message
  }), {
    status: 400
  });
  // 在 accounts 表创建记录
  const { error: accError } = await supabase.from('accounts').insert({
    user_id: user.id,
    name,
    type: account_type
  });
  if (accError) return new Response(JSON.stringify({
    error: accError.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    user_id: user.id
  }), {
    status: 200
  });
}
// 登录用户
async function handleLogin(body) {
  const { email, password, apple_user_id } = body;
  let user;
  if (apple_user_id) {
    const { data, error } = await supabase.from('accounts').select('user_id').eq('user_id', apple_user_id).single();
    if (error) return new Response(JSON.stringify({
      error: 'User not found'
    }), {
      status: 404
    });
    user = data;
  } else {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    if (error) return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 400
    });
    user = data.user;
  }
  // 查询订阅状态
  const { data: subs } = await supabase.rpc('get_user_subscription', {
    p_user_id: user.id
  });
  return new Response(JSON.stringify({
    user_id: user.id,
    subscriptions: subs
  }), {
    status: 200
  });
}
// 购买/激活订阅
async function handlePurchaseSubscription(body) {
  const { user_id, platform, start_at, expire_at } = body;
  const { error } = await supabase.rpc('upsert_subscription', {
    p_user_id: user_id,
    p_platform: platform,
    p_status: 'active',
    p_start_at: start_at,
    p_expire_at: expire_at
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// 查询订阅状态
async function handleCheckSubscription(body) {
  const { user_id } = body;
  const { data, error } = await supabase.rpc('get_user_subscription', {
    p_user_id: user_id
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    subscriptions: data
  }), {
    status: 200
  });
}
// 取消订阅
async function handleCancelSubscription(body) {
  const { user_id, platform } = body;
  const { error } = await supabase.from('user_subscriptions').update({
    status: 'cancelled',
    last_checked_at: new Date().toISOString()
  }).eq('user_id', user_id).eq('platform', platform);
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// ------------------- 获取指定用户的最新信息（如资产总额、最新持仓、最近交易等） -------------------
async function handleGetUserInfoLatest(userId) {
  const t0 = Date.now();
  // 1️⃣ 拉取账户相关信息
  const t1 = Date.now();
  const { data: accountData } = await supabase.rpc('get_user_account_info', {
    p_user_id: userId
  });
  const t2 = Date.now();
  console.log(`[PERF] get_user_account_info: ${t2 - t1} ms`);
  // 2️⃣ 拉取 stock_prices（stock-level）
  const { data: stockPrices } = await supabase.rpc('get_user_stock_prices', {
    p_user_id: userId
  });
  const t3 = Date.now();
  console.log(`[PERF] get_user_stock_prices: ${t3 - t2} ms`);
  // 3️⃣ 拉取 fx_rates（account-level）
  const { data: fxRates } = await supabase.rpc('get_user_fx_rates', {
    p_user_id: userId
  });
  const t4 = Date.now();
  console.log(`[PERF] get_user_fx_rates: ${t4 - t3} ms`);
  // 4️⃣ 组装账户基本信息
  const accountsMap = {};
  accountData.forEach((row)=>{
    const accId = row.account_id;
    if (!accountsMap[accId]) {
      accountsMap[accId] = {
        account_id: accId,
        account_name: row.account_name,
        type: row.type || '',
        trade_records: [],
        stocks: [],
        trade_sell_mapping: [],
        fx_rates: []
      };
    }
    const acc = accountsMap[accId];
    // 添加交易记录，去重
    if (!acc.trade_record_ids) acc.trade_record_ids = new Set();
    if (row.trade_id && !acc.trade_record_ids.has(row.trade_id)) {
      acc.trade_record_ids.add(row.trade_id);
      acc.trade_records.push(row.trade);
    }
    // 添加 trade_sell_mapping，去重
    if (!acc.trade_sell_mapping_ids) acc.trade_sell_mapping_ids = new Set();
    if (row.trade_sell_mapping_id && !acc.trade_sell_mapping_ids.has(row.trade_sell_mapping_id)) {
      acc.trade_sell_mapping_ids.add(row.trade_sell_mapping_id);
      acc.trade_sell_mapping.push(row.trade_sell_mapping);
    }
    // 添加股票，去重
    if (!acc.stock_ids) acc.stock_ids = new Set();
    if (row.stock_id && !acc.stock_ids.has(row.stock_id)) {
      acc.stock_ids.add(row.stock_id);
      // 初始化 stock 时附带空的 stock_prices
      acc.stocks.push({
        ...row.stock,
        stock_prices: []
      });
    }
  });
  const t5 = Date.now();
  console.log(`[PERF] assemble accountData: ${t5 - t4} ms`);
  // 🔹分配 fx_rates
  if (fxRates) {
    fxRates.forEach((fr)=>{
      const acc = accountsMap[fr.account_id];
      if (acc) {
        if (!acc.fx_rate_ids) acc.fx_rate_ids = new Set();
        if (!acc.fx_rate_ids.has(fr.fx_rate_id)) {
          acc.fx_rate_ids.add(fr.fx_rate_id);
          acc.fx_rates.push(fr.fx_rate);
        }
      }
    });
  }
  const t6 = Date.now();
  console.log(`[PERF] assign fxRates: ${t6 - t5} ms`);
  // 🔹分配 stock_prices
  if (stockPrices) {
    stockPrices.forEach((sp)=>{
      for (const acc of Object.values(accountsMap)){
        const stock = acc.stocks.find((s)=>s.id === sp.stock_id);
        if (stock) {
          if (!stock._stock_price_ids) stock._stock_price_ids = new Set();
          const key = `${sp.stock_price.price_at}_${sp.stock_price.price}`;
          if (!stock._stock_price_ids.has(key)) {
            stock._stock_price_ids.add(key);
            stock.stock_prices.push({
              price: sp.stock_price.price,
              price_at: sp.stock_price.price_at
            });
          }
        }
      }
    });
  }
  const t7 = Date.now();
  console.log(`[PERF] assign stockPrices: ${t7 - t6} ms`);
  // 🔹补充历史价格（并发+缓存优化）
  const t8 = Date.now();
  // 1. 构建缓存
  const historyCache = new Map();
  // 2. 并发限制
  const limit = pLimit(8); // 最多8个并发
  // 3. 收集所有需要补历史价格的 stock
  const supplementTasks = [];
  for (const acc of Object.values(accountsMap)){
    for (const stock of acc.stocks){
      const priceList = stock.stock_prices || [];
      // 找当前股票对应的 trade_records 的最早 trade_date
      const tradeDates = acc.trade_records.filter((tr)=>tr.asset_id === stock.id).map((tr)=>new Date(tr.trade_date));
      const earliestTradeDate = tradeDates.length ? new Date(Math.min(...tradeDates)) : null;
      if (!earliestTradeDate) continue;
      const thresholdDate = new Date(earliestTradeDate);
      thresholdDate.setDate(thresholdDate.getDate() - 3);
      const earliestPriceDate = priceList.length ? new Date(priceList[0].price_at) : null;
      if (!earliestPriceDate || earliestPriceDate > thresholdDate) {
        // 需要补历史价格
        supplementTasks.push(limit(async ()=>{
          const cacheKey = `${stock.exchange}_${stock.ticker}`;
          let parsedRows = historyCache.get(cacheKey);
          if (!parsedRows) {
            try {
              const bucket = 'money_grow_app';
              const objectPath = `historical_prices_split/${stock.exchange}_github/${stock.exchange}/${stock.ticker}.csv`;
              const { data: downloadData, error: dlErr } = await supabase.storage.from(bucket).download(objectPath);
              if (dlErr || !downloadData) {
                stock.warning = 'Could not download historical price CSV from storage';
                return;
              }
              const text = await downloadData.text();
              const lines = text.trim().split('\n');
              parsedRows = [];
              // 从尾部往前解析，取 price_at >= earliestTradeDate
              const hasHeader = isNaN(Date.parse(lines[0].split(',')[0]));
              const startIdx = hasHeader ? 1 : 0;
              for(let i = lines.length - 1; i >= startIdx; i--){
                const [priceAtStr, priceStr] = lines[i].split(',');
                const priceAt = new Date(priceAtStr);
                if (priceAt >= earliestTradeDate) {
                  parsedRows.push({
                    price_at: priceAtStr,
                    price: parseFloat(priceStr)
                  });
                } else break;
              }
              parsedRows.reverse();
              historyCache.set(cacheKey, parsedRows);
            } catch (storageErr) {
              stock.warning = 'Error while fetching/parsing historical prices';
              return;
            }
          }
          // 合并已有 + 补充
          const combined = [
            ...parsedRows || [],
            ...priceList
          ];
          combined.sort((a, b)=>new Date(a.price_at) - new Date(b.price_at));
          // 去重
          const unique = [];
          const seen = new Set();
          for (const r of combined){
            const key = `${r.price_at}_${r.price}`;
            if (!seen.has(key)) {
              seen.add(key);
              unique.push(r);
            }
          }
          stock.stock_prices = unique;
        }));
      }
    }
  }
  // 4. 并发执行所有补历史价格任务
  await Promise.all(supplementTasks);
  const t9 = Date.now();
  console.log(`[PERF] supplement historical prices (concurrent): ${t9 - t8} ms`);
  const result = Object.values(accountsMap).map((acc)=>{
    const { trade_record_ids, trade_sell_mapping_ids, stock_ids, fx_rate_ids, ...rest } = acc;
    return rest;
  });
  const t10 = Date.now();
  console.log(`[PERF] total handleGetUserInfoLatest: ${t10 - t0} ms`);
  return new Response(JSON.stringify({
    success: true,
    user_id: userId,
    account_info: result
  }), {
    status: 200
  });
}
// ------------------- 股票交易处理 -------------------
async function handleCreateTrade(userId, body) {
  const tradeDate = new Date(body.trade_date + "T00:00:00Z");
  const { data, error } = await supabase.rpc("insert_trade_with_mappings", {
    p_user_id: userId,
    p_trade_date: tradeDate.toISOString(),
    p_action: body.action,
    p_stock_id: body.stock_id,
    p_trade_type: body.trade_type,
    p_quantity: body.quantity,
    p_price: body.price,
    p_fee: body.fee,
    p_fee_currency: body.fee_currency,
    p_remark: body.remark ?? null,
    p_account_id: body.account_id ?? null,
    p_sell_mappings: body.sell_mappings ?? []
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    trade: data
  }), {
    status: 200
  });
}
async function handleUpdateTrade(userId, tradeId, body) {
  const tradeDate = new Date(body.trade_date + "T00:00:00Z");
  const { data, error } = await supabase.rpc("update_trade_with_mappings", {
    p_trade_id: tradeId,
    p_user_id: userId,
    p_trade_date: tradeDate.toISOString(),
    p_trade_type: body.trade_type,
    p_quantity: body.quantity,
    p_price: body.price,
    p_fee: body.fee,
    p_fee_currency: body.fee_currency,
    p_remark: body.remark ?? null,
    p_sell_mappings: body.sell_mappings ?? []
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    trade: data
  }), {
    status: 200
  });
}
async function handleDeleteTrade(userId, tradeId) {
  const { error } = await supabase.rpc("delete_trade_with_mappings", {
    p_trade_id: tradeId,
    p_user_id: userId
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// ------------------- 资产信息处理 -------------------
async function handleCreateAsset(userId, body) {
  // Basic validation
  if (!userId) {
    return new Response(JSON.stringify({
      error: 'Missing userId'
    }), {
      status: 400
    });
  }
  if (!body) {
    return new Response(JSON.stringify({
      error: 'Missing body'
    }), {
      status: 400
    });
  }
  const required = [
    'asset_type',
    'asset_id',
    'trade_date',
    'action',
    'quantity',
    'price'
  ];
  for (const f of required){
    if (body[f] === undefined || body[f] === null) {
      return new Response(JSON.stringify({
        error: `${f} is required`
      }), {
        status: 400
      });
    }
  }
  // If action is sell, require sell_mappings non-empty 
  if (String(body.action).toLowerCase() === 'sell') {
    if (!Array.isArray(body.sell_mappings) || body.sell_mappings.length === 0) {
      return new Response(JSON.stringify({
        error: 'sell_mappings is required for sell action'
      }), {
        status: 400
      });
    }
  }
  try {
    const { data, error } = await supabase.rpc('insert_asset', {
      p_user_id: userId,
      p_account_id: body.account_id ?? null,
      p_asset_type: body.asset_type,
      p_asset_id: body.asset_id,
      p_trade_date: body.trade_date,
      p_action: body.action,
      p_trade_type: body.trade_type ?? null,
      p_position_type: body.position_type ?? null,
      p_quantity: body.quantity,
      p_price: body.price,
      p_leverage: body.leverage ?? null,
      p_swap_amount: body.swap_amount ?? null,
      p_swap_currency: body.swap_currency ?? null,
      p_fee_amount: body.fee_amount ?? null,
      p_fee_currency: body.fee_currency ?? null,
      p_manual_rate_input: body.manual_rate_input ?? null,
      p_remark: body.remark ?? null
    });
    if (error) {
      // RPC error
      return new Response(JSON.stringify({
        error: error.message
      }), {
        status: 500
      });
    }
    // supabase-js may return data as [{ insert_asset: <id> }] or raw value; handle common shapes
    let insertedId = null;
    if (data === null || data === undefined) {
      insertedId = null;
    } else {
      insertedId = data;
    }
    // If sell, insert mappings into trade_sell_mappings
    let mappings = [];
    if (String(body.action).toLowerCase() === 'sell') {
      if (!insertedId) {
        return new Response(JSON.stringify({
          error: 'Failed to resolve inserted sell id'
        }), {
          status: 500
        });
      }
      mappings = body.sell_mappings.map((m)=>({
          sell_id: insertedId,
          buy_id: m.buy_id,
          quantity: m.quantity
        }));
      // Insert mappings in a single call
      const { error: mapErr } = await supabase.from('trade_sell_mappings').insert(mappings);
      if (mapErr) {
        // Consider rolling back the created trade record in production; here we report error
        return new Response(JSON.stringify({
          error: 'Failed to insert sell mappings',
          details: mapErr.message
        }), {
          status: 500
        });
      }
    }
    // After mappings inserted (or if not sell), fetch historical prices
    // Query stock_prices where stock_id = body.asset_id and price_at >= body.trade_date
    const { data: pricesData, error: pricesErr } = await supabase.from('stock_prices').select('price, price_at').eq('stock_id', body.asset_id).gte('price_at', body.trade_date).order('price_at', {
      ascending: true
    });
    if (pricesErr) {
      // Non-fatal? Return error to caller per original pattern
      return new Response(JSON.stringify({
        error: 'Failed to fetch stock prices',
        details: pricesErr.message
      }), {
        status: 500
      });
    }
    // Normalize to list of { price, price_at }
    let priceList = Array.isArray(pricesData) ? pricesData.map((p)=>({
        price: p.price,
        price_at: p.price_at
      })) : [];
    // If earliest available price_at is greater than trade_date, fetch from Storage parquet
    const earliestDate = priceList.length ? new Date(priceList[0].price_at) : null;
    const tradeDate = new Date(body.trade_date);
    if (!earliestDate || earliestDate > tradeDate) {
      try {
        const bucket = 'money_grow_app';
        const objectPath = `historical_prices_split/${body.exchange}_github/${body.exchange}/${body.asset_code}.csv`;
        const { data: downloadData, error: dlErr } = await supabase.storage.from(bucket).download(objectPath);
        if (dlErr || !downloadData) {
          return new Response(JSON.stringify({
            success: true,
            asset_id: data,
            sell_mappings: mappings,
            price_history: priceList,
            warning: 'Could not download parquet from storage',
            details: dlErr ? dlErr.message : undefined
          }), {
            status: 201
          });
        }
        const text = await downloadData.text();
        const lines = text.trim().split("\n");
        // 表头是 "price_at,price"
        const parsedRows = [];
        // 2. 从尾部往前解析
        for(let i = lines.length - 1; i > 0; i--){
          const [priceAtStr, priceStr] = lines[i].split(",");
          const priceAt = new Date(priceAtStr);
          if (priceAt >= tradeDate) {
            parsedRows.push({
              price_at: priceAtStr,
              price: parseFloat(priceStr)
            });
          } else {
            break; // 已经小于目标日期，提前结束
          }
        }
        // 3. 恢复升序输出
        parsedRows.reverse();
        // parquet file is ordered ascending by price_at; we only need rows with price_at >= trade_date
        // Merge parsedRows with existing priceList, ensuring unique and sorted ascending by price_at
        const combined = [
          ...parsedRows,
          ...priceList
        ];
        combined.sort((a, b)=>new Date(a.price_at) - new Date(b.price_at));
        // Deduplicate by price_at (or price_at+price)
        const unique = [];
        const seen = new Set();
        for (const r of combined){
          const key = `${r.price_at}_${r.price}`;
          if (!seen.has(key)) {
            seen.add(key);
            unique.push(r);
          }
        }
        priceList = unique;
      } catch (storageErr) {
        // On any storage-related error, return existing priceList with warning        
        return new Response(JSON.stringify({
          success: true,
          asset_id: data,
          sell_mappings: mappings,
          price_history: priceList,
          warning: 'Error while fetching/parsing parquet',
          details: storageErr && (storageErr.message || String(storageErr))
        }), {
          status: 201
        });
      }
    }
    // `data` format depends on supabase-js version and RPC. It may return the raw value or an array.
    // Return the raw data to the caller for convenience.
    return new Response(JSON.stringify({
      success: true,
      asset_id: data,
      sell_mappings: mappings,
      price_history: priceList
    }), {
      status: 201
    });
  } catch (err) {
    return new Response(JSON.stringify({
      error: err && err.message || String(err)
    }), {
      status: 500
    });
  }
}
async function handleUpdateAsset(userId, body) {
  const { data, error } = await supabase.rpc("update_asset", {
    p_asset_id: body.asset_id,
    p_user_id: userId,
    p_name: body.name,
    p_type: body.type ?? null
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    asset: data
  }), {
    status: 200
  });
}
async function handleDeleteAsset(userId, body) {
  const { error } = await supabase.rpc("delete_asset", {
    p_asset_id: body.asset_id,
    p_user_id: userId
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// ------------------- 资产金额记录处理 -------------------
async function handleCreateAssetValue(userId, body) {
  const valueDate = new Date(body.value_date + "T00:00:00Z");
  const { data, error } = await supabase.rpc("insert_asset_value", {
    p_user_id: userId,
    p_asset_id: body.asset_id,
    p_value_date: valueDate.toISOString(),
    p_amount: body.amount
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    asset_value: data
  }), {
    status: 200
  });
}
async function handleDeleteAssetValue(userId, body) {
  const valueDate = new Date(body.value_date + "T00:00:00Z");
  const { error } = await supabase.rpc("delete_asset_value", {
    p_user_id: userId,
    p_asset_id: body.asset_id,
    p_value_date: valueDate.toISOString()
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// ------------------- 分红记录处理 -------------------
async function handleCreateDividend(userId, body) {
  const divDate = new Date(body.dividend_date + "T00:00:00Z");
  const { data, error } = await supabase.rpc("insert_dividend", {
    p_user_id: userId,
    p_asset_id: body.asset_id,
    p_dividend_date: divDate.toISOString(),
    p_amount: body.amount
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    dividend: data
  }), {
    status: 200
  });
}
async function handleUpdateDividend(userId, body) {
  const divDate = new Date(body.dividend_date + "T00:00:00Z");
  const { data, error } = await supabase.rpc("update_dividend", {
    p_dividend_id: body.dividend_id,
    p_user_id: userId,
    p_asset_id: body.asset_id,
    p_dividend_date: divDate.toISOString(),
    p_amount: body.amount
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    dividend: data
  }), {
    status: 200
  });
}
async function handleDeleteDividend(userId, body) {
  const { error } = await supabase.rpc("delete_dividend", {
    p_dividend_id: body.dividend_id,
    p_user_id: userId
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// ------------------- 资产走势 -------------------
async function handleGetAssetChart(userId, searchParams) {
  const startDate = searchParams.get('start_date');
  const endDate = searchParams.get('end_date');
  const { data, error } = await supabase.rpc("get_asset_chart", {
    p_user_id: userId,
    p_start_date: startDate,
    p_end_date: endDate
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    chart: data
  }), {
    status: 200
  });
}
