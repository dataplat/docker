-- create a boatload of things to migrate

-- backup device
EXEC master.dbo.sp_addumpdevice  @devtype = N'disk', @logicalname = N'Old School', @physicalname = N'\\nas\sqlbackups\Old School.bak'
GO

-- custom errors
EXEC master.dbo.sp_addmessage @msgnum=60000, @lang=N'us_english', 
		@severity=16, 
		@msgtext=N'The item named %s already exists in %s.', 
		@with_log=false
GO

-- mail
EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'AccountRetryAttempts', @parameter_value=N'1', @description=N'Number of retry attempts for a mail server'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'AccountRetryDelay', @parameter_value=N'60', @description=N'Delay between each retry attempt to mail server'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'DatabaseMailExeMinimumLifeTime', @parameter_value=N'600', @description=N'Minimum process lifetime in seconds'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'DefaultAttachmentEncoding', @parameter_value=N'MIME', @description=N'Default attachment encoding'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'LoggingLevel', @parameter_value=N'2', @description=N'Database Mail logging level: normal - 1, extended - 2 (default), verbose - 3'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'MaxFileSize', @parameter_value=N'1000000', @description=N'Default maximum file size'
GO

EXEC msdb.dbo.sysmail_configure_sp @parameter_name=N'ProhibitedExtensions', @parameter_value=N'exe,dll,vbs,js', @description=N'Extensions not allowed in outgoing mails'
GO

EXEC msdb.dbo.sysmail_add_account_sp @account_name=N'The DBA Team', 
		@email_address=N'dbadistro@ad.local', 
		@display_name=N'The DBA Team'
GO

EXEC msdb.dbo.sysmail_add_profile_sp @profile_name=N'The DBA Team'
GO

EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name=N'The DBA Team', @account_name=N'The DBA Team', @sequence_number=1
GO

EXEC msdb.dbo.sysmail_add_principalprofile_sp @principal_name=N'guest', @profile_name=N'The DBA Team', @is_default=1
GO

EXEC msdb.dbo.sysmail_update_account_sp @account_name=N'The DBA Team', @description=N'', @email_address=N'dbadistro@ad.local', @display_name=N'The DBA Team', @replyto_address=N'', @mailserver_name=N'smtp.ad.local', @mailserver_type=N'SMTP', @port=25, @username=N'', @password=N'', @use_default_credentials=0, @enable_ssl=0
GO

-- extended events

CREATE EVENT SESSION [AlwaysOn_health_new] ON SERVER 
ADD EVENT sqlserver.alwayson_ddl_executed,
ADD EVENT sqlserver.availability_group_lease_expired,
ADD EVENT sqlserver.availability_replica_automatic_failover_validation,
ADD EVENT sqlserver.availability_replica_manager_state_change,
ADD EVENT sqlserver.availability_replica_state,
ADD EVENT sqlserver.availability_replica_state_change,
ADD EVENT sqlserver.error_reported(
    WHERE ([error_number]=(9691) OR [error_number]=(35204) OR [error_number]=(9693) OR [error_number]=(26024) OR [error_number]=(28047) OR [error_number]=(26023) OR [error_number]=(9692) OR [error_number]=(28034) OR [error_number]=(28036) OR [error_number]=(28048) OR [error_number]=(28080) OR [error_number]=(28091) OR [error_number]=(26022) OR [error_number]=(9642) OR [error_number]=(35201) OR [error_number]=(35202) OR [error_number]=(35206) OR [error_number]=(35207) OR [error_number]=(26069) OR [error_number]=(26070) OR [error_number]>(41047) AND [error_number]<(41056) OR [error_number]=(41142) OR [error_number]=(41144) OR [error_number]=(1480) OR [error_number]=(823) OR [error_number]=(824) OR [error_number]=(829) OR [error_number]=(35264) OR [error_number]=(35265) OR [error_number]=(41188) OR [error_number]=(41189))),
