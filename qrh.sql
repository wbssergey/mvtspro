 
select (cast(gw."Name" as varchar(50)) || ';' || cast(gw."Address" as varchar(20))
||':'||
case when gw."Sip" = '1' then '5060' else '1720' end 
||';'||case when((x."vrcPrice" >= x.effvrtcost) and (x."IsActive" = '1')) then '0' else '1' end
) as f1  
 from
(
select   ur."x1CustId", ur."userName", vr."vvdId",vr."order",
vr."vrtCost", vr."IsActive",
case when ((rc."vbsId"=1) and (vr."vbsId"=3)) then vr."vrtCost" * 1.2 else vr."vrtCost" end as effvrtcost, 
vr."vbsId" as vbi, rc."vrcPrice", rc."vbsId" as cbi  from 
"tblVoIPRateCustomerUSA" rc
join "tblVoipRateUSA" vr on vr.usavdsid=rc."usavdsId"
join "tblVoIPUserCustomer" uc on uc."Id"=rc."voipUserId" 
join "tblVoIPUserRoute" ur on ur."voipUserVendId"=vr."vvdId"
join "tblVoIPDestinationUSA" dsus on dsus."Id"=vr.usavdsid
where uc."userName"='med_cust' and vr.vdsdialcode='1786443' and dsus."vdsIsActive"='1'
and (case when rc.cli = '0' then 1 else case when rc.cli=vr.cli then 1 else 0 end end ) = 1
group by   ur."x1CustId",ur."userName", vr."vvdId",vr."order", vr."vrtCost", vr."IsActive", vr."vbsId", rc."vbsId", rc."vrcPrice"
) x
join "tblVoIPBillingStructure" vbs on vbs."vbsID"=x.vbi 
join "tblVoIPBillingStructure" cbs on cbs."vbsID"=x.cbi 
join "tblVoIPGatewayConfigs2" gw
on x."x1CustId"=gw."CustID" where gw."GWMode"=2 and gw."Enabled"='1'
and gw."vdsType"='Continental' and gw."UserName"=x."userName"
order by x."order" desc, x.effvrtcost asc, x.vbi
;  


