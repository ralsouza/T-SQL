/*
This script is used to override an homolog/desenv database by the production database.
I recommend creating a stored procedure in the master database to call the statement when it needs it.
*/

USE [master];
GO

DECLARE 
	@dbname_dest	varchar(max),
	@bkp_orig		varchar(max),
	@nmlogic_mdf	varchar(max),
	@nmlogic_ldf	varchar(max),
	@dest_mdf		varchar(max),
	@dest_ldf		varchar(max),
	@dbsingleuser	varchar(max),
	@dbmultiuser	varchar(max),
	@todaydate		varchar(max);

SET	@dbname_dest    = N'[Database Name]';
SET	@bkp_orig		= (SELECT [name] AS [file_name] FROM msdb..backupset WHERE [name] like '[Beginning Of File Name]%' AND [backup_start_date] >= DATEADD(D,0,DATEDIFF(D,0,GETDATE())) AND [backup_start_date] <  DATEADD(HH,1,DATEDIFF(D,0,GETDATE())))+N'.bak';
SET	@nmlogic_mdf	= N'[Logical name of the mdf file]';
SET	@nmlogic_ldf	= N'[Logical name of the ldf file]';
SET	@dest_mdf	    = N'[Path of mdf File]';
SET	@dest_ldf	    = N'[Path of ldf File]';
SET	@dbsingleuser	= N'ALTER DATABASE ' + @dbname_dest + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
SET @dbmultiuser	= N'ALTER DATABASE ' + @dbname_dest + ' SET MULTI_USER;';

EXECUTE (@dbsingleuser);

RESTORE DATABASE @dbname_dest 
FROM  DISK = @bkp_orig 
WITH  FILE = 1,  
MOVE @nmlogic_mdf TO @dest_mdf, 
MOVE @nmlogic_ldf TO @dest_ldf,
NOUNLOAD,  REPLACE,  STATS = 5;
GO

EXECUTE (@dbmultiuser);

