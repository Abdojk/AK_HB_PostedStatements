# Schema Confirmation Table — SOW-T2-001

**Report**: Hugo Boss POS — Retail Statement Payment Summary
**Date**: 24 March 2026
**Environment**: UAT
**Confirmed by**: Schema discovery via SSMS (Scripts 01–06) + Corrected via Steps 16–17

---

## Overall Status: APPROVED (CORRECTED)

All schema items confirmed. **Critical correction applied**: detail table changed from `RETAILSTATEMENTLINE` to `RETAILTRANSACTIONPAYMENTTRANS`. Full query validated against UAT — returns 8 rows of real production data.

---

## Confirmed Schema

| # | Assumed Name (SOW) | Confirmed Name (DB) | Source Script | Status | Notes |
|---|-------------------|---------------------|---------------|--------|-------|
| 1 | `RetailStatementJour` (header table) | `RETAILSTATEMENTJOUR` | Script 01 | CONFIRMED | 53 columns; includes DATAAREAID for multi-company |
| 2 | `RetailStatementTrans` (detail table) | **`RETAILTRANSACTIONPAYMENTTRANS`** | Steps 16–17 | **CORRECTED** | Originally assumed RetailStatementLine — that table belongs to RETAILSTATEMENTTABLE (calculated/unposted statements). The correct table for posted statement payment data is RETAILTRANSACTIONPAYMENTTRANS. |
| 3 | `StoreId` / `StoreNumber` (on header) | `STOREID` (nvarchar 10) | Script 01 | CONFIRMED | Values: 000041, 000042, 000044, 000045, 000062, 000073, 000116 |
| 4 | `StoreId` (on detail) | **`STORE`** (nvarchar 10) | Step 16 | **CORRECTED** | Column on RETAILTRANSACTIONPAYMENTTRANS is `STORE`, not `STOREID` |
| 5 | `StoreName` (source table + column) | `RETAILCHANNELVIEW.NAME` | Script 05 | CONFIRMED | NOT on header table. Join: `RETAILCHANNELVIEW.RETAILCHANNELID = STOREID`. |
| 6 | `StatementDate` (filter date) | `STATEMENTDATE` (datetime) | Script 01 | CONFIRMED | Also available: `POSTEDDATE` (GL posting date). Using STATEMENTDATE (business date) per decision. |
| 7 | `StatementType` (column name) | `STATEMENTTYPE` (int) | Script 01 | CONFIRMED | Enum integer, not string |
| 8 | `StatementType` = "Financial" (value) | `1` | Script 04 | CONFIRMED | 62,409 rows with value 1 (Financial); 1,952 rows with value 2 (Operational) |
| 9 | `StatementId` (join key header-detail) | `STATEMENTID` (nvarchar 20) | Scripts 01, Step 16 | CONFIRMED | Same column name on both RETAILSTATEMENTJOUR and RETAILTRANSACTIONPAYMENTTRANS |
| 10 | `TenderTypeId` (on detail table) | **`TENDERTYPE`** (nvarchar 10) | Step 16–17 | **CORRECTED** | Column on RETAILTRANSACTIONPAYMENTTRANS is `TENDERTYPE`, NOT `TENDERTYPEID`. Maps to `RETAILSTORETENDERTYPETABLE.TENDERTYPEID` for name lookup. |
| 11 | `TenderTypeName` (source table + column) | `RETAILSTORETENDERTYPETABLE.NAME` (nvarchar 60) | Script 06 | CONFIRMED | Join: P.TENDERTYPE = TT.TENDERTYPEID AND CV.RECID = TT.CHANNEL. Sample: ABC Cash (110), Cash POS USD (33), CC Card USD (21), Coupon (71), Gift Card Redeem (7), on Account (8), Tender RF (4) |
| 12 | `Currency` (on detail table) | `CURRENCY` (nvarchar 3) | Step 16 | CONFIRMED | ISO currency codes (USD confirmed in production data) |
| 13 | `CountedAmount` (on detail table) | **`AMOUNTTENDERED`** (numeric) | Step 16 | **CORRECTED** | Column on RETAILTRANSACTIONPAYMENTTRANS is `AMOUNTTENDERED`, NOT `COUNTEDAMOUNT`. |

