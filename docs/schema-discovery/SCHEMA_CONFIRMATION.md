# Schema Confirmation Table — SOW-T2-001

**Report**: Hugo Boss POS — Retail Statement Payment Summary
**Date**: 24 March 2026
**Environment**: UAT
**Confirmed by**: Schema discovery via SSMS (Scripts 01–06)

---

## Overall Status: APPROVED

All 12 schema items confirmed. Phase 2 implementation cleared.

---

## Confirmed Schema

| # | Assumed Name (SOW) | Confirmed Name (DB) | Source Script | Status | Notes |
|---|-------------------|---------------------|---------------|--------|-------|
| 1 | `RetailStatementJour` (header table) | `RETAILSTATEMENTJOUR` | Script 01 | CONFIRMED | 53 columns; includes DATAAREAID for multi-company |
| 2 | `RetailStatementTrans` (detail table) | `RETAILSTATEMENTLINE` | Script 02, 03 | CONFIRMED | SOW assumed RetailStatementTrans; actual table is RetailStatementLine (tender declaration lines). RetailStatementTrans also exists with identical key fields. |
| 3 | `StoreId` / `StoreNumber` (on header) | `STOREID` (nvarchar 10) | Script 01 | CONFIRMED | Values: 000041, 000042, 000044, 000045, 000062, 000073, 000116 |
| 4 | `StoreName` (source table + column) | `RETAILCHANNELVIEW.NAME` | Script 05 | CONFIRMED | NOT on header table. RETAILSTORETABLE and OMOPERATINGUNIT do not exist as base tables. Join: `RETAILCHANNELVIEW.RETAILCHANNELID = STOREID`. DIRPARTYTABLE direct join returns customer names (wrong). |
| 5 | `StatementDate` (filter date) | `STATEMENTDATE` (datetime) | Script 01 | CONFIRMED | Also available: `POSTEDDATE` (GL posting date). Using STATEMENTDATE (business date) per decision. |
| 6 | `StatementType` (column name) | `STATEMENTTYPE` (int) | Script 01 | CONFIRMED | Enum integer, not string |
| 7 | `StatementType` = "Financial" (value) | `1` | Script 04 | CONFIRMED | 62,409 rows with value 1 (Financial); 1,952 rows with value 2 (Operational) |
| 8 | `StatementId` (join key header-detail) | `STATEMENTID` (nvarchar 20) | Script 01, 03 | CONFIRMED | Same column name on both RETAILSTATEMENTJOUR and RETAILSTATEMENTLINE |
| 9 | `TenderTypeId` (on detail table) | `TENDERTYPEID` (nvarchar 10) | Script 03 | CONFIRMED | On both RETAILSTATEMENTLINE and RETAILSTATEMENTTRANS |
| 10 | `TenderTypeName` (source table + column) | `RETAILSTORETENDERTYPETABLE.NAME` (nvarchar 60) | Script 06 | CONFIRMED | NOT on detail table. Join: detail.STOREID -> RETAILCHANNELTABLE.RETAILCHANNELID -> .RECID = RETAILSTORETENDERTYPETABLE.CHANNEL + TENDERTYPEID match. Sample: Cash POS LBP, CC Card USD, Credit Card EUR, ABC Cash, Gift Card Redeem, Coupon, Loyalty, on Account |
| 11 | `Currency` (on detail table) | `CURRENCY` (nvarchar 3) | Script 03 | CONFIRMED | ISO currency codes (LBP, USD, EUR) |
| 12 | `CountedAmount` (on detail table) | `COUNTEDAMOUNT` (numeric 32,6) | Script 03 | CONFIRMED | Transaction currency amount. Also: COUNTEDAMOUNTMST (company currency), COUNTEDAMOUNTSTORE (store currency) |

---

## Confirmed Join Path

```
RETAILSTATEMENTJOUR (H)
  |  Key fields: STATEMENTID, STOREID, STATEMENTDATE, STATEMENTTYPE, DATAAREAID
  |
  |-- INNER JOIN RETAILSTATEMENTLINE (L)
  |     ON H.STATEMENTID = L.STATEMENTID
  |     AND H.DATAAREAID = L.DATAAREAID
  |     Key fields: TENDERTYPEID, CURRENCY, COUNTEDAMOUNT, STOREID
  |
  |-- LEFT JOIN RETAILCHANNELVIEW (CV)
  |     ON H.STOREID = CV.RETAILCHANNELID
  |     Key fields: NAME (store name), RECID
  |
  |-- LEFT JOIN RETAILSTORETENDERTYPETABLE (TT)
        ON L.TENDERTYPEID = TT.TENDERTYPEID
        AND CV.RECID = TT.CHANNEL
        AND L.DATAAREAID = TT.DATAAREAID
        Key fields: NAME (tender type name)
```

---

## Issues / Deviations from SOW Assumptions

1. **Detail table name**: SOW assumed `RetailStatementTrans`; actual table for tender declaration lines is `RetailStatementLine`. RetailStatementTrans also exists with similar structure but RetailStatementLine is the correct table for financial statement tender counting.

2. **Store name source**: SOW assumed StoreName might be on RetailStatementJour or RetailStoreTable. Neither is the case. `RETAILSTORETABLE` does not exist. `OMOPERATINGUNIT` does not exist as a base table. Store name is resolved via `RETAILCHANNELVIEW` (a D365 system view).

3. **Tender type name join**: More complex than assumed. Requires traversal through `RETAILCHANNELVIEW.RECID` to match `RETAILSTORETENDERTYPETABLE.CHANNEL` (bigint RECID), not a simple string join on store number.

4. **Multi-company data**: `DATAAREAID` column present with values `hb`, `stch`, `t2`. D365 company context handles filtering automatically in X++, but SQL validation queries must include `DATAAREAID = 'hb'` filter.

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| Developer | Abdo J. Khoury | 24 March 2026 | APPROVED |
| Reviewer | | | PENDING |

---

Phase 1 gate PASSED. Proceeding to Phase 2 implementation.
