# sqle2e

End-to-end SQL Server development portfolio simulating real-world enterprise development, CI/CD readiness, performance tuning, and advanced T-SQL practices.

This repository includes complete SQL Server object definitions, partitioning examples, unit testing, deployment artifacts, and proven optimization plans — structured for GitHub-based source control and Redgate SQL Change Automation compatibility.

---

##  Object Types Included

- **Tables** (with constraints and keys)
- **Views** (analytics-friendly, pre-joined)
- **Functions**
  - Scalar
  - Inline Table-Valued (ITVF)
  - Multi-statement Table-Valued (MSTVF)
- **Stored Procedures**
  - Batching logic with `ROW_NUMBER()`
  - Margin calculation pipeline
- **Triggers**
  - `AFTER INSERT` (e.g., audit logging)
  - `INSTEAD OF UPDATE` with `OUTPUT` clause
- **Partitioned Tables**
  - Example: `StagedSales` partitioned by `saleDate`
- **Indexes**
  - Clustered and Non-Clustered Indexes (NCIs)
- **Temp Tables**
  - Batch processing, staging, margin filtering
- **tSQLt Unit Tests**
  - Procedure/function-level test cases
- **Execution Plans**
  - Before vs After optimization comparison
- **Deployment Artifacts**
  - SQL Compare-compatible deploy + post-deploy scripts
  - Manual partitioning scripts
- **Optimization Techniques**
  - Indexing, batch pruning, function inlining
  - Partition pruning demonstration

---

##  Project Goals

- Clean, idiomatic T-SQL development
- Demonstrate performance tuning with metrics
- Build for Git-based versioning
- Mimic enterprise CI/CD via Redgate Toolbelt
- End-to-end unit testing with `tSQLt`
- Deployment-safe releases (Release 1.0, 2.0)

---

##  Releases

| Release | Highlights                                                                 |
|---------|---------------------------------------------------------------------------|
| 1.0     | Baseline: All core objects created + test data + tSQLt + deployment logs |
| 2.0     | Optimization: Partitioned `MarginAuditLog`, rewritten procedures, reduced I/O |


##  Testing & Deployment

- **Unit Testing**: `tSQLt` framework embedded and used in `Tests/`
- **Deployment**: SQL Compare-generated deploy scripts mimic real pipeline execution

---

##  Key Learnings & Takeaways

- Efficient batching with `ROW_NUMBER()` and temp tables
- Performance cost of TVFs vs inlined expressions
- Proper indexing + predicate logic for partition pruning
- Lightweight manual deployment strategy without Bamboo or CI agents

---

##  Tools Used

- SQL Server 2022
- SSMS
- Redgate SQL Toolbelt (SQL Compare, SCA)
- Git + GitHub

