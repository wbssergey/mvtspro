use [wiztel]
exec sp_replicationdboption @dbname = N'wiztel', @optname = N'publish', @value = N'true'
GO
-- Adding the snapshot publication
use [wiztel]
exec sp_addpublication @publication = N'pgnpratessnap', @description = N'Snapshot publication of database ''wiztel'' from Publisher ''DOLPHIN''.', @sync_method = N'native', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'snapshot', @status = N'active', @independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1
GO


exec sp_addpublication_snapshot @publication = N'pgnpratessnap', @frequency_type = 1, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1


use [wiztel]
exec sp_addarticle @publication = N'pgnpratessnap', @article = N'tblVoIPRateCustomerUSApost', @source_owner = N'dbo', @source_object = N'tblVoIPRateCustomerUSApost', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'none', @schema_option = 0x000000000803509D, @identityrangemanagementoption = N'manual', @destination_table = N'tblVoIPRateCustomerUSApost', @destination_owner = N'dbo', @vertical_partition = N'false'
GO




use [wiztel]
exec sp_addarticle @publication = N'pgnpratessnap', @article = N'tblVoipRateUSApost', @source_owner = N'dbo', @source_object = N'tblVoipRateUSApost', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'none', @schema_option = 0x000000000803509D, @identityrangemanagementoption = N'manual', @destination_table = N'tblVoipRateUSApost', @destination_owner = N'dbo', @vertical_partition = N'false'
GO




use [wiztel]
exec sp_changepublication N'pgnpratessnap', N'enabled_for_het_sub', 
N'true', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO

use [wiztel]
exec sp_addsubscription @publication = N'pgnpratessnap', 
@subscriber = N'72.15.129.11', @destination_db = N'wiztel', 
@subscription_type = N'Push', 
@sync_type = N'automatic', 
@article = N'all', @update_mode = N'read only', 
@subscriber_type = 3


use [wiztel]
exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_login', @value=N'wiztel'

exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_password', @value=N'*****'

exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_location', @value=N'wiztel'

exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_datasource', @value=N'72.15.129.11'

exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_provider', @value=N'PGNP'

exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_providerstring', 
@value=N'LOWERCASESCHEMA=OFF;'



exec sp_changesubscription @publication = N'pgnpratessnap', @subscriber = N'72.15.129.11',
@destination_db = N'wiztel', @article = N'all',
 @property=N'subscriber_catalog', @value=N'wiztel'



exec sp_addpushsubscription_agent @publication = N'pgnpratessnap', 
@subscriber = N'72.15.129.11', @subscriber_db = N'wiztel',
 @job_login = null, @job_password = null, @subscriber_security_mode = 0, 
@subscriber_login = N'*****', @subscriber_password =N'*****', 
@subscriber_provider = N'PGNP', 
@subscriber_datasrc = N'72.15.129.11', @frequency_type = 64, 
@frequency_interval = 0, @frequency_relative_interval = 0, 
@frequency_recurrence_factor = 0, @frequency_subday = 0, 
@frequency_subday_interval = 0, @active_start_time_of_day = 0, 
@active_end_time_of_day = 235959, @active_start_date = 20080605,
 @active_end_date = 99991231, @enabled_for_syncmgr = N'False',
 @dts_package_location = N'Distributor'
GO




