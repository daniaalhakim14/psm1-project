# Report Feature Backend Implementation Guide

This document outlines the backend API endpoints required for the Report feature in the Smart Expense Organiser (MyManage) app.

## Overview

The Report feature provides two main functionalities:
1. **Spending Analysis** - Comprehensive expense analytics with charts and KPIs
2. **Tax Relief - Eligible Expenses** - Tax relief breakdown by category and items

## Required API Endpoints

### 1. GET `/api/reports/expenses/summary`

**Purpose:** Fetch expense summary for spending analysis

**Query Parameters:**
- `userId` (int, required) - User ID
- `period` (string, required) - "month" or "year"
- `year` (int, required) - Year (e.g., 2025)
- `month` (int, optional) - Month (1-12, required if period="month")
- `tz` (string, optional) - Timezone (default: "Asia/Kuala_Lumpur")

**Response Example:**
```json
{
  "range": {
    "start": "2025-09-01",
    "end": "2025-09-30"
  },
  "currency": "MYR",
  "totals": {
    "sum": 2450.75
  },
  "dailyAverageSpending": {
    "calendarDays": 81.69,
    "activeDays": 122.54
  },
  "monthlyAverageSpending": 2100.30,
  "biggestExpenseCategory": {
    "id": 3,
    "name": "Groceries",
    "sum": 820.40
  },
  "mostUsedFinancialPlatform": {
    "byCount": {
      "id": 2,
      "name": "Touch 'n Go",
      "count": 19
    },
    "byAmount": {
      "id": 5,
      "name": "Maybank Debit",
      "sum": 1400.10
    }
  },
  "timeSeriesDaily": [
    {"date": "2025-09-01", "sum": 120.50},
    {"date": "2025-09-02", "sum": 85.20}
  ],
  "breakdownByCategory": [
    {"categoryId": 3, "name": "Groceries", "sum": 820.40},
    {"categoryId": 1, "name": "Transport", "sum": 450.30}
  ],
  "breakdownByPlatform": [
    {"platformId": 5, "name": "Maybank Debit", "sum": 1400.10},
    {"platformId": 2, "name": "Touch 'n Go", "sum": 650.25}
  ],
  "top5Expenses": [
    {"expenseid": 101, "name": "Phone", "amount": 799.00, "date": "2025-09-05"},
    {"expenseid": 102, "name": "Groceries", "amount": 250.50, "date": "2025-09-03"}
  ]
}
```

### 2. GET `/api/reports/taxrelief/eligible`

**Purpose:** Fetch tax relief eligible expenses

**Query Parameters:**
- `userId` (int, required) - User ID
- `year` (int, required) - Year (e.g., 2025)
- `tz` (string, optional) - Timezone (default: "Asia/Kuala_Lumpur")

**Response Example:**
```json
{
  "year": 2025,
  "categories": [
    {
      "reliefcategory": "Education (Self)",
      "items": [
        {
          "reliefitemid": 12,
          "itemName": "Master's Degree Fees",
          "itemClaimLimit": 7000,
          "itemTotalEligible": 4200,
          "itemRemaining": 2800,
          "expenses": [
            {
              "expenseid": 345,
              "name": "UM Tuition",
              "amount": 3500,
              "eligibleamount": 3500,
              "date": "2025-03-20",
              "hasReceipt": true
            }
          ]
        }
      ]
    }
  ]
}
```

### 3. POST `/api/reports/pdf` (Optional - Server-side PDF generation)

**Purpose:** Generate PDF report (alternative to client-side generation)

**Request Body:**
```json
{
  "userId": 123,
  "period": "month",
  "year": 2025,
  "month": 9,
  "tz": "Asia/Kuala_Lumpur"
}
```

**Response:** PDF file as binary data with appropriate headers

## SQL Implementation Guide

### Database Schema Requirements

Ensure these tables exist with proper indexes:

