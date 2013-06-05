USE [001]

GO

--ALTER VIEW BG_KPB_EOD_90 AS 

--Created:	10/15/12  By:	BG
--Last Updated:	  	  By:	BG
--Purpose: View for KPB EOD	90days
--Last Change: --

/*Shipments processed in WISYS, already invoiced, join with OH history to gather updated tracking and carrier if available*/ SELECT CASE WHEN max(pp.ship_dt) 
               IS NOT NULL THEN max(CONVERT(VARCHAR(10), PP.ship_dt, 101)) WHEN max(OL.shipped_dt) IS NOT NULL THEN max(CONVERT(VARCHAR(10), OL.shipped_dt, 
               101)) ELSE max(CONVERT(varchar(10), OH.inv_dt, 101)) END AS [ShippedDt], pp.shipment AS [Shipment], ltrim(oh.ord_no) AS OrdNo, LTRIM(OH.cus_no) AS [Cust #], 
               OH.cus_alt_adr_cd AS [Store], 
               /*If order comments contain more than 1 tracking code or carrier code in comments contains typo (doesn't exist in database), then pull the shipping data from wisys, otherwise pull comment shipping data */ CASE
                WHEN OH.cmt_1 LIKE '%,%' THEN (CASE WHEN PP.ParcelType = 'UPS' THEN 'UPG' WHEN PP.ParcelType = 'FedEx' THEN 'FXG' WHEN PP.parcelType IS NULL 
               THEN (CASE WHEN bl.ship_via_cd IS NULL THEN OH.ship_via_cd ELSE bl.ship_via_cd END) END) ELSE (CASE WHEN LEFT(OH.cmt_1, 3) IN
                   (SELECT sy_code
                    FROM   sycdefil_sql
                    WHERE cd_type = 'V') THEN LEFT(OH.cmt_1, 3) 
               ELSE (CASE PP.ParcelType WHEN 'UPS' THEN 'UPG' WHEN 'FedEx' THEN 'FXG' ELSE (CASE WHEN bl.ship_via_cd IS NULL 
               THEN OH.ship_via_cd ELSE bl.ship_via_cd END) END) END) END AS [Carrier], CASE WHEN OH.cmt_3 LIKE '%,%' THEN CASE WHEN PP.trackingno IS NULL 
               THEN dbo.FindLastDelimited(',', cmt_3) ELSE pp.trackingno END ELSE (CASE WHEN LEN(OH.cmt_3) > 3 THEN OH.cmt_3 ELSE pp.trackingno END) 
               END AS [TrackingNo], OH.ship_to_name AS [ShipTo], ol.item_no AS [Item], OL.loc AS [Dock], CASE WHEN SUM(pp.qty) IS NULL THEN SUM(OL.QTY_TO_SHIP) 
               WHEN SUM(pp.qty) > SUM(QTY_TO_SHIP) THEN SUM(OL.QTY_TO_SHIP) ELSE SUM(pp.Qty) END AS Qty, CASE WHEN OL.item_no IN ('KR1315290', 
               'KR1315252', 'KR1315290', 'KB1318610', 'KB1318553', 'KR1318801', 'KB1318800', 'KB1318609', 'KB1318609', 'KB1319964', 'KB1319968', 'KB1319965', 'KR1315292', 
               'KR1315291') THEN 'DEC' WHEN (OL.item_Desc_1 LIKE '%ENDCAP%' OR
               OL.item_desc_1 LIKE '%END CAP%') THEN 'MW' ELSE 'DEC' END AS [MW/DEC]
FROM  oelinhst_sql OL INNER JOIN
               oehdrhst_sql OH ON OH.inv_no = ol.inv_no LEFT OUTER JOIN
               [001].dbo.wsPikPak pp ON ol.item_no = pp.Item_no AND ol.ord_no = pp.ord_no LEFT OUTER JOIN
               [001].dbo.wsShipment ws ON ws.shipment = pp.shipment LEFT OUTER JOIN
               [001].dbo.oebolfil_sql BL ON BL.bol_no = ws.bol_no
               JOIN dbo.imitmidx_sql IM ON IM.item_no = OL.item_no
WHERE (PP.ship_dt > (DATEADD(day, - 91, GETDATE())) OR
       OL.shipped_dt > (DATEADD(day, - 91, GETDATE()))) AND qty_to_ship > 0
	   AND (IM.item_note_3 = 'KPB') 
/* AND oh.ord_no = '  675101'*/ 
GROUP BY oh.ord_no, oh.cus_no, pp.shipment, OL.item_no, oh.ship_via_cd, BL.ship_via_cd, pp.ParcelType, OL.loc, pp.TrackingNo, 
               pp.ship_dt, OH.cmt_3, OH.cmt_1, OH.cus_alt_adr_cd, OH.ship_to_name, OL.item_Desc_1
UNION ALL
/*Shipments processed in WISYS, not yet invoiced*/ SELECT CONVERT(varchar(10), pp.ship_dt, 101) AS [ShippedDt], pp.shipment AS [Shipment], ltrim(oh.ord_no) 
               AS OrdNo, LTRIM(OH.cus_no) AS [Cust #], OH.cus_alt_adr_cd AS [Store], 
               CASE PP.ParcelType WHEN 'UPS' THEN 'UPG' WHEN 'FedEx' THEN 'FXG' ELSE (CASE WHEN bl.ship_via_cd IS NULL 
               THEN OH.ship_via_cd ELSE bl.ship_via_cd END) END AS [Carrier], pp.TrackingNo[TrackingNo], OH.ship_to_name AS [ShipTo], pp.item_no AS [Item], 
               OL.loc AS [Dock], SUM(pp.qty) AS Qty, CASE WHEN OL.item_no IN ('KR1315290', 
               'KR1315252', 'KR1315290', 'KB1318610', 'KB1318553', 'KR1318801', 'KB1318800', 'KB1318609', 'KB1318609', 'KB1319964', 'KB1319968', 'KB1319965', 'KR1315292', 
               'KR1315291') THEN 'DEC' WHEN (OL.item_Desc_1 LIKE '%ENDCAP%' OR
               OL.item_desc_1 LIKE '%END CAP%') THEN 'MW' ELSE 'DEC' END AS [MW/DEC]
/*ELSE ltrim(pp.Pallet_UCC128) END AS [Pallet/Carton ID]*/ FROM oeordhdr_sql OH INNER JOIN
               oeordlin_sql OL ON OL.ord_no = OH.ord_no INNER JOIN
               [001].dbo.wsPikPak pp ON oh.ord_no = pp.ord_no AND OL.item_no = PP.item_no LEFT OUTER JOIN
               [001].dbo.wsShipment ws ON ws.shipment = pp.shipment LEFT OUTER JOIN
               [001].dbo.oebolfil_sql BL ON BL.bol_no = ws.bol_no 
               JOIN dbo.imitmidx_sql IM ON IM.item_no = OL.item_no
               
WHERE (shipped = 'Y' OR shipped IS NULL) AND (PP.ship_dt > (DATEADD(day, - 91, GETDATE())) OR
               OL.shipped_dt > (DATEADD(day, - 91, GETDATE()))) AND PP.item_no NOT LIKE '%TEST ITEM%' AND qty_to_ship > 0
               AND (IM.item_note_3 = 'KPB') 
GROUP BY OL.item_no, pp.ship_dt, OH.ord_no, oh.cus_no, pp.Shipment, OH.cus_alt_adr_cd, OH.ship_to_name, BL.ship_via_cd, pp.TrackingNo, pp.Item_no, OL.loc, PP.ParcelType, 
               OH.ship_via_cd, OL.item_Desc_1