ADD EVENT sqlserver.hadr_db_partner_set_sync_state,
ADD EVENT sqlserver.lock_redo_blocked
ADD TARGET package0.event_file(SET filename=N'AlwaysOn_health.xel',max_file_size=(5),max_rollover_files=(4))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO
CREATE EVENT SESSION [Login Tracker] ON SERVER 
ADD EVENT sqlserver.sql_statement_starting(SET collect_statement=(0)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.server_instance_name,sqlserver.server_principal_name)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)) AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%dbatools%') AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N'%management studio%') AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name],N'tempdb')))
ADD TARGET package0.event_file(SET filename=N'Login Tracker',max_file_size=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO
CREATE EVENT SESSION [QuickSessionStandard] ON SERVER 
ADD EVENT sqlserver.attention(
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.existing_connection(SET collect_options_text=(1)
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id)),
ADD EVENT sqlserver.login(SET collect_options_text=(1)
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id)),
ADD EVENT sqlserver.logout(
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_pid,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.session_id)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(package0.event_sequence,sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0))))
WITH (MAX_MEMORY=8192 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_CPU,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO
CREATE EVENT SESSION [system_health_new] ON SERVER 
ADD EVENT sqlclr.clr_allocation_failure(
    ACTION(package0.callstack,sqlserver.session_id)),
ADD EVENT sqlclr.clr_virtual_alloc_failure(
    ACTION(package0.callstack,sqlserver.session_id)),
ADD EVENT sqlos.memory_broker_ring_buffer_recorded,
ADD EVENT sqlos.memory_node_oom_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlos.process_killed(
    ACTION(package0.callstack,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.query_hash,sqlserver.session_id,sqlserver.session_nt_username)),
ADD EVENT sqlos.scheduler_monitor_deadlock_ring_buffer_recorded,
ADD EVENT sqlos.scheduler_monitor_non_yielding_iocp_ring_buffer_recorded,
ADD EVENT sqlos.scheduler_monitor_non_yielding_ring_buffer_recorded,
ADD EVENT sqlos.scheduler_monitor_non_yielding_rm_ring_buffer_recorded,
ADD EVENT sqlos.scheduler_monitor_stalled_dispatcher_ring_buffer_recorded,
ADD EVENT sqlos.scheduler_monitor_system_health_ring_buffer_recorded,
ADD EVENT sqlos.wait_info(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([duration]>(15000) AND ([wait_type]>=N'LATCH_NL' AND ([wait_type]>=N'PAGELATCH_NL' AND [wait_type]<=N'PAGELATCH_DT' OR [wait_type]<=N'LATCH_DT' OR [wait_type]>=N'PAGEIOLATCH_NL' AND [wait_type]<=N'PAGEIOLATCH_DT' OR [wait_type]>=N'IO_COMPLETION' AND [wait_type]<=N'NETWORK_IO' OR [wait_type]=N'RESOURCE_SEMAPHORE' OR [wait_type]=N'SOS_WORKER' OR [wait_type]>=N'FCB_REPLICA_WRITE' AND [wait_type]<=N'WRITELOG' OR [wait_type]=N'CMEMTHREAD' OR [wait_type]=N'TRACEWRITE' OR [wait_type]=N'RESOURCE_SEMAPHORE_MUTEX') OR [duration]>(30000) AND [wait_type]<=N'LCK_M_RX_X'))),
ADD EVENT sqlos.wait_info_external(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([duration]>(5000) AND ([wait_type]>=N'PREEMPTIVE_OS_GENERICOPS' AND [wait_type]<=N'PREEMPTIVE_OS_ENCRYPTMESSAGE' OR [wait_type]>=N'PREEMPTIVE_OS_INITIALIZESECURITYCONTEXT' AND [wait_type]<=N'PREEMPTIVE_OS_QUERYSECURITYCONTEXTTOKEN' OR [wait_type]>=N'PREEMPTIVE_OS_AUTHZGETINFORMATIONFROMCONTEXT' AND [wait_type]<=N'PREEMPTIVE_OS_REVERTTOSELF' OR [wait_type]>=N'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT' AND [wait_type]<=N'PREEMPTIVE_OS_DEVICEOPS' OR [wait_type]>=N'PREEMPTIVE_OS_NETGROUPGETUSERS' AND [wait_type]<=N'PREEMPTIVE_OS_NETUSERMODALSGET' OR [wait_type]>=N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICYFREE' AND [wait_type]<=N'PREEMPTIVE_OS_DOMAINSERVICESOPS' OR [wait_type]=N'PREEMPTIVE_OS_VERIFYSIGNATURE' OR [duration]>(45000) AND ([wait_type]>=N'PREEMPTIVE_OS_SETNAMEDSECURITYINFO' AND [wait_type]<=N'PREEMPTIVE_CLUSAPI_CLUSTERRESOURCECONTROL' OR [wait_type]>=N'PREEMPTIVE_OS_RSFXDEVICEOPS' AND [wait_type]<=N'PREEMPTIVE_OS_DSGETDCNAME' OR [wait_type]>=N'PREEMPTIVE_OS_DTCOPS' AND [wait_type]<=N'PREEMPTIVE_DTC_ABORT' OR [wait_type]>=N'PREEMPTIVE_OS_CLOSEHANDLE' AND [wait_type]<=N'PREEMPTIVE_OS_FINDFILE' OR [wait_type]>=N'PREEMPTIVE_OS_GETCOMPRESSEDFILESIZE' AND [wait_type]<=N'PREEMPTIVE_ODBCOPS' OR [wait_type]>=N'PREEMPTIVE_OS_DISCONNECTNAMEDPIPE' AND [wait_type]<=N'PREEMPTIVE_CLOSEBACKUPMEDIA' OR [wait_type]=N'PREEMPTIVE_OS_AUTHENTICATIONOPS' OR [wait_type]=N'PREEMPTIVE_OS_FREECREDENTIALSHANDLE' OR [wait_type]=N'PREEMPTIVE_OS_AUTHORIZATIONOPS' OR [wait_type]=N'PREEMPTIVE_COM_COCREATEINSTANCE' OR [wait_type]=N'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICY' OR [wait_type]=N'PREEMPTIVE_VSS_CREATESNAPSHOT')))),
ADD EVENT sqlserver.connectivity_ring_buffer_recorded(SET collect_call_stack=(1)),
ADD EVENT sqlserver.error_reported(
    ACTION(package0.callstack,sqlserver.database_id,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)
    WHERE ([severity]>=(20) OR ([error_number]=(17803) OR [error_number]=(701) OR [error_number]=(802) OR [error_number]=(8645) OR [error_number]=(8651) OR [error_number]=(8657) OR [error_number]=(8902) OR [error_number]=(41354) OR [error_number]=(41355) OR [error_number]=(41367) OR [error_number]=(41384) OR [error_number]=(41336) OR [error_number]=(41309) OR [error_number]=(41312) OR [error_number]=(41313)))),
ADD EVENT sqlserver.security_error_ring_buffer_recorded(SET collect_call_stack=(1)),
ADD EVENT sqlserver.sp_server_diagnostics_component_result(SET collect_data=(1)
    WHERE ([sqlserver].[is_system]=(1) AND [component]<>(4))),
ADD EVENT sqlserver.sql_exit_invoked(
    ACTION(package0.callstack,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.query_hash,sqlserver.session_id,sqlserver.session_nt_username)),
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename=N'system_health.xel',max_file_size=(5),max_rollover_files=(4)),
ADD TARGET package0.ring_buffer(SET max_events_limit=(5000),max_memory=(4096))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=120 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO
CREATE EVENT SESSION [telemetry_xevents_new] ON SERVER 
ADD EVENT qds.query_store_db_diagnostics,
ADD EVENT sqlserver.alter_column_event,
ADD EVENT sqlserver.always_encrypted_query_count,
ADD EVENT sqlserver.auto_stats,
ADD EVENT sqlserver.cardinality_estimation_version_usage,
ADD EVENT sqlserver.column_store_index_build_low_memory,
ADD EVENT sqlserver.column_store_index_build_throttle,
ADD EVENT sqlserver.columnstore_delete_buffer_flush_failed,
ADD EVENT sqlserver.columnstore_delta_rowgroup_closed,
ADD EVENT sqlserver.columnstore_index_reorg_failed,
ADD EVENT sqlserver.columnstore_log_exception,
ADD EVENT sqlserver.columnstore_rowgroup_merge_failed,
ADD EVENT sqlserver.columnstore_tuple_mover_delete_buffer_truncate_timed_out,
ADD EVENT sqlserver.columnstore_tuple_mover_end_compress,
ADD EVENT sqlserver.create_index_event,
ADD EVENT sqlserver.data_masking_ddl_column_definition,
ADD EVENT sqlserver.data_masking_traffic,
ADD EVENT sqlserver.data_masking_traffic_masked_only,
ADD EVENT sqlserver.database_cmptlevel_change,
ADD EVENT sqlserver.database_created,
ADD EVENT sqlserver.database_dropped,
ADD EVENT sqlserver.error_reported(
    WHERE ([severity]>=(16) OR ([error_number]=(18456) OR [error_number]=(17803) OR [error_number]=(701) OR [error_number]=(802) OR [error_number]=(8645) OR [error_number]=(8651) OR [error_number]=(8657) OR [error_number]=(8902) OR [error_number]=(41354) OR [error_number]=(41355) OR [error_number]=(41367) OR [error_number]=(41384) OR [error_number]=(41336) OR [error_number]=(41309) OR [error_number]=(41312) OR [error_number]=(41313) OR [error_number]=(33065) OR [error_number]=(33066)))),
ADD EVENT sqlserver.graph_match_query_compiled,
ADD EVENT sqlserver.index_build_error_event,
ADD EVENT sqlserver.index_defragmentation,
ADD EVENT sqlserver.interleaved_exec_status,
ADD EVENT sqlserver.json_function_compiled(
    ACTION(sqlserver.database_id)),
ADD EVENT sqlserver.missing_column_statistics,
ADD EVENT sqlserver.missing_join_predicate,
ADD EVENT sqlserver.natively_compiled_module_inefficiency_detected,
ADD EVENT sqlserver.natively_compiled_proc_slow_parameter_passing,
ADD EVENT sqlserver.query_memory_grant_blocking,
ADD EVENT sqlserver.query_optimizer_compatibility_level_hint_usage,
ADD EVENT sqlserver.reason_many_foreign_keys_operator_not_used,
ADD EVENT sqlserver.rls_query_count,
ADD EVENT sqlserver.sequence_function_used(
    ACTION(sqlserver.database_id)),
ADD EVENT sqlserver.server_memory_change,
ADD EVENT sqlserver.server_start_stop,
ADD EVENT sqlserver.stretch_database_disable_completed,
ADD EVENT sqlserver.stretch_database_enable_completed,
ADD EVENT sqlserver.stretch_database_reauthorize_completed,
ADD EVENT sqlserver.stretch_index_reconciliation_codegen_completed,
ADD EVENT sqlserver.stretch_query_telemetry,
ADD EVENT sqlserver.stretch_remote_column_execution_completed,
ADD EVENT sqlserver.stretch_remote_column_reconciliation_codegen_completed,
ADD EVENT sqlserver.stretch_remote_error,
ADD EVENT sqlserver.stretch_remote_index_execution_completed,
ADD EVENT sqlserver.stretch_table_alter_ddl,
ADD EVENT sqlserver.stretch_table_codegen_completed,
ADD EVENT sqlserver.stretch_table_create_ddl,
ADD EVENT sqlserver.stretch_table_data_reconciliation_results_event,
ADD EVENT sqlserver.stretch_table_hinted_admin_delete_event,
ADD EVENT sqlserver.stretch_table_hinted_admin_update_event,
ADD EVENT sqlserver.stretch_table_predicate_not_specified,
ADD EVENT sqlserver.stretch_table_predicate_specified,
ADD EVENT sqlserver.stretch_table_query_error,
ADD EVENT sqlserver.stretch_table_remote_creation_completed,
ADD EVENT sqlserver.stretch_table_row_migration_results_event,
ADD EVENT sqlserver.stretch_table_row_unmigration_results_event,
ADD EVENT sqlserver.stretch_table_unprovision_completed,
ADD EVENT sqlserver.stretch_table_validation_error,
ADD EVENT sqlserver.string_escape_compiled(
    ACTION(sqlserver.database_id)),
ADD EVENT sqlserver.temporal_ddl_period_add,
ADD EVENT sqlserver.temporal_ddl_period_drop,
ADD EVENT sqlserver.temporal_ddl_schema_check_fail,
ADD EVENT sqlserver.temporal_ddl_system_versioning,
ADD EVENT sqlserver.temporal_dml_transaction_fail,
ADD EVENT sqlserver.window_function_used(
    ACTION(sqlserver.database_id)),
ADD EVENT sqlserver.xtp_alter_table,
ADD EVENT sqlserver.xtp_db_delete_only_mode_updatedhktrimlsn,
ADD EVENT sqlserver.xtp_stgif_container_added,
ADD EVENT sqlserver.xtp_stgif_container_deleted,
ADD EVENT XtpCompile.cl_duration,
ADD EVENT XtpEngine.parallel_alter_stats,
ADD EVENT XtpEngine.serial_alter_stats,
ADD EVENT XtpEngine.xtp_db_delete_only_mode_enter,
ADD EVENT XtpEngine.xtp_db_delete_only_mode_exit,
ADD EVENT XtpEngine.xtp_db_delete_only_mode_update,
ADD EVENT XtpEngine.xtp_physical_db_restarted
ADD TARGET package0.ring_buffer(SET occurrence_number=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=120 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

-- logins


USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'app1') CREATE LOGIN [app1] WITH PASSWORD = 0x0100782FBD65E30E772B02685C41E3F69FC1E639EC77F5F4061A HASHED, SID = 0x63F51E14DBA20942AF361A3300193A7B, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [app1]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'appAdmin') CREATE LOGIN [appAdmin] WITH PASSWORD = 0x010078D465BE65DAF3B59593301B62F6199E86E70E83A542E19F HASHED, SID = 0x9243AF88BBE7B74EB83607393A9BB427, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [appAdmin]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'BUILTIN\Administrators') CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [BUILTIN\Administrators]
GO

USE master

GO
Grant CONNECT SQL TO [BUILTIN\Administrators]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'distributor_admin') CREATE LOGIN [distributor_admin] WITH PASSWORD = 0x0200A1E37336367DCA8A0D57373A5125982D7F774312E358C06DDD295A79FDC9F26509D7E95BF8D599EB0731F15D13272C5E2F504BC0B2C302BDC19F9697EAD3B442A7451083 HASHED, SID = 0x6EFAF247DFA6824EA9BA9B3ACC5949E6, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [distributor_admin]
GO

