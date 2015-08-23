DELETE  "tblVoIPRateCustomerUSApost" ;

INSERT INTO "tblVoIPRateCustomerUSA" (
 "vrcId", 
 "vdsId", 
 "usavdsId",
 "voipUserId", 
 "vrcPrice",   
 "vrcCreatedDt",
 "vrcEffectDt", 
 "vtrId",       
 "vbsId",       
 "UserBy",      
 "IsActive",    
 "cli"
)
SELECT
"vrcId", 
 "vdsId", 
 "usavdsId",
 "voipUserId", 
 "vrcPrice",   
 "vrcCreatedDt",
 "vrcEffectDt", 
 "vtrId",       
 "vbsId",       
 "UserBy",      
 "IsActive",    
 "cli"
FROM "tblVoIPRateCustomerUSApost" order by "vrcId";



DELETE "tblVoIPGatewayConfigs2" ;

INSERT INTO "tblVoIPGatewayConfigs2" (
"ID", 
 "CustID", 
 "Description", 
 "ShortDesc",   
 "Name",        
 "GroupName",   
 "Address",     
 "Prefix",      
 "SourceTranslate", 
 "Capacity",        
 "GWType",          
 "MinASR",          
 "Proxy",           
 "CodecAllow",      
 "RouteCause",      
 "GWMode",          
 "DebugLevel",      
 "UserName",        
 "AuthEnable",      
 "AcctEnable",      
 "Special",         
 "Enabled",         
 "Submited",        
 "CodecDeny",       
 "Locked",          
 "vdsType",         
 "vdsMobileCarrier",
 "vdsDescription",  
 "vdsName",         
 "IgnoreShortDesc", 
 "DialpeerShortDesc", 
 "CustIDspec",        
 "MaxCallRate",       
 "Sip"
)               
SELECT
"ID", 
 "CustID", 
 "Description", 
 "ShortDesc",   
 "Name",        
 "GroupName",   
 "Address",     
 "Prefix",      
 "SourceTranslate", 
 "Capacity",        
 "GWType",          
 "MinASR",          
 "Proxy",           
 "CodecAllow",      
 "RouteCause",      
 "GWMode",          
 "DebugLevel",      
 "UserName",        
 "AuthEnable",      
 "AcctEnable",      
 "Special",         
 "Enabled",         
 "Submited",        
 "CodecDeny",       
 "Locked",          
 "vdsType",         
 "vdsMobileCarrier",
 "vdsDescription",  
 "vdsName",         
 "IgnoreShortDesc", 
 "DialpeerShortDesc", 
 "CustIDspec",        
 "MaxCallRate",       
 "Sip"               
FROM "tblVoIPGatewayConfigs2post" ORDER BY "ID"
 ; 


DELETE  "tblVoipRateUSA" ;

INSERT INTO "tblVoipRateUSA" (
 "vrtId", 
 "vvdId", 
 "vdsId", 
 "vbsId", 
 "vdsdialcode", 
 "usavdsid",    
 "vtrid",       
 "vrtCost",     
 "order",       
 "vrtCreatedDt",
 "vrtEffectDt", 
 "UserBy",      
 "username",    
 "IsActive",    
 "cli"
 )
SELECT
 "vrtId", 
 "vvdId", 
 "vdsId", 
 "vbsId", 
 "vdsdialcode", 
 "usavdsid",    
 "vtrid",       
 "vrtCost",     
 "order",       
 "vrtCreatedDt",
 "vrtEffectDt", 
 "UserBy",      
 "username",    
 "IsActive",    
 "cli"
FROM "tblVoipRateUSApost" ORDER BY "vrtId"    
;