```sql
-- Expenses table
CREATE INDEX idx_expense_userid_date ON expense(userid, date);
CREATE INDEX idx_expense_categoryid ON expense(categoryid);
CREATE INDEX idx_expense_platformid ON expense(platformid);

-- For better performance on date queries
CREATE INDEX idx_expense_userid_date_tz ON expense(userid, (date AT TIME ZONE 'Asia/Kuala_Lumpur'));
```

### Sample SQL Queries

#### 1. Total Spending and Daily Averages

```sql
WITH range AS (
  SELECT 
    date_trunc('month', $1::timestamptz AT TIME ZONE 'Asia/Kuala_Lumpur') AS start_dt,
    (date_trunc('month', $1::timestamptz AT TIME ZONE 'Asia/Kuala_Lumpur') + INTERVAL '1 month - 1 day')::date AS end_dt
),
filtered AS (
  SELECT e.*
  FROM expense e, range r
  WHERE e.userid = $2
    AND (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date BETWEEN r.start_dt::date AND r.end_dt
)
SELECT
  COALESCE(SUM(amount), 0) AS total_sum,
  COALESCE(SUM(amount), 0) / GREATEST(1, (SELECT (end_dt - start_dt + 1) FROM range)) AS daily_avg_calendar,
  COALESCE(SUM(amount), 0) / GREATEST(1, COUNT(DISTINCT (date AT TIME ZONE 'Asia/Kuala_Lumpur')::date)) AS daily_avg_active
FROM filtered;
```

#### 2. Biggest Category

```sql
SELECT c.categoryid, c.categoryname, SUM(e.amount) AS sum
FROM expense e
JOIN category c ON c.categoryid = e.categoryid
WHERE e.userid = $1 AND (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date BETWEEN $2 AND $3
GROUP BY c.categoryid, c.categoryname
ORDER BY sum DESC LIMIT 1;
```

#### 3. Most Used Platform (by count and amount)

```sql
-- By count
SELECT fp.platformid, fp.name, COUNT(*) AS cnt
FROM expense e 
JOIN financialplatform fp ON fp.platformid = e.platformid
WHERE e.userid = $1 AND (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date BETWEEN $2 AND $3
GROUP BY fp.platformid, fp.name 
ORDER BY cnt DESC LIMIT 1;

-- By amount
SELECT fp.platformid, fp.name, SUM(e.amount) AS sum
FROM expense e 
JOIN financialplatform fp ON fp.platformid = e.platformid
WHERE e.userid = $1 AND (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date BETWEEN $2 AND $3
GROUP BY fp.platformid, fp.name 
ORDER BY sum DESC LIMIT 1;
```

#### 4. Time Series Data (Daily)

```sql
SELECT 
  (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date AS date,
  SUM(e.amount) AS sum
FROM expense e
WHERE e.userid = $1 
  AND (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date BETWEEN $2 AND $3
GROUP BY (e.date AT TIME ZONE 'Asia/Kuala_Lumpur')::date
ORDER BY date;
```

#### 5. Tax Relief Eligible Summary

```sql
SELECT 
  tri.reliefcategory,
  tri.reliefitemid,
  tri.description AS itemName,
  tri.reliefamount AS itemClaimLimit,
  COALESCE(SUM(ee.eligibleamount), 0) AS itemTotalEligible,
  GREATEST(0, tri.reliefamount - COALESCE(SUM(ee.eligibleamount), 0)) AS itemRemaining
FROM taxreliefitem tri
LEFT JOIN eligibleexpenses ee ON ee.reliefitemid = tri.reliefitemid
LEFT JOIN expense e ON e.expenseid = ee.expenseid
WHERE (e.userid = $1 OR e.userid IS NULL)
  AND date_part('year', e.date AT TIME ZONE 'Asia/Kuala_Lumpur') = $2
  AND tri.status = 'Active'
GROUP BY tri.reliefcategory, tri.reliefitemid, tri.description, tri.reliefamount
ORDER BY tri.reliefcategory, tri.reliefitemid;
```

