
DROP TABLE "tblVoIPGatewayConfigs2post"  ;

CREATE TABLE "tblVoIPGatewayConfigs2post" ( 

"ID"                 numeric(10,0)         ,
"CustID"             numeric(10,0)         ,
"Description"        character (50) ,
"ShortDesc"          character (50) ,
"Name"               character (50) ,
"GroupName"          character (50) ,
"Address"            text                  ,
"Prefix"             character (15) ,
"SourceTranslate"    character (15) ,
"Capacity"           numeric(5,0)          ,
"GWType"             numeric(5,0)          ,
"MinASR"             numeric(5,0)          ,
"Proxy"              numeric(10,0)         ,
"CodecAllow"         text                  ,
"RouteCause"         character (10) ,
"GWMode"             numeric(10,0)         ,
"DebugLevel"         numeric(5,0)          ,
"UserName"           character (50) ,
"AuthEnable"         numeric(5,0)          ,
"AcctEnable"         numeric(5,0)          ,
"Special"            text                  ,
"Enabled"            boolean               ,
"Submited"           boolean               ,
"CodecDeny"          text                  ,
"Locked"             boolean               ,
"vdsType"            character (18) ,
"vdsMobileCarrier"   character (50) ,
"vdsDescription"     character(200)       ,
"vdsName"            character(50)        ,
"IgnoreShortDesc"    boolean               ,
"DialpeerShortDesc"  character (50) ,
"CustIDspec"         numeric(10,0)         ,
"MaxCallRate"        numeric(5,0)          ,
"Sip"                boolean ) ;



CREATE UNIQUE INDEX "PK_tblVoIPGatewayConfigs2post" on "tblVoIPGatewayConfigs2post" ("ID") ;

ALTER TABLE "tblVoIPGatewayConfigs2post" OWNER TO wiztel ;

