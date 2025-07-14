CREATE PARTITION SCHEME ps_StagedSales_DateRange
AS PARTITION pf_StagedSales_DateRange
ALL TO ([PRIMARY]);