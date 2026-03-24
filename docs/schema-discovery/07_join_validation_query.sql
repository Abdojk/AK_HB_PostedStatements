-- ============================================================================
-- Script 07: Join Validation — Full Aggregation Query (CONFIRMED SCHEMA)
-- Purpose : Validate the complete join path and confirm that the aggregated
--           Counted Amount is correct. This query mirrors what the X++ RDP
--           class will execute.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- Updated : 24 March 2026 — all placeholders replaced with confirmed values
-- ============================================================================

-- 7a. Full aggregation query (mirrors the RDP class logic)
SELECT
    H.STOREID                               AS StoreId,
    CV.NAME                                 AS StoreName,
    L.TENDERTYPEID                          AS TenderTypeId,
    TT.NAME                                 AS TenderTypeName,
    L.CURRENCY                              AS CurrencyCode,
    SUM(L.COUNTEDAMOUNT)                    AS TotalCounted
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILSTATEMENTLINE L
    ON H.STATEMENTID = L.STATEMENTID
    AND H.DATAAREAID = L.DATAAREAID
LEFT JOIN RETAILCHANNELVIEW CV
    ON H.STOREID = CV.RETAILCHANNELID
LEFT JOIN RETAILSTORETENDERTYPETABLE TT
    ON L.TENDERTYPEID = TT.TENDERTYPEID
    AND CV.RECID = TT.CHANNEL
    AND L.DATAAREAID = TT.DATAAREAID
WHERE H.STATEMENTTYPE = 1                  -- Financial statements only
  AND H.STATEMENTDATE >= '2026-03-01'      -- Replace with test date range
  AND H.STATEMENTDATE <= '2026-03-24'      -- Replace with test date range
  AND H.STOREID IN ('000041')              -- Replace with test store(s)
  AND H.DATAAREAID = 'hb'                  -- Hugo Boss legal entity
GROUP BY
    H.STOREID,
    CV.NAME,
    L.TENDERTYPEID,
    TT.NAME,
    L.CURRENCY
ORDER BY
    H.STOREID,
    TT.NAME,
    L.CURRENCY;

-- 7b. Row count check (sanity test)
SELECT COUNT(*) AS TotalDetailRows
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILSTATEMENTLINE L
    ON H.STATEMENTID = L.STATEMENTID
    AND H.DATAAREAID = L.DATAAREAID
WHERE H.STATEMENTTYPE = 1
  AND H.STATEMENTDATE >= '2026-03-01'
  AND H.STATEMENTDATE <= '2026-03-24'
  AND H.DATAAREAID = 'hb';

-- 7c. Multi-store test
SELECT
    H.STOREID                               AS StoreId,
    CV.NAME                                 AS StoreName,
    L.TENDERTYPEID                          AS TenderTypeId,
    TT.NAME                                 AS TenderTypeName,
    L.CURRENCY                              AS CurrencyCode,
    SUM(L.COUNTEDAMOUNT)                    AS TotalCounted
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILSTATEMENTLINE L
    ON H.STATEMENTID = L.STATEMENTID
    AND H.DATAAREAID = L.DATAAREAID
LEFT JOIN RETAILCHANNELVIEW CV
    ON H.STOREID = CV.RETAILCHANNELID
LEFT JOIN RETAILSTORETENDERTYPETABLE TT
    ON L.TENDERTYPEID = TT.TENDERTYPEID
    AND CV.RECID = TT.CHANNEL
    AND L.DATAAREAID = TT.DATAAREAID
WHERE H.STATEMENTTYPE = 1
  AND H.STATEMENTDATE >= '2026-03-01'
  AND H.STATEMENTDATE <= '2026-03-24'
  AND H.STOREID IN ('000041', '000042', '000044', '000045')
  AND H.DATAAREAID = 'hb'
GROUP BY
    H.STOREID,
    CV.NAME,
    L.TENDERTYPEID,
    TT.NAME,
    L.CURRENCY
ORDER BY
    H.STOREID,
    TT.NAME,
    L.CURRENCY;

-- ============================================================================
-- VALIDATION CHECKLIST:
-- ============================================================================
-- [ ] Query 7a executes without error
-- [ ] Row count (7b) is plausible (not 0, not millions)
-- [ ] TotalCounted values are plausible (positive amounts, correct magnitude)
-- [ ] Store grouping is correct (7c shows multiple stores)
-- [ ] TenderTypeName values are not NULL
-- [ ] Currency codes are standard (LBP, USD, EUR)
-- [ ] Cross-check 1-2 rows against Posted Statements UI for accuracy
-- ============================================================================
