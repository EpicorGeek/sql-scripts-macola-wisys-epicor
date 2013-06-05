
DECLARE @loc AS varchar(30) = 'WS'
DECLARE @parentitem AS varchar(30) = 'DIT-24 6x9 OAK'
DECLARE @kitqty AS int = 5


SELECT @loc AS Location,
       @parentitem AS [Parent Item],
       CAST(iminvloc_sql.qty_on_hand AS DECIMAL(5, 2)) AS [Parent QOH],
       CASE
         WHEN bmprdstr_sql.seq_no = (SELECT MIN(BM.seq_no)
                                     FROM   bmprdstr_sql BM
                                     WHERE  BM.item_no = @parentitem) THEN CAST(@kitqty AS DECIMAL(5, 2))
         WHEN bmprdstr_sql.seq_no IS NULL THEN CAST(@kitqty AS DECIMAL(5, 2))
         ELSE CAST('0' AS DECIMAL(5, 2))
       END AS [Parent Qty To Recv],
       bmprdstr_sql.comp_item_no AS [Component Item],
       iminvloc_wv.qty_on_hand AS [Comp. QOH],
       CAST(( CAST(@kitqty AS DECIMAL(5, 2)) * bmprdstr_sql.qty_per_par ) AS DECIMAL(5, 2)) AS [Component Qty To Issue]
FROM   imitmidx_sql
       LEFT OUTER JOIN bmprdstr_sql
         ON bmprdstr_sql.item_no = imitmidx_sql.item_no
       INNER JOIN iminvloc_sql
         ON iminvloc_sql.item_no = imitmidx_sql.item_no
       LEFT OUTER JOIN iminvloc_wv
         ON iminvloc_wv.item_no = bmprdstr_sql.comp_item_no
WHERE  imitmidx_sql.item_no = @parentitem
       AND ( iminvloc_sql.loc = @loc
              OR iminvloc_sql.loc = NULL )
       AND ( iminvloc_wv.loc = @loc
              OR iminvloc_sql.loc = NULL )
ORDER  BY [Parent Qty To Recv] DESC 