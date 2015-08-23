 
select rc."voipUserId",rc.cli as clia, vr.cli as clib,  case when rc.cli=vr.cli then '1' else '0' end  as zz ,
case when rc.cli = '0' then '1' else case when rc.cli=vr.cli then '1' else '0' end end as xx,
 ur."userName", vr."vvdId"
,vr."vrtCost",  
 rc."vrcPrice"  from 
"tblVoIPRateCustomerUSA" rc
join "tblVoipRateUSA" vr on vr.usavdsid=rc."usavdsId"
join "tblVoIPUserCustomer" uc on uc."Id"=rc."voipUserId" 
join "tblVoIPUserRoute" ur on ur."voipUserVendId"=vr."vvdId"
join "tblVoIPDestinationUSA" dsus on dsus."Id"=vr.usavdsid
where uc."userName"='trd_cust' and vr.vdsdialcode='1786443' and dsus."vdsIsActive"='1'
and (case when rc.cli = '1' then 1 else case when rc.cli<>vr.cli then 1 else 0 end end ) = 1
group by rc."voipUserId",  ur."x1CustId",ur."userName", vr."vvdId", vr."vrtCost",  vr."vbsId", rc."vbsId", rc."vrcPrice" ,rc.cli, vr.cli
;  