USE master

GO
Grant CONNECT SQL TO [distributor_admin]  AS [sa]
GO

USE master

GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'storageuser') CREATE LOGIN [storageuser] WITH PASSWORD = 0x01003A2F024897F4A96E4AC4167E6431FBB0E26A9A987644D720 HASHED, SID = 0xEA947BDFB542FC4B816012ADE47D1651, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [storageuser]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'testlogin') CREATE LOGIN [testlogin] WITH PASSWORD = 0x02002E0CB89BE6A3118A65BE3B9BA53C98854361125B5722FAC66E9E32A6A996537E6E3556BCC09C4D0807650FD6753AA61881DAEE0C4AE962856EA17E0DDF2DFABBFC65BC34 HASHED, SID = 0x7612E56A4CAB2C468A7D24736564C6F7, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [Dansk]
GO

USE master

GO
Grant CONNECT SQL TO [testlogin]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'TestOrphan1') CREATE LOGIN [TestOrphan1] WITH PASSWORD = 0x0100479BFEEE79E83E8B847AAF33CD9A04B439ED43476C20BDDE HASHED, SID = 0xF1BACB136DD3764C9CE200E49041A0C2, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [TestOrphan1]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'TestOrphan2') CREATE LOGIN [TestOrphan2] WITH PASSWORD = 0x01000698EFA5455FE8F1C91429ECA4FE9CBFEFB953F1C08F96D5 HASHED, SID = 0x299C2102F657B4458F75653CB19A54A3, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO

