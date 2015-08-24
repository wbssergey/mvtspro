USE [wiztel]
GO
/****** Object:  StoredProcedure [dbo].[spPostgresUpdateHelp3]    Script Date: 08/24/2015 19:19:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[spPostgresUpdateHelp3]
    @tablename as varchar(max)= null,
    @copy as varchar(1) = null,
    @refresh as varchar(1) = null,
    @append  as varchar(1) = null,
    @mera as varchar(2) ,
    @pkey as varchar(10) = null,
    @update  as varchar(1) = null,
    @field  as varchar(max) = null,
    @value  as varchar(max) = null,
    @filter  as varchar(max) = null,
    @debug as varchar(1) = null
   
--exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y',
--@tablename='tblVoIPRateCustomerUSA',@field='vrcPrice',@value='0.009',@pkey='28'
  --
/*
exec spPostgresUpdateHelp3 @mera='2',@update='y',
@refresh='', @tablename='tblVoIPRateCustomerUSA',@field='vrcPrice',@value='0.009',
@pkey='28'  
 
exec spPostgresUpdateHelp3 @mera='2',@update='y',
@refresh='', @tablename='tblVoIPRateCustomerUSA',@field='set "vrcPrice"=0.01 , "vbsid"=1',
@pkey='169'   


exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y', @tablename='tblVoIPRateCustomerUSA',
@field='vrcPrice',@value='0.01',@pkey='169' , @filter=' and x."cli"= &0 and x."IsActive"= &1 and 
x."ris"=&1 and x."rwcli"=&1 '    
  

exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y', 
@tablename='tblVoIPRateUSA',@field='vrtCost',@value='0.0129',@pkey='690'    

exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y', @debug='y',
@tablename='tblVoIPRateUSA',@field='Set vrtCost=0.0129', @pkey='626'    
  

*/
AS
BEGIN
DECLARE @q  as varchar(max)
DECLARE @q1  as varchar(max)

Declare @w as varchar(max)
Declare @t as varchar(max)
Declare @wfilter as varchar(max)

declare @c1 as int
declare @c2 as int
declare @k int


set @q=''
set @k=0

while @k < 7
begin

set @k=@k+1
set @c1=-1

if @k=1
begin

set @t='tblVoIPRateUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
  begin

if isnull(@filter,'') <> ''
begin
 set @wfilter=replace(@filter,'&0','0')
 set @wfilter=replace(@wfilter,'&1','1')
end

if isnull(@refresh,'') <> ''
begin

set @q1='update tblVoIPRateUSApost
set vrtcost=x.vrtcost,
    vbsid=x.vbsid,
    isactive=x.isactive,
    cli=x.cli,
    userby=x.userby,
    fax=x.fax,
    [order]=x.[order],
    ris=x.ris
from      
 tblVoIPRateUSA x
 join tblVoIPRateUSApost rcpost on  x.vrtid=rcpost.vrtid
where x.vvdid='+@pkey 


if isnull(@filter,'') <> ''
begin
 --set @wfilter=replace(@filter,'&0','0')
-- set @wfilter=replace(@wfilter,'&1','1')

  set @q1=@q1+ ' ' + @wfilter
--@filter=' and x."cli"=0 and x."IsActive"= 1 '  
 -- set @wfilter=replace(@filter,'&0','False') 
 -- set @wfilter=replace(@wfilter,'&1','True')
 -- set @wfilter=replace(@wfilter,' x.',' ')
end

print(@q1)

if isnull(@debug,'') = '' exec(@q1)

end

if isnull(@filter,'') <> ''
begin
  set @wfilter=replace(@filter,'&0','False') 
  set @wfilter=replace(@wfilter,'&1','True')
  set @wfilter=replace(@wfilter,' x.',' ')
end

if isnull(@update,'') <> '' 
begin


if charindex('set ',@field) = 0 
set @q1='update "tblVoIPRateUSApost" set "'+@field+'"='+@value+'  where "vvdId"='+@pkey 
else
set @q1='update "tblVoIPRateUSApost" '+@field+'  where "vvdId"='+@pkey 


if (isnull(@filter,'') <> '' )  set @q1=@q1+ ' ' + @wfilter

set @q1=replace(@q1,'&0','False')
set @q1=replace(@q1,'&1','True')

set @q1=replace(@q1,'''','''''')
set @q1=' SELECT 1 from OPENQUERY(pgslave,'''+ @q1+''' ) ' 

print(@q1)

if isnull(@debug,'') = '' exec(@q1)


set @q1=replace(@q1,'USApost','USA')


print(@q1)

if isnull(@debug,'') = '' exec(@q1)

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
@field7='userId', @field8='@Value', @field9='&RateChanged',
@field10='&CustomerNotified',
 @count=100,@mcount=300000

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
@field6='@createdBy', @field7='userId',
 @count=100,@mcount=300000

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


set @q1=' update tblVoIPRateCustomerUSApost
set vrcprice=x.vrcprice,
    vbsid=x.vbsid,
    isactive=x.isactive,
    cli=x.cli,
    userby=x.userby
from      
 tblVoIPRateCustomerUSA x
 join tblVoIPRateCustomerUSApost rcpost on  x.vrcid=rcpost.vrcid
where x.voipuserid=' + @pkey 


if isnull(@filter,'') <> ''
begin
 set @wfilter=replace(@filter,'&0','0')
 set @wfilter=replace(@wfilter,'&1','1')

  set @q1=@q1+ ' ' + @wfilter
--@filter=' and x."cli"=0 and x."IsActive"= 1 '  
  set @wfilter=replace(@filter,'&0','False') 
  set @wfilter=replace(@wfilter,'&1','True')
  set @wfilter=replace(@wfilter,' x.',' ')
end

print(@q1)

exec(@q1)

end

if (isnull(@update,'') <> '') 
begin

if charindex('set ',@field) = 0 
set @q1='update "tblVoIPRateCustomerUSApost" set "'+@field+'"='+@value+'  where "voipUserId"='+@pkey 
else
set @q1='update "tblVoIPRateCustomerUSApost" '+@field+'  where "voipUserId"='+@pkey 


if (isnull(@filter,'') <> '' )  set @q1=@q1+ ' ' + @wfilter

set @q1=replace(@q1,'&0','False')
set @q1=replace(@q1,'&1','True')

set @q1=replace(@q1,'''','''''')
set @q1=' SELECT 1 from OPENQUERY(pgslave,'''+ @q1+''' ) ' 

print(@q1)

exec(@q1)

set @q1=replace(@q1,'USApost','USA')

print(@q1)

exec(@q1)

end


end
end

if @k=5
begin
set @t='tblVoIPDestinationUSA'
if lower(isnull(@tablename,@t)) = lower (@t)
begin
set @c1=(select count(*) mc from tblVoIPDestinationUSA)
set @c2=(select * from openquery(pgslave,'select count(*) as mc from  "tblVoIPDestinationUSA" ' ) )
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

end

--delete npapostgres
--insert into npapostgres (npa, location, country) select npa, location, country from npa 
--where isnull(location,'') <> '' and isnull(country,'') <> '' and country='US'

--select 0 as r;

END


  


















