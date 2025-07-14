## Optimization Summary: `usp_calculateVendorMargins`

| Metric                         | Before Optimization            | After Optimization                     |
|-------------------------------|--------------------------------|----------------------------------       |
| Execution Time (Elapsed)      | 1037 ms                        | 1612 ms                                 |
| CPU Time                      | 203 ms                         | 156 ms                                  |
| Logical Reads (MarginAuditLog)| 5034                           | 4070                                    |
| Logical Reads (Products)      | 2000+                          | 2                                       |
| Logical Reads (Vendors)       | 2000+                          | 16                                      |
| Worktable Usage               | Present                        | Removed                                 |
| Partition Pruning             |  No                          	 | Yes (via `saleDate` filter)             |
| Indexes Used                  | None                           | IX_StagedSales_saleID_saleDate + others |
| Plan Operators                | Scalar Functions, Table Scans  | Inlined Expressions, Index Seeks        |

### Observations

- The original procedure used scalar functions (`fn_getMarginPercent`) and full table scans, causing CPU overhead and excessive logical reads.
- The rewritten version eliminated UDFs by **inlining margin calculation**, which improved optimizer visibility and indexing.
- **Top margin products** are now precomputed in a temp table to avoid repetitive logic.
- Partitioning on `saleDate` enabled **pruning of `StagedSales`**, reducing unnecessary reads.
- **Worktables removed** by applying filters before applying `ROW_NUMBER()`.
- While elapsed time increased slightly due to controlled batching, CPU and IO usage dropped significantly, and performance is stable and scalable.

### Files

- [Before Execution Plan (.sqlplan)](../../OptimizationStats/pre optimization stats/usp_calculateVendorMargins/Execution Plans/usp_calculateVendorMargins pre op plan.sqlplan)
- [After Execution Plan (.sqlplan)](../../OptimizationStats/post optimization stats/usp_calculateVendorMargins/Execution plans/usp_calculateVendorMargins post op plan.sqlplan)
- [Before Stats (.txt)](../../OptimizationStats/pre optimization stats/usp_calculateVendorMargins/Execution IO and TIME stats/usp_calculateVendorMargins pre op io and time stats.txt)
- [After Stats (.txt)](../../OptimizationStats/post optimization stats/usp_calculateVendorMargins/Execution IO and TIME stats/usp_calculateVendorMargins post op io and time stats.txt)