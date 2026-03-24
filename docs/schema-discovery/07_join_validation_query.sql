-- ============================================================================
-- Script 07: Join Validation — Full Aggregation Query
-- Purpose : Validate the complete join path and confirm that the aggregated
--           Counted Amount is correct. This query mirrors what the X++ RDP
--           class will execute.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- ⚠️  INSTRUCTIONS:
-- This script CANNOT be run until Scripts 01-06 have been executed and
-- all placeholders below have been replaced with confirmed values.
-- DO NOT run this script with placeholder values.

-- ============================================================================
-- Replace ALL bracketed placeholders with confirmed column/table names:
-- ============================================================================
-- [HEADER_TABLE]       = RetailStatementJour (confirmed from Script 01)
-- [DETAIL_TABLE]       = _______________ (confirmed from Script 02/03)
-- [STORE_TABLE]        = _______________ (confirmed from Script 05)
-- [TENDER_TABLE]       = _______________ (confirmed from Script 06)
-- [STOREID_COL]        = _______________ (confirmed from Script 01)
-- [STATEMENTID_COL]    = _______________ (confirmed from Script 01)
-- [STATEMENTTYPE_COL]  = _______________ (confirmed from Script 01)
-- [STATEMENTDATE_COL]  = _______________ (confirmed from Script 01)
-- [FINANCIAL_VALUE]    = _______________ (confirmed from Script 04)
-- [TENDERTYPEID_COL]   = _______________ (confirmed from Script 03)
-- [CURRENCY_COL]       = _______________ (confirmed from Script 03)
-- [COUNTEDAMOUNT_COL]  = _______________ (confirmed from Script 03)
-- [STORENAME_COL]      = _______________ (confirmed from Script 05)
-- [TENDERNAME_COL]     = _______________ (confirmed from Script 06)
-- ============================================================================

/*
-- 7a. Full aggregation query (mirrors the RDP class logic)
SELECT
    H.[STOREID_COL]                         AS StoreId,
    S.[STORENAME_COL]                       AS StoreName,
    D.[TENDERTYPEID_COL]                    AS TenderTypeId,
    TT.[TENDERNAME_COL]                     AS TenderTypeName,
    D.[CURRENCY_COL]                        AS CurrencyCode,
    SUM(D.[COUNTEDAMOUNT_COL])              AS TotalCounted
FROM [HEADER_TABLE] H
INNER JOIN [DETAIL_TABLE] D
    ON H.[STATEMENTID_COL] = D.[STATEMENTID_COL]
   -- AND H.[STOREID_COL] = D.[STOREID_COL]  -- ← uncomment if composite key
LEFT JOIN [STORE_TABLE] S
    ON H.[STOREID_COL] = S.[STORENUMBER_COL]
LEFT JOIN [TENDER_TABLE] TT
    ON D.[TENDERTYPEID_COL] = TT.[TENDERTYPEID_COL]
   -- AND H.[STOREID_COL] = TT.[STORENUMBER_COL]  -- ← uncomment if per-store
WHERE H.[STATEMENTTYPE_COL] = [FINANCIAL_VALUE]
  AND H.[STATEMENTDATE_COL] >= '2025-01-01'    -- ← replace with test date range
  AND H.[STATEMENTDATE_COL] <= '2026-03-24'    -- ← replace with test date range
  AND H.[STOREID_COL] IN ('STORE1')             -- ← replace with test store(s)
GROUP BY
    H.[STOREID_COL],
    S.[STORENAME_COL],
    D.[TENDERTYPEID_COL],
    TT.[TENDERNAME_COL],
    D.[CURRENCY_COL]
ORDER BY
    H.[STOREID_COL],
    TT.[TENDERNAME_COL],
    D.[CURRENCY_COL];
*/

-- 7b. Row count check (sanity test)
/*
SELECT COUNT(*) AS TotalRows
FROM [HEADER_TABLE] H
INNER JOIN [DETAIL_TABLE] D
    ON H.[STATEMENTID_COL] = D.[STATEMENTID_COL]
WHERE H.[STATEMENTTYPE_COL] = [FINANCIAL_VALUE]
  AND H.[STATEMENTDATE_COL] >= '2025-01-01'
  AND H.[STATEMENTDATE_COL] <= '2026-03-24';
*/

-- ============================================================================
-- VALIDATION CHECKLIST:
-- ============================================================================
-- [ ] Query executes without error
-- [ ] Row count is plausible (not 0, not millions)
-- [ ] TotalCounted values are plausible (positive amounts, correct magnitude)
-- [ ] Store grouping is correct
-- [ ] Payment methods are correctly named (not NULL TenderTypeName)
-- [ ] Currency codes are standard (LBP, USD, EUR, etc.)
-- [ ] Cross-check 1-2 rows against Posted Statements UI for accuracy
--
-- If any check fails, flag the issue before proceeding to Phase 2.
-- ============================================================================
