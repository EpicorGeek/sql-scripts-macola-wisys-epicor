--ALTER VIEW Z_OPEN_OPS AS 

--Created:	02/01/11	 By:	AW/SW
--Last Updated:	7/11/12	 By:	BG
--Purpose:	View for Production Schedule Report 
--Last Change:  Added Nolock hint to prevent query from applying locks, trying to reduce blocking from the schedule refreshes
--Last Change 2:  Change line_seq_no to line_no, excluded IT location, added woodshop QOH
--Last Change 3:  Added QOH_ALL_LOC, changed QOH to be FW locations only (WS,MS,PS,MDC,NE,GD,IT)

SELECT			DISTINCT CASE    WHEN AUD_DTS.aud_dt_min IS NULL THEN OH.entered_dt 
                        ELSE AUD_DTS.aud_dt_min
                   END AS PRINTED, 
               AUD_DTS.aud_dt_max AS [LAST CHANGE], 
               CASE WHEN AUD_LAST.aud_action = 'A' THEN 'ADD' WHEN AUD_LAST.aud_action = 'C' THEN 'UPD' ELSE NULL END AS [CHANGE TYPE], 
               AUD_LAST.user_name AS [USER], 
               OH.mfg_loc AS [ORDER LOC], 
               OL.loc AS [ITEM LOC], 
               OH.shipping_dt AS [SHIP DATE], 
               LTRIM(OH.ord_no) AS [ORDER], 
               LTRIM(OH.cus_no) AS CUST, 
               OH.ship_to_name AS [SHIP TO], 
               --CASE WHEN BM.seq_no =
                   --(SELECT MIN(bm.seq_no)
                   -- FROM   IMITMIDX_SQL IM, BMPRDSTR_SQL BM
                   -- WHERE IM.item_no = BM.item_no AND OL.item_no = IM.item_no) THEN OL.qty_ordered WHEN BM.seq_no IS NULL THEN OL.qty_ordered ELSE 0 
               --END AS QTY, 
               OL.qty_ordered AS [PARENT QTY], 
               OL.item_no AS ITEM, 
    --           CASE WHEN OL.item_no IN
				--	   (SELECT item_no
				--		FROM   POORDLIN_SQL
				--		WHERE NOT item_no IN
				--						   (SELECT item_no
				--							FROM   bmprdstr_sql)) OR
    --                     OL.item_no IN
				--	   (SELECT item_no
				--		FROM   POLINHST_SQL
				--		WHERE NOT item_no IN
				--						   (SELECT item_no
				--							FROM   bmprdstr_sql)) THEN 'N' 
				--	ELSE 'Y' 
				--END AS KIT,
			   '' AS KIT, 
               CASE WHEN CMT.line_seq_no IS NULL  THEN 'N/A' 
                    ELSE 'See Comments' 
               END AS COMMENTS, 
               OH.ship_instruction_1 AS SHIP1, 
               OH.ship_instruction_2 AS SHIP2, 
               IM.prod_cat AS CAT, 
               OL.line_no AS [LINE SEQ], 
               OL.item_desc_1 AS DESC1, 
               OL.item_desc_2 AS DESC2, 
               CASE WHEN IM.drawing_revision_no IS NULL 
					THEN rtrim(IM.drawing_release_no) 
					ELSE rtrim(IM.drawing_release_no) + '-' + IM.drawing_revision_no 
				END AS DRAWING, 
				CASE WHEN BM.qty_per_par IS NULL THEN 0 
					 ELSE BM.qty_per_par 
				END AS [QTY PER PARENT], 
				CASE WHEN BM.qty_per_par IS NULL THEN 0 
					 ELSE (OL.qty_ordered * BM.qty_per_par) 
                END AS [COMP QTY], 
                BM.comp_item_no AS [COMP ITEM], 
                CASE WHEN
                   (SELECT IM.prod_cat
                    FROM   IMITMIDX_SQL IM
                    WHERE IM.item_no = BM.comp_item_no) IS NULL THEN IM.prod_cat ELSE
                   (SELECT IM.prod_cat
                    FROM   IMITMIDX_SQL IM
                    WHERE IM.item_no = BM.comp_item_no) END AS [COMP CAT], 
               BM.seq_no AS [BMP SEQ], 
               OH.oe_po_no AS PO, 
               --IM.item_note_3 AS [ITEM NOTE], 
               OL.ord_type AS [ORDER TYPE], 
               OH.slspsn_no AS SALES, 
               '' AS [LAST MALVERN SHIPPED DATE], 
               OH.ship_via_cd AS [SHIP VIA],
               --,LTRIM(PP.Pallet) AS [PALLET ID #]
               INVFW.qty_on_hand AS [QOH],
               INVWS.qty_on_hand AS [QOH WS],
               INV.qty_on_hand AS [QOH_ALL_LOC]
FROM  dbo.oeordlin_sql  AS OL WITH(NOLOCK)
			   INNER JOIN dbo.oeordhdr_sql AS OH WITH(NOLOCK) ON OH.ord_no = OL.ord_no  
               INNER JOIN dbo.imitmidx_sql AS IM WITH(NOLOCK) ON OL.item_no = IM.item_no 
               JOIN dbo.Z_IMINVLOC AS INV WITH(NOLOCK) ON INV.item_no = IM.item_no
               JOIN dbo.Z_IMINVLOC_FW_LOCS AS INVFW WITH(NOLOCK) ON INVFW.item_no = IM.item_no
               JOIN dbo.iminvloc_sql AS INVWS WITH(NOLOCK) ON INVWS.item_no = IM.item_no
               LEFT OUTER JOIN  dbo.bmprdstr_sql AS BM WITH(NOLOCK) ON OL.item_no = BM.item_no 
               LEFT OUTER JOIN  OELINCMT_SQL CMT WITH(NOLOCK) ON CMT.ord_no = OH.ord_no 
			   LEFT OUTER JOIN
							   (SELECT AO.ord_no, MAX(aud_dt) AS aud_dt_max, MIN(aud_dt) AS aud_dt_min
								FROM          dbo.oehdraud_sql AO WITH(NOLOCK)
							    WHERE     NOT (user_def_fld_5 IN ('', 'TEST')) 
										  AND aud_action IN ('A','C')
							    GROUP BY ord_no) AS AUD_DTS ON AUD_DTS.ord_no = OH.ord_no
			   LEFT OUTER JOIN
							   (SELECT ord_no, MAX(aud_action) AS aud_action, MAX(user_name) AS user_name, MAX(aud_dt) AS aud_Dt
								FROM dbo.oehdraud_sql AS AO WITH(NOLOCK)
								WHERE (NOT (user_def_fld_5 IN ('', 'TEST'))) AND (aud_action IN ('A', 'C'))
								GROUP BY ord_no) AS AUD_LAST ON AUD_LAST.ord_no = OH.ord_no AND AUD_LAST.aud_dt = AUD_DTS.aud_dt_max	
			    LEFT OUTER JOIN wspikpak AS PP WITH(NOLOCK) ON PP.ord_no = OH.ord_no AND PP.line_no = OL.line_no
			    		    
			   
WHERE			(OH.ord_type = 'O') 
				AND (LTRIM(OH.cus_no) NOT IN ('23033', '24033', '32300', '32401')) 
				AND (pp.shipped != 'Y' OR pp.shipped IS NULL) 
				AND (OL.shipped_dt IS NULL) 
				AND (NOT (OH.user_def_fld_5 IN ('', 'TEST'))) 
				AND (NOT (OH.user_def_fld_5 IS NULL)) 
				AND (OL.loc NOT IN ('CAN', 'IN','BR','IT'))
				AND INVWS.loc = 'WS'
				
GROUP BY OH.entered_dt, AUD_DTS.aud_dt_min, AUD_LAST.aud_dt, AUD_LAST.aud_action, AUD_LAST.user_name, AUD_DTS.aud_dt_max, OH.mfg_loc, OL.loc, OH.shipping_dt, OH.ord_no, OH.cus_no, OH.ship_to_name, OH.ship_to_addr_2, OH.ship_to_addr_4, OL.qty_ordered, OL.item_no, CMT.line_seq_no, OH.ship_instruction_1, OH.ship_instruction_2, IM.prod_cat, OL.line_no, OL.item_desc_1, OL.item_desc_2, IM.drawing_release_no, IM.drawing_revision_no, BM.qty_per_par, OL.qty_ordered, BM.comp_item_no, BM.seq_no, OL.unit_price, OH.oe_po_no, IM.item_note_3, OH.ord_dt, OL.picked_dt, OL.ord_type, OH.slspsn_no, OH.ship_via_cd, INV.qty_on_hand, INVWS.qty_on_hand, INVFW.qty_on_hand--,PP.Pallet
