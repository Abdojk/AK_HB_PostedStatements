-- ============================================================================
-- Script 07: Join Validation — Full Aggregation Query (CORRECTED SCHEMA)
-- Purpose : Validate the complete join path and confirm that the aggregated
--           Amount Tendered is correct. This query mirrors what the X++ RDP
--           class will execute.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- Updated : 24 March 2026 — CORRECTED detail table from RETAILSTATEMENTLINE
--           to RETAILTRANSACTIONPAYMENTTRANS. Column mappings:
--           TENDERTYPE (not TENDERTYPEID), AMOUNTTENDERED (not COUNTEDAMOUNT),
--           STORE (not STOREID on detail table).
--           Validated against UAT: returns 8 rows for March 2026 data.
-- ============================================================================

-- 7a. Full aggregation query (mirrors the RDP class logic)
SELECT
    H.STOREID                               AS StoreId,
    CV.NAME                                 AS StoreName,
    P.TENDERTYPE                            AS TenderTypeId,
    TT.NAME                                 AS TenderTypeName,
    P.CURRENCY                              AS CurrencyCode,
    SUM(P.AMOUNTTENDERED)                   AS TotalAmount,
    COUNT(*)                                AS TxCount
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILTRANSACTIONPAYMENTTRANS P
    ON H.STATEMENTID = P.STATEMENTID
    AND H.DATAAREAID = P.DATAAREAID
LEFT JOIN RETAILCHANNELVIEW CV
    ON H.STOREID = CV.RETAILCHANNELID
LEFT JOIN RETAILSTORETENDERTYPETABLE TT
    ON P.TENDERTYPE = TT.TENDERTYPEID
    AND CV.RECID = TT.CHANNEL
    AND P.DATAAREAID = TT.DATAAREAID
WHERE H.STATEMENTTYPE = 1                  -- Financial statements only
  AND H.STATEMENTDATE >= '2026-03-01'      -- Replace with test date range
  AND H.STATEMENTDATE <= '2026-03-23'      -- Replace with test date range
  AND H.STOREID IN ('000041')              -- Replace with test store(s)
  AND H.DATAAREAID = 'hb'                  -- Hugo Boss legal entity
GROUP BY
    H.STOREID,
    CV.NAME,
    P.TENDERTYPE,
    TT.NAME,
    P.CURRENCY
ORDER BY
    H.STOREID,
    TT.NAME,
    P.CURRENCY;

-- 7b. Row count check (sanity test)
SELECT COUNT(*) AS TotalDetailRows
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILTRANSACTIONPAYMENTTRANS P
    ON H.STATEMENTID = P.STATEMENTID
    AND H.DATAAREAID = P.DATAAREAID
WHERE H.STATEMENTTYPE = 1
  AND H.STATEMENTDATE >= '2026-03-01'
  AND H.STATEMENTDATE <= '2026-03-23'
  AND H.DATAAREAID = 'hb';

-- 7c. Multi-store test
SELECT
    H.STOREID                               AS StoreId,
    CV.NAME                                 AS StoreName,
    P.TENDERTYPE                            AS TenderTypeId,
    TT.NAME                                 AS TenderTypeName,
    P.CURRENCY                              AS CurrencyCode,
    SUM(P.AMOUNTTENDERED)                   AS TotalAmount,
    COUNT(*)                                AS TxCount
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILTRANSACTIONPAYMENTTRANS P
    ON H.STATEMENTID = P.STATEMENTID
    AND H.DATAAREAID = P.DATAAREAID
LEFT JOIN RETAILCHANNELVIEW CV
    ON H.STOREID = CV.RETAILCHANNELID
LEFT JOIN RETAILSTORETENDERTYPETABLE TT
    ON P.TENDERTYPE = TT.TENDERTYPEID
    AND CV.RECID = TT.CHANNEL
    AND P.DATAAREAID = TT.DATAAREAID
WHERE H.STATEMENTTYPE = 1
  AND H.STATEMENTDATE >= '2026-03-01'
  AND H.STATEMENTDATE <= '2026-03-23'
  AND H.STOREID IN ('000041', '000042', '000044', '000045')
  AND H.DATAAREAID = 'hb'
GROUP BY
    H.STOREID,
    CV.NAME,
    P.TENDERTYPE,
    TT.NAME,
    P.CURRENCY
ORDER BY
    H.STOREID,
    TT.NAME,
    P.CURRENCY;

-- ============================================================================
-- VALIDATION CHECKLIST:
-- ============================================================================
-- [x] Query 7a executes without error — VALIDATED 24 March 2026
-- [x] Row count (7b) is plausible (not 0, not millions)
-- [x] TotalAmount values are plausible (positive amounts, correct magnitude)
-- [x] Store grouping is correct (7c shows multiple stores)
-- [x] TenderTypeName values are not NULL
-- [x] Currency codes are standard (USD confirmed)
-- [ ] Cross-check 1-2 rows against Posted Statements UI for accuracy
-- ============================================================================
