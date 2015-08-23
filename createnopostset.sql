

drop table "tblVoIPRateCustomerUSA" ;
drop table "tblVoIPGatewayConfigs2" ;
drop table "tblVoIPDialPeerConfigs2" ;
drop table "tblVoIPRateUSA";
drop table "tblVoipOffNetUsa" ;

drop table "tblVoipCustBasedActiveUSA";

drop table "tblVoIPAlterRateUSA";

drop table "tblVoipCustBasedOrderUSA";

create table "tblVoipCustBasedActiveUSA"
(
"ID"          numeric(10,0)           not null,
"voipUserId"  numeric(10,0)           not null,
 "vvdId"       numeric(10,0)          not null,
 "IsActive"    boolean                not null,
 "CreatedDt"   timestamp without time zone not null , 
 "UserBy"      character varying(80)   
);

CREATE  UNIQUE  INDEX  "PK_tblVoipCustBasedActiveUSA" ON "tblVoipCustBasedActiveUSA"
("ID");

alter table "tblVoipCustBasedActiveUSA" owner to wiztel ;


create table "tblVoipCustBasedOrderUSA"
(
"ID"          numeric(10,0)           not null,
"voipUserId"  numeric(10,0)           not null,
 "vvdId"      numeric(10,0)          not null,
 "order"      numeric(10,0)          not null,
 "CreatedDt"   timestamp without time zone not null ,
 "UserBy"      character varying(80)
);

CREATE  UNIQUE  INDEX  "PK_tblVoipCustBasedOrderUSA" ON "tblVoipCustBasedOrderUSA"
("ID");

alter table "tblVoipCustBasedOrderUSA" owner to wiztel ;

create table "tblVoIPRateCustomerUSA"
(
 "vrcId" numeric(10,0)     not null,
 "vdsId"  numeric(10,0)    not null,
 "usavdsId"  numeric(10,0) not null,
 "voipUserId"  numeric(10,0)   not null,
 "vrcPrice"   double precision   not null,
 "vrcCreatedDt"  timestamp without time zone  not null,
 "vrcEffectDt"   timestamp without time zone , 
 "vtrId"       numeric(10,0)   not null,
 "vbsId"      numeric(10,0)    not null,
 "UserBy"     character varying(80) ,      
 "IsActive"   boolean          not null,
 "cli"        boolean 

);

CREATE  UNIQUE  INDEX  "PK_tblVoIPRateCustomerUSA" ON  "tblVoIPRateCustomerUSA"
( "vrcId" );
 

   
create table "tblVoIPGatewayConfigs2"
(
"ID"   numeric(10,0)   not null,
 "CustID"   numeric(10,0)    not null,
 "Name"     character varying(50) , 
 "Address"  character varying(20) , 
 "GWMode"   numeric(10,0)         , 
 "UserName" character varying(50) , 
 "Enabled"  boolean               , 
 "vdsType"  character varying(18) , 
 "Sip"      boolean   
 );

CREATE  UNIQUE  INDEX  "PK_tblVoIPGatewayConfigs2" ON  "tblVoIPGatewayConfigs2"
( "ID" );
 

create table "tblVoIPDialPeerConfigs2"
(
 "ID" numeric(10,0) not null,
 "CustID"  numeric(10,0), 
 "Enabled"   boolean  not null,
 "UseTestPrefix"  boolean  , 
 "TestPrefix"   character varying(50) , 
 "UseAddPrefix"  boolean, 
 "AddPrefix"   character varying(50), 
 "External"   boolean  , 
 "cli"      boolean   , 
 "usecli"   boolean   );

CREATE  UNIQUE  INDEX  "PK_tblVoIPDialPeerConfigs2" ON  "tblVoIPDialPeerConfigs2"
( "ID" );

create table "tblVoIPRateUSA"
(
 "vrtId"  numeric(10,0)                not null,
 "vvdId"         numeric(10,0)                not null,
 "vdsId"         numeric(10,0)                not null,
 "vbsId"         numeric(10,0)                not null,
 "vdsdialcode"   character varying(50)  ,      
 "usavdsid"      numeric(10,0)      ,          
 "vtrid"         numeric(10,0)                not null,
 "vrtCost"       double precision             not null,
 "order"         numeric(10,0)      ,          
 "vrtCreatedDt"  timestamp without time zone  not null,
 "vrtEffectDt"   timestamp without time zone  not null,
 "IsActive"      boolean                      not null,
 "cli"           boolean ,                     
 "fax"           boolean ,
 "ris"           boolean 
);

CREATE  UNIQUE  INDEX  "PK_tblVoIPRateUSA" ON  "tblVoIPRateUSA"
( "vrtId" );

create table "tblVoIPAlterRateUSA"
(
 "vrtId"  numeric(10,0)                not null,
 "vvdId"         numeric(10,0)                not null,
 "vdsId"         numeric(10,0)                not null,
 "vbsId"         numeric(10,0)                not null,
 "vdsdialcode"   character varying(50)  ,
 "usavdsid"      numeric(10,0)      ,
 "vtrid"         numeric(10,0)                not null,
 "vrtCost"       double precision             not null,
 "order"         numeric(10,0)      ,
 "vrtCreatedDt"  timestamp without time zone  not null,
 "vrtEffectDt"   timestamp without time zone  not null,
 "IsActive"      boolean                      not null,
 "cli"           boolean ,
 "fax"           boolean ,
 "ris"           boolean
);

CREATE  UNIQUE  INDEX  "PK_tblVoIPAlterRateUSA" ON  "tblVoIPAlterRateUSA"
( "vrtId" );



alter table "tblVoIPRateUSA" owner to wiztel ;
alter table "tblVoIPDialPeerConfigs2" owner to wiztel ;
alter table "tblVoIPGatewayConfigs2" owner to wiztel ;
alter table "tblVoIPRateCustomerUSA" owner to wiztel ;
alter table "tblVoIPAlterRateUSA" owner to wiztel ;

create table "tblVoipOffNetUsa"
(
 "ID"           numeric(10,0)     not null,
 "CustId"       numeric(10,0)     not null,
 "MeraVersion"  character varying(2)  not null,
 "Prefix"       character varying(50) ,       
 "Price"        double precision      not null,
 "CreatedDt"    timestamp without time zone , 
 "UserBy"       character varying(80)    
);

alter table "tblVoipOffNetUsa" owner to wiztel ;



#post


create table "tblVoIPAlterRateUSApost"
(
 "vrtId"  numeric(10,0)                not null,
 "vvdId"         numeric(10,0)                not null,
 "vdsId"         numeric(10,0)                not null,
 "vbsId"         numeric(10,0)                not null,
 "vdsdialcode"   character varying(50)  ,
 "usavdsid"      numeric(10,0)      ,
 "vtrid"         numeric(10,0)                not null,
 "vrtCost"       double precision             not null,
 "order"         numeric(10,0)      ,
 "vrtCreatedDt"  timestamp without time zone  not null,
 "vrtEffectDt"   timestamp without time zone  not null,
 "IsActive"      boolean                      not null,
 "cli"           boolean ,
 "fax"           boolean ,        
 "ris"           boolean
);
 
CREATE  UNIQUE  INDEX  "PK_tblVoIPAlterRateUSApost" ON  "tblVoIPAlterRateUSApost"
( "vrtId" );


alter table "tblVoIPAlterRateUSApost" owner to wiztel ;

