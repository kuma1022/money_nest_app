
# 🏦 资产管理 API 文档（完整）

> 所有 POST/PUT/DELETE 请求均需带  
> `Authorization: Bearer <SERVICE_ROLE_KEY>`  
> `Content-Type: application/json`  
> 日期统一使用 `YYYY-MM-DD`。

---

## 📌 API 快速参考表

| 路径 | 方法 | RPC 名称 | 功能说明 |
|------|------|----------|---------|
| `/stock-search` | POST | `search_stocks` | 股票搜索，支持模糊查询 ticker，按交易所过滤 |
| `/users/:userId/latest` | GET | `get_user_info_latest` | 获取指定用户的最新信息（如资产总额、最新持仓、最近交易等） |
| `/users/:userId/stocks/trades` | POST | `insert_trade_with_mappings` | 新增股票交易，卖出时记录 `trade_sell_mappings` |
| `/users/:userId/stocks/trades` | PUT | `update_trade_with_mappings` | 更新交易记录，不允许修改 `action`、`stock_id`、`account_id` |
| `/users/:userId/stocks/trades` | DELETE | `delete_trade_with_mappings` | 删除交易记录，自动删除相关 `trade_sell_mappings` |
| `/users/:userId/assets` | POST | `insert_asset` | 新增资产信息 |
| `/users/:userId/assets` | PUT | `update_asset` | 更新资产信息 |
| `/users/:userId/assets` | DELETE | `delete_asset` | 删除资产信息 |
| `/users/:userId/assets/values` | POST | `insert_asset_value` | 添加资产每日金额记录 |
| `/users/:userId/assets/values` | DELETE | `delete_asset_value` | 删除资产每日金额记录 |
| `/users/:userId/dividends` | POST | `insert_dividend` | 新增分红记录 |
| `/users/:userId/dividends` | PUT | `update_dividend` | 更新分红记录 |
| `/users/:userId/dividends` | DELETE | `delete_dividend` | 删除分红记录 |
| `/users/:userId/assets/chart` | GET | `get_asset_chart` | 获取资产走势，按日期返回资产金额列表 |

---

## 共用key值

| key      | 值   |
|-----------|--------|
| YOUR_EDGE_DOMAIN         | yeciaqfdlznrstjhqfxu.supabase.co/functions/v1/money_grow_api |
| SERVICE_ROLE_KEY  | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc |

---

## 1️⃣ 股票搜索 `/stock-search` (POST)

```bash
curl -L -X GET 'https://<YOUR_EDGE_DOMAIN>/stock-search?q={q}&exchange={exchange}&limit={limit}' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>'
```

**请求参数**

| 参数      | 类型   | 必填 | 描述                 |
|-----------|--------|------|--------------------|
| q         | string | 是   | 股票 ticker 模糊查询 |
| exchange  | string | 否   | 交易所筛选，例: US |
| limit     | int    | 否   | 返回数量上限，默认 20 |

**返回示例**

```json
{
  "query": "ACN",
  "exchange": "US",
  "count": 1,
  "results": [
    {
      "id": 123,
      "ticker": "ACN",
      "name": "Accenture PLC",
      "exchange": "US",
      "similarity": 1.0
    }
  ]
}
```

---

## 2️⃣ 股票交易 `/users/:userId/stocks/trades`

### 新增交易 (POST)

```bash
curl -L -X POST 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/stocks/trades' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{
  "trade_date": "2025-09-10",
  "action": "buy",
  "stock_id": 123,
  "trade_type": "normal",
  "quantity": 10,
  "price": 150.5,
  "fee": 1.5,
  "fee_currency": "USD",
  "remark": "首次买入",
  "account_id": 1,
  "sell_mappings": []
}'
```

### 更新交易 (PUT)

```bash
curl -L -X PUT 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/stocks/trades' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{
  "trade_id": 456,
  "trade_date": "2025-09-10",
  "trade_type": "normal",
  "quantity": 20,
  "price": 155.0,
  "fee": 2.0,
  "fee_currency": "USD",
  "remark": "修改数量",
  "sell_mappings": []
}'
```

### 删除交易 (DELETE)

```bash
curl -L -X DELETE 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/stocks/trades' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"trade_id": 456}'
```

