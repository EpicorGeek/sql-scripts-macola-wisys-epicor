USE [001_Test_06_17_2013]
GO
DBCC SHRINKDATABASE(N'001_Test_06_17_2013') --to shrink the database
GO
DBCC SHRINKFILE (N'001.mdf', 0, TRUNCATEONLY) --to shrink data file
GO
DBCC SHRINKFILE ('001_log.LDF' , 0, TRUNCATEONLY)--to shrink ldf file


GO
DBCC LOGINFO('001_Test_06_17_2013')
GO
DBCC SHRINKFILE(2, 0, TRUNCATEONLY)
GO