---

## Confirmed Join Path (CORRECTED)

```
RETAILSTATEMENTJOUR (H)
  |  Key fields: STATEMENTID, STOREID, STATEMENTDATE, STATEMENTTYPE, DATAAREAID
  |
  |-- INNER JOIN RETAILTRANSACTIONPAYMENTTRANS (P)
  |     ON H.STATEMENTID = P.STATEMENTID
  |     AND H.DATAAREAID = P.DATAAREAID
  |     Key fields: TENDERTYPE, CURRENCY, AMOUNTTENDERED, STORE
  |
  |-- LEFT JOIN RETAILCHANNELVIEW (CV)
  |     ON H.STOREID = CV.RETAILCHANNELID
  |     Key fields: NAME (store name), RECID
  |
  |-- LEFT JOIN RETAILSTORETENDERTYPETABLE (TT)
        ON P.TENDERTYPE = TT.TENDERTYPEID
        AND CV.RECID = TT.CHANNEL
        AND P.DATAAREAID = TT.DATAAREAID
        Key fields: NAME (tender type name)
```

---

## Validated Output (UAT, 24 March 2026)

Query parameters: StatementDate 2026-03-01 to 2026-03-23, Stores 000041/000042/000044, DataAreaId = 'hb'

| StoreId | StoreName | TenderType | TenderTypeName | Currency | TotalAmount | TxCount |
|---------|-----------|------------|----------------|----------|-------------|---------|
| 000041 | Hugo Boss ABC Dbayeh | 110 | ABC Cash | USD | 115,658.40 | 518 |
| 000042 | Hugo Boss Downtown | 33 | Cash POS USD | USD | 12,778.10 | 54 |
| 000042 | Hugo Boss Downtown | 21 | CC Card USD | USD | 6,304.15 | 31 |
| 000042 | Hugo Boss Downtown | 71 | Coupon | USD | -251.00 | 1 |
| 000042 | Hugo Boss Downtown | 7 | Gift Card Redeem | USD | 300.00 | 1 |
| 000042 | Hugo Boss Downtown | 8 | on Account | USD | 300.00 | 1 |
| 000042 | Hugo Boss Downtown | 4 | Tender RF | USD | 0.00 | 2 |
| 000044 | Hugo Boss ABC Achrafieh | 110 | ABC Cash | USD | 68,666.00 | 360 |

---

## Issues / Deviations from SOW Assumptions

1. **Detail table name**: SOW assumed `RetailStatementTrans`; originally mapped to `RetailStatementLine` which is WRONG — it belongs to `RETAILSTATEMENTTABLE` (calculated/unposted). **Correct table: `RETAILTRANSACTIONPAYMENTTRANS`** (payment transactions linked to posted statements via STATEMENTID).

2. **Column name differences on detail table**: `TENDERTYPE` (not `TENDERTYPEID`), `AMOUNTTENDERED` (not `COUNTEDAMOUNT`), `STORE` (not `STOREID`).

3. **Store name source**: `RETAILSTORETABLE` does not exist. `OMOPERATINGUNIT` does not exist as a base table. Store name is resolved via `RETAILCHANNELVIEW` (a D365 system view).

4. **Tender type name join**: Requires traversal through `RETAILCHANNELVIEW.RECID` to match `RETAILSTORETENDERTYPETABLE.CHANNEL` (bigint RECID), not a simple string join on store number. Detail column `TENDERTYPE` maps to lookup column `TENDERTYPEID`.

5. **Multi-company data**: `DATAAREAID` column present with values `hb`, `stch`, `t2`. D365 company context handles filtering automatically in X++, but SQL validation queries must include `DATAAREAID = 'hb'` filter.

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| Developer | Abdo J. Khoury | 24 March 2026 | APPROVED (CORRECTED) |
| Reviewer | | | PENDING |

---

Phase 1 gate PASSED (with corrections). Phase 2 artifacts updated accordingly.
