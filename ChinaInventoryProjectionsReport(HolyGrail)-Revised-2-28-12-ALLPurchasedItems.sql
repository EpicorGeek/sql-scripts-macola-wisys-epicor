SELECT TOP (100) PERCENT Item,  [ItemDesc1],  [ItemDesc2], [PO/SLS], [SHP OR RECV DT], [QTY (QOH/QTY SLS/QTY REC)], [PROJ QOH], ORD#, [VEND/CUS], [ORD DT], CONTAINER, [CONT. SHP TO], 
               [XFER TO], [PROD CAT], [CUS#/VEND#], CH, STORE, [PARENT ITEM (ONLY ON SALES)], CASE WHEN ESS IS NULL THEN 0 
																								   WHEN ISNUMERIC(ESS) = 0 THEN 0 ELSE ESS END AS ESS
FROM  (SELECT DISTINCT 
                              IM2.item_no AS Item, IM2.item_desc_1 AS [ItemDesc1], IM2.item_desc_2 AS [ItemDesc2], 'QOH' AS [PO/SLS],  CONVERT(varchar(10), GETDATE(), 101) AS [SHP OR RECV DT], 
                              IM.qty_on_hand AS [QTY (QOH/QTY SLS/QTY REC)], '' AS [PROJ QOH], 'QOH' AS ORD#, 'QOH' AS [VEND/CUS], 'QOH' AS [ORD DT], 'QOH' AS CONTAINER, 
                              'QOH' AS [CONT. SHP TO], 'QOH' AS [XFER TO], IM.prod_cat AS [PROD CAT], NULL AS [CUS#/VEND#], IM2.item_note_1 AS CH, 'QOH' AS STORE, 
                              'QOH' AS [PARENT ITEM (ONLY ON SALES)], IM2.item_note_4 AS ESS
               FROM   dbo.Z_IMINVLOC AS IM INNER JOIN
                              dbo.imitmidx_sql AS IM2 ON IM2.item_no = IM.item_no
               WHERE (IM2.prod_cat NOT IN ('036', '336', '102', '037')) AND (IM2.item_no IN
                                  (SELECT PL.item_no
                                   FROM   dbo.poordlin_sql AS PL INNER JOIN
                                                  dbo.poordhdr_sql AS PH ON PH.ord_no = PL.ord_no
                                   WHERE (PH.ord_dt > DATEADD(DAY, -365, GETDATE())) AND (PL.ord_status <> 'X')))
               UNION ALL
               SELECT PL.item_no AS ITEM, IM2.item_desc_1 AS [ItemDesc1], IM2.item_desc_2 AS [ItemDesc2], 'PO' AS [PO/SLS], 
                          CASE WHEN NOT (PL.user_def_fld_2 IS NULL) THEN PL.user_def_fld_2 
                               WHEN PL.user_def_fld_2 IS NULL AND NOT (PL.extra_8 IS NULL) THEN CONVERT(varchar(10), DATEADD(day, 28, PL.extra_8), 101) 
                               WHEN PL.user_Def_fld_2 IS NULL AND PL.extra_8 IS NULL AND LTRIM(PL.vend_no) IN (SELECT vend_no FROM BG_CH_Vendors) THEN CONVERT(varchar(10), DATEADD(DAY, 90, PH.ord_dt), 101) 
                               ELSE CONVERT(varchar(10), DATEADD(DAY, 7, PH.ord_dt), 101) 
                          END AS [SHP/RECV DT],
                       CAST(PL.qty_ordered AS int) AS QTY, '' AS [PROJ QOH], CAST(LTRIM(SUBSTRING(PL.ord_no, 1, 6)) AS VARCHAR) 
                              AS [ORDER], AP.vend_name AS [VEND/CUS], CONVERT(varchar(10), PH.ord_dt, 101) AS [ORDER DATE], PL.user_def_fld_1 AS [CONTAINER INFO], 
                              PL.user_def_fld_3 AS [Container Ship To], PS.ship_to_desc AS [TRANSFER TO], IM2.prod_cat AS [PROD CAT], LTRIM(PH.vend_no) AS [CUS NO], 
                              IM2.item_note_1 AS CH, '' AS STORE, '' AS [PARENT ITEM], IM2.item_note_4 AS ESS
               FROM  dbo.apvenfil_sql AS AP INNER JOIN
                              dbo.poordhdr_sql AS PH ON AP.vend_no = PH.vend_no INNER JOIN
                              dbo.poordlin_sql AS PL ON PL.ord_no = PH.ord_no AND PL.vend_no = PH.vend_no INNER JOIN
                              dbo.imitmidx_sql AS IM2 ON IM2.item_no = PL.item_no INNER JOIN
                              dbo.humres AS HR ON PL.byr_plnr = HR.res_id LEFT OUTER JOIN
                              dbo.poshpfil_sql AS PS ON PS.ship_to_cd = PH.ship_to_cd
               WHERE (PL.qty_received < PL.qty_ordered) AND (IM2.prod_cat NOT IN ('036', '336', '102', '037')) AND (IM2.item_no IN
                                  (SELECT PL.item_no
                                   FROM   dbo.poordlin_sql AS PL INNER JOIN
                                                  dbo.poordhdr_sql AS PH ON PH.ord_no = PL.ord_no
                                   WHERE (PH.ord_dt > DATEADD(DAY, -365, GETDATE())) AND (PL.ord_status <> 'X')))
               UNION ALL
               SELECT BM.comp_item_no AS ITEM, BMIM.item_desc_1 AS [ItemDesc1], BMIM.item_desc_2 AS [ItemDesc2],  'SALE' AS [PO/SLS], 
                CASE WHEN CONVERT(varchar(10), OH.shipping_dt, 101) < GETDATE() THEN CONVERT(VARCHAR(10), DATEADD(day, 1, GETDATE()), 101)
                     ELSE  CONVERT(varchar(10), OH.shipping_dt, 101) 
                END AS [SHP/RECV DT],    
               CAST(OL.qty_to_ship AS INT) 
                              * BM.qty_per_par * - 1 AS QTY, '' AS [PROJ QOH], CAST(RTRIM(LTRIM(OH.ord_no)) AS VARCHAR) AS [ORDER], OH.ship_to_name AS [VEND/CUS], 
                              CONVERT(varchar(10), OH.entered_dt, 101) AS [ORDER DATE], NULL AS [CONTAINER INFO], NULL AS [Container Ship To], NULL AS [TRANSFER TO], 
                              BMIM.prod_cat AS [PROD CAT], LTRIM(OH.cus_no) AS [CUS NO], IM2.item_note_1 AS CH, OH.cus_alt_adr_cd AS STORE, 
                              OL.item_no AS [PARENT ITEM ON SALES ORD], BMIM.item_note_4 AS ESS
               FROM  dbo.oeordhdr_sql AS OH INNER JOIN
                              dbo.oeordlin_sql AS OL ON OL.ord_no = OH.ord_no INNER JOIN
                              dbo.imitmidx_sql AS IM2 ON IM2.item_no = OL.item_no LEFT OUTER JOIN
                              dbo.bmprdstr_sql AS BM ON BM.item_no = OL.item_no LEFT OUTER JOIN
                              imitmidx_Sql AS BMIM ON BMIM.item_no = BM.comp_item_no
               WHERE (OH.ord_type = 'O') AND (IM2.prod_cat NOT IN ('036', '336', '102', '037')) AND ((CAST(LTRIM(OL.ord_no) AS VARCHAR) + CAST(CAST(OL.qty_to_ship AS INT) 
                              AS VARCHAR)) NOT IN
                                  (SELECT CAST(LTRIM(Ord_no) AS VARCHAR) + CAST(SUM(Qty) AS VARCHAR) AS Expr1
                                   FROM   dbo.wsPikPak
                                   WHERE (Shipped = 'Y')
                                   GROUP BY Ord_no, Item_no)) AND (BM.comp_item_no IN
                                  (SELECT PL.item_no
                                   FROM   dbo.poordlin_sql AS PL INNER JOIN
                                                  dbo.poordhdr_sql AS PH ON PH.ord_no = PL.ord_no
                                   WHERE (PH.ord_dt > DATEADD(DAY, -365, GETDATE())) AND (PL.ord_status <> 'X')))
               UNION ALL
               SELECT OL.item_no AS ITEM, IM2.item_desc_1 AS [ItemDesc1], IM2.item_desc_2 AS [ItemDesc2], 'SALE' AS [PO/SLS], 
						CASE WHEN CONVERT(varchar(10), OH.shipping_dt, 101) < GETDATE() THEN CONVERT(VARCHAR(10), DATEADD(day, 1, GETDATE()), 101)
                             ELSE  CONVERT(varchar(10), OH.shipping_dt, 101) 
                        END AS [SHP/RECV DT],
								 OL.qty_to_ship * - 1 AS QTY, '' AS [PROJ QOH], 
                              CAST(RTRIM(LTRIM(OH.ord_no)) AS VARCHAR) AS [ORDER], OH.ship_to_name AS [VEND/CUS], CONVERT(varchar(10), OH.entered_dt, 101) 
                              AS [ORDER DATE], NULL AS [CONTAINER INFO], NULL AS [Container Ship To], NULL AS [TRANSFER TO], OL.prod_cat AS [PROD CAT], LTRIM(OH.cus_no) 
                              AS [CUS NO], IM2.item_note_1 AS CH, OH.cus_alt_adr_cd AS STORE, OL.item_no AS [PARENT ITEM ON SALES ORD], IM2.item_note_4 AS ESS
               FROM  dbo.oeordhdr_sql AS OH INNER JOIN
                              dbo.oeordlin_sql AS OL ON OL.ord_no = OH.ord_no INNER JOIN
                              dbo.imitmidx_sql AS IM2 ON IM2.item_no = OL.item_no
               WHERE (OH.ord_type = 'O') AND (IM2.prod_cat NOT IN ('036', '336', '102', '037')) AND ((CAST(LTRIM(OL.ord_no) AS VARCHAR) + CAST(CAST(OL.qty_to_ship AS INT) 
                              AS VARCHAR)) NOT IN
                                  (SELECT CAST(LTRIM(Ord_no) AS VARCHAR) + CAST(SUM(Qty) AS VARCHAR) AS Expr1
                                   FROM   dbo.wsPikPak AS wsPikPak_1
                                   WHERE (Shipped = 'Y')
                                   GROUP BY Ord_no, Item_no)) AND (IM2.item_no IN
                                  (SELECT PL.item_no
                                   FROM   dbo.poordlin_sql AS PL INNER JOIN
                                                  dbo.poordhdr_sql AS PH ON PH.ord_no = PL.ord_no
                                   WHERE (PH.ord_dt > DATEADD(DAY, -365, GETDATE())) AND (PL.ord_status <> 'X')))) AS HolyGrail
ORDER BY Item, [SHP OR RECV DT]