USE master

GO
Grant CONNECT SQL TO [TestOrphan2]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'testuser2') CREATE LOGIN [testuser2] WITH PASSWORD = 0x0200DB112FF49345FC8DBE87F1F093429E5FCB4197F1E18D92D1594172843CE5CDA3B3DF269E2962D977EB60DFC855EAB774085069B43C408B3228A8EC20D4F2CE9775A0C0D7 HASHED, SID = 0xF959ADF337EF1149977812AD7969837C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER LOGIN [testuser2] DISABLE
GO
DENY CONNECT SQL TO [testuser2]
GO
ALTER SERVER ROLE [setupadmin] ADD MEMBER [testuser2]
GO

USE master

GO
Deny CONNECT SQL TO [testuser2]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'webuser') CREATE LOGIN [webuser] WITH PASSWORD = 0x0100162F297ABC8257F6431EA4FC8B776D42EFE04D6023211A08 HASHED, SID = 0x199A7A25579A3E4193A59299130DB683, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [webuser]
GO
ALTER SERVER ROLE [processadmin] ADD MEMBER [webuser]
GO

USE master

GO
Grant CONNECT SQL TO [webuser]  AS [sa]
GO

-- policy management

Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'AppRoles', @description=N'', @facet=N'ApplicationRole', @expression=N'<Operator>
				  <TypeClass>Bool</TypeClass>
				  <OpType>EQ</OpType>
				  <Count>2</Count>
				  <Attribute>
				    <TypeClass>DateTime</TypeClass>
				    <Name>DateLastModified</Name>
				  </Attribute>
				  <Function>
				    <TypeClass>DateTime</TypeClass>
				    <FunctionType>DateTime</FunctionType>
				    <ReturnType>DateTime</ReturnType>
				    <Count>1</Count>
				    <Constant>
				      <TypeClass>String</TypeClass>
				      <ObjType>System.String</ObjType>
				      <Value>2016-05-03T00:00:00.0000000</Value>
				    </Constant>
				  </Function>
				</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
 
