CREATE PARTITION SCHEME [ps_salesorderdate]
AS PARTITION [pf_salesorderdate]
TO ([FG2012], [FG2013], [FG2014], [FG2016], [FG2015])
GO
