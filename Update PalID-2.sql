/****** Script for SelectTopNRows command from SSMS  ******/
UPDATE [001].[dbo].[wmpalidraw_DISTRO] SET marco_item_no = item_no from [001].[dbo].[wmpalidraw_DISTRO] as PALID INNER JOIN [001].[dbo].[oecusitm_sql] AS CUSITM ON PALID.item = CUSITM.cus_item_no

