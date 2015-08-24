USE [wiztel]
GO

/****** Object:  StoredProcedure [dbo].[spPostgresInsertHelp3]    Script Date: 08/24/2015 19:21:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spPostgresInsertHelp3]
    @tablename as varchar(max)= null,
    @copy as varchar(1) = null,
    @refresh as varchar(1) = null,
    @append  as varchar(1) = null,
    @mera as varchar(2) ,
    @appendpost as varchar(1) = null,
    @pkey  as varchar(10) = null
--
--exec spPostgresInsertHelp3 @mera='2',@copy='',@refresh='',@tablename='tblVoIPGatewayConfigs'
--exec spPostgresInsertHelp3 @mera='2',@copy='y',@refresh='',@tablename='tblVoIPDialPeerConfigs'

--exec spPostgresInsertHelp3  @mera='2',@appendpost='y'
--exec spPostgresInsertHelp3 @mera='2',@copy='',@refresh='',@tablename='tblVoipOffNetUsa'

--exec spPostgresInsertHelp3 @mera='2',@copy='',@refresh='',@tablename='tblVoipCustBasedActiveUSA'
--exec spPostgresInsertHelp3 @mera='2',@copy='',@refresh='',@tablename='tblVoipCustBasedOrderUSA'
--exec spPostgresInsertHelp3 @mera='2',@copy='',@refresh='',@tablename='tblVoipAlterRateUSA'
--exec spPostgresInsertHelp3 @mera='2',@copy='y',@refresh='y',@tablename='tblVoipForceDeleteUSA'
/*
exec spPostgresInsertHelp3 @tablename='tblVoIPRateUSA', @refresh='' , @append='', @mera='2'    
 , @appendpost='y' 
*/
AS
BEGIN
DECLARE @q  as varchar(max)
DECLARE @q1  as varchar(max)

Declare @w as varchar(max)
Declare @t as varchar(max)

declare @c1 as int
declare @c2 as int
declare @k int


set @q=''
set @k=0

while @k < 12
begin

set @k=@k+1
set @c1=-1

if @k=1
begin
set @t='tblVoIPRateUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
  begin

if isnull(@refresh,'') <> ''
begin

delete tblVoipRateUSApost

INSERT INTO [wiztel].[dbo].[tblVoipRateUSApost]
           ([vrtId]
           ,[vvdId]
           ,[vdsId]
           ,[vbsId]
           ,[vdsdialcode]
           ,[usavdsid]
           ,[vtrid]
           ,[vrtCost]
           ,[order]
           ,[vrtCreatedDt]
           ,[vrtEffectDt]
           ,[UserBy]
           ,[username]
           ,[IsActive]
           ,[cli]
           ,[fax]
           ,[ris])
                
select * from tblVoipRateUSA order by vrtid

end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin


if isnull(@pkey,'') = '' 
begin
   set @q1='declare @x as int; set @x=(select 1 from openquery(pgslave,''delete from "tblVoIPRateUSApost"'' ) );';
