-- ============================================================================
-- Script 04: StatementType Enum — Confirm Filter Value
-- Purpose : Determine the exact stored value for "Financial" statement type.
--           This is likely an integer enum, NOT the string "Financial".
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- ⚠️  INSTRUCTIONS:
-- Replace [STATEMENTTYPE_COL] with the confirmed column name from Script 01.
-- If the column name is exactly STATEMENTTYPE, no change needed.

-- 4a. Distinct values in the StatementType column
SELECT
    STATEMENTTYPE,
    COUNT(*) AS RecordCount
FROM RETAILSTATEMENTJOUR
GROUP BY STATEMENTTYPE
ORDER BY STATEMENTTYPE;

-- 4b. Cross-reference with D365 enum metadata (if SQLDICTIONARY is available)
-- This query retrieves enum label-to-integer mappings
SELECT
    FIELDNAME,
    ENUMID,
    ENUMVALUE,
    NAME
FROM SQLDICTIONARY
WHERE TABLEID = 0
  AND NAME LIKE '%StatementType%'
ORDER BY ENUMID, ENUMVALUE;

-- 4c. Alternative: check the ENUMVALUES view if available
-- SELECT * FROM ENUMVALUES WHERE ENUMNAME LIKE '%StatementType%';

-- ============================================================================
-- EXPECTED FINDINGS:
-- ============================================================================
-- StatementType column name: _______________
-- Distinct values found:     _______________
-- Value for "Financial":     _______________
--   (e.g., 0 = Financial, 1 = Operational, or similar)
--
-- ⚠️  If the column stores a string instead of an integer, note it here:
--     String value for Financial: _______________
-- ============================================================================
