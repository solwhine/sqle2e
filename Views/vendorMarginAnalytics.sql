CREATE VIEW dev.vw_vendorMarginAnalytics
AS
SELECT 
	v.vendorID,
	v.vendorName,
	COUNT(s.saleID) AS totalSales,
	SUM(s.quantity) AS totalQuantity,
	SUM(p.listPrice * s.quantity) AS totalRevenue,
	SUM(p.costPrice * s.quantity) AS totalCost,
	SUM(p.listPrice * s.quantity) - SUM(p.costPrice * s.quantity) AS totalMargin,
	CASE
		WHEN SUM(p.ListPrice * s.Quantity) = 0 THEN 0.00
		ELSE ((SUM(p.listPrice * s.quantity) - SUM(p.costPrice * s.quantity))/
		NULLIF(SUM(p.listPrice * s.quantity),0)) * 100
		END
		AS marginPercent
FROM 
    dev.Vendors v
    INNER JOIN dev.Products p ON v.vendorID = p.vendorID
    INNER JOIN dev.Sales s ON p.productID = s.productID
GROUP BY 
	v.vendorID,
	v.vendorName