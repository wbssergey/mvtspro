CREATE PROCEDURE "spRoutingMera2postgres"
   @cdrUserName varchar(50),
	@cdrDstNum varchar(50)
    
AS
BEGIN

 declare @wnumber varchar(50);
 declare @l int;

set @wnumber=@cdrDstNum
 
if left(@cdrDstNum,1) <> '1' 
begin
set @l =len(@cdrDstNum)
set @wnumber=right(@cdrDstNum,@l-3)
end

set @wnumber=left(@wnumber,7)

select (cast(gw.[name] as varchar(50)) + ';'+cast(gw.address as varchar(20))
+':'+
case when charindex('port=',cast(gw.special as varchar(max)))=0 then '1720' else 
 substring(gw.special,charindex('port=',cast(gw.special as varchar(max)))+5,4) end 
+';'+case when((x.vrcprice >= x.effvrtcost) and (x.isactive = 1)) then '0' else '1' end
) as f1 , 
x.x1custid,x.username, x.vvdid,[order],vrtcost, effvrtcost,
cast(vbs.vbsinitialminsecspercall as varchar) + '/' + cast(vbs.vbsincrements as varchar) as vbi,
vrcprice,
cast(cbs.vbsinitialminsecspercall as varchar) + '/' + cast(cbs.vbsincrements as varchar) as cbi,
x.isactive,
case when((x.vrcprice >= x.effvrtcost) and (x.isactive = 1)) then 0 else 1 end disabled,
cast(gw.address as varchar(20)) ip,
case when charindex('port=',cast(gw.special as varchar(max)))=0 then 1720 else 
 substring(special,charindex('port=',cast(gw.special as varchar(max)))+5,4) end port
 from
(
select   uc.x1custid, ur.username, vr.vvdid,vr.[order],
vr.vrtcost, vr.isactive,
case when ((rc.vbsid=1) and (vr.vbsid=3)) then vr.vrtcost * 1.2 else vr.vrtcost end as effvrtcost, 
vr.vbsid as vbi, rc.vrcprice, rc.vbsid as cbi  from 
tblvoipratecustomerusa rc
join tblvoiprateusa vr on vr.usavdsid=rc.usavdsid
join tblvoipusercustomer uc on uc.id=rc.voipuserid 
join tblvoipuserroute ur on ur.voipuservendid=vr.vvdid
join tblvoipdestinationusa dsus on dsus.id=vr.usavdsid
where uc.username=@cdrUserName and vr.vdsdialcode=@wnumber and dsus.vdsisactive=1
and (case when rc.cli = 0 then 1 else case when rc.cli=vr.cli then 1 else 0 end end ) = 1
group by   uc.x1custid,ur.username, vr.vvdid,vr.[order], vr.vrtcost, vr.isactive, vr.vbsid, rc.vbsid, rc.vrcprice
) x
join tblvoipbillingstructure vbs on vbs.vbsid=x.vbi 
join tblvoipbillingstructure cbs on cbs.vbsid=x.cbi 
join tblvoipgatewayconfigs2 gw
on x.x1custid=gw.custid where gw.gwmode=2 and gw.enabled=1
and gw.vdstype='Continental' and gw.UserName=x.username
order by x.[order] desc, x.effvrtcost asc, x.vbi


  
END
