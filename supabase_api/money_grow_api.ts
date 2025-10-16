import { createClient } from 'npm:@supabase/supabase-js@2.31.0';
import pLimit from "npm:p-limit";
const supabase = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", {
  auth: {
    persistSession: false
  }
});
import { gzip } from "https://deno.land/x/compress@v0.4.5/mod.ts";
console.info('Edge Function initialized');
Deno.serve(async (req)=>{
  try {
    const url = new URL(req.url);
    const path = url.pathname;
    const method = req.method;
    console.log('Incoming request:', method, path);
    // ------------------- GET /stock-search 股票搜索 -------------------
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
    // ------------------- POST /auth/register 注册用户 -------------------
    if (path.startsWith('/auth/register') && method === 'POST') {
      return handleRegister(await req.json());
    }
    // ------------------- POST /auth/login 登录用户 -------------------
    if (path.startsWith('/auth/login') && method === 'POST') {
      return handleLogin(await req.json());
    }
    // ------------------- 订阅相关 -------------------
    if (path.startsWith('/subscriptions')) {
      // POST /subscriptions 购买/激活订阅
      if (method === 'POST') return handlePurchaseSubscription(await req.json());
      // GET /subscriptions 查询订阅状态
      if (method === 'GET') return handleCheckSubscription(await req.json());
      // DELETE /subscriptions 取消订阅
      if (method === 'DELETE') return handleCancelSubscription(await req.json());
    }
    // ------------------- GET /stock-prices 股票历史价格数据 -------------------
    if (path.endsWith('/stock-prices') && method === 'GET') {
      const stockIds = (url.searchParams.get('stock_ids') || '').trim().split(',');
      const startDate = url.searchParams.get('start_date') || null;
      const endDate = url.searchParams.get('end_date') || null;
      if (stockIds.length === 0 || startDate === null || endDate === null) {
        return new Response(JSON.stringify({
          error: 'Missing parameter: stock_ids or start_date or end_date'
        }), {
          status: 400
        });
      }
      return handleGetStockPrices(stockIds, startDate, endDate);
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
    // ------------------- 资产交易信息 -------------------
    if (subPath === 'assets') {
      const body = await req.json();
      // POST /users/:userId/assets 新增交易记录，卖出时记录 trade_sell_mappings
      if (method === 'POST') return handleCreateAsset(userId, body);
      // PUT /users/:userId/assets 更新交易记录，不允许修改 action、asset_id、account_id
      if (method === 'PUT') return handleUpdateAsset(userId, body);
      // DELETE /users/:userId/assets 删除交易记录，自动删除相关 trade_sell_mappings
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
    // ------------------- 用户摘要 -------------------
    if (subPath === 'summary' && method === 'GET') {
      return handleGetUserSummary(userId);
    }
    // ------------------- 用户历史记录 -------------------
    if (subPath === 'history' && method === 'GET') {
      const start = url.searchParams.get('start');
      const end = url.searchParams.get('end');
      if (!start || !end) {
        return new Response(JSON.stringify({
          error: 'Missing start or end param'
        }), {
          status: 400
        });
      }
      return handleGetUserHistory(userId, start, end);
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
// ------------------- GET /stock-prices 股票历史价格数据 -------------------
async function handleGetStockPrices(stockIds, startDate, endDate) {
  const { data: stockPrices, error } = await supabase.rpc('get_stock_prices', {
    p_stock_ids: stockIds,
    p_start_date: startDate,
    p_end_date: endDate
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  const { oldest_date, error: oldestDateErr } = await supabase.rpc('get_oldest_stock_price_date');
  if (oldestDateErr) {
    return new Response(JSON.stringify({
      error: oldestDateErr.message
    }), {
      status: 500
    });
  }
  if (!oldest_date || !stockPrices?.length) {
    return new Response(JSON.stringify({
      error: 'No stock price data found'
    }), {
      status: 404
    });
  }
  // 分配 stock_prices
  let stocks = {};
  stockPrices.forEach((sp)=>{
    if (!stocks[sp.stock_id]) {
      stocks[sp.stock_id] = {
        stock_id: sp.stock_id,
        exchange: sp.exchange,
        ticker: sp.ticker,
        stock_prices: [
          {
            price_at: sp.price_at,
            price: sp.price
          }
        ]
      };
    } else {
      stocks[sp.stock_id]['stock_prices'].push({
        price_at: sp.price_at,
        price: sp.price
      });
    }
  });
  if (new Date(oldest_date) > new Date(startDate)) {
    // 请求的 startDate 早于数据库中最早的价格日期，从外部数据源补齐
    const supplementTasks = [];
    const historyCache = new Map();
    const limit = pLimit(8); // 最多8个并发
    for (const stock of Object.values(stocks)){
      const priceList = stock.stock_prices || [];
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
              if (priceAt >= new Date(startDate)) {
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
          const key = `${r.price_at}`;
          if (!seen.has(key)) {
            seen.add(key);
            unique.push(r);
          }
        }
        stock.stock_prices = unique;
      }));
    }
    // 并发执行所有补历史价格任务
    await Promise.all(supplementTasks);
  }
  // 拉取 fx_rates
  const { data: fxRates, error: fxRatesErr } = await supabase.rpc('get_fx_rates', {
    p_start_date: startDate,
    p_end_date: endDate
  });
  if (fxRatesErr) {
    return new Response(JSON.stringify({
      error: fxRatesErr.message
    }), {
      status: 500
    });
  }
  // 转为数组
  const json = JSON.stringify({
    stocks: stocks || [],
    fx_rates: fxRates || []
  });
  // Gzip 压缩
  const gzipped = gzip(new TextEncoder().encode(json));
  return new Response(gzipped, {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Content-Encoding': 'gzip'
    }
  });
}
// ------------------- 股票交易处理 -------------------
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
    const { data, error } = await supabase.rpc('insert_asset_with_mappings', {
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
      p_remark: body.remark ?? null,
      p_sell_mappings: body.sell_mappings ?? []
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
    }
    // `data` format depends on supabase-js version and RPC. It may return the raw value or an array.
    // Return the raw data to the caller for convenience.
    return new Response(JSON.stringify({
      success: true,
      asset_id: data,
      sell_mappings: mappings
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
// 更新资产交易记录
async function handleUpdateAsset(userId, body) {
  const { data, error } = await supabase.rpc('update_asset_with_mappings', {
    p_user_id: userId,
    p_account_id: body.account_id ?? null,
    p_id: body.id,
    p_trade_date: body.trade_date,
    p_trade_type: body.trade_type ?? null,
    p_quantity: body.quantity,
    p_price: body.price,
    p_leverage: body.leverage ?? null,
    p_swap_amount: body.swap_amount ?? null,
    p_swap_currency: body.swap_currency ?? null,
    p_fee_amount: body.fee_amount ?? null,
    p_fee_currency: body.fee_currency ?? null,
    p_manual_rate_input: body.manual_rate_input ?? null,
    p_remark: body.remark ?? null,
    p_sell_mappings: body.sell_mappings ?? []
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  if (!data) return new Response(JSON.stringify({
    error: 'No data returned from update'
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true
  }), {
    status: 200
  });
}
// 删除资产交易记录
async function handleDeleteAsset(userId, body) {
  const { data, error } = await supabase.rpc('delete_asset_with_mappings', {
    p_user_id: userId,
    p_account_id: body.account_id ?? null,
    p_id: body.id
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  if (!data) return new Response(JSON.stringify({
    error: 'No data returned from delete'
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
// ------------------- 用户摘要 -------------------
// 返回账户、持仓
async function handleGetUserSummary(userId) {
  const t0 = Date.now();
  // 1. 查账户基本信息
  const { data: accountData } = await supabase.rpc('get_user_account_info', {
    p_user_id: userId
  });
  const t_db2 = Date.now();
  console.log(`[PERF] get_user_account_info: ${t_db2 - t0} ms`);
  // 4. 组装账户信息
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
        trade_sell_mapping: []
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
  // 去除临时Set字段
  const result = Object.values(accountsMap).map((acc)=>{
    const { trade_record_ids, trade_sell_mapping_ids, stock_ids, ...rest } = acc;
    return rest;
  });
  const t1 = Date.now();
  console.log(`[PERF] handleGetUserSummary: ${t1 - t0} ms`);
  const json = JSON.stringify({
    success: true,
    user_id: userId,
    account_info: result
  });
  const gzipped = gzip(new TextEncoder().encode(json));
  return new Response(gzipped, {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Content-Encoding": "gzip"
    }
  });
}
// ------------------- 用户历史记录 -------------------
async function handleGetUserHistory(userId, start, end) {
  const { data, error } = await supabase.rpc('get_user_history', {
    p_user_id: userId,
    p_start_date: start,
    p_end_date: end
  });
  if (error) return new Response(JSON.stringify({
    error: error.message
  }), {
    status: 500
  });
  return new Response(JSON.stringify({
    success: true,
    history: data
  }), {
    status: 200
  });
}