GO

Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'xp_cmdshell must be disabled_ObjectSet', @facet=N'ApplicationRole', @object_set_id=@object_set_id OUTPUT
Select @object_set_id
 Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'xp_cmdshell must be disabled_ObjectSet', @type_skeleton=N'Server/Database/ApplicationRole', @type=N'APPLICATION ROLE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database/ApplicationRole', @level_name=N'ApplicationRole', @condition_name=N'', @target_set_level_id=0
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'', @target_set_level_id=0
 
GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'xp_cmdshell must be disabled', @condition_name=N'AppRoles', @policy_category=N'', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=2, @is_enabled=True, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'xp_cmdshell must be disabled_ObjectSet'
Select @policy_id
 
GO


-- Resource Gov, I dunno


ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO

ALTER RESOURCE GOVERNOR WITH (MAX_OUTSTANDING_IO_PER_VOLUME = DEFAULT);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

-- some roles


CREATE SERVER ROLE [Endpoint-Admins]
GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER [Endpoint-Admins]
GO

-- triggers

CREATE TRIGGER [tr_MScdc_db_ddl_event] on all server for ALTER_DATABASE, DROP_DATABASE
		             as 
					set ANSI_NULLS ON
					set ANSI_PADDING ON
					set ANSI_WARNINGS ON
					set ARITHABORT ON
					set CONCAT_NULL_YIELDS_NULL ON
					set NUMERIC_ROUNDABORT OFF
					set QUOTED_IDENTIFIER ON

					declare @EventData xml, @retcode int
					set @EventData=EventData()  
					if object_id('sys.sp_MScdc_db_ddl_event' ) is not null
					begin 
						exec @retcode = sys.sp_MScdc_db_ddl_event @EventData
						if @@error <> 0 or @retcode <> 0 
						begin
							rollback tran
						end
					end		 

