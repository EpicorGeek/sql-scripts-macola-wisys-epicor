USE [001]
GO
/****** Object:  Trigger [dbo].[Insert_to_ARSHTTBL]    Script Date: 03/29/2011 13:59:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER trigger [dbo].[Insert_to_ARSHTTBL]
            on [001].[dbo].[ARSHTFIL_SQL]

			after insert
			AS

BEGIN


		INSERT INTO ARSHTTBL (
								 [ord_no]
								,[shipment_no]
								,[carrier_cd]
								,[mode]
								,[ship_cost]
								,[total_cost]
								,[cod_amount]
								,[tracking_no]
								,[zone]
								,[ship_weight]
								,[void_fg]
								,[complete_fg]
								,[hand_chg]
								,[ship_dt]
								,[filler_0001]
								,[extra_1]
							)

select
			 ltrim(ar.ord_no)
			,pp.Line_no
			,bl.ship_via_cd
			,CASE pp.Loc
				WHEN 'FW' THEN '?'
				WHEN 'PS' THEN '1'
				WHEN 'WS' THEN '2'
				WHEN 'BC' THEN '3'
				WHEN 'MS' THEN '4'
				WHEN 'NE' THEN '5'
				WHEN 'MDC' THEN '6'
				ELSE '?'
			 END
			,ar.ship_cost
			,ar.total_cost
			,ar.cod_amount
			,ar.tracking_no
			,ar.zone
			,ar.ship_weight
			,ar.void_fg
			,ar.complete_fg
			,pp.Qty
			,CONVERT(varchar(8),pp.ship_dt,112)
			,pp.Item_no
			,ar.tracking_no

from		inserted ar

inner join	[001].dbo.wsShipment ws

			on ws.shipment = Convert(BigInt, ar.filler_0001)                                                                                                                                                                                                                    

inner join	[001].dbo.wsPikPak pp

			on pp.Shipment = ws.Shipment
			
inner join	[001].dbo.oebolfil_sql bl

			on bl.bol_no = ws.bol_no			

END

