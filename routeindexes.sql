CREATE UNIQUE INDEX "PK_tblVoIPDestinationUSA" on "tblVoIPDestinationUSA" ("Id") ;

CREATE INDEX "ID_tblVoIPRateUSA" on "tblVoIPRateUSA" ("usavdsid") ;

CREATE INDEX "ID1_tblVoIPRateUSA" on "tblVoIPRateUSA" ("vvdId") ;

CREATE INDEX "ID_tblVoIPRateCustomerUSA" on "tblVoIPRateCustomerUSA" ("usavdsId") ;

CREATE INDEX "ID1_tblVoIPRateCustomerUSA" on "tblVoIPRateCustomerUSA" ("voipUserId") ;

CREATE INDEX "ID_tblVoIPUserCustomer" on "tblVoIPUserCustomer" ("Id") ;

CREATE INDEX "ID_tblVoIPUserRoute" on "tblVoIPUserRoute" ("voipUserVendId") ;

CREATE INDEX "ID2_tblVoIPRateCustomerUSA" on "tblVoIPRateCustomerUSA" ("cli") ;

CREATE INDEX "ID2_tblVoIPRateUSA" on "tblVoIPRateUSA" ("cli") ;

CREATE INDEX "ID3_tblVoIPRateCustomerUSA" on "tblVoIPRateCustomerUSApost" ("rwcli") ;

CREATE INDEX "ID4_tblVoIPRateCustomerUSA" on "tblVoIPRateCustomerUSApost" ("ris") ;

#CREATE INDEX "ID3_tblVoIPRateCustomerUSApost" on "tblVoIPRateCustomerUSApost" ("rwcli") ;

#CREATE INDEX "ID4_tblVoIPRateCustomerUSApost" on "tblVoIPRateCustomerUSApost" ("ris") ; 

CREATE INDEX "ID1_tblVoIPRateUSApost" on "tblVoIPRateUSApost" ("vvdId") ;

CREATE INDEX "ID2_tblVoIPRateUSApost" on "tblVoIPRateUSApost" ("cli") ;

CREATE INDEX "ID3_tblVoIPRateUSApost" on "tblVoIPRateUSApost" ("ris") ;

CREATE INDEX "ID4_tblVoIPRateUSApost" on "tblVoIPRateUSApost" ("IsActive") ;

CREATE INDEX "ID4_tblVoIPRateUSA" on "tblVoIPRateUSA" ("IsActive") ;

CREATE INDEX "IDM1_tblVoIPRateUSA" on "tblVoIPRateUSA" ("usavdsid","vvdId","cli","ris","IsActive");
CREATE INDEX "IDM1_tblVoIPRateUSApost" on "tblVoIPRateUSApost" ("usavdsid","vvdId","cli","ris","IsActive");