end
else
begin
   set @q1='declare @x as int; set @x=(select 1 from openquery(pgslave,''delete from "tblVoIPRateUSApost" '
   set @q1=@q1+ ' where "vvdId"='''+@pkey+''' ) )';
end;

exec(@q1)

--set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPRateUSApost"' ) )

end


exec spPostgresInsertByblocks2 @tablename='tblVoIPRateUSApost',

--exec spPostgresInsertByCountbyblocks2 @tablename='tblVoIPRateUSApost',
--@bycount=@pkey,
@pkey='vrtId',
  @field1='vvdId',
 @field2='vdsId', @field3='vbsId', @field4='@vdsdialcode', @field5='usavdsid', @field6='vtrid', 
@field7='vrtCost', @field8='[order]', @field9='@vrtCreatedDt',
@field10='@vrtEffectDt', @field11='&IsActive', @field12='&cli',
@field13='&fax',@field14='&ris',
 @count=30,@mcount=35700

   end

if isnull(@appendpost,'') <> ''
begin
/*
declare @c2 int
DECLARE @q  as varchar(max)
DECLARE @q1  as varchar(max)
*/
set @c2=(select maxid from OPENQUERY(pgslave,
' select max("vrtId") as maxid from "tblVoIPRateUSA" '
)
)


set @q1='insert into "tblVoIPRateUSA"
( "vvdId"
 ,"vdsId"
 ,"vbsId"
 ,"vdsdialcode"
 ,"usavdsid"
 ,"vtrid"
 ,"vrtCost"
 ,"order"
 ,"vrtCreatedDt"
 ,"vrtEffectDt"
 ,"IsActive"
 ,"cli"
 ,"fax"
 ,"ris")
select 
"vvdId"
,"vdsId"
,"vbsId"
,"vdsdialcode"
,"usavdsid"
,"vtrid"
,"vrtCost"
,"order"
,"vrtCreatedDt"
,"vrtEffectDt"
,"IsActive"
,"cli"
,"fax"
,"ris"
from "tblVoIPRateUSApost" 
where "vrtId" > ' + cast(@c2 as varchar)+ ' order by "vrtId" '

select @q1 as appendpgsql

set @q1 = null

end


  end
end


if @k=2
begin
set @t='tblVoIPUserCustomer'
if lower(isnull(@tablename,@t)) = lower (@t)
  begin

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPUserCustomer" ' ) )
end


exec spPostgresInsertbyblocks2 @tablename='tblVoIPUserCustomer',
@pkey='Id',
  @field1='x1CustId',
 @field2='@userName', @field3='defaultBillingIncrement', @field4='@description', 
@field5='@createdDate', @field6='@createdby', 
 @field7='@Value', @field8='&RateChanged',
 @count=1000,@mcount=300000

end
  end
end

if @k=3
begin
set @t='tblVoIPUserRoute'
if lower(isnull(@tablename,@t)) = lower (@t)
  begin
if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPUserRoute" ' ) )
end

exec spPostgresInsertbyblocks2 @tablename='tblVoIPUserRoute',
@pkey='voipUserVendId',
  @field1='x1CustId',
 @field2='@userName',  @field3='vbsId', 
@field4='@description', @field5='@createdDate', 
@field6='@createdBy', --@field7='userId',
 @count=1000,@mcount=300000

  end
end
end
if @k=4
begin
set @t='tblVoIPRateCustomerUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin

delete tblVoIPRateCustomerUSApost

INSERT INTO [wiztel].[dbo].[tblVoIPRateCustomerUSApost]
           ([vrcId]
           ,[vdsId]
           ,[usavdsId]
           ,[voipUserId]
           ,[vrcPrice]
           ,[vrcCreatedDt]
           ,[vrcEffectDt]
           ,[vtrId]
           ,[vbsId]
           ,[UserBy]
           ,[IsActive]
           ,[cli]
           ,[ris]
           ,[rwcli]
)
   
select
           [vrcId]
           ,[vdsId]
           ,[usavdsId]
           ,[voipUserId]
           ,[vrcPrice]
           ,[vrcCreatedDt]
           ,[vrcEffectDt]
           ,[vtrId]
           ,[vbsId]
           ,[UserBy]
           ,[IsActive]
           ,[cli]
           ,[ris]
           ,[rwcli]
   from 

 tblVoIPRateCustomerUSA order by vrcid

end


if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
select @c2=(select 1 from OPENQUERY(pgslave,' delete  from "tblVoIPRateCustomerUSApost"  '))
end

exec spPostgresInsertbyblocks2 @tablename='tblVoIPRateCustomerUSApost',
@pkey='vrcId',
  @field1='vdsId',
 @field2='usavdsId', @field3='voipUserId', @field4='vrcPrice', @field5='@vrcCreatedDt', @field6='@vrcEffectDt', 
@field7='vtrId', @field8='vbsId', @field9='&IsActive', @field10='&cli',
@field11='&ris',@field12='&rwcli',
@count=90,@mcount=3000000

end

if isnull(@appendpost,'') <> ''
begin
/*
declare @c2 int
DECLARE @q  as varchar(max)
DECLARE @q1  as varchar(max)
*/
set @c2=(select maxid from OPENQUERY(pgslave,
' select max("vrcId") as maxid from "tblVoIPRateCustomerUSA" '
)
)

set @q1='insert into "tblVoIPRateCustomerUSA"
(
 "vrcId"
,"vdsId"
,"usavdsId"
,"voipUserId"
,"vrcPrice"
,"vrcCreatedDt"
,"vrcEffectDt"
,"vtrId"
,"vbsId"
,"UserBy"
,"IsActive"
,"cli" 
,"ris"
,"rwcli"
) 
select 
 "vrcId"
,"vdsId"
,"usavdsId"
,"voipUserId"
,"vrcPrice"
,"vrcCreatedDt"
,"vrcEffectDt"
,"vtrId"
,"vbsId"
,"UserBy"
,"IsActive"
,"cli"
,"ris"
,"rwcli"
from "tblVoIPRateCustomerUSApost" 
where "vrcId" > ' + cast(@c2 as varchar)+ ' order by "vrcId" '

--set @appendpostsql = @q1

select @q1 as appendpgsql

set @q1 = null

end

end
end

if @k=5
begin
set @t='tblVoIPDestinationUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
begin
if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
select @c2=(select 1 from OPENQUERY(pgslave,' delete  from "tblVoIPDestinationUSA"  '))
end


exec spPostgresInsertbyblocks2 @tablename='tblVoIPDestinationUSA',
@pkey='Id',
  @field1='vdsId',
 @field2='@vdsGroupDialCode',  
@field3='@vdsDialcode', 
@field4='@vdsCreatedDt',
@field5='&vdsIsActive',
@field6='@state',
@count=90,@mcount=3000000
 

end

end
end

if @k=6

begin
set @t='tblVoIPGatewayConfigs' 
if lower(isnull(@tablename,@t)) = lower (@t)
begin
if isnull(@refresh,'') <> ''
begin

set @q1='delete tblVoIPGatewayConfigs' +@mera+'post'
--print(@q1)
exec(@q1)

set @q1='INSERT INTO tblVoIPGatewayConfigs'+@mera+'post'
set @q1=@q1+'( [ID] '
set @q1=@q1+' ,[CustID] '
set @q1=@q1+' ,[Name] '
set @q1=@q1+' ,[Address] '
set @q1=@q1+' ,[GWMode] '
set @q1=@q1+'  ,[Enabled] '
set @q1=@q1+'  ,[vdsType] '
set @q1=@q1+'  ,[Username] '
set @q1=@q1+'  ,[Sip]) '

set @q1=@q1+' select [ID] '
set @q1=@q1+' ,[CustID] '
set @q1=@q1+' ,[Name] '
set @q1=@q1+' ,[Address] '
set @q1=@q1+' ,[GWMode] '
set @q1=@q1+'  ,[Enabled] '
set @q1=@q1+'  ,[vdsType] '
set @q1=@q1+'  ,[Username] '
set @q1=@q1+'  ,[Sip] '
set @q1=@q1+ ' from tblVoIPGatewayConfigs'+@mera+' where gwmode=2 order by  id '
--print(@q1)

exec(@q1)


end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPGatewayConfigs2post" ' ) )
end

set @q1='tblVoIPGatewayConfigs'+@mera+'post';

exec spPostgresInsertbyblocks2 @tablename=@q1,
@pkey='ID',
  @field1='CustID',
 @field2='@Name', @field3='@Address', @field4='GWMode', @field5='@UserName', --@field6='@Special', 
@field7='&Enabled', @field8='@vdsType', @field9='&Sip', @count=50,@mcount=1000

end
end
end

if @k=7
begin
set @t='tblVoIPDialPeerConfigs'

if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin 

delete tblVoIPDialPeerConfigs2post

insert into tblVoIPDialPeerConfigs2post
(
[ID] ,	[CustID] ,
	[Enabled]  ,
	[UseTestPrefix] ,
	[TestPrefix] ,
	[UseAddPrefix],
	[AddPrefix] ,
	[External] ,
	[cli] ,
	[usecli]
)

select
[ID] ,	[CustID] ,
	[Enabled]  ,
	[UseTestPrefix] ,
	[TestPrefix] ,
	[UseAddPrefix],
	[AddPrefix] ,
	[External] ,
	[cli] ,
	[usecli]

from tblVoIPDialPeerConfigs2 order by id

end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPDialPeerConfigs2post" ' ) )
end

set @q1='tblVoIPDialPeerConfigs'+@mera+'post';

exec spPostgresInsertbyblocks2 @tablename=@q1,
@pkey='ID',
  @field1='CustID',
 @field2='&Enabled', @field3='&UseTestPrefix', @field4='@TestPrefix', @field5='&UseAddPrefix',
@field6='@AddPrefix', 
@field7='&External', @field8='&cli', @field9='&usecli', @count=50,@mcount=10000
end
end
end

if @k=8
begin
set @t='tblVoipOffNetUsa'

if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin 
print @t
end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoipOffNetUsa" ' ) )
end

exec spPostgresInsertbyblocks2 @tablename=@t,
@pkey='ID',
  @field1='CustId',
 @field2='@MeraVersion', @field3='@Prefix', @field4='Price', @field5='@CreatedDt',
@field6='@UserBy' ,
 @count=50,@mcount=10000
end --@copy or @append
end --@lower
end  -- @k=8


if @k=9
begin
set @t='tblVoipCustBasedActiveUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin 
print @t
end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoipCustBasedActiveUSA" ' ) )
end

exec spPostgresInsertbyblocks2 @tablename=@t,
@pkey='ID',
  @field1='voipUserId',
 @field2='vvdId', @field3='&IsActive',  @field4='@CreatedDt',
@field5='@UserBy' ,
 @count=50,@mcount=10000
end --@copy or @append
end --@lower
end  -- @k=9

if @k=10
begin
set @t='tblVoipCustBasedOrderUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin 
print @t
end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoipCustBasedOrderUSA" ' ) )
end

exec spPostgresInsertbyblocks2 @tablename=@t,
@pkey='ID',
  @field1='voipUserId',
 @field2='vvdId', @field3='[order]',  @field4='@CreatedDt',
@field5='@UserBy' ,
 @count=50,@mcount=10000
end --@copy or @append
end --@lower
end  -- @k=10


---22

if @k=11
begin
set @t='tblVoIPAlterRateUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
  begin
print(@t)
if isnull(@refresh,'') <> ''
begin

delete tblVoipAlterRateUSApost

INSERT INTO [wiztel].[dbo].[tblVoipAlterRateUSApost]
           ([vrtId]
           ,[vvdId]
           ,[vdsId]
           ,[vbsId]
           ,[vdsdialcode]
           ,[usavdsid]
           ,[vtrid]
           ,[vrtCost]
           ,[order]
           ,[vrtCreatedDt]
           ,[vrtEffectDt]
           ,[UserBy]
           ,[username]
           ,[IsActive]
           ,[cli]
           ,[fax]
           ,[ris])
                
select * from tblVoipAlterRateUSA order by vrtid

end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin 

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoIPAlterRateUSApost" ' ) )
end

exec spPostgresInsertbyblocks2 @tablename='tblVoIPAlterRateUSApost',
@pkey='vrtId',
  @field1='vvdId',
 @field2='vdsId', @field3='vbsId', @field4='@vdsdialcode', @field5='usavdsid', @field6='vtrid', 
@field7='vrtCost', @field8='[order]', @field9='@vrtCreatedDt',
@field10='@vrtEffectDt', @field11='&IsActive', @field12='&cli',
@field13='&fax',@field14='&ris',
 @count=30,@mcount=35700

   end
  end
end --@k=11

if @k=12
begin
set @t='tblVoipForceDeleteUSA'

if lower(isnull(@tablename,@t)) = lower (@t)
begin

if isnull(@refresh,'') <> ''
begin 
print @t
end

if (isnull(@copy,'') <> '') or (isnull(@append,'') <> '')
begin

if isnull(@append,'') = ''
begin
set @c2=(select 1 from openquery(pgslave,'delete from "tblVoipForceDeleteUSA" ' ) )
end
	
exec spPostgresInsertbyblocks2 @tablename=@t,
@pkey='ID',
 @field2='@MeraVersion', 
@field5='@CreatedDt',
@field6='@UserBy' ,
@field3='voipUserId', 
@field4='&IsActive', 
 @count=50,@mcount=10000
end --@copy or @append
end --@lower
end  -- @k=12


---22
end --@k<9


END




























GO