GO

GO
ENABLE TRIGGER [tr_MScdc_db_ddl_event] ON ALL SERVER
GO

-- spconfigure

EXEC sp_configure 'show advanced options' , 1;  RECONFIGURE WITH OVERRIDE
EXEC sp_configure 'recovery interval (min)' , 0;
EXEC sp_configure 'allow updates' , 0;
EXEC sp_configure 'user connections' , 0;
EXEC sp_configure 'locks' , 0;
EXEC sp_configure 'open objects' , 0;
EXEC sp_configure 'fill factor (%)' , 0;
EXEC sp_configure 'disallow results from triggers' , 0;
EXEC sp_configure 'nested triggers' , 1;
EXEC sp_configure 'server trigger recursion' , 1;
EXEC sp_configure 'remote access' , 1;
EXEC sp_configure 'default language' , 0;
EXEC sp_configure 'cross db ownership chaining' , 0;
EXEC sp_configure 'max worker threads' , 0;
EXEC sp_configure 'network packet size (B)' , 4096;
EXEC sp_configure 'show advanced options' , 1;
EXEC sp_configure 'remote proc trans' , 0;
EXEC sp_configure 'c2 audit mode' , 0;
EXEC sp_configure 'default full-text language' , 1033;
EXEC sp_configure 'two digit year cutoff' , 2049;
EXEC sp_configure 'index create memory (KB)' , 0;
EXEC sp_configure 'remote login timeout (s)' , 20;
EXEC sp_configure 'remote query timeout (s)' , 600;
EXEC sp_configure 'cursor threshold' , -1;
EXEC sp_configure 'user options' , 0;
EXEC sp_configure 'affinity mask' , 0;
EXEC sp_configure 'max text repl size (B)' , 65536;
EXEC sp_configure 'media retention' , 0;
EXEC sp_configure 'cost threshold for parallelism' , 5;
EXEC sp_configure 'max degree of parallelism' , 2;
EXEC sp_configure 'min memory per query (KB)' , 1024;
EXEC sp_configure 'query wait (s)' , -1;
EXEC sp_configure 'min server memory (MB)' , 0;
EXEC sp_configure 'max server memory (MB)' , 3072;
EXEC sp_configure 'query governor cost limit' , 0;
EXEC sp_configure 'lightweight pooling' , 0;
EXEC sp_configure 'scan for startup procs' , 0;
EXEC sp_configure 'affinity64 mask' , 0;
EXEC sp_configure 'affinity I/O mask' , 0;
EXEC sp_configure 'affinity64 I/O mask' , 0;
EXEC sp_configure 'transform noise words' , 0;
EXEC sp_configure 'precompute rank' , 0;
EXEC sp_configure 'PH timeout (s)' , 60;
EXEC sp_configure 'clr enabled' , 1;
EXEC sp_configure 'max full-text crawl range' , 4;
EXEC sp_configure 'ft notify bandwidth (min)' , 0;
EXEC sp_configure 'ft notify bandwidth (max)' , 100;
EXEC sp_configure 'ft crawl bandwidth (min)' , 0;
EXEC sp_configure 'ft crawl bandwidth (max)' , 100;
EXEC sp_configure 'default trace enabled' , 1;
EXEC sp_configure 'blocked process threshold (s)' , 5;
EXEC sp_configure 'in-doubt xact resolution' , 0;
EXEC sp_configure 'remote admin connections' , 0;
EXEC sp_configure 'common criteria compliance enabled' , 0;
EXEC sp_configure 'EKM provider enabled' , 0;
EXEC sp_configure 'backup compression default' , 0;
EXEC sp_configure 'optimize for ad hoc workloads' , 1;
EXEC sp_configure 'access check cache bucket count' , 0;
EXEC sp_configure 'access check cache quota' , 0;
EXEC sp_configure 'backup checksum default' , 0;
EXEC sp_configure 'automatic soft-NUMA disabled' , 0;
EXEC sp_configure 'external scripts enabled' , 0;
EXEC sp_configure 'clr strict security' , 1;
EXEC sp_configure 'Agent XPs' , 1;
EXEC sp_configure 'Database Mail XPs' , 0;
EXEC sp_configure 'Ad Hoc Distributed Queries' , 0;
EXEC sp_configure 'Replication XPs' , 0;
EXEC sp_configure 'contained database authentication' , 1;
EXEC sp_configure 'hadoop connectivity' , 0;
EXEC sp_configure 'polybase network encryption' , 1;
EXEC sp_configure 'remote data archive' , 0;
EXEC sp_configure 'allow polybase export' , 0;