#### 6. Tax Relief Expenses Detail

```sql
SELECT 
  e.expenseid,
  e.expensename AS name,
  e.amount,
  ee.eligibleamount,
  to_char(e.date AT TIME ZONE 'Asia/Kuala_Lumpur', 'YYYY-MM-DD') AS date,
  (e.receipt IS NOT NULL) AS hasReceipt
FROM eligibleexpenses ee
JOIN expense e ON e.expenseid = ee.expenseid
JOIN taxreliefitem tri ON tri.reliefitemid = ee.reliefitemid
WHERE e.userid = $1
  AND tri.reliefitemid = $2
  AND date_part('year', e.date AT TIME ZONE 'Asia/Kuala_Lumpur') = $3
ORDER BY e.date DESC;
```

## Performance Optimizations

### 1. Database Indexes
```sql
-- Essential indexes for report queries
CREATE INDEX idx_expense_userid_date_amount ON expense(userid, date, amount);
CREATE INDEX idx_expense_categoryid_amount ON expense(categoryid, amount) WHERE categoryid IS NOT NULL;
CREATE INDEX idx_expense_platformid_amount ON expense(platformid, amount) WHERE platformid IS NOT NULL;
CREATE INDEX idx_eligible_expenses_reliefitemid ON eligibleexpenses(reliefitemid);
```

### 2. Materialized Views (Optional)
For heavy usage, consider creating materialized views for monthly aggregates:

```sql
CREATE MATERIALIZED VIEW monthly_expense_summary AS
SELECT 
  userid,
  date_trunc('month', date AT TIME ZONE 'Asia/Kuala_Lumpur') AS month,
  categoryid,
  platformid,
  SUM(amount) AS total_amount,
  COUNT(*) AS transaction_count
FROM expense
GROUP BY userid, date_trunc('month', date AT TIME ZONE 'Asia/Kuala_Lumpur'), categoryid, platformid;

-- Refresh monthly or use a scheduled job
REFRESH MATERIALIZED VIEW monthly_expense_summary;
```

### 3. Caching Strategy
- Cache report results for 5-10 minutes (already implemented in Flutter)
- Use Redis or similar for server-side caching of expensive queries
- Cache tax relief calculations as they change less frequently

## Security Considerations

1. **Authentication:** All endpoints require valid Bearer token
2. **Authorization:** Ensure `userId` in request matches authenticated user
3. **Input Validation:** Validate all query parameters
4. **Rate Limiting:** Implement rate limiting for PDF generation endpoint

## Error Handling

Return appropriate HTTP status codes:
- `200` - Success
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (invalid token)
- `403` - Forbidden (access denied)
- `404` - Not Found (user has no data)
- `500` - Internal Server Error

Example error response:
```json
{
  "error": "Invalid date range",
  "message": "Start date cannot be after end date",
  "code": "INVALID_DATE_RANGE"
}
```

## Testing

### Sample Test Data
Create test expenses with:
- Various categories (Groceries, Transport, Entertainment, etc.)
- Different financial platforms (Cash, TNG, Credit Card, etc.)
- Multiple dates across different months
- Some expenses with tax relief eligibility

### Test Cases
1. Test with empty data (new user)
2. Test with single month data
3. Test with year-long data
4. Test timezone handling
5. Test various date ranges
6. Test tax relief calculations
7. Test large datasets (performance)

## Frontend Integration Notes

The Flutter app expects:
1. All amounts as `double` or numeric strings
2. Dates in ISO 8601 format (`YYYY-MM-DD`)
3. Currency symbol to be `MYR` 
4. Timezone-aware date handling
5. Graceful handling of empty/null data

## Deployment Notes

1. Ensure PostgreSQL timezone is set correctly
2. Configure proper database connection pooling
3. Set up monitoring for query performance
4. Consider implementing database connection retries
5. Set up proper logging for debugging

This implementation will provide a comprehensive reporting system that allows users to analyze their spending patterns and track tax relief eligibility effectively.
