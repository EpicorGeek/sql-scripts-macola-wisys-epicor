SELECT OH.ord_no, OH.cus_no, OH.bill_to_name, OH.inv_dt, prod_Cat, item_no, item_desc_1, item_desc_2, qty_ordered, unit_price, (unit_price*qty_ordered) AS LineTotal 
FROM dbo.oelinhst_sql OL JOIN dbo.oehdrhst_sql OH ON OH.inv_no = OL.inv_no 
WHERE prod_cat IN ('1','029','028') AND inv_dt > '01/01/2013'
UNION ALL
SELECT OH.ord_no, OH.cus_no, OH.bill_to_name, OH.inv_dt, prod_Cat, item_no, item_desc_1, item_desc_2, qty_ordered, unit_price, (unit_price*qty_ordered) AS LineTotal 
FROM dbo.oeordlin_sql OL JOIN dbo.oeordhdr_sql OH ON OH.ord_no = OL.ord_no 
WHERE prod_cat IN ('1','029','028')