# Schema Confirmation Table — SOW-T2-001

**Report**: Hugo Boss POS — Retail Statement Payment Summary
**Date**: 24 March 2026
**Environment**: UAT
**Status**: PENDING — awaiting query results from SSMS

---

## Instructions

1. Run Scripts 01–06 in SSMS against the UAT database
2. Record confirmed names in the table below
3. Replace all `PENDING` statuses with `CONFIRMED` or `NOT FOUND`
4. If `NOT FOUND`, document the alternative/resolution in Notes
5. Once all items are CONFIRMED, update Overall Status to **APPROVED**
6. Run Script 07 with all confirmed values to validate the full join

---

## Overall Status: ⏳ PENDING

---

## Confirmed Schema

| # | Assumed Name (SOW) | Confirmed Name (DB) | Source Script | Status | Notes |
|---|-------------------|---------------------|---------------|--------|-------|
| 1 | `RetailStatementJour` (header table) | | Script 01 | PENDING | |
| 2 | `RetailStatementTrans` (detail table) | | Script 02, 03 | PENDING | Candidates: RetailStatementLine, RetailStatementTrans, RetailTransactionPaymentTrans |
| 3 | `StoreId` / `StoreNumber` (on header) | | Script 01 | PENDING | Candidates: STOREID, STORERELATION, RETAILSTOREID |
| 4 | `StoreName` (source table + column) | | Script 05 | PENDING | May be on header or require join to RetailStoreTable/OMOperatingUnit |
| 5 | `StatementDate` (posted date) | | Script 01 | PENDING | Candidates: STATEMENTDATE, POSTEDDATE |
| 6 | `StatementType` (column name) | | Script 01 | PENDING | |
| 7 | `StatementType` = "Financial" (value) | | Script 04 | PENDING | Likely enum integer, not string |
| 8 | `StatementId` (join key header→detail) | | Script 01, 03 | PENDING | Confirm same column name on both tables |
| 9 | `TenderTypeId` (on detail table) | | Script 03 | PENDING | |
| 10 | `TenderTypeName` (source table + column) | | Script 06 | PENDING | May be on detail table or require join to RetailStoreTenderTypeTable |
| 11 | `Currency` (on detail table) | | Script 03 | PENDING | Candidates: CURRENCY, CURRENCYCODE |
| 12 | `CountedAmount` (on detail table) | | Script 03 | PENDING | Candidates: COUNTEDAMOUNT, COUNTEDAMNT |

---

## Join Path (to be confirmed)

```
RetailStatementJour (H)
  │
  ├── JOIN [detail_table] (D) ON H.[statementId] = D.[statementId]
  │
  ├── LEFT JOIN [store_table] (S) ON H.[storeId] = S.[storeNumber]
  │     └── For: StoreName
  │
  └── LEFT JOIN [tender_table] (TT) ON D.[tenderTypeId] = TT.[tenderTypeId]
        └── For: TenderTypeName
```

**Confirmed join path**: _(fill in after running Script 07)_

---

## Script 07 Validation Results

- [ ] Query executes without error
- [ ] Row count is plausible: _____ rows
- [ ] TotalCounted values are plausible
- [ ] Store grouping is correct
- [ ] TenderTypeName values are not NULL
- [ ] Currency codes are standard (LBP, USD, EUR)
- [ ] Cross-checked against Posted Statements UI: MATCH / MISMATCH

---

## Issues / Deviations from SOW Assumptions

_(Document any findings that contradict the SOW assumptions here)_

1.
2.
3.

---

## Sign-off

| Role | Name | Date | Status |
|------|------|------|--------|
| Developer | | | PENDING |
| Reviewer | | | PENDING |

---

**⛔ GATE**: Do NOT proceed to Phase 2 until Overall Status = APPROVED and all 12 items are CONFIRMED.