-- tons of agent stuff

EXEC msdb.dbo.sp_add_operator @name=N'MSXOperator', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dbadistro@ad.local', 
		@category_name=N'[Uncategorized]'
GO

EXEC msdb.dbo.sp_add_operator @name=N'The DBA Team', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dbadistro@ad.local', 
		@category_name=N'[Uncategorized]'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823', 
		@message_id=823, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824', 
		@message_id=824, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825', 
		@message_id=825, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Long merge over dialup connection (Threshold: mergeslowrunduration)', 
		@message_id=14163, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Long merge over LAN connection (Threshold: mergefastrunduration)', 
		@message_id=14162, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Slow merge over dialup connection (Threshold: mergeslowrunspeed)', 
		@message_id=14165, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Slow merge over LAN connection (Threshold: mergefastrunspeed)', 
		@message_id=14164, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Subscription expiration (Threshold: expiration)', 
		@message_id=14160, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication Warning: Transactional replication latency (Threshold: latency)', 
		@message_id=14161, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=30, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: agent custom shutdown', 
		@message_id=20578, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: agent failure', 
		@message_id=14151, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: agent retry', 
		@message_id=14152, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: agent success', 
		@message_id=14150, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: Subscriber has failed data validation', 
		@message_id=20574, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: Subscriber has passed data validation', 
		@message_id=20575, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Replication: Subscription reinitialized after validation failure', 
		@message_id=20572, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'Replication', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 016', 
		@message_id=0, 
		@severity=16, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 017', 
		@message_id=0, 
		@severity=17, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 018', 
		@message_id=0, 
		@severity=18, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 019', 
		@message_id=0, 
		@severity=19, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 020', 
		@message_id=0, 
		@severity=20, 
		@enabled=0, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 021', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 022', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 023', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 024', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_alert @name=N'Severity 025', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_10min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'7a263d89-1223-48a1-a9f5-7b63e8c4f336'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_10min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'41a6d121-6b6c-4899-98de-acf704d14f5d'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_15min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0772cf28-c787-435e-a5ed-dda1a86df02d'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_15min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0a6139ff-a28c-48d1-8dca-47e24a87f5eb'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_30min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6da2a147-9c77-4146-9932-c640ec187d01'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_30min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c40e90de-5ecc-4b89-9df8-424dd6160a0a'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_5min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a575ffd0-98a0-4d0e-b43c-b63482fb5b00'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_5min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e9d74ad4-c27d-4d6c-8c17-439572742a97'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_60min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'fd8ac6c3-1b03-4781-8e63-e4b2fa680995'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_60min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'89b3db93-fe2a-4ae7-bc88-fa0bcca45f29'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_6h', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'66aa8120-b988-433d-a766-0d05ba17831c'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'New_CollectorSchedule_Every_6h', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=6, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6a04ee27-167a-47a1-aecb-2317d8229028'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'RunAsSQLAgentServiceStartSchedule', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100402, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a8240410-145c-459f-99c1-05df5b707256'
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'RunAsSQLAgentServiceStartSchedule', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180914, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3f66a6ae-280d-4aff-9691-c9028d272b27'
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CommandLog Cleanup', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CommandLog Cleanup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DELETE FROM [dbo].[CommandLog]
WHERE StartTime < DATEADD(dd,-30,GETDATE())', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseBackup]
@Databases = ''SYSTEM_DATABASES'',
@Directory = N''\\nas\sqlbackups'',
@BackupType = ''FULL'',
@Verify = ''Y'',
@CleanupTime = NULL,
@CheckSum = ''Y'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - DIFF', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - DIFF', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseBackup]
@Databases = ''USER_DATABASES'',
@Directory = N''\\nas\sqlbackups'',
@BackupType = ''DIFF'',
@Verify = ''Y'',
@CleanupTime = NULL,
@CheckSum = ''Y'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseBackup]
@Databases = ''USER_DATABASES'',
@Directory = N''\\nas\sqlbackups'',
@BackupType = ''FULL'',
@Verify = ''Y'',
@CleanupTime = NULL,
@CheckSum = ''Y'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - LOG', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - LOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseBackup]
@Databases = ''USER_DATABASES'',
@Directory = N''\\nas\sqlbackups'',
@BackupType = ''LOG'',
@Verify = ''Y'',
@CleanupTime = NULL,
@CheckSum = ''Y'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = ''SYSTEM_DATABASES'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseIntegrityCheck - USER_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseIntegrityCheck - USER_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = ''USER_DATABASES'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexOptimize - USER_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'IndexOptimize - USER_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[IndexOptimize]
@Databases = ''USER_DATABASES'',
@LogToTable = ''N''', 
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Output File Cleanup', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Output File Cleanup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'cmd',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sp_delete_backuphistory', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_delete_backuphistory', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CleanupDate datetime
SET @CleanupDate = DATEADD(dd,-30,GETDATE())
EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate', 
		@database_name=N'msdb',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sp_purge_jobhistory', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_purge_jobhistory', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CleanupDate datetime
SET @CleanupDate = DATEADD(dd,-30,GETDATE())
EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate', 
		@database_name=N'msdb',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO