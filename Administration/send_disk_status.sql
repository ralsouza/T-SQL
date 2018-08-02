DECLARE @tableHTML  NVARCHAR(MAX) ;  

SET @tableHTML =  
    N'<H1>Disk Space Report SQL Server SGTC</H1>' +  
    N'<table border="1">' +  
    N'<tr><th>Date</th><th>Drive</th>' +  
    N'<th>Drive Name</th><th>Drive Size MB</th><th>Drive Free Space MB</th>' +  
    N'<th>Percentual Free Space</th></tr>' +
    CAST ( (SELECT DISTINCT
			  td = GETDATE(),       '',
			  td = vs.volume_mount_point, '',
			  td = vs.logical_volume_name, '',
			  td = vs.total_bytes/1024/1024, '',
			  td = vs.available_bytes/1024/1024, '',
			  td = CAST(CAST((vs.available_bytes/1024/1024 / CAST(vs.total_bytes/1024/1024 AS DECIMAL(10, 2))) * 100 AS DECIMAL(5, 2)) AS nvarchar(5)) + '%'
			FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			ORDER BY CAST(CAST((vs.available_bytes/1024/1024 / CAST(vs.total_bytes/1024/1024 AS DECIMAL(10, 2))) * 100 AS DECIMAL(5, 2)) AS nvarchar(5)) + '%' ASC  
              FOR XML PATH('tr'), TYPE   
    ) AS NVARCHAR(MAX) ) +  
    N'</table>' ;   

EXEC msdb.dbo.sp_send_dbmail @recipients='rafael.lima.dba@gmail.com',  
    @subject = 'Check Disk Space',  
    @body = @tableHTML,  
    @body_format = 'HTML' ;
