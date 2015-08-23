CREATE OR REPLACE FUNCTION  spRoutingSrcCliInter(
    varchar(50),  varchar(50), varchar(50),varchar(1),varchar(4)) RETURNS  SETOF rtab

AS $$
DECLARE
        cdrUserName ALIAS FOR $1;
        cdrDstNum ALIAS FOR $2;
        wnumber varchar(50);
        prefix varchar(3);
        r rtab%rowtype;
        l integer;
        znumber varchar(50);
        wstate varchar(20);
        zstate varchar(20);
        f809 varchar(50);
        mera ALIAS for $4;
        cdrSrcNum varchar(50);
        q text; 
        post ALIAS FOR $5;
BEGIN
-- select * from  spRoutingSrcCliInter('trd_cust','1212398','121239899','2','post');
-- ./qroute.sh 'trd_cust' '1212398' '121239899' '2' 'post'
 wnumber=$2;
 prefix = '';
 cdrSrcNum =$3;

if lpad(wnumber,1) <> '1' then

prefix = lpad(wnumber,3);
wnumber=substr(wnumber,3);

end if;

wnumber=lpad(wnumber,7);

znumber=cdrSrcNum;

if lpad(znumber,1) <> '1' then
znumber='1' || znumber;
end if;


wstate=(select isnull(fngetusstate(wnumber),''));

zstate=(select isnull(fngetusstate(znumber),''));



f809 = '0';

if ( wstate <> '' and  zstate <> ''   and wstate=zstate ) then

cdrSrcNum = '1809' || substr(znumber,4);

f809 = cdrSrcNum;

end if;

----create table rtab ( c text );

delete from rtab;

q='insert into rtab ("f1") select (cast(gw."Name" as varchar(50)) ||'';''|| cast(gw."Address" as varchar(20))
||'':''||
case when gw."Sip" = True then ''5060'' else ''1720''   end
||'';''||case when((x."vrcPrice" >= x.effvrtcost) and (x."IsActive" = True)) then ''0'' else ''1'' end
||'';'''''||f809|| ''' ) as f1
 from
(
select   ur."x1CustId", ur."userName", vr."vvdId",vr."order",
vr."vrtCost", vr."IsActive",

case when ((rc."vbsId"=1) and (vr."vbsId"=3)) then vr."vrtCost" * 1.2 else vr."vrtCost" end as effvrtcost,
vr."vbsId" as vbi, rc."vrcPrice", rc."vbsId" as cbi  from
"tblVoIPRateCustomerUSA'||post||'" rc
join "tblVoIPRateUSA'||post||'" vr on vr.usavdsid=rc."usavdsId"
join "tblVoIPUserCustomer" uc on uc."Id"=rc."voipUserId"
join "tblVoIPUserRoute" ur on ur."voipUserVendId"=vr."vvdId"
join "tblVoIPDestinationUSA" dsus on dsus."Id"=vr.usavdsid
join "tblVoIPDialPeerConfigs'||mera||post||'"  dp on dp."CustID"=uc."x1CustId"
where uc."userName"='''||cdrUserName|| ''' and vr.vdsdialcode=
'''||wnumber||''' and dsus."vdsIsActive"=True
and (case when
(case when isnull(dp.usecli,False)=True  then isnull(dp.cli,False) else rc.cli end ) = False then True else case when
(case when isnull(dp.usecli,False)=True  then isnull(dp.cli,False) else rc.cli end ) = vr.cli then True else False end end ) = True
and (case when  ('''||mera||''' in (''2'')) and ('''||cdrSrcNum||''' in ('''')) and ('''||cdrUserName||''' in (''trd_cust''))
then case when vr."vvdId" = 626 then True else False end else True end) = True
and isnull(dp."External",False)=True and isnull(dp."Enabled",False)=True
 and case when '''||prefix ||''' = '''' then
case when dp."UseAddPrefix" = False and dp."UseTestPrefix" = False then True else False end else
case when (dp."AddPrefix" = '''' and dp."UseAddPrefix"=True)
or (dp."TestPrefix" = '''||prefix||''' and dp."UseTestPrefix"=True)
then True else False end end = True
group by   ur."x1CustId",ur."userName", vr."vvdId",vr."order", vr."vrtCost", vr."IsActive", vr."vbsId", rc."vbsId", rc."vrcPrice"
) x
join "tblVoIPBillingStructure" vbs on vbs."vbsID"=x.vbi
join "tblVoIPBillingStructure" cbs on cbs."vbsID"=x.cbi
join "tblVoIPGatewayConfigs'||mera||post||'" gw
on x."x1CustId"=gw."CustID" where gw."GWMode"=2 and gw."Enabled"=True
and gw."vdsType"=''Continental'' and gw."UserName"=x."userName"
order by x."order" desc, x.effvrtcost asc, x.vbi';


execute q;

for r in select * from rtab
loop
  return next r;
end loop;

return;


END;$$ LANGUAGE 'plpgsql';
