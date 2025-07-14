##  Optimization Summary: `usp_analyzeMarginByVendor`

| Metric                         | Before Optimization            | After Optimization               |
|-----------------------------   |------------------------------  |-------------------------------   |
| Execution Time (Elapsed)       | 727 ms                         | 777 ms                           |
| CPU Time                       | 141 ms                         | 47 ms                            |
| Logical Reads (MarginAuditLog) | 124                            | 93                               |
| Plan Operators                 | MSTVF + Sequence + Scan        | ITVF + Index Seek + Scalar       |
| Index Used                     |  None                          |  IX_MarginAuditLog_MarginPercent |
| Wait Type                      | ASYNC_NETWORK_IO               | ASYNC_NETWORK_IO (normal)        |

###  Observations

- The original version used a **multi-statement TVF**, which materialized data and blocked optimization.
- After conversion to an **inline TVF**, SQL Server:
  - Removed the `Sequence` operator
  - Performed an **Index Seek** using the new index on `marginPercent`
  - Evaluated CASE logic via `Compute Scalar`
- CPU usage and logical reads dropped significantly.
- Elapsed time remains similar due to client/network fetch (`ASYNC_NETWORK_IO`) — expected for large result sets in SSMS.

###  Files

- [Before Execution Plan (.sqlplan)](../../OptimizationStats/pre optimization stats/usp_analyzeMarginByVendor/Execution plans/usp_analyzeMarginByVendor pre op plan.sqlplan)
- [After Execution Plan (.sqlplan)](../../OptimizationStats/post optimization stats/usp_analyzeMarginByVendor/Execution plans/usp_analyzeMarginByVendor post op plan.sqlplan)
- [Before Stats (.txt)](../../OptimizationStats/pre optimization stats/usp_analyzeMarginByVendor/Execution IO and TIME stats/usp_analyzeMarginByVendor pre op io and time stats.txt)
- [After Stats (.txt)](../../OptimizationStats/post optimization stats/usp_analyzeMarginByVendor/Execution IO and TIME stats/usp_analyzeMarginByVendor  post op io and time stats.txt)