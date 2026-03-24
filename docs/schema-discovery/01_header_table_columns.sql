-- ============================================================================
-- Script 01: RetailStatementJour — Header Table Column Inventory
-- Purpose : Confirm table exists and identify exact column names for:
--           StatementId, StoreId/StoreRelation, StatementDate, StatementType,
--           Posted flag, and any StoreName field.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- 1a. Full column listing
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTATEMENTJOUR'
ORDER BY ORDINAL_POSITION;

-- 1b. Sample data (top 10 rows) to visually confirm column usage
SELECT TOP 10 *
FROM RETAILSTATEMENTJOUR
ORDER BY RECID DESC;

-- ============================================================================
-- EXPECTED FINDINGS (to confirm or refute):
-- ============================================================================
-- [ ] StatementId column exists           → Name: _______________
-- [ ] Store identifier column exists      → Name: _______________
--     (candidates: STOREID, STORERELATION, RETAILSTOREID)
-- [ ] Statement date column exists        → Name: _______________
--     (candidates: STATEMENTDATE, POSTEDDATE, POSTEDDATETIME)
-- [ ] Statement type column exists        → Name: _______________
--     (candidates: STATEMENTTYPE, TYPE)
-- [ ] Posted flag column exists           → Name: _______________
--     (candidates: POSTED, ISPOSTED)
-- [ ] StoreName column on this table?     → YES / NO
-- ============================================================================