---

## 3️⃣ 资产信息 `/users/:userId/assets`

### 新增资产 (POST)

```bash
curl -L -X POST 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"name": "美股账户", "type": "stock"}'
```

### 更新资产 (PUT)

```bash
curl -L -X PUT 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"asset_id": 1, "name": "美股账户更新", "type": "stock"}'
```

### 删除资产 (DELETE)

```bash
curl -L -X DELETE 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"asset_id": 1}'
```

---

## 4️⃣ 资产金额记录 `/users/:userId/assets/values`

### 添加资产金额 (POST)

```bash
curl -L -X POST 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets/values' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"asset_id": 1, "value_date": "2025-09-10", "amount": 10000.5}'
```

### 删除资产金额 (DELETE)

```bash
curl -L -X DELETE 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets/values' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"asset_id": 1, "value_date": "2025-09-10"}'
```

---

## 5️⃣ 分红记录 `/users/:userId/dividends`

### 新增分红 (POST)

```bash
curl -L -X POST 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/dividends' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"asset_id": 1, "dividend_date": "2025-09-10", "amount": 50.5}'
```

### 更新分红 (PUT)

```bash
curl -L -X PUT 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/dividends' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"dividend_id": 10, "asset_id": 1, "dividend_date": "2025-09-10", "amount": 60.0}'
```

### 删除分红 (DELETE)

```bash
curl -L -X DELETE 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/dividends' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
-H 'Content-Type: application/json' \
--data '{"dividend_id": 10}'
```

---

## 6️⃣ 资产走势 `/users/:userId/assets/chart` (GET)

```bash
curl -L -X GET 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/assets/chart?start_date=2025-01-01&end_date=2025-09-10' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>'
```

**返回示例**

```json
{
  "success": true,
  "chart": [
    {"asset_id":1,"value_date":"2025-01-01","amount":9500},
    {"asset_id":1,"value_date":"2025-02-01","amount":9800},
    {"asset_id":1,"value_date":"2025-09-10","amount":10000.5}
  ]
}
```

---

## 7️⃣ 用户最新信息 `/users/:userId/latest` (GET)

```bash
curl -L -X GET 'https://<YOUR_EDGE_DOMAIN>/users/<USER_ID>/latest' \
-H 'Authorization: Bearer <SERVICE_ROLE_KEY>'
```

**返回示例**

```json
{
  "success": true,
  "user_id": "85963d3d-9b09-4a15-840c-05d1ded31c18",
  "account_info": [
    {
      "account_id": 1,
      "account_name": "test",
      "type": "",
      "trade_records": [
        {
          "id": 456,
          "asset_type": "stock",
          "asset_id": 123,
          "trade_date": "2025-09-10",
          "action": "buy",
          "trade_type": "normal",
          "quantity": 10,
          "price": 150.5,
          "fee_amount": 0,
          "fee_currency": "JPY",
          "position_type": null,
          "leverage": null,
          "swap_amount": null,
          "swap_currency": null,
          "manual_rate_input": false,
          "remark": "",
        }
      ],
      "stocks": [
        {
          "id": 123,
          "ticker": "ACN",
          "exchange": "US",
          "name": "Accenture",
          "name_us": "Accenture",
          "currency": "USD",
          "country": "US",
          "sector_industry_id": 2,
          "logo": "",
          "status": "active",
          "stock_prices": [
            {
              "price": 230.09,
              "price_at": "2025-09-10",
            }
          ],
        }
      ],
      "trade_sell_mapping": [
        {
          "id": 123,
          "buy_id": 12,
          "sell_id": 15,
          "quantity": 10,
        }
      ],
      "fx_rates": [
        {
          "fx_pair_id": 123,
          "rate_date": "2025-09-10",
          "rate": 140.23,
        }
      ]
    }
  ]
}
```

---

📌 **说明**

1. 替换 `<YOUR_EDGE_DOMAIN>` 为 Edge Function 域名  
2. 替换 `<USER_ID>` 为目标用户 UUID  
3. POST/PUT/DELETE 请求需带 `Authorization` 头  
4. 日期字段统一 `YYYY-MM-DD`  
5. 股票交易卖出时，`sell_mappings` 填对应买入记录及数量
