/****** Object:  LinkedServer [PGSLAVE]    Script Date: 08/24/2015 19:25:37 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'PGSLAVE', @srvproduct=N'PGNP', @provider=N'PGNP.1', @datasrc=N'########', @provstr=N'PORT=5432;CNV_SPECIAL_FLTVAL=ON;SQLSERVER=2008;', @catalog=N'mvtsradius'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'PGSLAVE',@useself=N'False',@locallogin=NULL,@rmtuser=N'mvts',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'PGSLAVE', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

