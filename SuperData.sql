/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [view_id]
      ,[view_name]
      ,[type_id]
      ,[owner]
      ,[create_date]
      ,[visible]
      ,[languageid]
  FROM [SD206N_001].[dbo].[report_view]
  
  
  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [query_id]
      ,[query_name]
      ,[create_date]
      ,[owner]
      ,[reportdata]
      ,[reportfile]
      ,[reportformat]
      ,[languageid]
  FROM [SD206N_001].[dbo].[report_querys]
  
  SELECT * FROM dbo.saledetail

SELECT * FROM billname

SELECT  * FROM    drawdetail