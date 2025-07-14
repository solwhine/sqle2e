CREATE PARTITION SCHEME ps_MarginAuditLog_Range
AS PARTITION pf_MarginAuditLog_Range
ALL TO ([PRIMARY]); 