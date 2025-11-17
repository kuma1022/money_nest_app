import { createClient } from 'npm:@supabase/supabase-js@2.31.0';
import pLimit from "npm:p-limit";
const supabase = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", {
  auth: {
    persistSession: false
  }
});
import { gzip } from "https://deno.land/x/compress@v0.4.5/mod.ts";
console.info('Edge Function initialized');
Deno.serve(async (req: { url: string | URL; method: any; headers: { get: (arg0: string) => string; }; json: () => any; })=>{
  try {
    const url = new URL(req.url);
    const path = url.pathname;
    const method = req.method;

    // 只在非 GET 请求时读取 body
    let body: any = {};
    if (method !== 'GET') {
      try {
        const contentType = req.headers.get('content-type') || '';
        if (contentType.includes('application/json')) {
          body = await req.json();
        }
      } catch (e) {
        console.warn('Failed to parse JSON body:', e);
      }
    }
    console.log('Incoming request:', method, path, body);
    
    // POST actions
    if (method === 'POST') {
      const action = url.searchParams.get('action');

      // login 登录用户
      if (action === 'login') return handleLogin(body);
      // register 注册用户
      if (action === 'register') return handleRegister(body);
      // 购买/激活订阅
      if (action === 'subscriptions') return handlePurchaseSubscription(body);
      // 新增股票交易记录
      if (action === 'user-assets') {
        const userId = url.searchParams.get('user_id');
        return handleCreateAsset(userId, body);
      }
      // 暗号资产key值
      if (action === 'user-cryptoInfo') {
        const userId = url.searchParams.get('user_id');
        return handleCreateOrUpdateCryptoInfo(userId, body);
      }
      // 新增基金交易记录
      if (action === 'user-fund') {
        const userId = url.searchParams.get('user_id');
        return handleCreateFund(userId, body);
      }
    }

    // GET actions
    if (method === 'GET') {
      const action = url.searchParams.get('action');

      // 股票搜索
      if (action === 'stock-search') {
        const q = (url.searchParams.get('q') || '').trim();
        const exchange = (url.searchParams.get('exchange') || '').trim() || null;
        const limit = Math.min(Math.max(parseInt(url.searchParams.get('limit') || '20', 10), 1), 200);
        return handleStockSearch(q, exchange, limit);
      }
      // 股票历史价格数据
      if (action === 'stock-prices') {
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
      // 查询订阅状态
      if (action === 'subscriptions') {
        //return handleCheckSubscription(await req.json());
      }
      // 用户摘要
      if (action === 'user-summary') {
        const userId = url.searchParams.get('user_id');
        return handleGetUserSummary(userId);
      }
      // 获取最后一次同步时间
      if (action === 'get-last-sync-time') {
        const userId = url.searchParams.get('user_id');
        const accountId = url.searchParams.get('account_id');
        return handleGetLastSyncTime(userId, accountId);
      }
      // Fund搜索
      if (action === 'fund-search') {
        const q = (url.searchParams.get('q') || '').trim();
        const limit = Math.min(Math.max(parseInt(url.searchParams.get('limit') || '20', 10), 1), 200);
        return handleFundSearch(q, limit);
      }
    }

    // PUT actions
    if (method === 'PUT') {
      const action = url.searchParams.get('action');

      // 更新交易记录，不允许修改 action、asset_id、account_id
      if (action === 'user-assets') {
        const userId = url.searchParams.get('user_id');
        return handleUpdateAsset(userId, body);
      }
    }

    // DELETE actions
    if (method === 'DELETE') {
      const action = url.searchParams.get('action');
      // 取消订阅
      if (action === 'subscriptions') return handleCancelSubscription(body);
      // 删除交易记录，自动删除相关 trade_sell_mappings
      if (action === 'user-assets') {
        const userId = url.searchParams.get('user_id');
        return handleDeleteAsset(userId, body);
      }
      // 删除暗号资产key值
      if (action === 'user-cryptoInfo') {
        const userId = url.searchParams.get('user_id');
        return handleDeleteCryptoInfo(userId, body);
      }
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

// ------------------- 股票搜索 -------------------
async function handleStockSearch(q: string, exchange: string | null, limit: number) {
  if (!q) {
    return new Response(JSON.stringify({
      error: 'Missing parameter: q'
    }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
       
  const { data, error } = await supabase.rpc('search_stocks', {
    search_query: q,
    row_limit: limit,
    exchange_filter: exchange
  });
  
  if (error) {
    return new Response(JSON.stringify({
      error: 'Database error'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
  
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

// ------------------- 股票搜索 -------------------
async function handleFundSearch(q: string, limit: number) {
  if (!q) {
    return new Response(JSON.stringify({
      error: 'Missing parameter: q'
    }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
       
  const { data, error } = await supabase.rpc('search_funds', {
    search_query: q,
    row_limit: limit
  });
  
  if (error) {
    return new Response(JSON.stringify({
      error: 'Database error'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
  
  return new Response(JSON.stringify({
    query: q,
    count: data?.length || 0,
    results: data || []
  }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
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
    // Call the new RPC which returns TABLE(trade_id, account_updated_at)
    const { data, error } = await supabase.rpc('insert_trade_and_update_account', {
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

    // Normalize RPC response shapes (array / single object)
    let tradeId = null;
    let accountUpdatedAt = null;
    if (Array.isArray(data) && data.length > 0) {
      tradeId = data[0]?.trade_id ?? null;
      accountUpdatedAt = data[0]?.account_updated_at ?? data[0]?.updated_at ?? null;
    } else if (data && typeof data === 'object') {
      tradeId = data.trade_id ?? null;
      accountUpdatedAt = data.account_updated_at ?? data.updated_at ?? null;
    } else {
      // fallback: sometimes supabase RPC returns scalar
      tradeId = data ?? null;
    }

    if (!tradeId) {
      return new Response(JSON.stringify({
        error: 'Failed to create trade record'
      }), {
        status: 500
      });
    }

    // Return created trade id and updated account timestamp
    return new Response(JSON.stringify({
      success: true,
      trade_id: tradeId,
      account_updated_at: accountUpdatedAt
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('handleCreateAsset error:', err);
    return new Response(JSON.stringify({
        error: 'Failed to create trade record'
      }), {
        status: 500
      });
  }
}

// 更新资产交易记录
async function handleUpdateAsset(userId, body) {
  try {
    const { data, error } = await supabase.rpc('update_trade_and_update_account', {
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

    // Normalize RPC response shapes (array / single object)
    let accountUpdatedAt = null;
    if (Array.isArray(data) && data.length > 0) {
      accountUpdatedAt = data[0]?.account_updated_at ?? data[0]?.updated_at ?? null;
    } else if (data && typeof data === 'object') {
      accountUpdatedAt = data.account_updated_at ?? data.updated_at ?? null;
    } else {
      // fallback: sometimes supabase RPC returns scalar
      accountUpdatedAt = data ?? null;
    }

    if (!accountUpdatedAt) {
      return new Response(JSON.stringify({
        error: 'Failed to update trade record'
      }), {
        status: 500
      });
    }

    return new Response(JSON.stringify({
      success: true,
      account_updated_at: accountUpdatedAt
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('handleUpdateAsset error:', err);
    return new Response(JSON.stringify({
        error: 'Failed to update trade record'
      }), {
        status: 500
      });
  }
}

// 删除资产交易记录
async function handleDeleteAsset(userId, body) {
  try {
    const { data, error } = await supabase.rpc('delete_trade_and_update_account', {
      p_user_id: userId,
      p_account_id: body.account_id ?? null,
      p_trade_id: body.id
    });
    if (error) return new Response(JSON.stringify({
      error: error.message
    }), {
      status: 500
    });

    // Normalize RPC response shapes (array / single object)
    let accountUpdatedAt = null;
    if (Array.isArray(data) && data.length > 0) {
      accountUpdatedAt = data[0]?.account_updated_at ?? data[0]?.updated_at ?? null;
    } else if (data && typeof data === 'object') {
      accountUpdatedAt = data.account_updated_at ?? data.updated_at ?? null;
    } else {
      // fallback: sometimes supabase RPC returns scalar
      accountUpdatedAt = data ?? null;
    }

    if (!accountUpdatedAt) {
      return new Response(JSON.stringify({
        error: 'Failed to delete trade record'
      }), {
        status: 500
      });
    }
    
    return new Response(JSON.stringify({
      success: true,
      account_updated_at: accountUpdatedAt
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('handleDeleteAsset error:', err);
    return new Response(JSON.stringify({
        error: 'Failed to delete trade record'
      }), {
        status: 500
      });
  }
}

// ------------------- 基金交易处理 -------------------
async function handleCreateFund(userId, body) {
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
    'account_id',
    'fund_id',
    'trade_date',
    'action',
    'trade_type',
    'account_type'
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
  //if (String(body.action).toLowerCase() === 'sell') {
  //  if (!Array.isArray(body.sell_mappings) || body.sell_mappings.length === 0) {
  //    return new Response(JSON.stringify({
  //      error: 'sell_mappings is required for sell action'
  //    }), {
  //      status: 400
  //    });
  //  }
  //}
  try {
    // Call the new RPC which returns TABLE(trade_id, account_updated_at)
    const { data, error } = await supabase.rpc('add_fund_transaction', {
      p_user_id: userId,
      p_account_id: body.account_id,
      p_fund_id: body.fund_id,
      p_trade_date: body.trade_date,
      p_action: body.action,
      p_trade_type: body.trade_type,
      p_account_type: body.account_type,
      p_amount: body.amount ?? null,
      p_quantity: body.quantity ?? null,
      p_price: body.price ?? null,
      p_fee_amount: body.fee_amount ?? null,
      p_fee_currency: body.fee_currency ?? null,
      p_recurring_frequency_type: body.recurring_frequency_type ?? null,
      p_recurring_frequency_config: body.recurring_frequency_config ?? null,
      p_recurring_start_date: body.recurring_start_date ?? null,
      p_recurring_end_date: body.recurring_end_date ?? null,
      p_recurring_status: body.recurring_status ?? null,
      p_remark: body.remark ?? null,
    });
    if (error) {
      // RPC error
      return new Response(JSON.stringify({
        error: error.message
      }), {
        status: 500
      });
    }

    // Normalize RPC response shapes (array / single object)
    let transactionId = null;
    let accountUpdatedAt = null;
    if (Array.isArray(data) && data.length > 0) {
      transactionId = data[0]?.transaction_id ?? null;
      accountUpdatedAt = data[0]?.account_updated_at ?? data[0]?.updated_at ?? null;
    } else if (data && typeof data === 'object') {
      transactionId = data.trade_id ?? null;
      accountUpdatedAt = data.account_updated_at ?? data.updated_at ?? null;
    } else {
      // fallback: sometimes supabase RPC returns scalar
      transactionId = data ?? null;
    }

    if (!transactionId) {
      return new Response(JSON.stringify({
        error: 'Failed to create trade record'
      }), {
        status: 500
      });
    }

    // Return created trade id and updated account timestamp
    return new Response(JSON.stringify({
      success: true,
      transaction_id: transactionId,
      account_updated_at: accountUpdatedAt
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('handleCreateFund error:', err);
    return new Response(JSON.stringify({
        error: 'Failed to create fund trade record'
      }), {
        status: 500
      });
  }
}

// ------------------- 用户摘要 -------------------
// 返回账户、持仓
async function handleGetUserSummary(userId) {
  const t0 = Date.now();
  // 1. 查账户基本信息
  const { data: accountData, error: accountError } = await supabase.rpc('get_user_account_info', {
    p_user_id: userId
  });
  if (accountError) return new Response(JSON.stringify({
    error: accountError.message
  }), {
    status: 500
  });
  const t_db2 = Date.now();
  console.log(`[PERF] get_user_account_info: ${t_db2 - t0} ms`);
  // 3. 查询crypto_info
  const accIds = Array.from(new Set(accountData.map((row)=>row.account_id)));
  const { data: cryptoData, error: cryptoError } = await supabase.from('crypto_info').select('*').in('account_id', accIds);
  if (cryptoError) return new Response(JSON.stringify({
    error: cryptoError.message
  }), {
    status: 500
  });
  const cryptoMap = {};
  if (cryptoData) {
    cryptoData.forEach((ci)=>{
      if (!cryptoMap[ci.account_id]) {
        cryptoMap[ci.account_id] = [];
      }
      cryptoMap[ci.account_id].push(ci);
    });
  }
  const t_db3 = Date.now();
  console.log(`[PERF] get_crypto_info: ${t_db3 - t_db2} ms`);
  // 2. 组装账户信息
  const accountsMap = {};
  accountData.forEach((row)=> {
    const accId = row.account_id;
    const accountUpdatedAt = row.account_updated_at;
    if (!accountsMap[accId]) {
      accountsMap[accId] = {
        account_id: accId,
        account_name: row.account_name,
        account_updated_at: accountUpdatedAt,
        type: row.type || '',
        trade_records: [],
        stocks: [],
        trade_sell_mapping: [],
        crypto_info: cryptoMap[accId] || [],
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

// ------------------- 暗号资产key值处理 -------------------
async function handleCreateOrUpdateCryptoInfo(userId, body) {
  if (!userId || !body || !body.account_id || !body.crypto_exchange || !body.api_key || !body.api_secret) {
    return new Response(JSON.stringify({
      error: 'Missing body'
    }), {
      status: 400
    });
  }
  console.log("Upserting crypto info for user:", userId);
  console.log("Crypto info:", body);
  const { data, error } = await supabase.rpc("upsert_crypto_info", {
    p_user_id: userId,
    p_account_id: body.account_id,
    p_crypto_exchange: body.crypto_exchange,
    p_api_key: body.api_key,
    p_api_secret: body.api_secret,
    p_status: body.status ?? 'active',
  });
  console.log("Upsert result:", data, error);
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

// 删除暗号资产key值
async function handleDeleteCryptoInfo(userId, body) {
  // 支持单个或多个 crypto_exchange 删除
  const exchanges = Array.isArray(body.crypto_exchange) 
    ? body.crypto_exchange 
    : [body.crypto_exchange];
  
  const { error } = await supabase.rpc("delete_crypto_info_batch", {
    p_user_id: userId,
    p_account_id: body.account_id,
    p_crypto_exchanges: exchanges
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

// ------------------- POST /auth/register 注册用户 -------------------
async function handleRegister(body) {
  const { email, password, name, account_type, code } = body;

  if (!code) {
    try {
      //const verificationCode = generateCode();
      //await saveVerificationCode(email, verificationCode);

      // 创建未确认的用户，这会触发 Confirm signup 邮件模板
      const { data: userData, error: userError } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: false,
      });

      if (userError) {
        return new Response(JSON.stringify({
          error: 'ユーザー作成に失敗しました: ' + userError.message
        }), { status: 400 });
      }

      const { data: otpData, error: otpError } = await supabase.auth.signInWithOtp({
        email: email
      });

      if (otpError) {
        return new Response(JSON.stringify({ 
          error: 'メール送信に失敗しました: ' + otpError
        }), { status: 400 });
      }

      console.log(`Verification code sent to ${email}`);
      
      return new Response(JSON.stringify({
        success: true,
        message: '認証コードをメールに送信しました',
      }), { status: 200 });
      
    } catch (error) {
      console.error('Error in registration step 1:', error);
      return new Response(JSON.stringify({ 
        error: 'サーバーエラーが発生しました: ' + error
      }), { status: 500 });
    }
  }

  // 第二步：验证验证码并确认用户
  try {
    /*const { data: verifData, error: verifErr } = await supabase.from('auth_verification')
      .select('*')
      .eq('email', email)
      .eq('code', code)
      .gt('expire_at', new Date().toISOString())
      .single();*/
    const { data: verifData, error: verifErr } = await supabase.auth.verifyOtp({
      email,
      token: code,
      type: 'email'
    });
    console.log('Verifying code for email:', email, 'code:', code);
    console.log('Verification data:', verifData);
    console.log('Verification error:', verifErr);
    if (verifErr) {
      return new Response(JSON.stringify({
        error: '認証コードが無効または期限切れです'
      }), { status: 400 });
    }

    // 在 accounts 表创建记录
    const { data: accountData, error: accError } = await supabase.from('accounts').insert({
      user_id: verifData.user.id,
      name: name || '未設定',
      type: account_type || 'personal'
    }).select();
    
    if (accError) {
      console.error('Account creation error:', accError);
      return new Response(JSON.stringify({ 
        error: 'アカウント作成に失敗しました: ' + accError.message 
      }), { status: 500 });
    }

    // 检查是否成功插入
    if (!accountData || accountData.length === 0) {
      return new Response(JSON.stringify({
        error: 'アカウントの作成に失敗しました'
      }), { status: 500 });
    }
    
    const accountId = accountData[0].id; // 获取插入记录的 ID
    return new Response(JSON.stringify({ 
      user_id: verifData.user.id,
      account_id: accountId,
      success: true,
      message: 'アカウント作成が完了しました'
    }), { status: 200 });
    
  } catch (error) {
    console.error('Error in registration step 2:', error);
    return new Response(JSON.stringify({ 
      error: 'アカウント作成中にエラーが発生しました: ' + error 
    }), { status: 500 });
  }
}

// ------------------- POST /auth/login 登录用户 -------------------
async function handleLogin(body) {
  const { email, password, apple_user_id } = body;
  let user;
  if (apple_user_id) {
    const { data, error } = await supabase.from('accounts').select('user_id').eq('user_id', apple_user_id).single();
    if (error) return new Response(JSON.stringify({ error: 'User not found' }), { status: 404 });
    user = data;
  } else {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error || !data.user) {
      console.error('Login error:', error);
      return new Response(JSON.stringify({ error: error?.message || 'Login failed' }), { status: 400 });
    }
    user = data.user;
  }

  // 查询订阅状态
  const { data: subs, error: subsError } = await supabase.rpc('get_user_subscription', { p_user_id: user.id });
  if (subsError) {
    return new Response(JSON.stringify({ error: subsError.message }), { status: 500 });
  }

  return new Response(JSON.stringify({ user_id: user.id, subscriptions: subs || [], success: true, message: 'Login success' }), { status: 200 });
}

// ------------------- 获取最后一次同步时间 -------------------
async function handleGetLastSyncTime(userId, accountId) {
  const { data, error } = await supabase.from('accounts').select('updated_at').eq('id', accountId).eq('user_id', userId).limit(1).single();
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
  if (!data || !data.updated_at) {
    return new Response(JSON.stringify({ error: 'Account not found' }), { status: 404 });
  }
  return new Response(JSON.stringify({ last_sync_time: data.updated_at }), { status: 200 });
}