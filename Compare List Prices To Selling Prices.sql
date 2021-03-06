USE [001]


SELECT     ol.item_no AS Item, il.last_cost AS [Last Cost], il.price, MAX(ol.unit_price) AS [Unit Price - MAX], il.price - MAX(ol.unit_price) * 1.2 AS Expr1
FROM         dbo.oelinhst_sql AS ol INNER JOIN
                      dbo.oehdrhst_sql AS oh ON oh.ord_no = ol.ord_no INNER JOIN
                      dbo.Z_IMINVLOC AS il ON ol.item_no = il.item_no
WHERE     (oh.inv_dt > DATEADD(year, - 1, GETDATE())) AND (LTRIM(oh.cus_no) = '1575')
GROUP BY  ol.item_no, il.last_cost, il.price