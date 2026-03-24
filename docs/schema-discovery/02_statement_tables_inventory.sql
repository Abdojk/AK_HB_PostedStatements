-- ============================================================================
-- Script 02: Retail Statement Tables — Full Inventory
-- Purpose : List all tables matching RETAILSTATEMENT% to identify the correct
--           detail/payment/tender line table.
-- Run In  : SSMS against UAT database
-- Reference: SOW-T2-001 Phase 1
-- ============================================================================

-- 2a. All tables with RETAILSTATEMENT in the name
SELECT
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME LIKE 'RETAILSTATEMENT%'
ORDER BY TABLE_NAME;

-- 2b. Also check for related payment/tender transaction tables
SELECT
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND (
       TABLE_NAME LIKE 'RETAILTRANSACTIONPAYMENT%'
    OR TABLE_NAME LIKE 'RETAILTENDERTRANS%'
    OR TABLE_NAME LIKE 'RETAILSTATEMENTLINE%'
  )
ORDER BY TABLE_NAME;

-- ============================================================================
-- EXPECTED FINDINGS:
-- ============================================================================
-- From results, identify the table that holds tender/payment-level data
-- per statement with Counted Amounts.
--
-- Candidates:
-- [ ] RETAILSTATEMENTLINE         → columns checked in Script 03
-- [ ] RETAILSTATEMENTTRANS        → columns checked in Script 03
-- [ ] RETAILTRANSACTIONPAYMENTTRANS → requires additional join via
--                                     RETAILTRANSACTIONTABLE
--
-- Confirmed detail table name: _______________
-- ============================================================================
