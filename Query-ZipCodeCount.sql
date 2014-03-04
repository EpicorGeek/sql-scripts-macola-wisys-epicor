select DISTINCT left(ship_to_zip,4), COUNT(ord_no)
FROM OEHDRHST_SQL
WHERE ship_to_zip is not null
GROUP BY left(ship_to_zip,4)
HAVING COUNT(ord_no) > 10

