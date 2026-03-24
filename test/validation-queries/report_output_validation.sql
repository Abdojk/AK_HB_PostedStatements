-- ============================================================================
-- Report Output Validation Query (CORRECTED)
-- Purpose : Cross-check SSRS report output against raw database.
--           This query mirrors exactly what the HBRetailStatementPaymentDP
--           data provider class produces.
-- Reference: SOW-T2-001 | T2 Trading — Hugo Boss
-- Date     : 24 March 2026
-- Updated  : 24 March 2026 — Corrected detail table from RETAILSTATEMENTLINE
--            to RETAILTRANSACTIONPAYMENTTRANS. Validated against UAT (8 rows).
-- ============================================================================
-- USAGE:
--   1. Run the SSRS report with specific Store IDs and Date Range
--   2. Run this query with the SAME parameters (replace values below)
--   3. Compare row-by-row: StoreId, TenderTypeName, Currency, TotalAmount
--   4. All values must match exactly
-- ============================================================================

-- Replace these parameter values to match your SSRS report run:
DECLARE @FromDate DATE = '2026-03-01';
DECLARE @ToDate   DATE = '2026-03-23';
DECLARE @DataArea NVARCHAR(4) = 'hb';
-- Store IDs: add/remove as needed in the WHERE clause below

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
  AND H.STATEMENTDATE >= @FromDate
  AND H.STATEMENTDATE <= @ToDate
  AND H.STOREID IN ('000041', '000042', '000044', '000045')  -- Match report params
  AND H.DATAAREAID = @DataArea
GROUP BY
    H.STOREID,
    CV.NAME,
    P.TENDERTYPE,
    TT.NAME,
    P.CURRENCY
ORDER BY
    H.STOREID,
    TT.NAME ASC,
    P.CURRENCY;

-- ============================================================================
-- SUMMARY: Grand Total per Currency (should match report footer)
-- ============================================================================
SELECT
    P.CURRENCY                              AS CurrencyCode,
    SUM(P.AMOUNTTENDERED)                   AS GrandTotal
FROM RETAILSTATEMENTJOUR H
INNER JOIN RETAILTRANSACTIONPAYMENTTRANS P
    ON H.STATEMENTID = P.STATEMENTID
    AND H.DATAAREAID = P.DATAAREAID
WHERE H.STATEMENTTYPE = 1
  AND H.STATEMENTDATE >= @FromDate
  AND H.STATEMENTDATE <= @ToDate
  AND H.STOREID IN ('000041', '000042', '000044', '000045')
  AND H.DATAAREAID = @DataArea
GROUP BY P.CURRENCY
ORDER BY P.CURRENCY;
