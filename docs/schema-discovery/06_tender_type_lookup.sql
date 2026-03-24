-- ============================================================================
-- Script 06: Tender Type Lookup — Confirm Payment Method Name Source
-- Purpose : Determine where the Payment Method Name (TenderTypeName) lives.
--           It may be on the detail table or require a join to a lookup table.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- 6a. RetailStoreTenderTypeTable — per-store tender type configuration
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTORETENDERTYPETABLE'
ORDER BY ORDINAL_POSITION;

-- 6b. Sample tender type data
SELECT TOP 20 *
FROM RETAILSTORETENDERTYPETABLE;
-- → Look for: TENDERTYPEID, NAME, STORENUMBER, CHANNELID

-- 6c. RetailTenderTypeTable — global tender type master (if exists)
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILTENDERTYPETABLE'
ORDER BY ORDINAL_POSITION;

-- 6d. RetailStoreTenderTypeCardTable — card-specific sub-types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTORETENDERTYPECARDTABLE'
ORDER BY ORDINAL_POSITION;

-- 6e. All tables with TENDERTYPE in the name
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME LIKE '%TENDERTYPE%'
ORDER BY TABLE_NAME;

-- 6f. Sample join: Detail table → TenderType lookup for name
-- ⚠️  Replace placeholders with confirmed values from Scripts 01-03
/*
SELECT TOP 20
    D.[TENDERTYPEID_COL],
    TT.NAME AS TenderTypeName,
    TT.*
FROM [DETAIL_TABLE_NAME] D
LEFT JOIN RETAILSTORETENDERTYPETABLE TT
    ON D.[TENDERTYPEID_COL] = TT.TENDERTYPEID
   AND D.[STOREID_COL] = TT.STORENUMBER  -- ← tender types may be per-store
ORDER BY D.RECID DESC;
*/

-- ============================================================================
-- EXPECTED FINDINGS:
-- ============================================================================
-- TenderTypeName source: _______________
--   Option A: Directly on detail table (column: _______________)
--   Option B: Join to RetailStoreTenderTypeTable
--             Join key(s): _______________
--   Option C: Join to another table: _______________
--
-- Tender type lookup table:     _______________
-- Name column on lookup:        _______________
-- Join key(s) from detail:      _______________
-- ============================================================================
