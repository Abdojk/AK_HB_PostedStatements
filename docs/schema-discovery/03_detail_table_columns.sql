-- ============================================================================
-- Script 03: Detail Table — Column Inventory
-- Purpose : List all columns on the confirmed detail table to identify:
--           CountedAmount, TenderTypeId, Currency, and join key to header.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- ⚠️  INSTRUCTIONS:
-- Replace [DETAIL_TABLE_NAME] below with the confirmed table name from
-- Script 02 results. Run EACH candidate table that might hold payment data.

-- 3a. Column listing for candidate: RETAILSTATEMENTLINE
SELECT
    'RETAILSTATEMENTLINE' AS TableName,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTATEMENTLINE'
ORDER BY ORDINAL_POSITION;

-- 3b. Column listing for candidate: RETAILSTATEMENTTRANS
SELECT
    'RETAILSTATEMENTTRANS' AS TableName,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTATEMENTTRANS'
ORDER BY ORDINAL_POSITION;

-- 3c. Column listing for candidate: RETAILTRANSACTIONPAYMENTTRANS
SELECT
    'RETAILTRANSACTIONPAYMENTTRANS' AS TableName,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILTRANSACTIONPAYMENTTRANS'
ORDER BY ORDINAL_POSITION;

-- 3d. Sample data from each candidate (top 10 rows)
-- Uncomment the relevant block after identifying the correct table

-- SELECT TOP 10 * FROM RETAILSTATEMENTLINE ORDER BY RECID DESC;
-- SELECT TOP 10 * FROM RETAILSTATEMENTTRANS ORDER BY RECID DESC;
-- SELECT TOP 10 * FROM RETAILTRANSACTIONPAYMENTTRANS ORDER BY RECID DESC;

-- ============================================================================
-- EXPECTED FINDINGS (to confirm or refute):
-- ============================================================================
-- Confirmed detail table: _______________
--
-- [ ] Counted Amount column     → Name: _______________
--     (candidates: COUNTEDAMOUNT, COUNTEDAMNT, COUNTED)
-- [ ] Tender/Payment Method ID  → Name: _______________
--     (candidates: TENDERTYPEID, TENDERTYPE, PAYMENTMETHOD)
-- [ ] Tender/Payment Name       → On this table? YES / NO
--     If NO → lookup table needed (see Script 06)
-- [ ] Currency column           → Name: _______________
--     (candidates: CURRENCY, CURRENCYCODE, TRANSACTIONCURRENCYCODE)
-- [ ] Join key to header        → Name: _______________
--     (candidates: STATEMENTID, STATEMENTNUM)
-- [ ] Additional join keys?     → Name: _______________
--     (e.g., STORERELATION, STOREID for composite key)
-- ============================================================================
