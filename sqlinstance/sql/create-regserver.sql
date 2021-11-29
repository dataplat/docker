Declare @server_group_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group @parent_id=1, @name=N'Production', @description=N'', @server_type=0, @server_group_id=@server_group_id OUTPUT
Select @server_group_id

go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=6, @name=N'SQL Server 2005 Ent', @server_name=N'sql2005', @description=N'', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=6, @name=N'SQL Server 2005', @server_name=N'SQL2005', @description=N'SharePoint dbs', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=6, @name=N'SQL Server 2008 R2 Instance', @server_name=N'sql2008', @description=N'', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go

Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=6, @name=N'SQL Server 2008', @server_name=N'sql2008\sql2k8', @description=N'', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go

Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=6, @name=N'SQL Server 2012', @server_name=N'sql2012', @description=N'', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go
Declare @server_group_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group @parent_id=1, @name=N'Test', @description=N'', @server_type=0, @server_group_id=@server_group_id OUTPUT
Select @server_group_id

go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=7, @name=N'SQL Server 2000 Dev', @server_name=N'sql2000', @description=N'', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=7, @name=N'SQL Server 2005 Express Instance', @server_name=N'sql2005express\sqlexpress', @description=N'Instance', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id
go
Declare @server_id int
EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server @server_group_id=7, @name=N'The 2008 Clustered Instance', @server_name=N'sql01', @description=N'HR''s Dedicated SharePoint instance', @server_type=0, @server_id=@server_id OUTPUT
Select @server_id

go
