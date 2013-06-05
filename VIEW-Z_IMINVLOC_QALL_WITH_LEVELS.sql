/*Last Change: Excluded KPB items sold to Infiniti(22523)*/ 
SELECT [Parent Item] AS [item_no], SUM(qty_to_ship) AS [qty_allocated], 'PARENT' AS [Level], 
               [Parent Item] AS [Parent Item]
FROM  (SELECT ol.item_no AS [Parent Item], qty_to_ship
               FROM   oeordlin_sql ol 
					JOIN imitmidx_sql IM ON IM.item_no = ol.item_no
					JOIN oeordhdr_sql OH ON OH.ord_no = ol.ord_no
					LEFT OUTER JOIN (SELECT DISTINCT item_no, line_no, shipped, ord_no
                                     FROM   wspikpak) AS PP ON PP.ord_no = OL.ord_no AND PP.line_no = OL.line_no
               WHERE (shipped = 'N' OR shipped IS NULL) AND ol.loc NOT IN ('CAN', 'IN', 'BR') AND oh.ord_type IN ('O')
					   --Exclude KPB items sold to Inf
					   AND NOT (ltrim(oh.cus_no) = '22523' AND IM.item_note_3 = 'KPB') ) AS LVL_ALL
GROUP BY [Parent Item]
UNION ALL
SELECT [Comp Lvl 1] AS [item_no], SUM([Comp Lvl 1 Qty To Ship]) AS [qty_allocated], 'LVL 1' AS [Level], [Parent Item] AS [Parent Item]
FROM  (SELECT ol.item_no AS [Parent Item], OL.qty_to_ship, BM.comp_item_no[Comp Lvl 1], BM.qty_per_par[Comp Lvl 1 Per Par], 
                              BM.qty_per_par * ol.qty_to_ship AS [Comp Lvl 1 Qty To Ship]
               FROM   oeordlin_sql ol JOIN
                              dbo.bmprdstr_sql AS BM ON BM.item_no = ol.item_no LEFT OUTER JOIN
                                  (SELECT DISTINCT item_no, line_no, shipped, ord_no
                                   FROM   wspikpak) AS PP ON PP.ord_no = OL.ord_no AND PP.line_no = OL.line_no
               WHERE (shipped = 'N' OR
                              shipped IS NULL) AND ol.loc NOT IN ('CAN', 'IN', 'BR') AND ord_type IN ('O')) AS LVL_ALL
GROUP BY [Comp Lvl 1], [Parent Item]