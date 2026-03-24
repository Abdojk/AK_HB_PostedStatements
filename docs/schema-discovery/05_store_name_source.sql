-- ============================================================================
-- Script 05: Store Name Source — Confirm Where StoreName Lives
-- Purpose : Determine if StoreName is on RetailStatementJour or requires
--           a join to a store reference table.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- 5a. Check if RetailStatementJour has a StoreName-like column
-- (Already partly covered by Script 01, but this focuses on the store join)
SELECT TOP 5
    *
FROM RETAILSTATEMENTJOUR
WHERE 1=1
ORDER BY RECID DESC;
-- → Visually inspect: is there a column with store names?

-- 5b. RetailStoreTable — primary store master
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILSTORETABLE'
ORDER BY ORDINAL_POSITION;

-- 5c. Sample store data
SELECT TOP 10 *
FROM RETAILSTORETABLE;
-- → Look for: STORENUMBER, NAME, RETAILCHANNELID, OMOPERATINGUNITID

-- 5d. RetailChannelTable — alternative store reference
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'RETAILCHANNELTABLE'
ORDER BY ORDINAL_POSITION;

-- 5e. OMOperatingUnit — may hold the store name via DirPartyTable
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OMOPERATINGUNIT'
ORDER BY ORDINAL_POSITION;

-- 5f. DirPartyTable — ultimate name source if store name goes through party
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DIRPARTYTABLE'
ORDER BY ORDINAL_POSITION;

-- 5g. Sample join: Statement → RetailStoreTable for store name
-- ⚠️  Replace [STOREID_COL] with confirmed column from Script 01
SELECT TOP 10
    sj.RECID,
    sj.STATEMENTID,
    -- sj.[STOREID_COL],
    rst.*
FROM RETAILSTATEMENTJOUR sj
LEFT JOIN RETAILSTORETABLE rst
    ON sj.STORERELATION = rst.STORENUMBER  -- ← adjust join columns as needed
ORDER BY sj.RECID DESC;

-- ============================================================================
-- EXPECTED FINDINGS:
-- ============================================================================
-- StoreName source: _______________
--   Option A: Directly on RetailStatementJour (column: _______________)
--   Option B: Join to RetailStoreTable (join key: _______________)
--   Option C: Join chain: RetailStoreTable → OMOperatingUnit → DirPartyTable
--
-- Store ID column on header:    _______________
-- Store Name column / join path: _______________
-- ============================================================================
