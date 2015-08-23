#!/bin/sh


/usr/local/pgsql/bin/psql -U postgres wiztel -c "select * from spRoutingSrcCliInter('$1' , truncdstp('$2'),'$3','$4','$5') ; "
#select * from  spRoutingSrcCliInter('trd_cust','1212398','121239899','2','post') ;

