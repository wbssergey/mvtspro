





DROP TABLE "tblVoipRateUSA" ;

CREATE TABLE "tblVoipRateUSA" (
"vrtId"         numeric(10,0),              
 "vvdId"        numeric(10,0),              
 "vdsId"         numeric(10,0),               
 "vbsId"         numeric(10,0),              
 "vdsdialcode"   character varying(50),        
 "usavdsid"      numeric(10,0),                
 "vtrid"         numeric(10,0),               
 "vrtCost"       double precision,           
 "order"         numeric(10,0),                
 "vrtCreatedDt"  timestamp without time zone, 
 "vrtEffectDt"   timestamp without time zone, 
 "username"      character varying(30),       
 "IsActive"      boolean,                     
 "cli"           boolean      
);

CREATE UNIQUE INDEX "PK_tblVoIPRateUSA" on "tblVoipRateUSA" ("vrtId") ;

ALTER TABLE "tblVoIPRateUSA" OWNER TO wiztel ;

INSERT INTO "tblVoIPRateUSA" SELECT * FROM "tblVoipRateUSApost" order by "vrtId" ;

