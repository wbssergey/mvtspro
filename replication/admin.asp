<%pgTitle="Postgres Administration": sAllowed="1,2": sUPCpntAllowed="CDM"%>
<!--#include file=../include/Header.asp-->
<!--#include file="../include/voipCustomer1.asp"-->
<!--#include file="multiuser2.asp"-->
<!--#include file="postgresheader.asp"-->

<style type="text/css">
<!--
.wiztelFields {
	width: 160px;
}
.wiztelInputFields {
	font-size:10px;font-weight:normal;font-family:tahoma,sans-serif;width=100;
}
-->
</style>
<%
Dim voipCust

Dim tbltempRateLog, tblTempVoIPRateCustomer, tblTempVoIPRate

Dim granins



granins=500

user=Request.Cookies("userUnixName")

If not (user="sergey") Then

'redirerr ( "temporary locked for non privileged users")

End If


tbltempRateLog="tblTempRateLog"
tblTempVoIPRateCustomer="tblTempVoIPRateCustomer"
tblTempVoIPRate="tblTempVoIPRate"

msgpostgres=""
msgpostgreslog=""
msgpostgresboot=""


Set voipCust= New voipCustomer

server.ScriptTimeout = 8000
oConn.CommandTimeout = 8000

x1CustId = rqF("sX1CustId")


voipUserId = rqF("sVoipUserId")
voipUserName= rqF("sVoipUserName")
Destination = rqF("sDestination")
vvdId=rqf("svvdID")

Destination="USA"


DestinationType = rqF("sDestinationType")

DestinationType="Continental"


DestinationMobileCarrier = rqF("sDestinationMobileCarrier")

DestinationMobileCarrier=""


Description = rqF("sDescription")

Description=""


StatusId = rqF("sStatusId")
TierId = rqF("sTierId")

StatusId="1"
TierId = "1"

'AddCustomerRateList = rqF("sAddCustomerRateList")
AddVendorId = rqF("sAddVendorId")
Intention = Trim(rqF("sIntention"))
custRateResult ="" ' rqF("scustRateResult")
KeepTempTable=rqF("sKeepTempTable")
DialCodesSelect=rqf("DstPattern")
LabelDialCode=rqf("LabelDialCode")
If LabelDialCode="" Then
LabelDialCode="DialCodes(All)" 
End if


If tierid = "" Then tierid = 1 End If

checkdatabase=rqf("scheckdatabase")
checkreplication=rqf("scheckreplication")
checkradius=rqf("scheckradius")
checklistrates=rqf("schecklistrates")
checklistcosts=rqf("schecklistcosts")

checktabledirectory=rqf("schecktabledirectory")
typetabledirectory=rqf("stypetabledirectory")

purgefiles=rqf("spurgefiles")
typepurgefiles=rqf("stypepurgefiles")

pglist="tblVoIPRateUSA,tblVoIPRateCustomerUSA,tblVoIPDestinationUSA,tblVoIPUserCustomer,tblVoIPUserRoute,"
pglist=pglist&"tblVoIPGatewayConfigs,tblVoIPDialPeerConfigs,tblVoipOffNetUsa" 
pglist=pglist&",tblVoipCustBasedActiveUSA,tblVoipCustBasedOrderUSA,tblVoIPAlterRateUSA" 

mode=rqf("smode")
pgmode=rqf("spgmode")
pgmera=rqf("spgmera")

pgmera="2" ' rqf("spgmera")

pgtable=rqf("spgtable")
pgpost=rqf("spgpost")
pglevel=rqf("spglevel")
pghide=rqf("spghide")
fullstatus=rqf("fullstatus")
fullstatus="y"'rqf("fullstatus")

forcesync=rqf("forcesync")

mode=evaluate(mode="","0",mode)

pgmode=evaluate(pgmode="","1",pgmode)

pgmera=evaluate(pgmera="","2",pgmera)

pgtable=evaluate(pgtable="","all",pgtable)

pgpost=evaluate(pgpost="","3",pgpost)

vvdid=evaluate(vvdid="","0",vvdid)

pglevel=evaluate(pglevel="","0",pglevel)

pghide=evaluate(pghide="","0",pghide)


irecpgdb=""
irectdcount=""
'----------------------------------------- Action Section 

If checklistrates <> "" then
sqlfast= " select xc.id, rc.voipuserid,uc.username,xc.organization, cli, isactive, count(*) as mcount, "
sqlfast=sqlfast & " min(vrcprice) minprice, max(vrcprice) maxprice, min(vbsid) minvbsid, max(vbsid) maxvbsid, "
sqlfast=sqlfast & " min(vrccreateddt) minvrccreateddt, max(vrccreateddt) maxvrccreateddt, "
sqlfast=sqlfast & " min(vrceffectdt) minvrceffectdt, max(vrceffectdt) maxvrceffectdt "

sqlfast=sqlfast & " from tblvoipratecustomerusa rc "
sqlfast=sqlfast & " join tblvoipusercustomer uc "
sqlfast=sqlfast & " join x1customer xc on xc.id=uc.x1custid "
sqlfast=sqlfast & " on uc.id=rc.voipuserid "

'If Not (voipUserId = "0" Or voipuserid = "") Then
'sqlfast=sqlfast & " where rc.voipuserid="&voipUserId
'End If

If x1custid <> "-1" Then
v=voipcust.GetFirstUserCustomerId(x1CustId)
If v = 0 Then v=voipuserid End If
If v = "" Then v = 0 End if
sqlfast=sqlfast & " where rc.voipuserid="&v
End If


sqlfast=sqlfast & " group by xc.organization, xc.id, uc.username,rc.voipuserid,rc.cli,rc.isactive "
sqlfast=sqlfast & " order by xc.organization, uc.username "

End If

If checklistcosts <> "" Then

sqlfastcosts= " select vvdid,ur.username,xc.organization,  vr.isactive,vr.[order], cli, vr.fax, max(vrtcost) maxcost, min(vrtcost) mincost, "

sqlfastcosts=sqlfastcosts & " min(vrtcreateddt) minvrtcreateddt, max(vrtcreateddt) maxvrtcreateddt, "
sqlfastcosts=sqlfastcosts & " min(vrteffectdt) minvrteffectdt, max(vrteffectdt) maxvrteffectdt, "


sqlfastcosts=sqlfastcosts & " max(vr.vbsid) maxvbsid, min(vr.vbsid) minvbsid ,count(*) mcount from tblvoiprateusa vr "
sqlfastcosts=sqlfastcosts & " join tblvoipuserroute ur " 
sqlfastcosts=sqlfastcosts & " join x1customer xc on xc.id=ur.x1custid "
sqlfastcosts=sqlfastcosts & " on ur.voipuservendid=vr.vvdid "
'Response.Write "<script>alert('"&vvdid&"') </script>"

If CStr(vvdId) <> "-1" Then
sqlfastcosts=sqlfastcosts & "where vr.vvdid="&vvdid
End if

sqlfastcosts=sqlfastcosts & " group by vvdid,ur.username,xc.organization , vr.isactive,vr.[order],cli,vr.fax "
sqlfastcosts=sqlfastcosts & " order by xc.organization, ur.username "



End If

If checktabledirectory <> "" Then

If typetabledirectory = "" Then typetabledirectory = "1" End If

If typetabledirectory = "1" Then obtype="T" End If
If typetabledirectory = "2" Then obtype="P" End If
If typetabledirectory = "3" Then obtype="F" End If


sqltabledirectory="select " 
sqltabledirectory=sqltabledirectory&" case  when Status='Unknown' then 1000 else case when Status='Test' then 900 else " 
sqltabledirectory=sqltabledirectory&" case when Status='Basic' then 1 else case when Status='Billing' then 2 else "

sqltabledirectory=sqltabledirectory& " case when Status='MVTS' then 3 else case when Status='Reports' then 4  else" 
sqltabledirectory=sqltabledirectory& " case when Status='USARates' then 5  " 
sqltabledirectory=sqltabledirectory& " else case when Status='System' then 100 else 1000 end end end end end end end end cord "
sqltabledirectory=sqltabledirectory &" , * from tblZTablesDirectory where  [Type]='"&obtype&"' and left(Table_name,2) <> 'z_' order by cord " 
sqltabledirectory=sqltabledirectory& " , Table_name, timestamp desc"

' sp_columns @table_name='tblZTablesDirectory'
' sp_columns_ex @table_server='pgslave', @table_name='tblVoIPRateUSA'
' sp_tables_ex  @table_server='pgslave'

tdcaption=""

sql=" select count(*) mc , max(timestamp) tstmp from tblZTablesDirectory where [type]='T' "

Set rs=oconn.execute(sql)

mc=0
tstmp=Now()

If Not rs.eof Then

mc=rs("mc")
tstmp=rs("tstmp")

End If
rs.close
tdcaption=tdcaption&"<tr><td><b>Tables:</b></td><td>Registered:"&mc&"</td><td>Updated:"&tstmp&"</td></tr>"

sql=" select count(*) mc , max(timestamp) tstmp  from tblZTablesDirectory where [type]='P' "

Set rs=oconn.execute(sql)

mc=0
tstmp=Now()

If Not rs.eof Then

mc=rs("mc")
tstmp=rs("tstmp")

End If

rs.close
tdcaption=tdcaption&"<tr><td><b>Procedures:</b></td><td>Registered:"&mc&"</td><td>Updated:"&tstmp&"</td></tr>"

sql=" select count(*) mc, max(timestamp) tstmp  from tblZTablesDirectory where [type]='F' "

Set rs=oconn.execute(sql)

mc=0
tstmp=Now()

If Not rs.eof Then

mc=rs("mc")
tstmp=rs("tstmp")

End If

rs.close

tdcaption=tdcaption&"<tr><td><b>Functions:<b></td><td>Registered:"&mc&"</td><td>Updated:"&tstmp&"</td></tr>"

End If

If purgefiles <> "" Then
purgefilescaption=""


mc=0
size=0

p= application("textpath") 

set fld=ofs.getfolder(p)
for each fle in fld.files
If InStr(fle.name,".pdf")>0 Or InStr(fle.name,".html")>0 then
mc=mc+1
size=size+fle.size
End if
next

size=formatnumber(Cdbl(size) / 1024.0 /1024.0,2)
t=1

If mc > 0 then
zlink="<a href=/z.asp onclick=""return doSubmit('purgefiles','"&t&"');"">Purge</a>"
Else
zlink=""
End if

purgefilescaption=purgefilescaption&"<tr><td nowrap><b>Invoices(pdf,html):</b></td><td nowrap><b>Number of files:</b></td><td>"&mc&"</td><td nowrap><b>Used space:</b></td><td nowrap>"&size&"&nbsp;MB</td><td>"&zlink&"</td></tr>"
mc=0
size=0

p=  application("excelpath")

set fld=ofs.getfolder(p)
for each fle in fld.files
If InStr(fle.name,".xls")>0 Or InStr(fle.name,".zip")>0 Or InStr(fle.name,".csv")>0 then
mc=mc+1
size=size+fle.size
End if
next
size=formatnumber(Cdbl(size) / 1024.0 /1024.0,2)

t=2

If mc > 0 then
zlink="<a href=/z.asp onclick=""return doSubmit('purgefiles','"&t&"');"">Purge</a>"
Else
zlink=""
End If

purgefilescaption=purgefilescaption&"<tr><td nowrap><b>Excel(xls,zip,csv):</b></td><td><b>Number of files:</b></td><td>"&mc&"</td><td nowrap><b>Used space:</b></td><td>"&size&"&nbsp;MB</td><td>"&zlink&"</td></tr>"
mc=0
size=0

	p=  application("textpath")&"\disputeout\"
    
set fld=ofs.getfolder(p)
for each fle in fld.files
If InStr(fle.name,".csv")>0 Or InStr(fle.name,".html")>0 Or InStr(fle.name,".csv")>0 Or InStr(fle.name,".zip")>0 Or InStr(fle.name,".bak")>0  then
mc=mc+1
size=size+fle.size
End if
next

size=formatnumber(Cdbl(size) / 1024.0 /1024.0,2)

t=3
If mc > 0 then
zlink="<a href=/z.asp onclick=""return doSubmit('purgefiles','"&t&"');"">Purge</a>"
Else
zlink=""
End if
purgefilescaption=purgefilescaption&"<tr><td nowrap><b>Disputes(csv,html,zip,bak):</b></td><td><b>Number of files:</b></td><td>"&mc&"</td><td nowrap><b>Used space:</b></td><td>"&size&"&nbsp;MB</td><td>"&zlink&"</td></tr>"

End If

select case Intention

Case "purgefiles":

t=rqf("sfastdata")


   Server.ScriptTimeout = 40000
'set ofs=createobject("scripting.filesystemobject")

		s=switchUser( 1  )
        If InStr(s,"fail") > 0 then
		Endpage s
		End If

On Error Resume Next ' supprese error if trying delete not existed file

If t="1" Then

		v=  application("textpath")&"*.pdf"

		ofs.deletefile v,true 
		
	    v=  application("textpath")&"*.html"

	    ofs.deletefile v,true 

End If

If t="2" then


		v=  application("excelpath")&"*.xls"

        ofs.deletefile v,true 

		v=  application("excelpath")&"*.zip"

        ofs.deletefile v,true 

        v=  application("excelpath")&"*.csv"

        ofs.deletefile v,true 

End If

If t = "3" then

		v=  application("textpath")&"\disputeout\*.csv"
        
		ofs.deletefile v,true 

        v=  application("textpath")&"\disputeout\*.html"
        
		ofs.deletefile v,true 

        v=  application("textpath")&"\disputeout\*.zip"
        
		ofs.deletefile v,true 
        
        v=  application("textpath")&"\disputeout\*.bak"
        
		ofs.deletefile v,true 

End If

On Error Goto 0

		s=switchUser ( 0 )
	    If InStr(s,"fail") > 0 then
		Endpage s
		End if
       
	'   Set ofs=Nothing
       
     '  redirerr "deleted"


 	Case "sphelp":

	v=rqf("sFastData")

sql="	SELECT table_name,ordinal_position,column_name,data_type,  is_nullable,character_maximum_length FROM "
sql=sql&" information_schema.COLUMNS WHERE table_name ='"&v&"' "
sql=sql& " ORDER BY ordinal_position "

s=""

Set rs=oconn.execute(sql)
while Not rs.eof 
v=rs("column_name")
s=s&"<tr><td>"&v&"</td>"
v=rs("data_type")
s=s&"<td>"&v&"</td>"
v=rs("is_nullable")
s=s&"<td>"&v&"</td>"
v=rs("character_maximum_length")
If IsNull(v) Then v="" End If
s=s&"<td>"&v&"</td>"
s=s&"</tr>"

rs.movenext
Wend

t="<br><table><tr><th>ColumnName</th>"
t=t&"<th>DataType</th>"
t=t&"<th>IsNullable</th>"
t=t&"<th>Lenght</th></tr>"
t=t&s&"</table>"

rs.close

redirerr t

 	Case "sphelptext":

	v=rqf("sFastData")
sql=" EXEC sp_helptext '"&v&"' "

s=""

Set rs=oconn.execute(sql)

while Not rs.eof 
v=rs("text")
s=s&"<tr><td>"&v&"</td>"
s=s&"</tr>"
rs.movenext
Wend

t="<br><table><tr><th>Text</th>"
t=t&"</tr>"
t=t&s&"</table>"

rs.close

redirerr t

Case "syncgrp":

v=rqf("SyncList")
a=Split(v,",")
l=UBound(a)-1
w=""

 

For i=0 To l
w=w & "<br>" & a(i) & ";"
Next


post=a(0)


For i=1 To l

s=a(i)

If post <> "" then

'post;
'tblVoIPRateUSA:append;
'tblVoIPRateCustomerUSA:append;
'tblVoIPGatewayConfigs:copy;
'tblVoIPDialPeerConfigs:copy;

var=Split(s,":")
v=var(0)

u=var(1)
op="?"
If u = "refresh" Then op="" End if 
If u = "copy" Then op=", @copy='y'"  End if 
If u = "append" Then op=", @append='y'" End if 


v=Replace(v,pgmera,"")
sql="exec spPostgresInsertHelp3 @tablename='"&v
sql=sql  & "',  @refresh='y' "&op 
sql=sql & ", @mera='"&evaluate(pgmera="1","",pgmera)&"' " 

oconn.execute(sql)

Else 'post <> ""

';
'tblVoIPRateUSA:0;
'tblVoIPRateCustomerUSA:0;
'tblVoIPDestinationUSA:0;
'tblVoIPUserCustomer:0;
'tblVoIPUserRoute:0;
'tblVoIPGatewayConfigs:0;
'tblVoIPDialPeerConfigs:0;  

var=Split(s,":")
v=var(0)

u=var(1)


op="?"
If u = "refresh" Then op="" End if 
If u = "copy" Then op=", @copy='y'"  End if 
If u = "append" Then op=", @append='y'" End if 

u=""


If InStr(v,"Gateway") > 1 Then u = "1" End If
If InStr(v,"DialPeer") > 1  Then u = "2" End If
If InStr(v, "RateCustomer") > 1 Then u = "4" End If
If InStr(v, "VoIPRateUSA") > 1  Then u = "3" End If
'If InStr(v, "DestinationUSA") > 1  Then u = "5" End If
If InStr(v, "VoIPAlterRateUSA") > 1  Then u = "6" End If

If u <> "" Then
' post data

s="/usr/local/pgsql/bin/qsync1.sh " & u & " " & meraversion

s=replace(paramUNIXcommand,"@text@",s)


Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
If InStr(retpg,"195708") = 0  then
redirerr retpg
End If

Else

' nopost data
'"tblVoIPUserRoute" 
'"tblVoIPUserCustomer" 
'"tblVoIPDestinationUSA" 
'"tblVoipOffNetUsa"
If v="tblVoIPDestinationUSA" Then
op=", @append='y'"
End If

If v="tblVoIPUserCustomer" Then
op=", @copy='y'"
End If

If v="tblVoIPUserRoute" Then
op=", @copy='y'"
End If

If v="tblVoipOffNetUsa" Then
op=", @copy='y'"
End If

If v="tblVoipCustBasedActiveUSA" Then
op=", @copy='y'"
End If

If v="tblVoipCustBasedOrderUSA" Then
op=", @copy='y'"
End If

sql="exec spPostgresInsertHelp3 @tablename='"&v
sql=sql  & "',  @refresh='y' "&op 
sql=sql & ", @mera='"&evaluate(pgmera="1","",pgmera)&"' " 


oconn.execute(sql)

End If

End If

Next


Case "fixresynccosts":

v=rqf("sfastData")

a=Split(v,":")
cost=a(0)
vbsid=a(1)
vendor=a(2)
cli=a(3)
fax=a(4)
isactive=a(5)
order=a(6)

'vvdid&":"&vcli&":"&vfax&":"&visactive&":"&order
'redirerr v ' -- - 0.0129:1:690:1:0:0:1

sql=" exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y', "
sql=sql & " @tablename='tblVoIPRateUSA',@field='vrtCost',@value='"&cost&"',@pkey='"&vendor&"' "

oconn.execute(sql)

Case "fixresync":

v=rqf("sfastData")
a=Split(v,":")
price=a(0)
vbsid=a(1)
customer=a(2)
cli=a(3)
isactive=a(4)

'redirerr v '-- 28:0:1 --0.009:1:28:0:1  
   
sql=" exec spPostgresUpdateHelp3 @mera='2',@update='y',@refresh='y', "
sql=sql & " @tablename='tblVoIPRateCustomerUSA',@field='vrcPrice',@value='"&price&"',@pkey='"&customer&"' "

redirerr sql
oconn.execute(sql)


case "pgfixpost":

s=rqf("spgfixdata")
var=Split(s,":")
v=var(0)

u=var(1)
op="?"
If u = "refresh" Then op="" End if 
If u = "copy" Then op=", @copy='y'"  End if 
If u = "append" Then op=", @append='y'" End if 


v=Replace(v,pgmera,"")
sql="exec spPostgresInsertHelp3 @tablename='"&v
sql=sql  & "',  @refresh='y' "&op 
sql=sql & ", @mera='"&evaluate(pgmera="1","",pgmera)&"' " 
'debugerr sql
oconn.execute(sql)

case "pgfixnopost":


s=rqf("spgfixdata")
var=Split(s,":")
v=var(0)

u=var(1)


op="?"
If u = "refresh" Then op="" End if 
If u = "copy" Then op=", @copy='y'"  End if 
If u = "append" Then op=", @append='y'" End if 



u=""


If InStr(v,"Gateway") > 1 Then u = "1" End If
If InStr(v,"DialPeer") > 1  Then u = "2" End If
If InStr(v, "RateCustomer") > 1 Then u = "4" End If
If InStr(v, "RateUSA") > 1  Then u = "3" End If
'If InStr(v, "DestinationUSA") > 1  Then u = "5" End If

If u <> "" Then
' post data

s="/usr/local/pgsql/bin/qsync1.sh " & u & " " & meraversion
'debugerr s
s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
If InStr(retpg,"195708") = 0  then
debugerr retpg
End if
Else

' nopost data
'"tblVoIPUserRoute" 
'"tblVoIPUserCustomer" 
'"tblVoIPDestinationUSA" 

If v="tblVoIPDestinationUSA" Then
op=", @append='y'"
End If

If v="tblVoIPUserCustomer" Then
op=", @copy='y'"
End If

If v="tblVoIPUserRoute" Then
op=", @copy='y'"
End If

sql="exec spPostgresInsertHelp3 @tablename='"&v
sql=sql  & "',  @refresh='y' "&op 
sql=sql & ", @mera='"&evaluate(pgmera="1","",pgmera)&"' " 
'debugerr sql
oconn.execute(sql)

End If

Case "pgcdr":

v=rqf("spgfixdata")
'v="trd_cust"
v="SRC-NUMBER-IN="&v
s=" grep " & v & " /usr/local/mvts/billing/.tmp*"
's=" grep " & v & " /usr/local/mvts/billing/Pbill*"

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 

p=InStr(retpg,"HOST")
If p > 0 Then
q=27
retpg=Right(retpg,Len(retpg)-p+1+q)
retpg=Replace(retpg,"Server closed network connection","")
retpg=Replace(retpg,"Server sent command exit status 0","")
retpg=Replace(retpg,",",",<br>")
Else
redirerr "cdr not found"
End If

redirerr retpg

Case "pglog":

s=rqf("spgfixdata")

var=Split(s,";")
u=var(0)
v=var(1)

t=""

If u = "short" Then t="3" End If
If u = "long" Then t="2" End If

If (t <> "") And isnumberm(v) then
s="tail -"&(v+1)&" /usr/local/var/log/radius"&t&" | grep iptel_cust ; date" 
s="tail -"&(v+1)&" /usr/local/var/log/radius"&t&" ; date" 

s=replace(paramUNIXcommand,"@text@",s)
'redirerr UnixCommand & " " & s
Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
p=InStr(retpg,"Auth:")
If p > 0 Then
p=InStr(p,retpg,")")
retpg=Right(retpg,Len(retpg)-p)
retpg=Replace(retpg,")",")")
End If
retpg=Replace(retpg,"Server sent command exit status 0","")
retpg=Replace(retpg,"Server closed network connection","")

msgpostgreslog=retpg

Else

redirerr "wrong parameters"

End If

Case "pgboot":

s=rqf("spgfixdata")

var=Split(s,";")
u=var(0)
v=var(1)
w=var(2)

s=""

If v = "1" Then s="start" End If
If v = "2" Then s="stop" End If
If v = "3" Then s="restart" End If
If v = "4" Then s="status" End If

s1=""
If w = "1" Then s1="-nocons" End If
If w = "2" Then s1="-cons" End If

s2=""

If u="1" Then s2="2ms" End If
If u="2" Then s2="2pg" End If
If u="3" Then s2="none" End If


If (s<>"") And (s1 <>"") And (s2<>"" ) Then

s="/usr/local/etc/raddb/radiusmode.sh " & s2 & " " & s & " " & s1

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
retpg=Replace(retpg,"Server sent command exit status 0","")
retpg=Replace(retpg,"Server closed network connection","")

msgpostgresboot=retpg

Else

redirerr "wrong parameters"

End if


Case "pgtoggle":
redirerr "temporary closed"
v=rqf("spgfixdata")

u=""

If v="MSSQL" Then u="2pg" End If
If v="Postgres" Then u="2ms" End If


s="/usr/local/etc/raddb/radiusmode.sh " & u & " restart -nocons  " 

s="/usr/local/etc/raddb/radiusmodestable.sh " & u & " restart -nocons -stable" 

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
retpg=Replace(retpg,"Server sent command exit status 0","")
retpg=Replace(retpg,"Server closed network connection","")

msgpostgresboot=retpg

Case "pgsnap":

v=rqf("spgfixdata")

If (v = "cu") Or (v="route") Or ( v="user") then

sql="exec  spPostgresSnapshotReplication @mera='"&pgmera&"', @type='"&v&"' , @nodrop='y', @droponly='' "

oconn.execute(sql)

Else
redirerr " wrong3 " & v
End If

Case "pgsnapstop":

v=rqf("spgfixdata")

If (v = "cu") Or (v="route") Or ( v="user")  then

sql="exec  spPostgresSnapshotReplication @mera='"&pgmera&"', @type='"&v&"' , @nodrop='', @droponly='y' "


oconn.execute(sql)

Else
redirerr " wrong4 " & v
End If


Case "pgtran":

v=rqf("spgfixdata")

If (v = "gw") Or (v = "dp") Or (v = "cutrans") then
sql="exec  spPostgresTransReplication @mera='"&pgmera&"', @type='"&v&"' , @nodrop='y', @droponly='' "
'debugerr sql
oconn.execute(sql)

Else

redirerr " wrong5 " & v

End If

Case "pgtranstop":

v=rqf("spgfixdata")

If (v = "gw") Or (v = "dp") Or (v="cutrans") then

sql="exec  spPostgresTransReplication @mera='"&pgmera&"', @type='"&v&"' , @nodrop='', @droponly='y' "

'debugerr sql

oconn.execute(sql)

Else

redirerr " wrong6 " & v

End If

Case "tdstatus":
c=rqf("irectdcount")
c=CInt(c)

For i=1 To c
v=rqf("checktdstatus"&i)
If v <> "" Then
id=rqf("tdid"&i)
 s=rqf("tdstatus"&i)
 a=Trim(rqf("tdauthor"&i))
 c=Trim(rqf("tdcomments"&i))

 sql="update tblZTablesDirectory set timestamp=getdate(), status='"&s&"', author='"&a&"' , comments = '"&c&"' where id ="&id

oconn.execute(sql)


End if
Next



End Select 

If mode = "0" And ( checkdatabase <> "" ) Then

pglistlen=-1

	
If pgtable = "all" Then

	pglistar=Split(pglist,",")
	pglistlen=UBound(pglistar)

Else
    pglistar=Split(pgtable,",")
	
	pglistlen=0


End If

If pgpost = "3" Then
k=1
Else
k=0
End If

irec=0

irecnopost=0
irecpost=0

For j=0 To k



If j=0 Then 
post=""
If pgpost="1" Then post="post" End If
End If


If j=1 Then 
post="post" 
End If


If post ="" Then
th="<tr><th></th><th>TableName</th><th>Check<br>(counters)</th>"
If fullstatus <> "" then
th=th&"<th>Status<br>(full)</th><th>Check<br>Status</th>"
End If
th=th&"<th><input class=databutton type='button' value='Sync' onClick=""doSubmit('syncgrp','"&post&"');""></th><th>Action<br>Mode</th></tr>" 
Else
th="<tr><th></th><th>TableName<br>(Post)</th><th>Check<br>(counters)</th>"
If fullstatus <> "" Then
th=th&"<th>Status<br>(full)</th><th>Check<br>Status</th>"
End if
th=th&"<th><input class=databutton type='button' value='Sync' onClick=""doSubmit('syncgrp','"&post&"');""></th><th>Action<br>Mode</th></tr>" 
'th=th&"</table><table>"
End If

s=""



For i=0 To  pglistlen


irec=irec+1

eskipdb=rqf("eskipdb"&irec)

If post = "" Then
irecnopost=irecnopost+1
Else
irecpost=irecpost+1
End if

t=pglistar(i)

s1=""
If t = "tblVoIPUserRoute" And post="" then
s1=" , @gwuser = 'y' "
End If

If t = "tblVoIPUserCustomer" And post = "" then
s1=" , @dpuser = 'y' "
End If

sql="exec sppostgresinsertHelp2 @tablename='"&t&"' , @post='"&post&"' " & s1

'If t = "tblVoIPUserCustomer"  then
'debugerr sql
'End if

If Not ( eskipdb = "" ) then

Set rs=oconn.execute(sql)

End If

If   eskipdb = "" Then

w=rqf("eskipdb"&irec)

If eskipdb <> "" Then s1=s1 & " checked " End If

s1="<td align=center><input type=checkbox class=datacheckboxn name='eskipdb"&irec&"' value='y'"
If w <> "" Then s1=s1 & " checked " End If
s1=s1& "></td><td><b>" & t & post & "</b></td><td ><b>skipped</b></td><td colspan=4></td>" 

s=s&"<tr>"&s1&"</tr>"

Else 
If  rs.State <> 1 Then

s1="<td>&nbsp</td><td>" & t & post & "</td><td><b>closed</b></td>" 
s1=s1&"<td></td>"
else

If Not rs.eof Then
f=t
If post <> "" Then f=t & post End if
v=rs(f)
If InStr(v,"match") > 0 Then 
c ="green" 
Else
c = "red" 
End if

If InStr(v,"not in") > 0 Then c = "" End if

w=rqf("eskipdb"&irec)

s1="<td align=center><input type=checkbox class=datacheckboxn name='eskipdb"&irec&"' value='y' "
If w <> "" Then s1=s1 & " checked " End If
s1=s1& "></td><td><b>"

If c <> "" Then s1=s1 & "<font color="&c&">"  End if
s1=s1 & t & post 
s1=s1 & "</font>"
s1=s1 & "</b></td><td><b>"
If c <> "" Then s1=s1 & "<font color="&c&"> " End if
s1=s1 & v 
If c <> "" Then s1=s1 & "</font>" End if
s1=s1 & "</b></td>" 

If fullstatus <> "" Then

v=""
w=rqf("checktable"&irec)
If rqf("irecpgdb") = "" Then
b=(t = "tblVoIPGatewayConfigs") Or (t= "tblVoIPDialPeerConfigs" ) 
b=b Or (t="tblVoipCustBasedActiveUSA" and post="")
b=b Or (t="tblVoipCustBasedOrderUSA" and post="")

If b then 
w="y"
End if
End If

If w <> "" Then
b= (t = "tblVoIPGatewayConfigs") Or (t= "tblVoIPDialPeerConfigs" ) Or (t="tblVoIPDestinationUSA" And post="")
b=b Or (t="tblVoIPUserCustomer" And post="" ) Or (t="tblVoIPUserRoute" And post="")
b=b Or (t="tblVoipOffNetUsa" and post="")
b=b Or (t="tblVoipCustBasedActiveUSA" and post="")
b=b Or (t="tblVoipCustBasedOrderUSA" and post="")

If b And c="green" Then


sql="exec spPostgresInsertHelp2 @detail='y', @tablename='"&t&"', @mera='2', @post='"&post&"'  "

Set rsa=oconn.execute(sql)

If Not rsa.eof Then
v=rsa(t&post)
If InStr(v,"not in") > 0 Then v = "" End if
End if

rsa.close

End if
End If

If v <> ""  then
If (v = "details 0")  Or InStr(v,"match") > 0 Then 
v = "<b><font color=green>match</font></b>" 
Else
v = "<b><font color=red>diff"&Replace(v,"diff","")&"</font></b>" 
c="red"
End If
Else
If c = "red" And w <> "" Then v="<b><font color=red>Diff</font></b>" End if
End If


s1 = s1 & "<td><b>" & v & "</b></td><td align=center>"

b= (t = "tblVoIPGatewayConfigs") Or (t= "tblVoIPDialPeerConfigs" ) Or (t="tblVoIPDestinationUSA" And post="")
b=b Or (t="tblVoIPUserCustomer" And post="" ) Or (t="tblVoIPUserRoute" And post="")
b=b Or (t="tblVoipOffNetUsa" and post="")
b=b Or (t="tblVoipCustBasedActiveUSA" and post="")
b=b Or (t="tblVoipCustBaseOrderUSA" and post="")

If b then
s1 = s1 & "<input type=checkbox class=datacheckboxn name='checktable"&irec&"' value='y' "
If w <> "" Then s1=s1 & " checked " End If
s1=s1& ">"
Else
s1=s1&"<b>not in use</b>"
End if
s1=s1 & " </td>"
End If ' fullstatus

b=(t = "tblVoIPGatewayConfigs") Or (t= "tblVoIPDialPeerConfigs" ) Or (t="tblVoIPUserRoute") Or (t="tblVoIPUserCustomer")
b= b Or (t="tblVoIPDestinationUSA") Or (t="tblVoipOffNetUsa")
b=b Or (t="tblVoipCustBasedActiveUSA" and post="")
b=b Or (t="tblVoipCustBaseOrderUSA" and post="")

If Request.Cookies("userUnixName") = "sergey"  Then
b=b or (t = "tblVoIPRateCustomerUSA") or (t = "tblVoIPRateUSA") Or  (t = "tblVoIPAlterRateUSA") 
End if
If ((c = "red") Or (forcesync <> "" And c <> "" )) And (b)  Then

If post = "" then
zlink="<a href="&"/z.asp onclick=""return doSubmit('pgfixnopost','"&t&":"&irec&"');"">"
Else
zlink="<a href="&"/z.asp onclick=""return doSubmit('pgfixpost','"&t&":"&irec&"');"">"
End if


If post = "" then
s1=s1&"<td align=center><input type=checkbox class=datacheckboxn name='checksync"&post&"grp"&irecnopost&"' value='"&t&":"&irec&"'></td>"
Else
s1=s1&"<td align=center><input type=checkbox class=datacheckboxn name='checksync"&post&"grp"&irecpost&"' value='"&t&":"&irec&"'></td>"
End If

If post <> "" then
s1=s1&"<td><select name='selmodfix"&irec&"'><option value='refresh'>refresh</option>"
s1=s1&"<option value='append'"
If (t = "tblVoIPRateUSA") Or (t= "tblVoIPRateCustomerUSA" ) then 
s1=s1&" selected "
End if

s1=s1&">append</option><option value='copy'"
If (t = "tblVoIPGatewayConfigs") Or (t= "tblVoIPDialPeerConfigs" ) Or (t="tblVoIPUserRoute") Or (t="tblVoIPUserCustomer") then 
s1=s1&" selected "
End if

s1=s1&">copy</option></select></td>"
Else
s1=s1&"<td></td><td></td>"
End if
Else
s1=s1&"<td></td><td></td>"
End if

Else
c="red"
w=rqf("eskipdb"&irec)

s1="<td align=center><input type=checkbox class=datacheckboxn name='eskipdb"&irec&"' value='y'"
If w <> "" Then s1=s1 & " checked " End If
s1=s1&"></td><td>" & t & post & "</td><td>eof</td>" 
s1=s1&"<td></td>"

End If

rs.close

End if

'End If ' skipdb

s= s & "<tr>" & s1 & "</tr>"

End If ' skipdb

Next


msgpostgres=msgpostgres&th'"<tr><th>TableName</th><th>Status</th></tr>" 
msgpostgres=msgpostgres & s 
irecpgdb=irec


Next


End If

'----------------------------------------- End Action Section ----------------------------------------------------
%>
<form name="form1" method="post" action="">

  <table  border="0" cellpadding="2" cellspacing="0" bordercolor="#FFFFFF" bgcolor="#FFFFFF" class="datatable">
    <!--
	<tr><td class=fadeaway style=font-weight:bold ><i><big style=font-weight:bold;font-size:14px;color:<%=colorMsg%>>
	Postgres Administration Page</big></i></td></tr>
-->
    <tr class="datacol0"  style="display:none;" > 
	
	
        <td style=font-weight:bold width="85">Destination: </td>
      <td  width="168"><select name="fDestination" id="select2" class="wiztelFields" onchange="switchOption1(); return doSubmit('select','')">
         <option value=''  <%If destination = "" then%>selected<%End if%>>-- Select Destination --</option>
		 <option value='0'  <%If destination = "0" then%>selected<%End if%>>--All--</option>
		 <%=voipCust.WriteDestinationList(Destination)%>
        </select></td>
      
      <td style=font-weight:bold width="119">&nbsp;Destination Type:</td>
      <td><select name="fDestinationType" id="select3" class="wiztelFields" onchange="switchOption1(); return doSubmit('select','')">
          <option value="" selected>&nbsp;&nbsp;&nbsp;&nbsp;---- All ---- &nbsp;&nbsp;&nbsp;&nbsp;</option>
		  <%=voipCust.WriteDestinationTypeList(Destination, DestinationType)%>
        </select></td>
      <td style=font-weight:bold>Carrier:</td>
      <td><select name="fDestinationMobileCarrier" id="select4" class="wiztelFields" onchange="switchOption1(); return doSubmit('select','')">
          <option value="" selected>&nbsp;&nbsp;&nbsp;&nbsp;---- All ---- &nbsp;&nbsp;&nbsp;&nbsp;</option>
		  <%=voipCust.WriteMobileCarrierListNoBlank(Destination, DestinationType, DestinationMobileCarrier)%>
        </select></td>
      <td style=font-weight:bold>&nbsp;Breakout:</td>
      <td><select name="fDescription" id="select1" class="wiztelFields" onchange="switchOption1(); return doSubmit('select','')">
          <option value="" selected>&nbsp;&nbsp;&nbsp;&nbsp;---- All ---- &nbsp;&nbsp;&nbsp;&nbsp;</option>
		  <%=voipCust.WriteDescriptionListNoBlank(Destination, DestinationType, Description)%>
        </select></td>
		</tr>
		<tr>
			<td  style=font-weight:bold style="display:none;">&nbsp;Mode:&nbsp;<select name="mode"  onchange="return doSubmit('select','')">
		<option value="0" <%If mode="0" then%> selected<%End if%>>Fast Setup</option>
		<option value="1" <%If mode="1" then%> selected<%End if%>>Full List</option>
		<option value="2" <%If mode="2" then%> selected<%End if%>>Both</option></select>
		</td>
		<%
		 d=""
		 If mode <> "0" Then d="style='display:none'" End if
		%>
		<td style=font-weight:bold <%=d%>nowrap style="display:none;">&nbsp;Postgres View:&nbsp;<select name="pgmode" onchange="return doSubmit('select','')"  >
		<option value="0" <%If pgmode="0" then%> selected<%End if%>>None</option>
		<option value="1" <%If pgmode="1" then%> selected<%End if%>>All</option>
		
		</select>
	</td>
			<%
		 d=""
		 If  pgmode = "0" Then d="style='display:none'" End If
		%>
        <td colspan=3><i><big style=font-weight:bold;font-size:14px;color:<%=colorMsg%>>
	Postgres Administration Page</big></i></td>
		<td colspan=10 align=right style=font-weight:bold <%=d%>>&nbsp;Mera:&nbsp;<select name="pgmera"   >
		<option value="0" <%If pgmera="0" then%> selected<%End if%>>-All-</option>
		<option value="1" <%If pgmera="1" then%> selected<%End if%>>Mera1</option>
		<option value="2" <%If pgmera="2" then%> selected<%End if%>>Mera2</option>
		<option value="3" <%If pgmera="3" then%> selected<%End if%>>Mera3</option>
		
		</select>
		<%
				meraversion=evaluate(pgmera="1","",pgmera)
		%>
	    <input type=hidden name="meraversion" value="<%=meraversion%>">
	</td>

			<%
		 
	     
		 d="style='display:none'"
	
		%>
		<%
		 d=""
		 If pgmode = "0" Then d="style='display:none'" End if
		%>

		</tr>
				<tr ><td colspan=16>&nbsp</td></tr>
		<tr class="datacol0"><td colspan=16>&nbsp</td></tr>
		<tr  class="datacol0" align=center >
 <td><b>Database&nbsp;&nbsp;</b><br><input type=checkbox class=datacheckboxn  
name="checkdatabase"  <%If checkdatabase <> "" then%> checked <%End if%> value="y" ></td><td><b>Replication&nbsp;&nbsp;</b><br>
<input type=checkbox class=datacheckboxn  
name="checkreplication"  <%If checkreplication <> "" then%> checked <%End if%> value="y" >
</td><td colspan=4><b>Radius&nbsp;&nbsp;</b><br>
<input type=checkbox class=datacheckboxn  
name="checkradius"  <%If checkradius <> "" then%> checked <%End if%> value="y"></td>
<td nowrap ><b>Customer Rates&nbsp;&nbsp;</b><br><input type=checkbox class=datacheckboxn  
name="checklistrates"  <%If checklistrates <> "" then%> checked <%End if%> value="y" ></td>
<td nowrap colspan=6><b>Vendor Costs&nbsp;&nbsp;</b><bR><input type=checkbox class=datacheckboxn  
name="checklistcosts"  <%If checklistcosts <> "" then%> checked <%End if%> value="y" ></td>

	<td  <%=d%>>&nbsp</td>
	<td style=font-weight:bold <%=d%>>
<br><input class=databutton type='button' value='Apply' 
onclick="return doSubmit('select','');"
/></td>


		</tr>
<%If syslabuser = "sergey" then%>
<tr>
<td nowrap  align=center><b>ObjectDirectory&nbsp;&nbsp;</b><bR><input type=checkbox class=datacheckboxn  
name="checktabledirectory"  <%If checktabledirectory <> "" then%> checked <%End if%> value="y" ></td>
<%
If checktabledirectory <> "" Then
%>
<td  align=center valign=bottom>
<select name="typetabledirectory">
<option value="1" <%If typetabledirectory="1" then%>selected<%End if%>>Tables</option>
<option value="2" <%If typetabledirectory="2" then%>selected<%End if%>>Procedures</option>
<option value="3" <%If typetabledirectory="3" then%>selected<%End if%>>Functions</option>
</select></td>
<%
End if
%>
<td nowrap  align=center><b>Purge Files&nbsp;&nbsp;</b><bR><input type=checkbox class=datacheckboxn  
name="purgefiles"  <%If purgefiles <> "" then%> checked <%End if%> value="y" ></td>
<%
If False Then 'purgefiles <> "" Then
%>
<td  align=center valign=bottom>
<select name="typepurgefiles">
<option value="1" <%If typepurgefiles="1" then%>selected<%End if%>>Invoices(pdf,html)</option>
<option value="2" <%If typepurgefiles="2" then%>selected<%End if%>>Excel(xls,zip,csv)</option>
<option value="3" <%If typepurgefiles="3" then%>selected<%End if%>>Dispute(csv,html,zip,bak)</option>
</select></td>

<%
End if
%>
</tr>
<%
If tdcaption <> "" then
Response.write tdcaption
End If
If purgefilescaption <> "" then
Response.write purgefilescaption
End if
end if%>
			<tr class="datacol0"><td colspan=16>&nbsp</td></tr>
	
  <%
  d="style='display:none;'"
  If checklistrates <> "" Then
  d=""
  End If
  'onchange="return doSubmit('selectx','')">
  %>
	<tr class="datacol1"  <%=d%>> 
      <td style=font-weight:bold width="85" >&nbsp;Customer: </td>
      <td width="168"><select name="fX1CustId" id="fX1CustId" class="wiztelFields" >
          <option value="0" >---- Select Customer ---- </option>
          <option value="-1">---- All ---- </option>
		 
		  <%=voipCust.WriteCustomerList(X1CustId)%>
        </select></td>
      <td width="119"><b>&nbsp;User: </b></td>
      <td width="149"><select name="fvoipUserId" id="fvoipUserId" class="wiztelFields" onchange="return doSubmit('select','')">

			<%
			v=voipCust.WriteUserListNew(X1CustId,VoipUserId)
			If v > 0 Then  
			VoipUserId= v  
			VoipUserName=voipCust.GetVoipUserName(X1CustId,VoipUserId)
			End If
        	%>
        </select></td>
		</tr>
<%
  d="style='display:none;'"
  If checklistcosts <> "" Then
  d=""
  End If
   %>
<tr class="datacol1"  <%=d%>> 
			<td style=font-weight:bold nowrap title='Vendor' >&nbsp;Vendor:&nbsp;</td><td>
			<select class=dataselect name="vvdId" onchange="return doSubmit('select','');">
              <option value="0" >---- Select Vendor ---- </option>
 				<option value="-1"  <%=selected("-1",vvdId)%> >-- All --</option><%
				set rs=oConn.execute("select vvdId,vvdName,Organization, username from vwVoIPVendor order by Organization, username")
				while not rs.eof
					if rs("vvdId")=vvdId then vvdName=rs("vvdName")%>
					<option value="<%=rs("vvdId")%>" <%=selected(rs("vvdId"),vvdId)%>><%=htmlencode(shortStr(rs("Organization"),18)& " - "&shortStr(rs("username"),18))%></option><%
					rs.movenext
				wend: rs.close%>
			</select>
		</td>
</tr>

</table>

  <table style='display:none' border="0" cellpadding="2" cellspacing="0" bordercolor="#FFFFFF" bgcolor="#FFFFFF" class="datatable">
		
		<tr>
		<%
zLink = siteRoot &"voip/voidialcodes.asp?destination="&Destination&"&dtype="& DestinationType
zLink = zLink & "&carrier="&DestinationMobileCarrier & "&description="&Description
zLink = zLink & "&doc=2"
%>

		<td  nowrap ><b><a href="/z.asp" onclick="return doDialCode(this,'<%=zlink%>')">
		<input  class=datacol0 style="font-size:8pt;font-weight:normal;font-family:Arial;cursor:hand;color:#3333cc;text-decoration:underline;"
         readonly  type=text name=LabelDialCode value="<%=LabelDialCode%>"> </a></b></td>

      </tr>
 	<tr>
	<td></td>
</tr>
  </table>

  <%
  s1=voipCust.GetCustomerName(X1CustId)
  s= " : " & voipUserName
  %>
  <br>
  <%
  If InStr(s,"Select User")>0  Or voipusername = "" Then s = "" End If

  s2=""
  If s = "" Then
  s2=" <BR>Please Select User"
  End if

  %>
   <br>
  
  <table style='display:none'  border="0" cellspacing="0" cellpadding="2" id="idList1">
    <tr class="datacol1"> 
      <td width="72">&nbsp;Status: </td>
      <td ><select name="fStatusId" id="fStatusId" onchange="return doSubmit('select','')">
          <option value="1" <%If (StatusId = "1") then%>selected<%End if%>>Active</option>
          <option value="2" <%If (StatusId = "2") then%>selected<%End if%>>Retired</option>
          <option value="3" <%If (StatusId = "3") then%>selected<%End if%>>Pending</option>
          <option value="0" <%If (StatusId = "0") then%>selected<%End if%>>All</option>
        </select></td>
	</tr>
  </table>
  
     <%

repllist=",pgnpdialpeerstrans?,pgnpgatewaytrans?,pgnpcustpricesnap?,pgnpusersnap?"
repllist=repllist&",pgnproutesnap?,pgnpcustpricetrans?,pgnpdestsnap?,"
repllist=Replace(repllist,"?",meraversion)


If  msgpostgres <> ""Then

dp=False
gw=False
cu=False
user=False
route=False

destsnap=False
cutrans=False
irepl=0
sql=" exec sp_helppublication "

Set rs=oconn.execute(sql)

bopen=  (rs.State = 1) ' is  open
beof=false
If  bopen  Then
beof = rs.eof
End If

If bopen And (Not beof) Then

While  Not rs.eof
u=rs("name")
act=""
typrep=""

If InStr(repllist,","&u&",") > 0 Then

If InStr(u,"dialpeerstrans") > 0 Then
dp =True 
s= "dp" 
u="Dialpeers"
typrep="pgtran"
'lb="Transactional"
End If

If InStr(u,"gatewaytrans") > 0 Then
gw =True 
s = "gw" 
u="Gateways"
typrep="pgtran"
'lb="Transactional"
End If

If InStr(u,"custpricesnap") > 0 Then
cu=True
s="cu"
u="RatesCustomer"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"usersnap") > 0 Then
user=True
s="user"
u="UserCustomers"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"routesnap") > 0 Then
route=True
s="route"
u="UserRoute"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"destsnap") > 0 Then
destsnap=True
s="dest"
u="DestinationUSA"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"custpricetrans") > 0 Then
cutrans=True
s="cutrans"
u="RatesCustomer"
typrep="pgtran"
'lb="Snapshot"

End If

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"stop','"&s&"');"">Stop</a>"

End If ' If InStr(repllist,","&u&",") > 0 Then

v=rs("description")
p=InStr(v," ")
v=Mid(v,1,p-1)
%>
 
  <strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Warning: Transactional Replication for <%=u%> is active <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
 <br>
<%
irepl=irepl+1
rs.movenext
Wend
rs.close

End If ' not beof


If irepl > 0 Then
%>
  <strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Do Not Use Manual Synchronization for transactionaly replicated tables <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
  <br>
<%
End If

%>
    <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Postgres Database <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>
<table class="datatable">
		<tr  class="datacol0" ><td align=center width="80"><br><input type=button   class=databutton  
name="checkskipdb"  value="Check All" onclick="return ccheckskipdb();" ></td>
 <td align=center><b>Force Sync<br></b><input type=checkbox class=datacheckboxn  
name="checkforcesync"  
<%
If forcesync <> "" Then
%> checked 
<%End if%> 
value="y" ></td>
		<td style=font-weight:bold align=center>&nbsp;Postgres Table<br>&nbsp;<select name="pgtable"  >
		<option value="none" <%If pgtable="none" then%> selected<%End if%>>None</option>
		
		<option value="all" <%If pgtable="all" then%> selected<%End if%>>-All-</option>
		<%
		pglistar=Split(pglist,",")
		pglistlen=UBound(pglistar)
		For i=0 To pglistlen
		v=pglistar(i)
		%>
		<option value="<%=v%>" <%If pgtable=v then%> selected<%End if%>><%=v%></option>
		<%next%>
		
		</select>
	</td>
		
		<td style=font-weight:bold  nowrap align=center>&nbsp;Post Group<br>&nbsp;<select name="pgpost"   >
		<option value="1" <%If pgpost="1" then%> selected<%End if%>>Yes</option>
		<option value="2" <%If pgpost="2" then%> selected<%End if%>>No</option>
		<option value="3" <%If pgpost="3" then%> selected<%End if%>>Both</option>
		
		</select>
	</td>

	<td style=font-weight:bold ><br><%=spacesHTML(18)%>
<input class=databutton type='button' value='Apply' 
onclick="return doSubmit('select','');"
/></td>

<td style='display:none' ><b>Full Status&nbsp;&nbsp;</b>
<input type=checkbox class=datacheckboxn  
name="checkfullstatus"  <%If fullstatus <> "" then%> checked <%End if%> value="y" >
</td></td>
		</tr>
		</table><table>
<%=msgpostgres%>
</table>
<%
End If

If (mode = "0" Or mode = "2") And (  checkreplication <> "" ) Then
%>
    <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">List of Replications <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
<table>
<tr><th>Name</th>
<th>Type</th>
<th>Action</th>
</tr>
<%

'repllist=",pgnpdialpeerstrans?,pgnpgatewaytrans?,pgnpcustpricesnap?,pgnpusersnap?"
'repllist=repllist&",pgnproutesnap?,pgnpcustpricetrans?,pgnpdestsnap?,"
'repllist=Replace(repllist,"?",meraversion)

dp=False
gw=False
cu=False
user=False
route=False

destsnap=False
cutrans=False

sql=" exec sp_helppublication "

Set rs=oconn.execute(sql)

bopen=  (rs.State = 1) ' is  open
beof=false
If  bopen  Then
beof = rs.eof
End If

If bopen And (Not beof) Then

While  Not rs.eof
u=rs("name")
act=""
typrep=""

If InStr(repllist,","&u&",") > 0 Then

If InStr(u,"dialpeerstrans") > 0 Then
dp =True 
s= "dp" 
u="Dialpeers"
typrep="pgtran"
'lb="Transactional"
End If

If InStr(u,"gatewaytrans") > 0 Then
gw =True 
s = "gw" 
u="Gateways"
typrep="pgtran"
'lb="Transactional"
End If

If InStr(u,"custpricesnap") > 0 Then
cu=True
s="cu"
u="RatesCustomer"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"usersnap") > 0 Then
user=True
s="user"
u="UserCustomers"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"routesnap") > 0 Then
route=True
s="route"
u="UserRoute"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"destsnap") > 0 Then
destsnap=True
s="dest"
u="DestinationUSA"
typrep="pgsnap"
'lb="Snapshot"

End If

If InStr(u,"custpricetrans") > 0 Then
cutrans=True
s="cutrans"
u="RatesCustomer"
typrep="pgtran"
'lb="Snapshot"

End If


act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"stop','"&s&"');"">Stop</a>"

End If ' If InStr(repllist,","&u&",") > 0 Then

v=rs("description")
p=InStr(v," ")
v=Mid(v,1,p-1)
%>
<tr><td><%=u%></td><td><%=v%></td><td><%=act%></td>
</tr>
<%
rs.movenext
Wend
rs.close

End If ' not beof

If Not gw Then

s = "gw" 
u="Gateways"
typrep="pgtran"
lb="Transactional"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

If Not dp Then

s= "dp" 
u="Dialpeers"
typrep="pgtran"
lb="Transactional"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

If Not cutrans Then

s="cutrans"
u="RatesCustomer"
typrep="pgtran"
lb="Transactional"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If


If Not cu Then

s="cu"
u="RatesCustomer"
typrep="pgsnap"
lb="Snapshot"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

If Not user Then

s="user"
u="UserCustomer"
typrep="pgsnap"
lb="Snapshot"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

If Not route Then

s="route"
u="UserRoute"
typrep="pgsnap"
lb="Snapshot"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

If Not destsnap Then

s="dest"
u="DestinationUSA"
typrep="pgsnap"
lb="Snapshot"

act="<a href="&"/z.asp onclick=""return doSubmit('"&typrep&"','"&s&"');"">Run</a>"

%>
<tr><td><%=u%></td><td><%=lb%></td><td><%=act%></td>
<%
End If

%>


</table>

<%

End If
If (mode = "0" Or mode = "2") And ( checkradius <> "" ) Then

%>
   <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Radius Server <em><font color="#990000">
  </font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>
<table>
<tr><th><b>Mera</b></th><th><b>Action&nbsp;</b></th><th>Config</th><th>Boot</th><th><b>Console&nbsp;</b><th><b>Log&nbsp;</b></th>
<th><b># Lines&nbsp;</b></th><th>Level</th>

<%If CInt(pglevel)=2 then%>
<th style='text-align:center'>Hide</th>
<%End if%>
</tr>
<tr>
<%
s="cat /usr/local/etc/raddb/radiusd.conf | grep tagwiztel  "

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
'redirerr retpg
retpg=ClearAlphaN(retpg)

pgconfig=""

If InStr(retpg,"ms_conf") > 0  then
pgconfig="MSSQL"
End if
If InStr(retpg,"pg_conf") > 0  then
pgconfig="Postgres"
End if

If pgconfig = "" Then
redirerr retpg
End If

s="cat /usr/local/etc/raddb/modecons.txt" '-- cons nocons

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 


logproto=""

If InStr(retpg,"shorttagwiztel") > 0  Then
logproto="short"
End If

If InStr(retpg,"longtagwiztel") > 0  Then
logproto="long"
End If

If logproto = "" Then
redirerr retpg
End If

rquery=""

If pgconfig = "Postgres" then

s="cat /usr/local/etc/raddb/pg.conf | grep routing_query " '-- cons nocons

s=replace(paramUNIXcommand,"@text@",s)

Executor.Application = UNIXcommand

Executor.Parameters=s
  
retpg = Executor.ExecuteDosApp 
retpg=ClearAlphaN(retpg)
p= InStr(retpg,"Calling_Station_Id")
l=Len(retpg)
If p > 0 Then
s=Right(retpg,l-p+1)
Else
redirerr retpg
End If
If InStr(s,"post") > 0 Then
rquery="non stable"
Else
rquery="stable"
End if
End If

act2="<a href="&"/z.asp onclick=""return doSubmit('pgboot','');"">Toggle</a>"
act3="<a href="&"/z.asp onclick=""return doSubmit('pglog','"&logproto&"');"">View </a>"
w=rqf("sboot")
%>
<td title="<%=rquery%>">Mera<%=pgmera%></td><td><%=act2%></td><td>
<select name="pgconfig">
<option value="1" <%if pgconfig="MSSQL" then%> selected <%end if%>>MSSQL</option>
<option value="2" <%if pgconfig="Postgres" then%> selected <%end if%>>Postgres</option>
<option value="3" <%if pgconfig="" then%> selected <%end if%>>Skip</option>
</select>
</td>
<td>
<select name="boot">
<%
w=rqf("sboot")
If w="" Then w="3" End if
%>
<option value="1" <%if w="1" then%> selected <%end if%>>Start</option>
<option value="2" <%if w="2" then%> selected <%end if%>>Stop</option>
<option value="3" <%if w="3" then%> selected <%end if%>>Restart</option>
<option value="4" <%if w="4" then%> selected <%end if%>>Status</option>
<option value="5" <%if w="5" then%> selected <%end if%>>None</option>
</select></td><td>
<select name="logproto">
<option value="1" <%if logproto="short" then%> selected <%end if%>>Short</option>
<option value="2" <%if logproto="long" then%> selected <%end if%>>Long</option>
</select>
</td><td><%=act3%></td><td>
<%
ntail=rqf("sntail")
If ntail = "" Then ntail = "20" End if
%>
 <input type='text' name='ntail' style="font-size:11;text-align:center" size=5  value="<%=ntail%>">
 
</td>
<td>
<select name="pglevel" onchange="return doSubmit('pglog','<%=logproto%>');">
<option value="0" <%if pglevel="0" then%> selected <%end if%>>0</option>
<option value="1" <%if pglevel="1" then%> selected <%end if%>>1</option>
<option value="2" <%if pglevel="2" then%> selected <%end if%>>2</option>

</select>
</td>
<%If CInt(pglevel)=2 then%>
<td>
<select name="pghide" onchange="return doSubmit('pglog','<%=logproto%>');">
<option value="0" <%if pghide="0" then%> selected <%end if%>>Do not hide</option>
<option value="1" <%if pghide="1" then%> selected <%end if%>>DC Not found</option>
<option value="2" <%if pghide="2" then%> selected <%end if%>>CDR Not found</option>
<option value="3" <%if pghide="3" then%> selected <%end if%>>ALL Not found</option>
<option value="4" <%if pghide="4" then%> selected <%end if%>>ALL Good and ALL Not Found</option>

</select>
</td>

<%End if%>
</tr>
</table>
<%
If (msgpostgreslog<>"") Or (msgpostgresboot <> "") Then
If msgpostgreslog <>"" then
msgar=Split(msgpostgreslog,")")
l=UBound(msgar)
k=1
t=msgar(l)
Else
p=InStr(msgpostgresboot,"tagwiztel")
If p > 0 Then
p=p+8
msgpostgresboot=Right(msgpostgresboot,Len(msgpostgresboot)-p)
End if
msgar=Split(msgpostgresboot&"@@@","@@@")
'l=UBound(msgar) = 1
k=0
l=0
t=""
End if
%>
<table class datatable><th>#</th><th><b>Radius Server Log </b><%=t%></th>
<th>Get Cdr</th>
<%If CInt(pglevel)=2 then%>
<th>Vendor</th>
<th>Q931</th>
<%End if%>
<th>Test Route</th>
</tr>
<%
irec=0
For i=k To l

cdrfound=False
cdrdisconnectnormal=False
cdrdstuser=""
cdrq931code=""

s=msgar(l-i)
If msgpostgresboot <> "" Then
s=Replace(s,vbcrlf,"<br>")
end If

cdrtimestamp=""


p=InStr(s,": Auth")
If p > 0 Then
s1=Left(s,p-1)
s1=Trim(s1)
's1=":Ready to process requests. Tue Dec 9 19:01:02 2008"
p=InStr(s1,"requests.") 
If p > 0 Then 
s1=Mid(s1,p+9,Len(s1)-p-8) 
'debugerr ":"&s1&":"
End if
cdrtimestamp=s1

End if


p=InStr(s,"Info")
s=Replace(s,"Info","<br>Info")
If p > 0 Then
s=Replace(s,"Auth","<br>Auth")
End If


actcli=""
p=InStr(s,"dst ")
If p > 0 Then
number=right(s,Len(s)-p-3)

dcfound=True


if CInt(pglevel) >= 1 Then

If Left(number,1) <> "1" Then
trynumber=Mid(number,4,7)
Else
trynumber=Mid(number,1,7)
End If

sql=" select vdsdialcode from tblvoipdestinationusa where vdsdialcode='"&trynumber&"' "

Set rs=oconn.execute(sql)

If rs.eof then
dcfound=false
End If

rs.close

End If ' pglevel=1

ahref=" href=/z.asp"

If CInt(pglevel) = 2 Then


s1= cdrlookup(number,10)


If Not cdrfound Then
ahref="style=font-weight:bold;font-size=10;text-decoration:none;color:magenta href=/z.asp"

else

If Not cdrdisconnectnormal Then
ahref="style=font-weight:bold;font-size=10;text-decoration:none;color:red href=/z.asp"
else
ahref="style=font-weight:bold;font-size=10;text-decoration:none;color:green href=/z.asp"
End if

End If

End If

cdrtimestamp=Replace(cdrtimestamp,":","Xx")

cdrtimestamp=clearalphan(cdrtimestamp)

zLink = siteRoot &"voip/showcdr.asp?cli="&number&"&mera="&meraversion&"&tstamp="&cdrtimestamp

actcli="<a " & ahref & " onclick=""return acctWin(this,'"&zlink&"');"">"&number&"</a>"


End If

d=""
If pghide = "1" And (Not dcfound) Then
d="style='display:none'"
End if

If pghide = "2" And (Not cdrfound) Then
d="style='display:none'"
End if

If pghide = "3" And ( (Not cdrfound) Or (Not dcfound) ) Then
d="style='display:none'"
End if

If pghide = "4" And  ( (Not cdrfound) Or (Not dcfound) or cdrdisconnectnormal ) Then
d="style='display:none'"
End if

If d="" then
irec=irec+1
End if
%>

<tr  class="datarow<%=(irec Mod 2)%>" <%=d%> ><td><%=irec%></td><td nowrap><%=s%></td>

<td ><%=actcli%></td>

<%If CInt(pglevel) = 2 Then

cause=""
If cdrq931code <> "" then
sql="select * from tblQ931code where code="&cdrq931code
Set rs=oconn.execute(sql)
If Not rs.eof then
cause=rs("Cause")
End If
rs.close
End if

%>
<td style='text-align:center' nowrap><%=cdrdstuser%></td>
<td style='text-align:center' nowrap title="<%=cause%>"><%=cdrq931code%></td>

<%
End if
testroute=""
If actcli <> "" then
p=InStr(s,"[")
If p > 0 then
q=InStr(p,s,"/]")
End if
If p > 0 And q > 0 Then
cust=Mid(s,p+1,q-p-1)
End If
srcnum=""
p=InStr(s,"cli ")
If p > 0 Then
q=InStr(p,s,"dst")
End If
If p > 0 And q > 0 then
srcnum=Trim(mid(s,p+3,q-p-4))
End If

'debugerr srcnum& ": <bR> " & p & " " & q & " :" & cust & ":"
zLink = siteRoot &"manager/testdialpeer.asp?ext=y&dstnum="&number&"&srcnum="&srcnum&"&group=no&cust="&cust&"&mera="&meraversion
testroute="<a href="&"/z.asp onclick=""return acctWin(this,'"&zlink&"');"">Test</a>"
End If ' actcli <> ""
If dcfound  then
%>

<td style=text-align:center><%=testroute%></td>

<%else%>

<td style='text-align:center;color=red' nowrap>not found</td>

<%End if%>

</tr>
<%
Next
%>
</table>
<%
end if

End If ' (mode = "0" Or mode = "2") And ( pgmode = "1" )
If ((mode = "0" Or mode = "2") And (pgmode = "0" )) Or (checktabledirectory <> "") Then

If typetabledirectory = "1" Then s="Tables" End If
If typetabledirectory = "2" Then s="Stored Procedure" End If
If typetabledirectory = "3" Then s="SQL Functions" End If

 Set rs=oconn.execute(sqltabledirectory)
  irec=0
  If Not rs.eof Then
  %>
    <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Wiztel <%=s%> Directory <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>
  <br>

 <table>
 <tr><th></th>
 <th>TableName</th>
 <th align=center>Status</th>
 <th align=center>Author</th>
 <th align=center>Comments</th>
 <th align=center><input name='btdstatus' class=databutton type='button'  value='Update'  OnClick="return doSubmit('tdstatus','')"> 
 <th align=center>Definition</th>
 
</th>
  </tr> 
<%

  While Not rs.eof
  irec=irec+1
  id=rs("id")
  t=rs("table_name")
  status=rs("status")
  author=rs("author")
  comments=rs("comments")
  If IsNull(status) Then status = "Unknown" End If
  If IsNull(author) Then author = "" End If

  If IsNull(comments) Then comments = "" End If

  vstatus=rqf("tdstatus"&irec)
  vauthor=Trim(rqf("tdauthor"&irec))
  vcomments=Trim(rqf("tdcomments"&irec))
  
  vauthor=Replace(vauthor,"""","")
  vcomments=Replace(vcomments,"""","")

  'wx(st)
  If vstatus = "" Then vstatus = status End If
  If vauthor = "" Then vauthor= author End If
  If vcomments = "" Then vcomments= comments End If
   vstatus = status
   vauthor= author 
  vcomments= comments 
  
%>
<tr class=datarow<%=(irec Mod 2)%>><td><%=irec%></td>
 <input type='hidden' name='tdid<%=irec%>'  value="<%=id%>">

<td><%=t%></td>
<td nowrap>
<select name="tdstatus<%=irec%>">
<option value="Basic" <%=selected(status,"Basic")%>>Basic</option>
<option value="System" <%=selected(status,"System")%>>System</option>
<option value="Billing" <%=selected(status,"Billing")%>>Billing</option>
<option value="MVTS" <%=selected(status,"MVTS")%>>MVTS</option>
<option value="Reports" <%=selected(status,"Reports")%>>Reports</option>
<option value="USARates" <%=selected(status,"USARates")%>>USARates</option>
<option value="Test" <%=selected(status,"Test")%>>Test</option>
<option value="Unknown" <%=selected(status,"Unknown")%>>Unknown</option>

</select></td>
<td nowrap>
 <input type='text' name='tdauthor<%=irec%>' style="font-size:11;text-align:left" size=5  value="<%=vauthor%>"/>
</td>
<td nowrap>
 <input type='text' name='tdcomments<%=irec%>' style="font-size:11;text-align:left" size=20  maxlength=100 value="<%=vcomments%>"/>
 
</td>
<td nowrap align=center>
 <input type=checkbox class=datacheckboxn  
name="checktdstatus<%=irec%>" value='1' >
</td>
<%
v="sphelp"

If typetabledirectory <> "1" Then v=v & "text" End If
 
%>
 <input type="hidden" name='tdfastData<%=irec%>'  value='<%=(""""&vstatus&""""&vauthor&""""&""""&vcomments&"""")%>' > 
<td nowrap align=center><a href="/z.asp" onclick="return doSubmit('<%=v%>','<%=t%>')">Show</a></td>

</tr>
<%
  rs.movenext
  wend
%>
 <input type="hidden" name="irectdcount"  value="<%=irec%>"/>
</table>
<%
irectdcount=irec
End if
End if

	If ((mode = "0" Or mode = "2") And (pgmode = "0" )) Or (checklistrates <> "") then
  Set rs=oconn.execute(sqlfast)
  irec=0
  If Not rs.eof Then
  %>
    <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Customer Rates USA Continental <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>
  <br>

 <table>
 <tr><th></th>
 <th>Organization</th>
 <th>Username</th>
 <th>Check<br>Status</th>
<th>Min Price</th>
<th>Max Price</th>
<th>Min B.I.</th>
<th>Max B.I.</th>
<th style=text-align:center>Is<br>Active</th>
<th>CLI</th>
<th style=text-align:center>Set New Price</th>
<th style=text-align:center>Set New B.I.</th>
<th style=text-align:center>Max Effect<br>Date</th>
<th style=text-align:center>Max Created<br>Date</th>

  </tr>
  <%


  While Not rs.eof
  irec=irec+1
  x1custid=rs("id")
  customer=rs("voipuserid")
   vdetail=""
   vcheck=rqf("checktablecust"&irec)

  If vcheck <> "" Then
  
   sql=" exec spPostgresInsertHelp2 @detail='y', @tablename='tblVoIPRateCustomerUSA',@post='post', @mera="&meraversion
   sql=sql& ",@pkey='"&customer&"'"
   Set rstest=oconn.execute(sql)

   If Not rstest.eof Then
   vdetail=rstest("tblVoIPRateCustomerUSApost")
   End If
   
   rstest.close

   
  End If
  
  cli=rs("cli")
 ' fax=rs("fax")
  isactive=rs("isactive")
    maxprice=rs("maxprice")
  minprice=rs("minprice")

 maxvbsid=rs("maxvbsid")
  minvbsid=rs("minvbsid")
 
  If IsNull(cli) Then cli=False End If
  'If IsNull(fax) Then fax=False End If
  If IsNull(isactive) Then isactive=False End If
  
  If cli Then
  vcli="1"
  Else
  vcli="0"
  End If
   
  If isactive Then
  visactive="1"
  Else
  visactive="0"
  End If


   u=rs("mcount") 

  sql= " select count(*) as mc from (select distinct usavdsid from tblvoipratecustomerusa where voipuserid="&customer 
  sql=sql & " and isnull(cli,0)="&vcli&" and isnull(isactive,0)="&visactive
  sql=sql &  " ) x "

  Set rstest=oconn.execute(sql)
  
  v=  rstest("mc") 
  
  rstest.close
  
   s=u

  If u <> v Then
  s=s &  ",<br> " &(u-v)&" duplicates detected  " 
  End if  

 sql=" select count(*) as mc from tblvoipdestinationusa  where vdsisactive=1 and ( id not in "
 sql=sql & " (select usavdsid from tblvoipratecustomerusa where voipuserid="&customer
 sql=sql & " ) ) "

  Set rstest=oconn.execute(sql)
  
  w=  rstest("mc") 
  
  rstest.close

   If w > 0 Then
   s= s & ",<br> " & w & " dialcodes are not registered "

   If (maxprice=minprice) And (maxvbsid=minvbsid)then
   s = s & " <br><a href=""/z.asp"" OnClick=""return doSubmit('fix','"&irec&"')"">Fix by Default</a>"
   Else
   s = s & " <br>Fix Manualy Only</a>"
     End If
   
    
   End If
   
   If vcheck <> "" then
     If (vdetail <> "") And (vdetail <> "details 0" ) Then

	 s=s & "<br> <a href=""/z.asp"" OnClick=""return doSubmit('fixresync','"&irec&"')"">Resync Postgres " 
	 s=s & Replace(vdetail,"details","") & " rec </a>"

   Else
   s=s&"<br> Postgres Sync OK"
   End if
   End If

  %>
  <tr class=datarow<%=(irec Mod 2)%>>
  <td><%=irec%></td>
  <td title="x1custid=<%=x1custid%>" nowrap><b><%=rs("organization")%></b> (<%=s%>)</td>
  <td title="voipuserid=<%=customer%>" nowrap><%=rs("username")%></td>
  <%
  style="style=text-align:right"
  If maxprice <> minprice Then
  style=style&";background=yellow"
  End if
  %>
  <td  nowrap><input type=checkbox class=datacheckboxn  
name="checktablecust<%=irec%>" value='1' <%If vcheck <> "" then%> checked <%End if%>>
</td>

  <td <%=style%> ><%=minprice%></td>
  <td <%=style%>><%=maxprice%></td>
 <%
 
  style="style=text-align:center"
  If maxvbsid <> minvbsid Then
  style=style&";background=yellow"
  End if
  
  %>
  
  <td <%=style%>><%=minvbsid%></td>
  <td <%=style%>><%=maxvbsid%></td>

    <%
  v=rs("isactive")
  If IsNull(v) Then v=False End If
  If v Then u="Yes" Else u="No" End If
  %>
  <td style=text-align:center>
<a href="/z.asp" OnClick="return doSubmit('isactive','<%=irec%>')">
		  <%If v  Then%><font color=green>Yes</font><%Else%><font color=red>No</font><%End if%></a>
  
</td>
  <%
  
  v=rs("cli")
  If IsNull(v) Then v=False End If
  If v Then u="Yes" Else u="No" End If
  %>
  <td style=text-align:center>
<a href="/z.asp" OnClick="return doSubmit('cli','<%=irec%>')">
		  <%If v  Then%><font color=green>Yes</font><%Else%><font color=red>No</font><%End if%></a>
  
</td>
  <td style=text-align:center nowrap>
  <input name='bNewPrice<%=irec%>' class=databutton type='button'  value='Submit:'  OnClick="return doSubmit('fastprice','<%=irec%>')"> 
  <input type='text' name='fastPrice<%=irec%>' style="font-size:11;text-align:center" size=5  value="<%=maxprice%>"/>
  <input type='hidden' name='fastCust<%=irec%>' value='<%=customer%>'>

  </td>
   <td style=text-align:center nowrap>
  <input name='bNewBI<%=irec%>' class=databutton type='button'  value='Submit:'  OnClick="return doSubmit('fastbi','<%=irec%>')"> 
  <!--<input type='text' name='fastBi<%=irec%>' style="font-size:11;text-align:center" size=5  value="<%=maxvbsid%>"/>-->
  <select name='fastBi<%=irec%>'>
  <%
  sqlx="select vbsid, cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName " 
  sqlx=sqlx & " from tblvoipbillingstructure order by vbsid"
  Set rstest=oconn.execute(sqlx)
  While Not rstest.eof
  v=rstest("vbsid")
  %>
  <option value="<%=v%>" <%If maxvbsid=v then%>selected<%End if%>><%=v%>:<%=rstest("vbsname")%></option>
  <%
  rstest.movenext
  wend
  rstest.close
  %>
  </select>
  <input type='hidden' name='fastBiCust<%=irec%>' value='<%=customer%>'>

 <input type='hidden' name='fastArray<%=irec%>' value='<%=(customer&":"&vcli&":"&visactive)%>'>

  </td>
  <%
   minxvrceffectdt=rs("minvrceffectdt")
  minvrccreateddt=rs("minvrccreateddt")

  maxvrceffectdt=rs("maxvrceffectdt")
  maxvrccreateddt=rs("maxvrccreateddt")
  u=displayDate(maxvrceffectdt,11)
  v=displayDate(maxvrccreateddt,11)

  If minxvrceffectdt <>  maxvrceffectdt Then
	icolor1="yellow"
	title1="Effect Dates are not the same"
  Else
  	icolor1=""
	title1="Effect Dates are the same"
   End If
  
  If minvrccreateddt <>  maxvrccreateddt Then
  	icolor2="yellow"
	title2="Created Dates are not the same"
  Else
  	icolor2=""
	title2="Created Dates are the same"
  
  End If
  
   
  %>
   <td style=text-align:center nowrap title="<%=title1%>"
   <%If icolor1 <> "" then%>style="background=<%=icolor1%>;"<%End if%> 
   ><%=u%></td>
   <td style=text-align:center nowrap title="<%=title2%>"
   <%If icolor2 <> "" then%>style="background=<%=icolor2%>;"<%End if%> 
   ><%=v%></td>

  </tr>
  <%
  rs.movenext
  Wend
  rs.close
  irecpgcust=irec
  %>
  </table>
  <!--
  </form>
  -->
  <% 
  End If ' not rs.eof
 End If ' 	If mode = "0" Or mode = "2" then
 	If ((mode = "0" Or mode = "2") And (pgmode = "0" )) Or (checklistcosts <> "") Then
 	
	  Set rs=oconn.execute(sqlfastcosts)
  If Not rs.eof Then
  irec=0
  %>
    <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Vendor Costs for USA Continental <em><font color="#990000"></font></em></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>
  <br>

 <table>
 <tr>
  <th></th>
 <th>Organization</th>
 <th>Username</th>
 <th>Check<br>Status</th>
<th>Min Cost</th>
<th>Max Cost</th>
<th>Min B.I.</th>
<th>Max B.I.</th>
<th style=text-align:center>Is<br>Active</th>
<th>Cli</th>
<th>Fax</th>
<th>Order</th>
<th style=text-align:center>Set New Cost</th>
<th style=text-align:center>Set New B.I.</th>
<th style=text-align:center>Max Effect<br>Date</th>
<th style=text-align:center>Max Created<br>Date</th>

  </tr>
  <%
  irec= 0
  While Not rs.eof
  vvdid=rs("vvdid") 
  cli=rs("cli")
  fax=rs("fax")
  isactive=rs("isactive")
  order=rs("order")
   irec=irec+1
 
  vdetail=""
    vcheck=rqf("checktablevend"&irec)
 
  If vcheck <> "" Then
  
   sql=" exec spPostgresInsertHelp2 @detail='y', @tablename='tblVoIPRateUSA',@post='post', @mera="&meraversion
   sql=sql& ",@pkey='"&vvdid&"'"

    Set rstest=oconn.execute(sql)

   If Not rstest.eof Then
   vdetail=rstest("tblVoIPRateUSApost")
   End If
   
   rstest.close

   
  End If

  If IsNull(cli) Then cli=False End If
  If IsNull(fax) Then fax=False End If
  If IsNull(isactive) Then isactive=False End If
   If IsNull(order) Then order=1 End If
 
  If cli Then
  vcli="1"
  Else
  vcli="0"
  End If
  
  If fax Then
  vfax="1"
  Else
  vfax="0"
  End If
  
  If isactive Then
  visactive="1"
  Else
  visactive="0"
  End If

  
  u=rs("mcount")

  sql= " select count(*) as mc from (select distinct vdsdialcode from tblvoiprateusa where vvdid="&vvdid 
  sql=sql & " and isnull(cli,0)="&vcli&" and isnull(fax,0)="&vfax&" and isnull(isactive,0)="&visactive
  sql=sql & " and [order]="&order
  sql=sql &  " ) x "

  Set rstest=oconn.execute(sql)
  
  v=  rstest("mc")
  
  rstest.close
  
   s=u

  If u <> v Then
  s=s &  " <br> " &(u-v)&" duplicates detected  " 


  End If

  If vcheck <> "" then
       If (vdetail <> "") And (vdetail <> "details 0" ) Then
	 s=s & "<br> <a href=""/z.asp"" OnClick=""return doSubmit('fixresynccosts','"&irec&"')"">Resync Postgres " 
	 s=s & Replace(vdetail,"details","") & " rec </a>"
     Else
	 s= s &"<br>Sync OK"
     End if
   End If
   

  %>
  <tr class=datarow<%=(irec Mod 2)%>>
  <td nowrap><%=irec%></td>
  <td nowrap><b><%=rs("organization")%></b> (<%=s%>)</td>
  <td title="vvdid=<%=vvdid%>"><%=rs("username")%></td>
  <td  nowrap><input type=checkbox class=datacheckboxn  
name="checktablevend<%=irec%>" value='1' <%If vcheck <> "" then%> checked <%End if%>>
</td>

  <td style=text-align:right><%=rs("mincost")%></td>
  <%
  maxcost=rs("maxcost")
  %>
  <td style=text-align:right><%=maxcost%></td>
    <td style=text-align:center><%=rs("minvbsid")%></td>
  <%
  maxvbsid=rs("maxvbsid")
  %>
  <td style=text-align:center><%=maxvbsid%></td>

  <%
  
 
  If isactive Then u="Yes" Else u="No" End If
  %>
  <td style=text-align:center>
<a href="/z.asp" OnClick="return doSubmit('isactive','<%=irec%>')">
		  <%If isactive  Then%><font color=green>Yes</font><%Else%><font color=red>No</font><%End if%></a>
  
</td>
   <td style=text-align:center>
<a href="/z.asp" OnClick="return doSubmit('cli','<%=irec%>')">
		  <%If cli Then%><font color=green>Yes</font><%Else%><font color=red>No</font><%End if%></a>
 
</td>
   <td style=text-align:center>
<a href="/z.asp" OnClick="return doSubmit('fax','<%=irec%>')">
		  <%If fax Then%><font color=green>Yes</font><%Else%><font color=red>No</font><%End if%></a>
  
</td>

 <td style=text-align:center><%=order%></td>

   <td style=text-align:center nowrap>
  <input name='bNewPrice<%=irec%>' class=databutton type='button'  value='Submit:'  OnClick="return doSubmit('fastprice','<%=irec%>')"> 
  <input type='text' name='fastPrice<%=irec%>' style="font-size:11;text-align:center" size=5  value="<%=maxcost%>"/>

  </td>
   <td style=text-align:center nowrap>
  <input name='bNewBI<%=irec%>' class=databutton type='button'  value='Submit:'  OnClick="return doSubmit('fastbi','<%=irec%>')"> 
  <!--<input type='text' name='fastBi<%=irec%>' style="font-size:11;text-align:center" size=5  value="<%=maxvbsid%>"/>-->
  <select name='fastBi<%=irec%>'>
  <%
  sqlx="select vbsid, cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName " 
  sqlx=sqlx & " from tblvoipbillingstructure order by vbsid"
  Set rstest=oconn.execute(sqlx)
  While Not rstest.eof
  v=rstest("vbsid")
  %>
  <option value="<%=v%>" <%If maxvbsid=v then%>selected<%End if%>><%=v%>:<%=rstest("vbsname")%></option>
  <%
  rstest.movenext
  wend
  rstest.close
  %>
  </select>
  
  <input type='hidden' name='fastArray<%=irec%>' value='<%=(vvdid&":"&vcli&":"&vfax&":"&visactive&":"&order)%>'>

  </td>
  <%
   minxvrteffectdt=rs("minvrteffectdt")
  minvrtcreateddt=rs("minvrtcreateddt")

  maxvrteffectdt=rs("maxvrteffectdt")
  maxvrtcreateddt=rs("maxvrtcreateddt")
  u=displayDate(maxvrteffectdt,11)
  v=displayDate(maxvrtcreateddt,11)

  If minxvrteffectdt <>  maxvrteffectdt Then
	icolor1="yellow"
	title1="Effect Dates are not the same"
  Else
  	icolor1=""
	title1="Effect Dates are the same"
   End If
  
  If minvrtcreateddt <>  maxvrtcreateddt Then
  	icolor2="yellow"
	title2="Created Dates are not the same"
  Else
  	icolor2=""
	title2="Created Dates are the same"
  
  End If
  
   
  %>
   <td style=text-align:center nowrap title="<%=title1%>"
   <%If icolor1 <> "" then%>style="background=<%=icolor1%>;"<%End if%> 
   ><%=u%></td>
   <td style=text-align:center nowrap title="<%=title2%>"
   <%If icolor2 <> "" then%>style="background=<%=icolor2%>;"<%End if%> 
   ><%=v%></td>

  </tr>
  <%
  rs.movenext
  Wend
  rs.close
  irecpgvend=irec

  %>
  </table>
   <% 
  End If ' not rs.eof

  End If ' 	If mode = "0" Or mode = "2" then

   If mode = "1" Or mode = "2" then

  Dim  sqlQuery
  
  If doretire <> "" Then

s1=rqf("orgdest")
s2=rqf("orgtype")

  If s1 = "" Then
	DestinationString = ""
  Else
	DestinationString = " AND vdsName LIKE '"&s1&"%' "   
  End If

  If s2 = "" Then
	DestinationTypeString = ""
  Else
	DestinationTypeString = " AND vdsType LIKE '"&s2&"%' "  
  End If

Else ' doretire

  If Destination = "" Or Destination = "0" Then
	DestinationString = ""
  Else
	DestinationString = " AND vdsName LIKE '"&Destination&"%' "   
  End If

  If DestinationType = "" Then
	DestinationTypeString = ""
  Else
	DestinationTypeString = " AND vdsType LIKE '"&DestinationType&"%' "  
  End If

End If ' doretire


  If DestinationMobileCarrier = "" Then
	DestinationMobileCarrierString = ""
  Else
	DestinationMobileCarrierString = " AND isnull(ltrim(rtrim(vdsMobileCarrier)),'') = '"&trim(DestinationMobileCarrier)&"' "  
  End If
 
  If Description = "" Then
	DescriptionString = ""
  Else
	DescriptionString = " AND isnull(ltrim(rtrim(vdsDescription)),'') = '"&trim(Description)&"' "  
  End If
  
If DialCodesSelect = "" Then
DialCodesSelectString=""
else
   s="'" & Replace(DialCodesSelect,",","','") & "'"
   DialCodesSelectString= " and vdsDialCode in (" & s & ")" 
End If

  If TierId = "" Then
	TierIdString = ""
  Else
	TierIdString = " AND rc.vtrId = '"&TierId&"' "  
  End If

retirementString = "  "	

if StatusId>0 then 

If StatusId = 1 Then ' active

'retirementString =  " and isnull(vr.vrtRetireDt, getdate()) >= getdate() and vr.vrtEffectDt < getdate()   "
'retirementString =  " and isnull(rc.vrcRetireDt, getdate()) >= getdate() and rc.vrcEffectDt < getdate()   "
retirementString =  " and isnull(isnull(rc.vrcRetireDt,vr.vrtretiredt), getdate()) >= getdate() and isnull(rc.vrcEffectDt,vr.vrteffectdt) < getdate()   "

End If

If StatusId = 2 Then ' retired

'retirementString = " and  vr.vrtRetireDt < getdate() "
'retirementString = " and  rc.vrcRetireDt < getdate() "
retirementString = " and  isnull(rc.vrcRetireDt,vr.vrtretireDt) < getdate() "

End If

If StatusId = 3 then ' pending

'retirementString = " and  getDate() < vr.vrtEffectDt  "
retirementString = " and  getDate() < rc.vrcEffectDt  "

End If

End If ' iRetireStatus > 0

If vvdid <> "" Then

vvdidstring= " and vr.vvdid=" & vvdid 

Else

vvdidstring = ""

End if


   zsql="SELECT vr.vvdid, vr.vdsDialCode, ds.state , "
   zsql=zsql & " cast(bs.vbsInitialMinSecsPerCall as varchar) +'/' +cast(bs.vbsIncrements as varchar) vbsName, "
   zsql=zsql & " vr.vrtCost, vr.vrteffectdt, vr.vbsid , vrc.* FROM tblVoIPRateCustomerUSA vrc  "		


sqlQuery =" select distinct  ds.State, count(*) as mcount, xc.organization as customer, " 
sqlQuery=sqlQuery & " xc.id as x1custid, vuc.id as usercustid, " 
sqlQuery=sqlQuery & " vuc.username custusername,  " 
 sqlQuery=sqlQuery & " xc1.organization as vendor, xc1.id as x1vendid,  " 
 sqlQuery=sqlQuery &" vu.voipUserVendId as vendid, vu.username as vendusername, " 
  sqlQuery=sqlQuery & " max(vr.vrtCost) as maxcost, min(vr.vrtCost) as mincost, " 
      sqlQuery=sqlQuery & " max(vrc.vrcPrice) as maxprice, min(vrc.vrcPrice) as minprice, " 
      sqlquery=sqlquery & " max(vrc.vbsid) as maxcustvbsid, min(vrc.vbsid) as mincustvbsid, "
    sqlquery=sqlquery & " max(vr.vbsid) as maxvendvbsid, min(vr.vbsid) as minvendvbsid, "
      sqlquery=sqlquery & " max(isnull(vrc.vrcEffectDt,'12/31/5999')) as maxefd, "
      sqlquery=sqlquery & " min(isnull(vrc.vrcEffectDt,'12/31/5999')) as minefd, "
      sqlquery=sqlquery & " max(isnull(vr.vrtEffectDt,'12/31/5999')) as maxefdvendor, "
      sqlquery=sqlquery & " min(isnull(vr.vrtEffectDt,'12/31/5999')) as minefdvendor "
    
 sqlQuery=sqlQuery & "  from tblVoipUsercustomer vuc "
   
  sqlQuery=sqlQuery &  " join tblVoipRateCustomerUSA vrc on vuc.id=vrc.voipUserid "

 sqlQuery1=sqlQuery

  sqlQuery2=  " join tblVoipRateUSA vr on vrc.usavdsid=vr.usavdsid "
  sqlQuery2=sqlQuery2 & " join tblVoipUserRoute vu on vr.vvdId=vu.voipUserVendId "
 sqlQuery2=sqlQuery2 & " join x1customer xc on xc.id=vuc.x1custid "
 sqlQuery2=sqlQuery2 & " join x1customer xc1 on xc1.id=vu.x1custid "
 sqlQuery2=sqlQuery2 & " join tblVoipDestinationUSA ds on ds.id=vr.usavdsid "
  

 sqlQuery3=   " where ds.vdsisactive=1 " 

 If X1CustId <> "-1" then
     sqlQuery3=sqlQuery3 & " and xc.id = '"&X1CustId&"'  "
 End If

sqlquery=sqlQuery & sqlQuery2 & sqlQuery3	
 sqlQuery=sqlQuery & " group by vuc.id, vuc.username, vu.voipUserVendId , vu.username, "
 sqlQuery=sqlQuery & " xc.organization, xc1.organization , xc.id, xc1.id , ds.state "
 'sqlQuery=sqlQuery & " order by xc.organization, xc1.organization, State, vuc.username,vu.username  "
 sqlQuery=sqlQuery & " order by xc.organization, State, xc1.organization,  vuc.username,vu.username  " 
  

If True Then ' Not (intention = "addnewrate" Or  intention = "addgrpsave") Then
If destination <> "" then
Set rs=oconn.execute(sqlquery)
iRec=0
If rs.eof Then
%>
</td></tr>
<tr><td>
<table align=left>
	<tr><td class=datarow1  align=center><i>No rates matching selection</i></td></tr>	
</table>
</td></tr>
<tr><td>
<%
else
%>
</td></tr>
<tr><td>
 <br>
  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">List of 
  Rates for Customer <em><font color="#990000"><%=s1%><%=s%></font></em><%=s2%></font></strong>&nbsp;&nbsp;&nbsp;&nbsp;
   <br>

<table align=left>
<tr>
 <th width='5'>&nbsp;</th>
 <th>Vendor</th>
 <th>Route</th>
 <th>Max Cost</th>
 <th>Max Price</th>
  <th style=text-align:center nowrap>Max Vend <br>Billing Inc</th>
 <th style=text-align:center nowrap>Max Cust <br>Billing Inc</th>

 <th style=text-align:center nowrap>Max Vend <br>Effect Date</th>
 <th style=text-align:center nowrap>Max Cust <br>Effect Date</th>
 <th style=text-align:center>Details</th>
 <%If statusid = 1 then%>
  <%End if%>
</tr>
<%
orgc="?"
igrp=0
irec=0
While Not rs.eof 
irec=irec+1

orgefdt=""
If statusid= 2 then
orgefdt=rs("vrcEffectdt")
End If

orgcustomer=rs("customer")
state=rs("state")

orgn=orgcustomer & " " & state

if orgc <> orgn Then
orgc=orgn
iGrp=iGrp+1
irec=1
%>
<tr class="datacol0">
<td colspan=12 style=text-align:left nowrap><b><%=orgcustomer%>&nbsp;&nbsp;&nbsp;&nbsp;</b><b><%=state%>&nbsp;&nbsp;&nbsp;&nbsp;</b>
</td>
</tr>
<%
End If ' orgc <> org

org=rs("vendor")
username=rs("vendusername")
vvdid=rs("vendid")

mc=rs("mcount")

maxcost=rs("maxcost")
mincost=rs("mincost")
If maxcost <> mincost Then
col="yellow"
Else
col=""
End If

maxprice=rs("maxprice")
minprice=rs("minprice")
If maxprice <> minprice Then
col01="yellow"
Else
col01=""
End If

maxvbsid=rs("maxcustvbsid")
minvbsid=rs("mincustvbsid")
If maxvbsid <> minvbsid Then
col1="yellow"
Else
col1=""
End if
mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
mystr=mystr & " where vbsid="& maxvbsid

set myrs = oConn.execute(myStr) 

maxvbsname=myrs("vbsname")
     
myrs.close

maxvendvbsid=rs("maxvendvbsid")
minvvendbsid=rs("minvendvbsid")
If maxvendvbsid <> minvendvbsid Then
col101="yellow"
Else
col101=""
End if
mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
mystr=mystr & " where vbsid="& maxvendvbsid

set myrs = oConn.execute(myStr) 

maxvendvbsname=myrs("vbsname")
     
myrs.close

maxefd=rs("maxefd")
minefd=rs("minefd")

If maxefd <> minefd Then
col3="yellow"
Else
col3=""
End If

maxefdvendor=rs("maxefdvendor")
minefdvendor=rs("maxefdvendor")
If maxefdvendor <> minefdvendor Then
col30="yellow"
Else
col30=""
End If

%>
<tr class=datarow<%=irec Mod 2%>>
<td><%=irec%></td>
<td nowrap><%=org%> : <%=rs("mcount")%></td>
</td>
<td nowrap><%=username%>
</td>
<td <%if col <> "" then%>style="background:<%=col%>"<%End if%> align=center><%=FormatNumber(maxcost,4)%></td>
<td <%if col01 <> "" then%>style="background:<%=col01%>"<%End if%> align=center><%=FormatNumber(maxprice,4)%></td>
<td <%If col101 <> "" then%>style="background:<%=col1%>"<%End if%> align=center><%=maxvendvbsname%></td>
<td <%If col1 <> "" then%>style="background:<%=col1%>"<%End if%> align=center><%=maxvbsname%></td>
<%
s=maxefdvendor
If Year(s) = "5999"  Then
s="--never--"
Else
s=displaydate(s,11)
minval1=s
End if
%>
<td <%If col30 <> "" then%>style="background:<%=col30%>"<%End if%> align=center nowrap><%=s%></td>

<%s=maxefd
If Year(s) = "5999"  Then
s="--never--"
Else
s=displaydate(s,11)
minval2=s
End if
%>
<td <%If col3 <> "" then%>style="background:<%=col3%>"<%End if%> align=center nowrap><%=s%></td>

<%


  s=zsql 

  s=s & "  join tblVoipUsercustomer vuc on vuc.id=vrc.voipuserid "

  s =s & sqlquery2 
  s=s & " join  tblVoIPBillingStructure bs on bs.vbsId = vrc.vbsid " 
 
  If statusid = 2 Then
  s=s & " and rc.vrceffectdt='" & orgefdt & "' " 
  End If
  s= s & sqlquery3

  s=s & " and ds.state = '"&state&"' "
  s=s & " and vr.vvdid="&vvdid
  
  s=Replace(s,"'",":quote:")
  s=Replace(s,"+",":plus:")

  zlink = siteRoot & "voip/showcustratesusa.asp?sql="& s 
  
  s= "&org="&org&"&user="&username

  
  s=Replace(s,"'",":quote:")
  s=Replace(s,"+",":plus:")
  
  zlink=zlink & s


%>
<td nowrap><a href="/z.asp" onclick="return acctWin1(this,'<%=zLink%>',1150,650,50,10);">Show Details</a>
</td>
</tr>
<%
rs.movenext
Wend
rs.close

%>
</table>
<% 
End If ' If destination <> "" then
End If ' If mode = "1" Or mode = "2" then

%>
</td></tr>
<tr><td>
</td></tr>
<tr><td>
<%End If
 End If '  If intention = "addnewrate" Or  intention = "addgrpsave" Then
%>
  <br>
  <br>

<%If False And   voipuserid <> "0" And Tierid <>"" And intention <> "retiregrp" And destination <> ""  And voipusername <> ""  then
%>

  <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Add New 
  Rates for Customer <em><font color="#990000"><%=voipCust.GetCustomerName(X1CustId)%>&nbsp;:&nbsp;<%=voipUserName%></font></em></font></strong>

<%If destination <> "0" then%>

  <br>
    <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">For Destination<em><font color="#990000">
  <%=Destination%>&nbsp;<%=DestinationType%>&nbsp;<%=DestinationMobileCarrier%>&nbsp;<%=Description%>&nbsp;<%=LabelDialCode%></font></em>
  </font></strong>

 		 <br><br>
		 <%
		 If AddVendorId = "" Then
         AddVendorId=0
		 End if
		 %>
  <table  border="0" cellspacing="0" cellpadding="2">
	<tr style="height:25;" align='center' class='datacol1'><td colspan='18'> Vendor: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <select name='fAddVendorId' id='fAddVendorId' class='wiztelFields' style='width: 280;' onchange="return doSubmit('select','')">
    <option value='0' selected>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;---- All ---- </option>     
    <% = voipCust.WriteVendorList1(AddVendorId, Destination, DestinationType ,DestinationMobileCarrier , Description, DialCodesSelect ) %>    </select>     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input name='fAddNewRate' class=databutton type='button' id='fAddNewRate' value='Add New Rates'  OnClick="return doSubmit('addnewrate','')">        
	</td></tr>
</table>
<%else%>
  <br>
    <strong><font size="3" face="Verdana, Arial, Helvetica, sans-serif">Please Select Destination<em><font color="#990000">
<%
End if
End If
If intention = "addnewrate" Or  intention = "addgrpsave" Or intention="addallgrpsave" Or intention="skipallgrp" Then
%>
<br>
 <%
 

   DescriptionString = ""
   DestinationMobileCarrierString = ""
   DestinationTypeString=""
   DestinationString=""
   DialCodesSelectString=""

	
	If Not(Destination = "") Then
		DestinationString = " , @Destination='"&Destination&"'"
	End If
	If Not(DestinationType = "") Then
		DestinationTypeString = " , @DestinationType='"&DestinationType&"' "
	End If
	If Not(DestinationMobileCarrier = "") Then
		DestinationMobileCarrierString = " , @DestinationMobileCarrier='"&trim(DestinationMobileCarrier)&"' "
	End If

	
	If Not(Description = "") Then
		DescriptionString = " , @Description='"&trim(Description)&"' "
	End If

  
If Not( DialCodesSelect = "") Then
   s="''" & Replace(DialCodesSelect,",","'',''") & "''"
   DialCodesSelectString= " , @DialCodesSelect= " & "'" & s &  "'"
End If

filt=DestinationString&DestinationTypeString&DestinationMobileCarrierString&DescriptionString&DialCodesSelectString

sql= "Exec spViewCustomerDestHeaderVendorRates2 @voipUserId='"&voipUserId&"', @TierId='"&TierId&"' "

If AddVendorId > 0 Then
        sql=sql & ", @vrUserId = '"&AddVendorId&"' "
End if

sql=sql &  filt

  
  If KeepTempTable = "" Then
  Set thers=oConn.execute(sql)

 
  user=Request.Cookies("userUnixName")

sess=GetSessionID(tblTempVoIPRateCustomer)

sqla = " delete tblvoipratelock where userby = '" & user & "' and session=" & sess

oconn.execute(sqla)

  oconn.execute ("delete " & tblTempVoIPRateCustomer)
  
  group=100
  orgc="?"

  While Not thers.eof
  
  group=group+1
  voipuservendid=thers("vvdid")

  orgdest=theRs("vdsname")
orgtype=theRs("vdsType")

orgn=orgdest & "  " & orgtype

if orgc <> orgn then
   
   orgc=orgn

   DescriptionString = ""
   DestinationMobileCarrierString = ""
   DestinationTypeString=""
   DestinationString=""
   DialCodesSelectString=""

	
	If Not(orgdest = "") Then
		DestinationString = " , @Destination='"&orgdest&"'"
	End If
	
	If Not(orgtype = "") Then
		DestinationTypeString = " , @DestinationType='"&orgtype&"' "
	End If

	If Not(Trim(DestinationMobileCarrier) = "") Then
		DestinationMobileCarrierString = " , @DestinationMobileCarrier='"&trim(DestinationMobileCarrier)&"' "
	End If

	

	If Not(Trim(Description) = "") Then
		DescriptionString = " , @Description='"&trim(Description)&"' "
	End If

  
If Not( DialCodesSelect = "") Then
   s="''" & Replace(DialCodesSelect,",","'',''") & "''"
   DialCodesSelectString= " , @DialCodesSelect= " & "'" & s &  "'"
End If

filt=DestinationString&DestinationTypeString&DestinationMobileCarrierString&DescriptionString&DialCodesSelectString


 End if


  sqla="exec spViewCustomerVendorRatesTmpPrepareProcess2 "
  sqla= sqla & " @tblTempVoIPRateCustomer = '" & tblTempVoIPRateCustomer & "',"
  sqla= sqla & " @group = " & group & ","
  sqla= sqla & " @TierId = " & TierId & ","
  sqla= sqla & " @voipUserid = " & voipuserid & ","
  sqla= sqla & " @vrUserId = " & voipuservendid 
  sqla= sqla & filt

  oconn.execute(sqla)

  thers.movenext

  Wend

  thers.close

  lista=CheckLockAbs()

  list=""
  
  If lista = "" Then
  
  list=CheckLock1(tblTempVoIPRateCustomer)
  
  End If
  
  s=""

  If lista <>  ""  Then
  s=s&"Billing subsystem is locked by another user:<br> " & lista
  End If


  If list <> "" Then
    
	s=s&"Customer Rates are locked by another user:<br>" & list
  
  End If
  
  If s <> "" Then
        redirerr(s)
  End If
  
  WriteLock1  tblTempVoIPRateCustomer 

  End If
  
  Set thers=oConn.execute(sql)

%>
 <table>
			   <tr height=30>
			   <th width=350></th>
   			   <th style=text-align:center nowrap>Check<br>New<br>Price</th>
			   <th></th>
			   <th style=text-align:center nowrap>New<br>Price</th>
			   <th></th>
			   <th style=text-align:center nowrap>New<br>B.I.</th> 
               <th></th>
 			   	<th style=text-align:center nowrap>New Cust<br>Effect Date</th> 
               <th></th>
			   	<th style=text-align:center nowrap>New Cust<br>Retire Date</th> 
               <th></th>
			   </tr>
			   <tr>
			   <td width=350></td>
                 <td ><select name='CheckNewPrice2copy'>
				 <%v=rqf("CheckNewPrice2copy")%>
				 <option value="0" <%If v = "0" then%>selected<%End if%>>Deny</option>
                 <option value="1" <%If v = "1" then%>selected<%End if%>>Allow</option>
				 </select>
                 </td>
				 <td><input class=databutton type=button name=buttoncopyall value="Copy To All" 
                onclick="return doCopy2All('0')">
                </td>
               
			    <td ><input type='text' name='newCustPrice2copy' style="font-size:11;text-align:center" size=5  value="<%=rqf("newCustPrice2copy")%>"/></td>
				 <td><input class=databutton type=button name=buttoncopyall value="Copy To All" 
                onclick="return doCopy2All('1')">
                </td>
			    <td >
				<select class=dataselect name='newBi2copy'>
<option value='0'>-- All --</option><%
set rstest=oConn.execute("select vbsId, cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure")
'i=1
v=rqf("newBi2copy")
If v = "" Then v= 0 End If
v=CInt(v)
while not rstest.eof
u=rstest("vbsid")
%>
<option  value="<%=u%>" <%If v=u then%>selected<%End if%>> 
<%=shortStr(rstest("vbsName"),12)%></option>
<%rstest.movenext
Wend
rstest.close%>
</select>
	</td>
				 <td><input class=databutton type=button name=buttoncopyall value="Copy To All" 
                onclick="return doCopy2All('2')">
                </td>
			    <td ><input type='text' name='newEffectDt2copy' style="font-size:11;text-align:center" size=8  value="<%=rqf("newEffectDt2copy")%>"/></td>
				 <td><input class=databutton type=button name=buttoncopyall value="Copy To All" 
                onclick="return doCopy2All('4')">
                </td>


			    <td ><input type='text' name='newRetireDt2copy' style="font-size:11;text-align:center" size=8  value="<%=rqf("newRetireDt2copy")%>"/></td>
				 <td><input class=databutton type=button name=buttoncopyall value="Copy To All" 
                onclick="return doCopy2All('3')">
                </td>

 			   </tr>
			   </table>
			
  <table  border="0" cellspacing="0" cellpadding="2">

  <%

NoMatchingVendors=false

If thers.eof Then

NoMatchingVendors=true

%>
<tr><td class=datarow1 colspan=10 align=center><i>No vendors matching selection or Route Retire Dates < CurrentDate + 7</i></td></tr>	
<%
End If

thers.close

%>
 </table>

<%
if not NoMatchingVendors then

sql="select ds.vdsname, ds.vdstype, xc.organization, ur.username, vr.vvdid, count(*) as mcount, " 
sql = sql & " sum(cast(rc.vrtExists as int)) as cexists, sum(cast(rc.custpend as int)) as ccustpend, sum(cast(rc.vendpend as int)) as cvendpend, "
sql = sql & " max(vrtCost) as maxcost, min(vrtCost) as mincost, "
sql = sql & " max(rc.hvrcPrice) as maxprice, min(rc.hvrcPrice) as minprice, "
sql = sql & " max(rc.hvbsid) as maxvbsid, min(rc.hvbsid) as minvbsid, "
sql = sql & " max(rc.hvrcEffectdt) as maxvrceffectdt, min(rc.hvrcEffectdt) as minvrceffectdt, "
sql = sql & " max(vr.vrtEffectdt) as maxvrteffectdt, min(vr.vrtEffectdt) as minvrteffectdt, "
sql = sql & " max(isnull(rc.hvrcRetiredt,'12/31/5999')) as maxvrcretiredt, "
sql=  sql & " min(isnull(rc.hvrcRetiredt,'12/31/5999')) as minvrcretiredt, "
sql = sql & " max(isnull(vr.vrtRetiredt,'12/31/5999')) as maxvrtretiredt, "
sql = sql & " min(isnull(vr.vrtRetiredt,'12/31/5999')) as minvrtretiredt, "
sql = sql & " max(rc.grp) as grpindex, "
sql = sql & " max(rc.cvrcprice) as cvrcprice, "
sql = sql & " max(rc.cvbsid) as cvbsid, "
sql = sql & " max(rc.cvrcEffectDt) as cvrcEffectDt, "
sql = sql & " max(rc.cvrcRetireDt) as cvrcRetireDt, "
sql = sql & " max(isnull(rc.rsid,0)) as maxrsid, "
sql = sql & " min(isnull(rc.rsid,0)) as minrsid, "
sql = sql & " max(rc.crsid) as crsid, "
sql = sql & " max(cast(isnull(rc.skip,0) as int)) as skip "
sql=sql & " from " & tblTempVoIPRateCustomer & " rc "
sql=sql & " join tblVoipRate vr on vr.vrtid=rc.vrtid "
sql=sql & " join tblVoipUserRoute ur on ur.voipuservendid=vr.vvdid "
sql=sql & " join x1customer xc on xc.id=ur.x1custid "
sql=sql & " join tblvoipdestination ds on ds.vdsid=vr.vdsid "
sql=sql & " group by ds.vdsname, ds.vdstype, xc.organization, ur.username , vr.vvdid, rc.skip, rc.grp "
sql=sql & " , rc.cvrcprice , rc.cvbsid, rc.cvrcEffectDt, rc.cvrcRetireDt"
sql=sql & " order by isnull(rc.skip,0), ds.vdsname, ds.vdstype, xc.organization, ur.username , vr.vvdid "



%>
</td></tr>
<tr><td>
 <table  border="0" cellspacing="0" cellpadding="2">
<tr >
<th>&nbsp;</th>
<th style=text-align:center nowrap>Skip<br>Group</th> 
<th style=text-align:center nowrap>Vendor</th>
<th style=text-align:center nowrap>Max<br>Cost</th>
<th style=text-align:center nowrap>Max<br>B.I.</th>
<th style=text-align:center nowrap>Check<br>New<br>Price</th>
<th style=text-align:center nowrap>New<br>Price</th>
<th style=text-align:center nowrap>New<br>B.I.</th> 
<th style=text-align:center nowrap>New Cust <br>Effect Date</th> 
<th style=text-align:center nowrap>New Cust <br>Retire Date</th> 
<th style=text-align:center nowrap>New Cust <br>RSID</th> 
<th style=text-align:center nowrap>Group<br>Operation</th> 
<th style=text-align:center nowrap>Edit<br>Details</th> 
<th style=text-align:center nowrap>Max<br>Price</th>
<th style=text-align:center nowrap >Max Vend<br>Effect Date</th>
<th style=text-align:center nowrap >Max Vend <br>Retire Date</th>
<th style=text-align:center nowrap>Max Cust <br>Effect Date</th>
<th style=text-align:center nowrap>Max Cust <br>Retire Date</th>

</tr>
<%
irec=0
iact=0
orgc="?"
skipc=0

Set thers=oconn.execute(sql)

While Not thers.eof
irec=irec+1
c=thers("cexists")
c1=thers("mcount") - c
cpcust=thers("ccustpend")
cpvend=thers("cvendpend")
org=thers("organization")
username=thers("username")

	  maxcost=theRs("maxcost")
	  maxprice=theRs("maxprice")
      mincost=theRs("mincost")
	  minprice=theRs("minprice")
	  	 
	  minvbsid=theRs("minvbsid")
	  maxvbsid=theRs("maxvbsid")

skip=theRs("skip")

grpindex=theRs("grpindex")

mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
mystr=mystr & " where vbsid="& maxvbsid

	 set myrs = oConn.execute(myStr) 

	 maxvbsname=myrs("vbsname")
     
	 myrs.close

  If maxcost <> mincost Then
	icolor1="yellow"
	title1="Vendor Costs are not the same"
	Else
	icolor1=""
    title1="All Vendor Costs are the same"
	End If

  If maxprice <> minprice Then
	icolor2="yellow"
	title2="Customer Prices are not the same"
	Else
	icolor2=""
    title2="All Customer Prices are the same"
	End If

  If minvbsid <> maxvbsid Then
	icolor3="yellow"
	title3="Billing Increments are not the same"
	Else
	icolor3=""
    title3="All Billing Increments are the same"
	End If

    minvrteffectdt=theRs("minvrteffectdt")

	If Year(CDate(minvrteffectdt)) = 5999 Then minvrteffectdt = "--never--" End if

    maxvrteffectdt=theRs("maxvrteffectdt")
	If Year(CDate(maxvrteffectdt)) = 5999 Then 
	maxvrteffectdt = "--never--"
    End If
    
  If minvrteffectdt <> maxvrteffectdt Then
	icolor4vrteff="yellow"
	title4vrteff="Route Effect Dates are not the same"
	Else
	icolor4vrteff=""
    title4vrteff="All Route Effect Dates are the same"
	End If
    
	max1=""
	If maxvrteffectdt <> "--never--" Then
	max1=maxvrteffectdt
	maxvrteffectdt=displayDate(maxvrteffectdt,11)
	End if

	minvrtretiredt=theRs("minvrtretiredt")

	If Year(CDate(minvrtretiredt)) = 5999 Then minvrtretiredt = "--never--" End if

    maxvrtretiredt=theRs("maxvrtretiredt")
	If Year(CDate(maxvrtretiredt)) = 5999 Then
	maxvrtretiredt = "--never--" 
	End if
	
  If minvrtretiredt <> maxvrtretiredt Then
	icolor4vrtrt="yellow"
	title4vrtrt="Route Retire Dates are not the same"
	Else
	icolor4vrtrt=""
    title4vrtrt="All Route Retire Dates are the same"
	End If

   	If maxvrtretiredt <> "--never--" then
	maxvrtretiredt=displayDate(maxvrtretiredt,11)
	End if

    minvrceffectdt=theRs("minvrceffectdt")

	If Year(CDate(minvrceffectdt)) = 5999 Then minvrceffectdt = "--never--" End if

    maxvrceffectdt=theRs("maxvrceffectdt")
	If Year(CDate(maxvrceffectdt)) = 5999 Then
	maxvrceffectdt = "--never--" 
	End if
	
	If c = 0 Then
	
	If maxvrceffectdt = max1 then
	minvrceffectdt="--none--"
    maxvrceffectdt="--none--"
    End If
    
	End If
	

  If minvrceffectdt <> maxvrceffectdt Then
	icolor4vrceff="yellow"
	title4vrceff="Customer Effect Dates are not the same"
	Else
	icolor4vrceff=""
    title4vrceff="All Customer Effect Dates are the same"
	End If
    
	max2=""
	If (maxvrceffectdt <> "--never--") And (maxvrceffectdt <> "--none--") Then
   	max2=maxvrceffectdt
	maxvrceffectdt=displayDate(maxvrceffectdt,11)
	End if

    minvrcretiredt=theRs("minvrcretiredt")

	If Year(CDate(minvrcretiredt)) = 5999 Then minvrcretiredt = "--never--" End if

    maxvrcretiredt=theRs("maxvrcretiredt")
	If Year(CDate(maxvrcretiredt)) = 5999 Then
	maxvrcretiredt = "--never--" 
	End if
	
  If minvrcretiredt <> maxvrcretiredt Then
	icolor4vrcrt="yellow"
	title4vrcrt="Customer Retire Dates are not the same"
	Else
	icolor4vrcrt=""
    title4vrcrt="All Customer Retire Dates are the same"
	End If

   	If maxvrcretiredt <> "--never--" then
	maxvrcretiredt=displayDate(maxvrcretiredt,11)
	End if

    
	s=""

    If  max2 <> "" Then 'vrc
        s=CStr(dateadd("d", 1, max2))
	Else
	   If max1 <> "" then 'vrt
  	     If c > 0 Then ' number of existed
           s=CStr(dateadd("d", 1, max1))
	      Else
	       s=max1

	     End If
       End if  
	End If

    If s <> "" then
   	newvrceffectdt=displayDate(s,11)
    Else
    newvrceffectdt=""
    End If
    
	' last requirement

    tc=   Dateadd("n", 30,  Now() ) 

    If Minute(tc) <= 30 Then
                    s3=month(tc)&"/"&day(tc)&"/"&year(tc)&" " & Hour(tc) & ":00"
    Else
                    s3=month(tc)&"/"&day(tc)&"/"&year(tc)&" " & Hour(tc) & ":30"
    End If
                    
	s3=displaydate(s3,11)
		
	newvrceffectdt=s3
    

    If minvrtretiredt = "--never--" Then
    
	newvrcretiredt= "--never--" 

    Else
    
	newvrcretiredt=displayDate(minvrtretiredt,11)

	End If

    minrsid=theRs("minrsid")
    maxrsid=theRs("maxrsid")

If (minrsid = maxrsid) And maxrsid = 0 Then

mystr=" select isnull(cRSID,0) as cRSID from X1Customer where id="&x1CustId

set myrs = oConn.execute(myStr) 
If Not myrs.eof then
minrsid=myrs("cRSID") ' default for customer
maxrsid=minrsid
End if
myrs.close


End If

rowexist = True

cex= ((cpcust>0) Or (cpvend > 0) Or (not rowexist) )


sctitle=""

scex=""

If Not rowexist Then

sctitle="Not existed"
scex="y"

else

If cex Then 

scex="y" 

If cpvend > 0 then
sctitle="Vendor pending records : " & cpvend
End If

If cpcust > 0 then
sctitle=sctitle & "&nbsp;&nbsp;&nbsp;&nbsp;Customer pending records : " & cpcust
End If

End If ' If cex Then 
End If ' If Not rowexist Then

If Not cex then
iact=iact+1
End if

voipuservendid=thers("vvdid")
orgdest=theRs("vdsname")
orgtype=theRs("vdsType")

orgn=orgdest & "  " & orgtype

if (orgc <> orgn) Or (skipc <> skip) then
   
   skipc = skip

   orgc=orgn

   DescriptionString = ""
   DestinationMobileCarrierString = ""
   DestinationTypeString=""
   DestinationString=""
   DialCodesSelectString=""

	
	If Not(orgdest = "") Then
		DestinationString = " , @Destination='"&orgdest&"'"
	End If
	
	If Not(orgtype = "") Then
		DestinationTypeString = " , @DestinationType='"&orgtype&"' "
	End If

	If Not(DestinationMobileCarrier = "") Then
		DestinationMobileCarrierString = " , @DestinationMobileCarrier='"&trim(DestinationMobileCarrier)&"' "
	End If

	

	If Not(Description = "") Then
		DescriptionString = " , @Description='"&trim(Description)&"' "
	End If

  
If Not( DialCodesSelect = "") Then
   s="''" & Replace(DialCodesSelect,",","'',''") & "''"
   DialCodesSelectString= " , @DialCodesSelect= " & "'" & s &  "'"
End If

filt=DestinationString&DestinationTypeString&DestinationMobileCarrierString&DescriptionString&DialCodesSelectString


   

%>
<tr <%If skipc=1 then%>style="background:#b3c7d2;"<%End if%>><td></td><td></td><td colspan=16><b><%=orgc%></b></td></tr>
<% End if

 theSQL = "Exec spViewCustomerVendorRatesTmpA2 @tblTempVoIPRateCustomer='" &  tblTempVoIPRateCustomer & "'"
 theSQL = theSQL &" , @voipUserId='"&voipUserId&"', @TierId='"&TierId&"', @vrUserId = '"&voipuservendid&"' "
 theSQL = theSQL & filt
 	
    s=theSQL
    
	s=Replace(s,"'",":quote:")
    s=Replace(s,"+",":plus:")
    

    zlink = siteRoot & "voip/setcustrates1.asp?sql=" & s 

    s= "&org="&org&"&user="&username

    s=Replace(s,"'",":quote:")
    s=Replace(s,"+",":plus:")
    
	s=s&"&tier="&TierId&"&voipuserid="&voipuserid
    s=s&"&grp="&irec
    zlink=zlink & s
  
  
%>
<tr id="rid<%=irec%>" <%If skipc = 0 then%><%If cex then%>style="background:yellow;" title="<%=sctitle%>"<%else%>class=datarow<%=irec mod 2%><%End if%>
<%else%>style="background:#b3c7d2;"<%End if%>>
<td><%=irec%></td>
<td align=center><%If Not cex Then

If KeepTempTable = "" Then
v=false
Else
v= ( rqf("skipgrp") (irec) <> "")
End If
If intention = "skipallgrp" then
v=theRs("skip")
End if
%>
<input type=checkbox class=datacheckboxn  
name='skipgrp' value='1' <%If v then%> checked <%End if%> onclick="doSubmit('skipgrp','<%=irec%>')">
<%else%>
<input type=hidden name='skipgrp' value=''>
<%End if%>
</td>
<td nowrap title="<%="Vendor Username: "&username%>"><%=org%>&nbsp;<%If Not cex then%>:<%=c%>:<%=c1%><%End if%></td>
<td <%If Not cex then%><%If icolor1 <> "" then%>style="text-align:center;font-size:12;background=<%=icolor1%>;"<%else%>style="text-align:center;font-size:12;"
<%End if%>  nowrap title="<%=title1%>"<%else%>colspan=8<%End If%>><%If Not cex then%>&nbsp;<%=FormatNumber(maxCost,4)%>
<%else%><%=sctitle%><%End if%></td>
 
 <input type=hidden name="gvcost" value="<%=maxCost%>">
 <input type=hidden name="maxcustefdt" value="<%=maxvrceffectdt%>">
 <input type=hidden name="maxvendefdt" value="<%=maxvrteffectdt%>">
 <input type=hidden name="maxvendrtdt" value="<%=maxvrtretiredt%>">
 <input type=hidden name="cex" value="<%=scex%>">
 <input type=hidden name="grpindex" value="<%=grpindex%>">

<%If Not cex then%>
 <td <%If Not cex then%><%If icolor3 <> "" then%>style="text-align:center;font-size:12;background=<%=icolor3%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title3%>">&nbsp;<%=maxvbsname%><%End if%></td>
 <%End If ' if not cex
 %>
  <td  style="text-align:center;font-size:12;" nowrap id="idtdnp<%=irec%>">
  <%If Not cex Then%>
    <select name="np" id="idnp<%=irec%>" onchange="ValidateGroup('<%=irec%>','')">
   </select>
   <%End If ' if not cex
   %>
  </td>
  <td><%If Not cex Then
  If KeepTempTable = ""  then

	newCustPrice=maxPrice ' + 0.05
    newCustPriceSave=newCustPrice
	
Else
   
if intention = "skipallgrp" Then

newCustPrice=thers("cvrcPrice")
If IsNull(newCustPrice) Then

	newCustPrice=maxPrice ' + 0.05
    newCustPriceSave=newCustPrice

End If

newCustPriceSave=newCustPrice

Else

	w=rqf("sgrpCnt")

	
	If w = "" Then w = 0 Else w=CInt(w) End If
	If w = irec Or (intention="addallgrpsave")  Then 
	
	'newCustPrice=maxPrice ' + 0.05
  
	newCustPrice=rqf("newCustPrice")(irec)
    newCustPriceSave=newCustPrice
    
	Else
	

    newCustPrice=rqf("newCustPrice")(irec)
    newCustPriceSave=rqf("newCustPriceSave")(irec)

	
    End if 
    
End If

End If

  %>
  <input type='text' name='newCustPrice' style="font-size:11;text-align:center;"  size=5
   value='<%= FormatNumberC(newCustPrice,4)%>' onBlur="ValidateGroup('<%=irec%>','')"/><%else%><input type=hidden name='newCustPrice' value='0'>
<%End if%>
 <input type='hidden' name='newCustPriceSave' value='<%= FormatNumberC(newCustPriceSave,4) %>' />        
 </td>
   <td>
<%
If KeepTempTable = "" then

v=maxvbsid
vname=maxvbsname
v1=0
If c = 0 Then
s="select xc.defaultbillingincrement from tblvoipusercustomer uc join x1customer xc on xc.id=uc.x1custid where uc.id="&voipuserid
Set rstest=oconn.execute(s)
If Not rstest.eof then
v1=rstest("defaultbillingincrement")
If IsNull(v1) Then v1 = 0 End if
End if
rstest.close
End If ' c = 0
If v1 > v Then 
v = v1 

mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
mystr=mystr & " where vbsid="& v
set myrs = oConn.execute(myStr) 
vname=myrs("vbsname")
myrs.close

End If

newvbsIdTextSave=vname
newvbsIdSave=v

Else

if intention = "skipallgrp" Then

v=thers("cvbsid")

If IsNull(v) Then

v=maxvbsid
vname=maxvbsname
v1=0
If c = 0 Then
s="select xc.defaultbillingincrement from tblvoipusercustomer uc join x1customer xc on xc.id=uc.x1custid where uc.id="&voipuserid
Set rstest=oconn.execute(s)
If Not rstest.eof then
v1=rstest("defaultbillingincrement")
If IsNull(v1) Then v1 = 0 End if
End if
rstest.close
End If ' c = 0

If v1 > v Then 
v = v1 
End If

End If ' isnull(v)

mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
mystr=mystr & " where vbsid="& v
set myrs = oConn.execute(myStr) 
vname=myrs("vbsname")
myrs.close


newvbsIdTextSave=vname
newvbsIdSave=v

Else

	w=rqf("sgrpCnt")
	If w = "" Then w = 0 Else w=CInt(w) End if
	If w = irec Or (intention="addallgrpsave")  Then 
	
	  v = rqf("newvbsId") ( irec ) 
      
	  newvbsIdSave=v
	  
	  If v <> "" Then
	  
	  mystr=" select cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure"
      mystr=mystr & " where vbsid="& v
      set myrs = oConn.execute(myStr) 
      vname=myrs("vbsname")
      myrs.close

      newvbsIdTextSave=vname
      
	  End If
      
    Else
	v = rqf("newvbsId") ( irec ) 
    newvbsIdSave=rqf("newvbsIdSave") ( irec )
	newvbsIdTextSave=rqf("newvbsIdTextSave") ( irec )
    End if 

End If

End if

%>
<%If Not cex then%>
<select class=dataselect name=newvbsId onBlur="ValidateGroup('<%=irec%>','')" >
<option value='0'>--All--</option><%
set rstest=oConn.execute("select vbsId, cast(vbsInitialMinSecsPerCall as varchar) +'/' +cast(vbsIncrements as varchar) vbsName from tblVoIPBillingStructure")
while not rstest.eof%>
<option  value='<%=rstest("vbsId")%>' 
<%=selected(rstest("vbsId"),v)%>><%=shortStr(rstest("vbsName"),12)%></option>
<%rstest.movenext
Wend
rstest.close%>
</select>
<%else%>
<input type=hidden name=newvbsId value='0'>
<%End if%>
<input type='hidden' name='newvbsIdSave' value='<%= newvbsIdSave %>' />        
<input type='hidden' name='newvbsIdTextSave' value='<%= newvbsIdTextSave %>' />        
</td>
<td><%If Not cex Then

If KeepTempTable = ""  then

newGrpEffDt=newvrceffectdt
newGrpEffDtSave=newGrpEffDt

  
Else

if intention = "skipallgrp" Then

newGrpEffDt=thers("cvrcEffectDt")

If IsNull(newGrpEffDt) Then

newGrpEffDt=newvrceffectdt

Else

newGrpEffDt=displayDate(newGrpEffDt,11)

End If

newGrpEffDtSave=newGrpEffDt

Else
	
	
	w=rqf("sgrpCnt")
	If w = "" Then w = 0 Else w=CInt(w) End if
	If (w = irec) Or (intention="addallgrpsave")  Then 

    newGrpEffDt = rqf("newGrpEffectDt") ( irec ) 
    newGrpEffDtSave=newGrpEffDt

    Else
	newGrpEffDt = rqf("newGrpEffectDt") ( irec ) 
    newGrpEffDtSave=rqf("newGrpEffectDtSave") (irec)

    End if 
End if
End If
%>
<input type='text' name='newGrpEffectDt' style="font-size:11;text-align:center" 
 value="<%=newGrpEffDt%>" onBlur="ValidateGroup('<%=irec%>','')"/>
<%else%>
<input type=hidden name='newGrpEffectDt' value=''>
<%End if%>
<input type='hidden' name='newGrpEffectDtSave' value='<%= newGrpEffDtSave %>' />        
</td>
<td><%If Not cex Then
If KeepTempTable = ""  then
newGrpRetDt=newvrcretiredt
newGrpRetDtSave=newGrpRetDt
Else

if intention = "skipallgrp" Then

newGrpRetDt=thers("cvrcRetireDt")

if IsNull(newGrpRetDt) Then

newGrpRetDt=newvrcretiredt

Else
If Year(newGrpRetDt) = 5999 then
newGrpRetDt="--never--"
Else
newGrpRetDt=displayDate(newGrpRetDt,11)
End If

End If

newGrpRetDtSave=newGrpRetDt

Else

    w=rqf("sgrpCnt")
	If w = "" Then w = 0 Else w=CInt(w) End if
	If w = irec Or (intention="addallgrpsave") Then 
	'newGrpRetDt=newvrcretiredt
	newGrpRetDt = rqf("newGrpRetireDt") ( irec ) 
    newGrpRetDtSave=newGrpRetDt
    Else
	newGrpRetDt = rqf("newGrpRetireDt") ( irec ) 
    newGrpRetDtSave=rqf("newGrpRetireDtSave") (irec)
    End if 
End if
End if
%>
<input type='text' name='newGrpRetireDt' style="font-size:11;text-align:center" size=8
 value="<%=newGrpRetDt%>" onBlur="ValidateGroup('<%=irec%>','')"/>
<%else%>
<input type='hidden' name='newGrpRetireDt' value=''>
<%End if%>
<input type='hidden' name='newGrpRetireDtSave' value='<%= newGrpRetDtSave %>' />        
</td>
<%If Not cex Then%>
<td  style="text-align:center;font-size:13;color:0000aa;">
<%
If Not cex Then

If minrsid <> maxrsid Then
	icolor5rsid="yellow"
	title5rsid="Customer RSID are not the same"
	Else
	icolor5rsid="white"
    title5rsid="All Customer RSID are the same"
End If

u=0


If KeepTempTable = ""  Then

v=0

If minrsid = maxrsid then
   v=maxrsid
End If

newrsIdSave=v

Else

 
if intention = "skipallgrp" Then

v=thers("crsid")

If IsNull(v) Then
   v=0
If minrsid = maxrsid then
   v=maxrsid
End If

End If

newrsIdSave=v

Else 


	w=rqf("sgrpCnt")

'    response.write "<script>alert('"&w&"');</script>"

	If w = "" Then w = 0 Else w=CInt(w) End if
	If (w = irec) Or (intention="addallgrpsave")  Then 

    v = rqf("newrsId") ( irec ) 
    newrsIdSave=v

    Else
	v = rqf("newrsId") ( irec ) 
    newrsIdSave=rqf("newrsIdSave") (irec)
    End if 

End If ' intention = "skipallgrp"


End If ' KeepTempTable=""

newrsIdColor=icolor5rsId

If newrsIdSave <> v Then

newrsIdColor="#eedede"


End If


%>
<select class=dataselect name=newrsId  
<%If Not bAllowRSID then%> title="You are not allowed to set up RSID" disabled <%else%> title="<%=title5rsid%>" <%End if%> 
onBlur="ValidateGroup('<%=irec%>','')" style="background-color:<%=newrsIdColor%>;" 
>
<option value = '0'  <%=selected(u,v)%> >-Select-</option>

<%

mystr = "SELECT c.ID, c.RSID, t.userFN +' '+ t.userLN as "
mystr = mystr & " UserName , c.CommType, c.Rate FROM  Commissions AS c INNER JOIN SalesPerson "
mystr = mystr & " AS s ON c.SPID = s.SPID INNER JOIN tblUser AS t ON s.userId = t.userId order by  c.RSID"

TempRSID=""

set rstest=oConn.execute(mystr)

keygrp=0
i=0
while not rstest.eof
key=rstest("RSID")
begingrp=false
If key <> keygrp Then
i=i+1
keygrp=key
begingrp=true
End If

If rstest("CommType")="Percentage" Then
             rTempRate=CDbl(rstest("Rate"))*100
             Field=cstr(rTempRate)&"%"
  End If
 If rstest("CommType")="Fixed" Then
             Field="$"&rstest("Rate")
    End If
   If key=tempRSID Then
            Field= spacesHtml(2*Len(key)+1) & rstest("UserName")&" "&Field
    Else
            tempRSID=key
            Field=key&"&nbsp;"&rstest("UserName")&" "&Field
   End If
           
if Not bShowRSID Then
Field=" Hidden "
End if

		   %>
 <option   value = '<%=TempRSID%>' <%If begingrp then%><%=selected(tempRSID,v)%><%End if%>><%=Field%></option>
<%
rstest.movenext
Wend
rstest.close
%>
</select>
<%else%>
<input type='hidden' name='newrsId'  value='0'>
<%End if%>
<input type='hidden' name='newrsIdSave' value='<%= newrsIdSave %>' />   
<input type='hidden' name='newrsIdColor' value='<%= icolor5rsId %>' />   

</td>
<%
End If ' if not cex
%>

<%If Not cex Then%>
<td  style="text-align:center;font-size:13;color:0000aa;">
<%If Not cex Then
%>
<input class=databutton type='button' value='Apply' 
onclick="return doApplyCustGroup1('<%=irec%>');"
/><%End if%>
</td>
<%
End If ' if not cex
%>
<td  style="text-align:center;font-size:13;color:0000aa;" nowrap>
<%If Not cex then%>
<a href="/z.asp" onclick="return acctWin1(this,'<%=zLink%>',1000,650,50,10);">Edit</a>
<%End if%>
</td>
<%If Not cex then%>
 <td <%If Not cex then%><%If icolor2 <> "" then%>style="text-align:center;font-size:12;background=<%=icolor2%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title2%>"<%End if%>><%If Not cex then%>&nbsp;<%=FormatNumber(maxPrice,4)%><%End if%></td>
 <td <%If Not cex then%><%If icolor4vrteff <> "" then%>style="text-align:center;font-size:12;background=<%=icolor4vrteff%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title4vrteff%>"<%End if%>><%If Not cex then%>&nbsp;<%=maxvrteffectdt%><%End if%></td>
 <td <%If Not cex then%><%If icolor4vrtrt <> "" then%>style="text-align:center;font-size:12;background=<%=icolor4vrtrt%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title4vrtrt%>"<%End if%>><%If Not cex then%>&nbsp;<%=maxvrtretiredt%><%End if%></td>
 <td <%If Not cex then%><%If icolor4vrceff <> "" then%>style="text-align:center;font-size:12;background=<%=icolor4vrceff%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title4vrceff%>"<%End if%>><%If Not cex then%>&nbsp;<%=maxvrceffectdt%><%End if%></td>
 <td <%If Not cex then%><%If icolor4vrcrt <> "" then%>style="text-align:center;font-size:12;background=<%=icolor4vrcrt%>;"<%else%>style="text-align:center;font-size:12;"
 <%End if%>  nowrap title="<%=title4vrcrt%>"<%End if%>><%If Not cex then%>&nbsp;<%=maxvrcretiredt%><%End if%></td>
<%End If ' If Not cex 
%>

</tr>
<%
thers.movenext
Wend
thers.close
If iact > 0 then
%>
             
<tr bgcolor='eeeeee'><td></td><td colspan='1' >
                       <input class=databutton type='button' value='Sort' 
					   onclick="return doSubmit('skipallgrp','')"
					    />
					</td><td colspan=8 style=text-align:right>
					   <input id='fSave' class=databutton type='button' value='      Save      ' 
					   onclick="return doSubCust(<%=irec%>);"
					    />
					   <input class=databutton type='button' value='      Cancel      ' 
					   onclick="return doSubmit('transcancel','');"
					    /></td><td>
                        <input class=databutton type='button' value='Apply All ' 
					   onclick="return doApplyAll(<%=irec%>);"
					    /></td><td colspan=6>
					  
						</td></tr> 
 </table>

<input type=hidden name='numrec' id='idnumrec' value="<%=irec%>">

 <%
 workgroupCnt=irec
End If ' iact > 0
End If ' if not NoMatchingVendors then>
End If ' voipuserid > 0 And Tierid > 0 
 %>
  <br>
 </form>

<br>

<form name=fSubmit action='' method='post'>
	<input type=hidden name="sX1CustId" id="sX1CustId" value="">
	<input type=hidden name="sVoipUserId" id="sVoipUserId" value="">
    <input type=hidden name="sVoipUserName"  value="">
	<input type=hidden name="sDestination" id="sDestination" value="">
	<input type=hidden name="sDestinationType" id="sDestinationType" value="">
	<input type=hidden name="sDestinationMobileCarrier" id="sDestinationMobileCarrier" value="">
	<input type=hidden name="sDescription" id="sDescription" value="">
	
	<input type=hidden name="sTierId" id="sTierId" value="<%=TierId%>">

	<input type=hidden name="sStatusId" id="sStatusId" value="">
	<input type=hidden name="sListDate1" id="sListDate1" value="">
	<input type=hidden name="sListDate2" id="sListDate2" value="">
	<input type=hidden name="sListVendorId" id="sListVendorId" value="">
	<input type=hidden name="sAddVendorId" id="sAddVendorId" value="">
	<input type=hidden name="sVbsId" id="sVbsId" value="">
	<input type=hidden name="sIntention" value="">
	<input type=hidden name="sql" value="">
    <input type=hidden name="filt" value="">
	<input type=hidden name="sgrpCnt" value="">
    <input type=hidden name="sallgrpCnt" value="">
	<input type=hidden name="snprice" value="">
	<input type=hidden name="snvbsid" value="">
	<input type=hidden name="snrtdt" value="">
    <input type=hidden name="snefdt" value="">
    <input type=hidden name="snrsid" value="">
    <input type=hidden name="sKeepTempTable" value="">
	<input type=hidden name="DstPattern" id=idDstPattern value="<%=DialCodesSelect%>">
	<input type=hidden name="LabelDialCode"  value="<%=LabelDialCode%>">
    <input type=hidden name="min1Value" value="">
    <input type=hidden name="min2Value" value="">
    <input type=hidden name="vrcRetireDt" value="">
    <input type=hidden name="vvdid" value="<%=vvdid%>">
	<input type=hidden name="orgdest" value="<%=orgdest%>">
    <input type=hidden name="orgtype" value="<%=orgtype%>">
    <input type=hidden name="numgrp" value="<%=irec%>"> 
	<input type=hidden name="CheckNewPrice2copy" value=""> 
	<input type=hidden name="newCustPrice2copy" value=""> 
	<input type=hidden name="newBi2copy" value=""> 
	<input type=hidden name="newEffectDt2copy" value=""> 
	<input type=hidden name="newRetireDt2copy" value=""> 
 	<input type=hidden name="sMode" id="sMode" value="<%=mode%>">
    <input type=hidden name="sfastData"  value="">
 	<input type=hidden name="spgmode" id="spgmode" value="<%=pgmode%>">
 	<input type=hidden name="spgmera"  value="<%=pgmera%>">
 	<input type=hidden name="spgtable"  value="<%=pgtable%>">
 	<input type=hidden name="spgpost"  value="<%=pgpost%>">
	<input type=hidden name="spgfixdata"  value="">
    <input type=hidden name="meraversion" value="<%=meraversion%>">
    <input type=hidden name="sboot"  value="<%=boot%>">
 	 <input type=hidden name="slogproto"  value="<%=logproto%>">
 	 <input type=hidden name="scheckdatabase"  value="<%=checkdatabase%>">
 	 <input type=hidden name="scheckreplication"  value="<%=checkreplication%>">
 	 <input type=hidden name="scheckradius"  value="<%=checkradius%>">
     <input type=hidden name="sntail"  value="<%=ntail%>">
 	 <input type=hidden name="fullstatus"  value="<%=fullstatus%>">
     <input type=hidden name="forcesync"  value="<%=forcesync%>">
 	 <input type=hidden name="schecklistrates"  value="<%=checklistrates%>">
   	 <input type=hidden name="schecklistcosts"  value="<%=checklistcosts%>">
    <input type=hidden name="svvdId" value="<%=vvdid%>">
	 <input type=hidden name="irecpgdb" value="<%=irecpgdb%>">
	 <input type=hidden name="irecnopost" value="<%=irecnopost%>">
	 <input type=hidden name="irecpost" value="<%=irecpost%>">
	
	 <input type=hidden name="SyncList" value="">
	 <input type=hidden name="spglevel"  value="<%=pglevel%>">
     <input type=hidden name="spghide"  value="<%=pghide%>">
	  	 <input type=hidden name="schecktabledirectory"  value="<%=checktabledirectory%>">
   <input type=hidden name="stypetabledirectory"  value="<%=typetabledirectory%>">
  	  	 <input type=hidden name="spurgefiles"  value="<%=purgefiles%>">
   <input type=hidden name="stypepurgefiles"  value="<%=typepurgefiles%>">

 
	<%
	If irecpgdb = "" Then irecpgdb=0 End If
	If irecpgcust = "" Then irecpgcust=0 End If
	If irecpgvend = "" Then irecpgvend=0 End If
	If irectdcount = "" Then irectdcount = 0 End If
	For i=1 To irecpgdb
	%>
    <input type=hidden name="checktable<%=i%>" value="">
	<input type=hidden name="eskipdb<%=i%>" value="">
	<%
	Next
	For i=1 To irecpgcust
	%>
    <input type=hidden name="checktablecust<%=i%>" value="">
	<%
	Next
	For i=1 To irecpgvend
	%>
    <input type=hidden name="checktablevend<%=i%>" value="">
	<%
	Next
	For i=1 To irectdcount
	%>
    <input type=hidden name="tdstatus<%=i%>" value="">
	<input type=hidden name="tdauthor<%=i%>" value="">
	<input type=hidden name="tdcomments<%=i%>" value="">
	<input type=hidden name="checktdstatus<%=i%>" value="">
	<input type=hidden name="tdid<%=i%>" value="">
	
	<%
	Next
	%>
 <input type=hidden name="irectdcount" value="<%=irectdcount%>">
	
</form>

<%

Function FormatNumberC(value,n)
Dim r

If IsNumeric(value) Then
r=FormatNumber(value,n)
Else
r=value
End If
FormatNumberC=r
End Function

%>

<script language=Javascript>
	var f1=document.forms.form1; f1.action='';
	var fs=document.forms.fSubmit; fs.action=''; 
	var fId = document.getElementById('fSave');
	var wa;
	  var bShowList1 = ((fs.sIntention.value == 'addnewrate') || (fs.sIntention == 'addgrpsave') );
    var sAllowRSID= '<%if bAllowRSID then%>y<%else%><%end if%>'

	var sToday='<%=displayDate(now,11)%>';
	var sNextday='<%=displayDate(month(now+1)&"/"&day(now+1)&"/"&year(now+1)&" 00:00",11)%>';
	
	var wrn1='Delete this rate entry?';
	var wrn2='Retire this rate entry?';
	var wrn3='Please make following selections first:\nTier, Destination, Dialcode, Vendor, Billing-Increment';
	var wrn4='Please fill in at least the Price field';
	var wrn5='You can add a rate to this Customer only by Cloning\n\nPlease locate a relevant rate and clone it,\nor return to VENDOR view and add a new rate to be cloned';

    var irecpgdb='<%=irecpgdb%>';
    var irecpgcust='<%=irecpgcust%>';
    var irecpgvend='<%=irecpgvend%>';
    var irectdcount='<%=irectdcount%>';

function switchOption1() {
	     fs.DstPattern.value='';
		 fs.LabelDialCode.value='DialCodes(All)';
 }


function KeepMainFilter()
{

		fs.sX1CustId.value = f1.fX1CustId.options[f1.fX1CustId.selectedIndex].value;
		
		fs.sVoipUserId.value = f1.fvoipUserId.options[f1.fvoipUserId.selectedIndex].value;
		fs.sDestination.value = f1.fDestination.options[f1.fDestination.selectedIndex].value;			
		fs.sDestinationType.value = f1.fDestinationType.options[f1.fDestinationType.selectedIndex].value;				
		fs.sDestinationMobileCarrier.value = f1.fDestinationMobileCarrier.options[f1.fDestinationMobileCarrier.selectedIndex].value;
		fs.sDescription.value = f1.fDescription.options[f1.fDescription.selectedIndex].value;
		fs.sStatusId.value = f1.fStatusId.options[f1.fStatusId.selectedIndex].value;
		
		var vendorId = document.getElementById('fAddVendorId');
			
			if (vendorId != null)
			{
		
		fs.sAddVendorId.value = vendorId.options[vendorId.selectedIndex].value;			

			}
				
		
		if (f1.fDestination.options[f1.fDestination.selectedIndex].value == '')
		{	
		 fs.sDestinationType.value = '';fs.sDestinationMobileCarrier.value='';
		}

        fs.sVoipUserName.value = f1.fvoipUserId.options[f1.fvoipUserId.selectedIndex].text;

	     fs.sMode.value=f1.mode.options[f1.mode.selectedIndex].value;

         fs.spgmode.value=f1.pgmode.options[f1.pgmode.selectedIndex].value;

         fs.spgmera.value=f1.pgmera.options[f1.pgmera.selectedIndex].value;

        if(f1.pgtable=='[object]') {
         fs.spgtable.value=f1.pgtable.options[f1.pgtable.selectedIndex].value;
        };

        if(f1.pgpost=='[object]') {
        
         fs.spgpost.value=f1.pgpost.options[f1.pgpost.selectedIndex].value;
        };

		 fs.meraversion.value=f1.meraversion.value;

         if (f1.boot=='[object]')
         {
		   fs.sboot.value=f1.boot.options[f1.boot.selectedIndex].value;
         };
         if (f1.logproto=='[object]')
         {
		 fs.slogproto.value=f1.logproto.options[f1.logproto.selectedIndex].value;
         };

         if (f1.pglevel=='[object]')
         {
		 fs.spglevel.value=f1.pglevel.options[f1.pglevel.selectedIndex].value;
         };

         if (f1.pghide=='[object]')
         {
		 fs.spghide.value=f1.pghide.options[f1.pghide.selectedIndex].value;
         };

		 fs.scheckradius.value='';
		 fs.scheckdatabase.value='';
		 fs.scheckreplication.value='';
		  fs.schecklistrates.value='';
		  fs.schecklistcosts.value='';
		  fs.schecktabledirectory.value='';
		 fs.stypetabledirectory.value='';
		  fs.spurgefiles.value='';
		 fs.stypepurgefiles.value='';
		

		 if (f1.checkradius.checked) {fs.scheckradius.value='y';};
         if (f1.checkdatabase.checked) {fs.scheckdatabase.value='y';};
         if (f1.checkreplication.checked) {fs.scheckreplication.value='y';};
         if (f1.checklistrates.checked) {fs.schecklistrates.value='y';};
         if (f1.checklistcosts.checked) {fs.schecklistcosts.value='y';};
         
		 if(f1.checktabledirectory=='[object]') {
		 if (f1.checktabledirectory.checked) {fs.schecktabledirectory.value='y';};
         };

	     if(f1.typetabledirectory=='[object]') {
		  fs.stypetabledirectory.value=f1.typetabledirectory.options[f1.typetabledirectory.selectedIndex].value;
         };

         if(f1.purgefiles=='[object]') {
		 if (f1.purgefiles.checked) {fs.spurgefiles.value='y';};
         };


	     if(f1.typepurgefiles=='[object]') {
		  fs.stypepurgefiles.value=f1.typepurgefiles.options[f1.typepurgefiles.selectedIndex].value;
         };


         if(f1.ntail=='[object]') {
         fs.sntail.value=f1.ntail.value;
		 };
         
		 
		  if(f1.checkforcesync=='[object]') {
          fs.forcesync.value='';
		  fs.fullstatus.value='';
		  if(f1.checkforcesync.checked) {fs.forcesync.value='y';};
		  if(f1.checkfullstatus.checked) {fs.fullstatus.value='y';};
		  };

        
         if(f1.vvdId=='[object]') {
		 fs.svvdId.value=f1.vvdId.value;
         };

          if(f1.checkdatabase.checked) {
		  for (i=1;i<=irecpgdb;i++)
		  {
           if(eval('f1.checktable'+i)=='[object]') {
		   v= eval('f1.checktable'+i+'.checked');
		    u='';
		   if(v) u='y';
		   eval('fs.checktable'+i+'.value=\''+u+'\'');
		   //u=eval('fs.checktable'+i+'.value;');
		   //alert(u);
		  };

          if(eval('f1.eskipdb'+i)=='[object]') {
		   v= eval('f1.eskipdb'+i+'.checked');
		    u='';
		   if(v) u='y';
		   eval('fs.eskipdb'+i+'.value=\''+u+'\'');
		   //u=eval('fs.checktable'+i+'.value;');
		   //alert(u);
		  };


          };
          };


	  	  if(f1.checktablecust1=='[object]') {
		  for (i=1;i<=irecpgcust;i++)
		  {
		   v= eval('f1.checktablecust'+i+'.checked');
		    u='';
		   if(v) u='y';
		   eval('fs.checktablecust'+i+'.value=\''+u+'\'');
		   u=eval('fs.checktablecust'+i+'.value;');
		  };
          };

      	  if(f1.checktablevend1=='[object]') {
		  for (i=1;i<=irecpgvend;i++)
		  {
		   v= eval('f1.checktablevend'+i+'.checked');
		    u='';
		   if(v) u='y';
		   eval('fs.checktablevend'+i+'.value=\''+u+'\'');
		   u=eval('fs.checktablevend'+i+'.value;');
		  };
          };


 		
      	  if(f1.tdstatus1=='[object]') {
		 
		  for (i=1;i<=irectdcount;i++)
		  {
		  eval('fs.tdstatus'+i+'.value = f1.tdstatus'+i+'.value');
		  eval('fs.tdauthor'+i+'.value = f1.tdauthor'+i+'.value');
		  eval('fs.tdcomments'+i+'.value = f1.tdcomments'+i+'.value');
		   eval('fs.tdid'+i+'.value = f1.tdid'+i+'.value');
		 
		   };

};

 return true;
}

	function doSubmit(itn,prm) {
	
		itn = itn.toLowerCase();
		
        
		 KeepMainFilter();

   			switch (itn) {
			case 'select':
				fs.sIntention.value = 'select';
		
				fs.submit(); 
				break
            case 'selectx':
                fs.sVoipUserId.value='';
				fs.sVoipUserName.value=''; //bugfelix
                fs.sTierId.value = '';
				fs.sIntention.value = 'selectx';
			
				fs.submit(); 
				break
			case 'addnewrate':
			if(fId!=null)
			{
			return false;
			}
             	fs.sIntention.value = 'addnewrate';
				fs.submit(); 
				break

			case 'rollback':

             	fs.sIntention.value = itn;
				fs.submit(); 
				break
            
			case 'restore':
             	fs.sIntention.value = itn;
				fs.submit(); 
				break
            case 'transcancel':
	            fs.sIntention.value = itn;
				fs.submit(); 
                break;
			case 'skipallgrp':
		
				n=f1.numrec.value;
				
				xdirty=false;
				
				for(i = 1; i <= n; i++) {
   		          x=CheckDirty(i);
                  xdirty=xdirty||x
	            };
	            
				if (xdirty)
	            {
                 if(!confirm('Warning: you will lost your last changes, marked brown, in browser. Proceed?'))
				 {
                   if(f1.newCustPrice.length != null) {
                     f1.skipgrp[prm-1].checked=!f1.skipgrp[prm-1].checked;
					 }
					 else
					 {
                     f1.skipgrp.checked=!f1.skipgrp.checked;
					 }
				  return false;
			     }
	            }
  
        fs.sIntention.value = itn;
        
		fs.sallgrpCnt.value=n;
		
		SetAllSkipGroupFlags();

		
		fs.sKeepTempTable.value='y';

        fs.CheckNewPrice2copy.value=	f1.CheckNewPrice2copy.options[f1.CheckNewPrice2copy.selectedIndex].value;
		fs.newCustPrice2copy.value=f1.newCustPrice2copy.value; 
		fs.newBi2copy.value=f1.newBi2copy.value;
		fs.newRetireDt2copy.value=f1.newRetireDt2copy.value;
		fs.newEffectDt2copy.value=f1.newEffectDt2copy.value;

				fs.submit(); 
			
			     return false;
            case 'skipgrp':
			    ValidateGroup(prm,'');
			    return false;
			
			case 'purgefiles':

                  fs.sfastData.value=prm;
	              fs.sIntention.value = itn;
                  fs.submit(); 
				    return false;
	
			case 'tdstatus':
			      n=irectdcount;
                  b=false;
				  for(i=1;i<=n;i++)
				  {
				     v= eval('f1.checktdstatus'+i+'.checked');
		               u='';
		               if(v) {
					   b=true;
					   u='y';
					   };
			
		             eval('fs.checktdstatus'+i+'.value = \''+u+'\'');
		           };
				   if(!b) {
				   alert('nothing to do');
				   return false;
				   }; 
				
        	/*
				  v=eval('f1.tdstatus'+prm+'.value');
                  u=eval('f1.tdauthor'+prm+'.value');
                  w=eval('f1.tdcomments'+prm+'.value');
		         // eval('fs.tdstatus'+prm+'.value=');
                 
                 // eval('fs.tdauthor'+prm+'.value=');
               //   eval('fs.tdcomments'+prm+'.value=');
			
				  fs.sfastData.value=v;
                  */
				  fs.sIntention.value = itn;
                	fs.submit(); 
		
			   return false;
			
			
			case 'isactive':
	
		 fs.sIntention.value = itn;
        
		
		 fs.sfastData.value=eval('f1.fastArray'+prm+'.value');
		
                	fs.submit(); 
			
			     return false;
            case 'cli':
				 fs.sIntention.value = itn;
        
			 fs.sfastData.value=eval('f1.fastArray'+prm+'.value');
		
                	fs.submit(); 
			
			     return false;
              case 'fastprice':

				 fs.sIntention.value = itn;
				 v=eval('f1.fastPrice'+prm+'.value');
	
	  fs.sfastData.value=v+':'+eval('f1.fastArray'+prm+'.value');

  if(!confirm('Price will be changed to '+v+' for all dialcodes ... Are you sure?'))
          {
            return false;
          };

    
                	fs.submit(); 
				     return false;
         
				   case 'fastbi':

	
				 fs.sIntention.value = itn;
				 v=eval('f1.fastBi'+prm+'.value');

  fs.sfastData.value=v+':'+eval('f1.fastArray'+prm+'.value');

   if(!confirm('Billing Increment will be changed to '+v+' for all dialcodes ... Are you sure?'))
          {
            return false;
          };

		
                	fs.submit(); 
	                return false;

            case 'fix' :
	             fs.sIntention.value = itn;

				 u=eval('f1.fastPrice'+prm+'.value');
	
				 v=eval('f1.fastBi'+prm+'.value');
                 w=eval('f1.fastArray'+prm+'.value');

        fs.sfastData.value=u+':'+v+':'+w;

		wa=w.split(':');
        
		x='No' 
        
		if (wa[1]=='1')
        {
		 x='Yes'
        } 
          s='Missed Prices will be added with default attributes\nPrice '+u+'\nB.I. '+v
          s=s+'\nCLI='+x
		  s=s+' \nAre you sure?'
          if(!confirm(s))
          {
            return false;
          };

		
                	fs.submit(); 
	                return false;
           
		   case 'fixresync':
           case 'fixresynccosts':

           alert('sorry about this ... option is locked temporary');
		   return false;

                fs.sIntention.value = itn;

                 u=eval('f1.fastPrice'+prm+'.value');
				 v=eval('f1.fastBi'+prm+'.value');
            
                w=eval('f1.fastArray'+prm+'.value');
				fs.sfastData.value=u+':'+v+':'+w;

                fs.submit();
          
            return false;
        
		   case 'pgfixpost':
		   case 'pgfixnopost':
		      wa= prm.split(':');
              u=wa[0];
			  v=wa[1];
			  z=eval('f1.selmodfix'+v+';')
			 
			  w='0';
			  if (z=='[object]')
			  {
			  w=eval('f1.selmodfix'+v+'.options[f1.selmodfix'+v+'.selectedIndex].value;');
			  };
			  fs.sIntention.value = itn;
		      fs.spgfixdata.value = u+':'+w;
		      fs.submit();
			  return false;
          case 'pgtran':
		  case 'pgtranstop':
          case 'pgsnap':
		  case 'pgsnapstop':
           case 'pgcdr':

		     fs.sIntention.value = itn;
		      fs.spgfixdata.value = prm;
		      fs.submit();
              return false;
         
		  case 'pglog':
              fs.sIntention.value = itn;
			  s=prm;
			  s=s+';'+f1.ntail.value;
			  fs.spgfixdata.value = s;
		      fs.submit();
              return false;
          
	      case 'pgboot':
		      fs.sIntention.value = itn;
			  s=f1.pgconfig.value;
			  s=s+';'+f1.boot.value;
			  s=s+';'+f1.logproto.value;
		      fs.spgfixdata.value = s;
		      fs.submit();
              return false;
        
		      fs.spgfixdata.value = prm;
		      fs.submit();
              return false;
           case 'syncgrp':
		   if (prm=='')
		   {
		   n=eval('document.getElementById("irecnopost").value');
		   }
		   else
		   {
           n=eval('document.getElementById("irecpost").value');
		   };
		   	r=0;
		    lstsync='';
			for(i=1;i<=n;i++)
			{
if (eval('document.getElementById("'+'checksync'+prm+'grp'+i+'")')!=null)
{
			if (eval('document.getElementById("'+'checksync'+prm+'grp'+i+'").checked'))
			{
			r=r+1;
			eval('vprm=document.getElementById("'+'checksync'+prm+'grp'+i+'").value');
			 wa= vprm.split(':');
              u=wa[0];
			  v=wa[1];
			  z=eval('f1.selmodfix'+v+';')
			 
			  w='0';
			  if (z=='[object]')
			  {
			  w=eval('f1.selmodfix'+v+'.options[f1.selmodfix'+v+'.selectedIndex].value;');
			  };
			  v = u+':'+w;
		
			lstsync=lstsync+ v + ',' ;
			};
			};
};

             if (r > 0)
             {
			 s='Synchronize checked ' + r + ' tables?';

  		     if(!confirm(s)) {return false}; 
             }
             else
			 {
			 alert("Nothing to do");
			 return false;
  			 };
			  
			  fs.SyncList.value = prm + ','+ lstsync;
		      fs.sIntention.value = itn;
		      fs.submit();
              return false;
			
     case 'sphelp':

	 	      fs.sIntention.value = itn;
	          fs.sfastData.value=prm;
    	      fs.submit();
	          return false;
	  		  break;	

	 case 'sphelptext':

	 	      fs.sIntention.value = itn;
	          fs.sfastData.value=prm;
    	      fs.submit();
	          return false;
	  		  break;	
	
		   default:
				fs.submit();
				break	
		}
	}


function doSubmit1(itn,prm) {

 KeepMainFilter();

switch (itn)
{

case 'load_add':

if(fId != null)
{
return false;
};

   var a = prm.split('|')

	  fs.sIntention.value= 'retiregrp';
      fs.min1Value.value=a[0];
      fs.min2Value.value=a[1];
      fs.vvdid.value=a[2];
      fs.orgdest.value=a[3];
      fs.orgtype.value=a[4];
      fs.doretire.value='yes';
	  	
	  fs.submit();
      break;

case 'submit':
      fs.vrcRetireDt.value=f1.vrcRetireDt.value;
      fs.sIntention.value= 'doretiregrp';
      fs.doretire.value='';
      fs.submit();
      break;
case 'cancel':
      fs.vvdid.value='';
      fs.doretire.value='';
      fs.sIntention.value= 'cancel';

	  fs.submit();
      break;

}

}

function isDateM(p_Expression){
	return !isNaN(new Date(p_Expression));		// <<--- this needs checking
}

function dateAdd(p_Interval, p_Number, p_Date){
	if(!isDateM(p_Date)){return "invalid date: '" + p_Date + "'";}
	if(isNaN(p_Number)){return "invalid number: '" + p_Number + "'";}	

	p_Number = new Number(p_Number);
	var dt = new Date(p_Date);
	switch(p_Interval.toLowerCase()){
		case "yyyy": {// year
			dt.setFullYear(dt.getFullYear() + p_Number);
			break;
		}
		case "q": {		// quarter
			dt.setMonth(dt.getMonth() + (p_Number*3));
			break;
		}
		case "m": {		// month
			dt.setMonth(dt.getMonth() + p_Number);
			break;
		}
		case "y":		// day of year
		case "d":		// day
		case "w": {		// weekday
			dt.setDate(dt.getDate() + p_Number);
			break;
		}
		case "ww": {	// week of year
			dt.setDate(dt.getDate() + (p_Number*7));
			break;
		}
		case "h": {		// hour
			dt.setHours(dt.getHours() + p_Number);
			break;
		}
		case "n": {		// minute
			dt.setMinutes(dt.getMinutes() + p_Number);
			break;
		}
		case "s": {		// second
			dt.setSeconds(dt.getSeconds() + p_Number);
			break;
		}
		case "ms": {		// second
			dt.setMilliseconds(dt.getMilliseconds() + p_Number);
			break;
		}
		default: {
			return "invalid interval: '" + p_Interval + "'";
		}
	}
	return dt;
}

 function CheckDirty(grpCnt) {
  var xerr,xcol,s;
 xerr=false;


 if(f1.newCustPrice.length != null) {

					if (f1.cex[grpCnt-1].value!='')
					{
					 return false;

					};

					if (f1.skipgrp[grpCnt-1].checked)
					{
			
					  return false;

					};


                    nprice=f1.newCustPrice[grpCnt-1].value;
					nprice1=f1.newCustPriceSave[grpCnt-1].value;
					nvbsid=f1.newvbsId[grpCnt-1].value;       
                    nvbsid1=f1.newvbsIdSave[grpCnt-1].value;  

					nrsid=f1.newrsId[grpCnt-1].value;       
                    nrsid1=f1.newrsIdSave[grpCnt-1].value;  
					newrsIdColor=f1.newrsIdColor[grpCnt-1].value; 

				    nefdt=f1.newGrpEffectDt[grpCnt-1].value;
                    nefdt1=f1.newGrpEffectDtSave[grpCnt-1].value;
                    nrtdt=f1.newGrpRetireDt[grpCnt-1].value;
                    nrtdt1=f1.newGrpRetireDtSave[grpCnt-1].value;
                    nvbsidtext1=f1.newvbsIdTextSave[grpCnt-1].value;       
                 
					}
					else
					{

  				   if (f1.cex.value!='')
					{
					 return false;

					};

					if (f1.skipgrp.checked)
					{
			
					  return false;

					};


                    nprice=f1.newCustPrice.value;
					nprice1=f1.newCustPriceSave.value;
				    nvbsid=f1.newvbsId.value;       
                    nvbsid1=f1.newvbsIdSave.value;    
					
					nrsid=f1.newrsId.value;       
                    nrsid1=f1.newrsIdSave.value;  
                    newrsIdColor=f1.newrsIdColor.value; 
				
				    nefdt=f1.newGrpEffectDt.value;
                    nefdt1=f1.newGrpEffectDtSave.value;
                    nrtdt=f1.newGrpRetireDt.value;
                    nrtdt1=f1.newGrpRetireDtSave.value;
                    nvbsidtext1=f1.newvbsIdTextSave.value;       
                  
					};

					
					xerr1=((1*nprice)!=(1*nprice1));
                    xerr=xerr||xerr1;  
					if (xerr1)
                        {
						   xcol='#eedede';
				   		   s='Current value was changed from previous - price ' + nprice1 + ' - but is not applied to the codes';
                        }
						else
						{
                            xcol='white';
							s='';
						};

 if(f1.newCustPrice.length != null) {

                       f1.newCustPrice[grpCnt-1].style.backgroundColor = xcol;
                       f1.newCustPrice[grpCnt-1].title=s;
}else
{
                       f1.newCustPrice.style.backgroundColor = xcol;
                       f1.newCustPrice.title=s;

};

	                xerr1=(nvbsid!=nvbsid1);
                    xerr=xerr||xerr1;  
					if (xerr1)
                        {
                           xcol='#eedede';
						   s1='Current value was changed from previous - bi ' + nvbsidtext1 + ' - but is not applied to the codes';
               
                        }
						else
						{
                            xcol='white';
							s1='';
						};

if ((s!='')&&(s1!=''))
{
s='Current values were changed from previous - price ' + nprice1 + ' bi ' + nvbsidtext1 + ' - but were not applied to the codes';
}
else
{
if(s!='')
{
xcol='#eedede';
};
if (s1!='')
{
s=s1;
}
};

 if(f1.newCustPrice.length != null) {

                       f1.newCustPrice[grpCnt-1].style.backgroundColor = xcol;
                       f1.newCustPrice[grpCnt-1].title=s;
					   if (s1!='')
					   {
					   f1.newvbsId[grpCnt-1].style.backgroundColor = xcol;
					   }

}else
{
                       f1.newCustPrice.style.backgroundColor = xcol;
                       f1.newCustPrice.title=s;
					   if (s1!='')
					   {
					   f1.newvbsId.style.backgroundColor = xcol;
					   }

};


/*
 if(f1.newCustPrice.length != null) {

                       f1.newvbsId[grpCnt-1].style.backgroundColor = xcol;
					   f1.newvbsId[grpCnt-1].title=s;
}else
{
                       f1.newvbsId.style.backgroundColor = xcol;
                       f1.newvbsId.title=s;

};

*/


                    xerr1=(nefdt!=nefdt1);
                    xerr=xerr||xerr1;  
                    if (xerr1)
                        {
                           xcol='#eedede';
						   s='Current value was changed from previous ' + nefdt1 + ' but is not applied to the codes';
                        }
						else
						{
                            xcol='white';
							s='';
						};

 if(f1.newCustPrice.length != null) {

                       f1.newGrpEffectDt[grpCnt-1].style.backgroundColor = xcol;
                       f1.newGrpEffectDt[grpCnt-1].title=s;
}else
{
                       f1.newGrpEffectDt.style.backgroundColor = xcol;
                       f1.newGrpEffectDt.title=s;

};
				

                    xerr1=(nrtdt!=nrtdt1);
                    xerr=xerr||xerr1;  
                    if (xerr1)
                        {
                           xcol='#eedede';
						   s='Current value was changed from previous ' + nrtdt1 + ' but is not applied to the codes';
                        }
						else
						{
                            xcol='white';
							s='';
						};

 if(f1.newCustPrice.length != null) {

                       f1.newGrpRetireDt[grpCnt-1].style.backgroundColor = xcol;
                       f1.newGrpRetireDt[grpCnt-1].title=s;
}else
{
                       f1.newGrpRetireDt.style.backgroundColor = xcol;
                       f1.newGrpRetireDt.title=s;

};

if(sAllowRSID!='')
	{
	
                    xerr1=(nrsid!=nrsid1);
                    xerr=xerr||xerr1;  
                    if (xerr1)
                        {
					       xcol='#eedede';
						   s='Current value was changed from previous ' + nrsid1 + ' but is not applied to the codes';
                        }
						else
						{
                            xcol=newrsIdColor; //'white';
							s='';
						};

 if(f1.newCustPrice.length != null) {

                       f1.newrsId[grpCnt-1].style.backgroundColor = xcol;
                       f1.newrsId[grpCnt-1].title=s;
					  // f1.newGrpRetireDt[grpCnt-1].style.backgroundColor = xcol;
                      
}else
{
                       f1.newrsId.style.backgroundColor = xcol;
                       f1.newrsId.title=s;

};
				
                   
   };                   
 
 return xerr;

 };


 var nprice, nvbsid, nefdt, nrtdt, nrsid; // must be common!
 var actcount;

 function SetSkipGroupFlag(grpCnt) {

 if(f1.newCustPrice.length != null) {

					if (f1.cex[grpCnt-1].value!='')
					{
 					 fs.skipgrp[grpCnt-1].value= 'y';
					 return false;

					};

					if (f1.skipgrp[grpCnt-1].checked)
					{
			
					 fs.skipgrp[grpCnt-1].value= 'y';
                      return false;

					};

					fs.skipgrp[grpCnt-1].value='';

  } else

  {
					if (f1.cex.value!='')
					{
					 fs.skipgrp.value= 'y';
					 return false;

					};

					if (f1.skipgrp.checked)
					{
			
 					 fs.skipgrp.value= 'y';
                      return false;
                     };
 					 
					 fs.skipgrp.value='';

 };

 return true;

 }

function SetAllSkipGroupFlags() {
var n,i,xerr,xerr1;

n=fs.numgrp.value;

if (n=='0')
{
 return false;
};

xerr=false;

for(i = 1; i <= n; i++) {
xerr1=SetSkipGroupFlag(i);
xerr=xerr||xerr1;
};

return xerr;

}

function roundNumber(rnum) {
	var rlength = 4; // The number of decimal places to round to
	if (rnum > 8191 && rnum < 10485) {
		rnum = rnum-5000;
		var newnumber = Math.round(rnum*Math.pow(10,rlength))/Math.pow(10,rlength);
		newnumber = newnumber+5000;
	} else {
		var newnumber = Math.round(rnum*Math.pow(10,rlength))/Math.pow(10,rlength);
	}
	return  newnumber;
}

 function ValidateGroup(grpCnt,alerts) {
 // var nprice, nvbsid, nefdt, nrtdt; // must be common!
  var xerr1,xerr2,xerr20, xerr3,min1,max1,s,xcol,xwarn;

  var balert = (alerts != '');

             xerr1=false;
             xerr2=false;
             xerr20=false;
             xerr3=false;
			
			 xwarn=false;

if(f1.newCustPrice.length != null) {

					if (f1.cex[grpCnt-1].value!='')
					{
                   //  fs.newCustPrice[grpCnt-1].value= f1.newCustPrice[grpCnt-1].value;
					 fs.skipgrp[grpCnt-1].value= 'y';
					 return false;

					};

					if (f1.skipgrp[grpCnt-1].checked)
					{
			
				//	  fs.newCustPrice[grpCnt-1].value= '0'; // nprice;   //                     
				        fs.newCustPrice[grpCnt-1].value=f1.newCustPrice[grpCnt-1].value;
                        fs.newvbsId[grpCnt-1].value=f1.newvbsId[grpCnt-1].value; 
                        fs.newGrpEffectDt[grpCnt-1].value=f1.newGrpEffectDt[grpCnt-1].value;
                        fs.newGrpRetireDt[grpCnt-1].value=f1.newGrpRetireDt[grpCnt-1].value;
						
						fs.newCustPriceSave[grpCnt-1].value=f1.newCustPriceSave[grpCnt-1].value;
                        fs.newvbsIdSave[grpCnt-1].value=f1.newvbsIdSave[grpCnt-1].value; 
                        fs.newvbsIdTextSave[grpCnt-1].value=f1.newvbsIdTextSave[grpCnt-1].value; 

                        fs.newGrpEffectDtSave[grpCnt-1].value=f1.newGrpEffectDtSave[grpCnt-1].value;
                        fs.newGrpRetireDtSave[grpCnt-1].value=f1.newGrpRetireDtSave[grpCnt-1].value;
						
					    fs.newrsId[grpCnt-1].value=f1.newrsId[grpCnt-1].value; 
                        fs.newrsIdSave[grpCnt-1].value=f1.newrsIdSave[grpCnt-1].value; 
                        fs.newrsIdColor[grpCnt-1].value=f1.newrsIdColor[grpCnt-1].value; 
                     
						fs.grpindex[grpCnt-1].value=f1.grpindex[grpCnt-1].value;
						document.getElementById('idnp'+grpCnt).options.length=0;
						document.getElementById('idnp'+grpCnt).options[0]=new Option("SKIPPED", "0");           
						
 					    fs.skipgrp[grpCnt-1].value= 'y';

                        document.getElementById('rid'+grpCnt).style.backgroundColor='#b3c7d2';
                          
                        return false;

					};
                    
					document.getElementById('rid'+grpCnt).style.backgroundColor='';
                      
                    fs.skipgrp[grpCnt-1].value ='';

                    nprice=f1.newCustPrice[grpCnt-1].value;
	                
                    s='';

                    if (isNaN(nprice)) {
	                        s = 'Line ' + grpCnt + ': New Cust. Price Rate Must A Number!';
                            if (balert) {  alert(s); }

						    xerr1=true;
	                    }
					 
					 
	                    if ((!xerr1)&&(1*nprice <= 1*(f1.gvcost[grpCnt-1].value))) {
                            s = 'Line ' + grpCnt + ': New Cust. Rate Must > $' + f1.gvcost[grpCnt-1].value + '  - Vendor Rate!';
                            if (balert) {  alert(s); }

						    xerr1=true;
	                    }
					
                        if (xerr1)
                        {
                           xcol='#FA8072';
                        }
						else
						{
	                       xcol='white';
						};

                       f1.newCustPrice[grpCnt-1].style.backgroundColor = xcol;
                       f1.newCustPrice[grpCnt-1].title=s;
						
					   if ((!xerr1)&&( (1*nprice) > (roundNumber(0.02 + 1*(f1.gvcost[grpCnt-1].value)) ))) {
                            
							s = 'Warning: New Cust.Rate ' + nprice + ' Is 2 cents more then Vendor Cost ' + f1.gvcost[grpCnt-1].value;
                           	
							v=document.getElementById('idnp'+grpCnt).value;
							l=document.getElementById('idnp'+grpCnt).options.length;

                            if (v=='0')
							{
                              if (balert) {  alert(s); };
							  xerr1=true;
							  xwarn=true;
							};
                            
					
                            document.getElementById('idnp'+grpCnt).options.length=0;
                            document.getElementById('idnp'+grpCnt).options[0]=new Option("Deny", "0");           
                 			document.getElementById('idnp'+grpCnt).options[1]=new Option("Allow", "1");

                            k=fs.nnnp[grpCnt-1].value;
                
							if (((v=='1')&&(l==2))||((k=='1')&&(l==0)))
                    	    {
							k=1;
                            document.getElementById('idnp'+grpCnt).options.selectedIndex = k; 

                            }
							else
							{
							k=0;
                            document.getElementById('idnp'+grpCnt).options.selectedIndex = k; 
							xerr1=true;  
							};


  						    document.getElementById('idtdnp'+grpCnt).title=s;

                            
                            fs.nnnp[grpCnt-1].value = k; 

						   }
						else
						{
						
						    document.getElementById('idnp'+grpCnt).options.length=0;
							if (xerr1)
							{
							document.getElementById('idnp'+grpCnt).options[0]=new Option("ER", "0");           
							}
							else
							{
                            document.getElementById('idnp'+grpCnt).options[0]=new Option("OK", "1");           
							};

						    fs.nnnp[grpCnt-1].value = ''; 

                        };


						if (xerr1)
						    {
							 //s='Error';
							 xcol='#FA8072';
						    }
							else
							{
						    s='OK'; 
							xcol='lightgreen';
							};

                        	document.getElementById('idnp'+grpCnt).style.backgroundColor=xcol;
                            document.getElementById('idtdnp'+grpCnt).title=s;

					
					 
					   s='';  

                       nvbsid=f1.newvbsId[grpCnt-1].value;       
                       if (nvbsid=='0') {
	                        s = 'Line ' + grpCnt + ': New Billing Increment Must Be Selected!';

	                        if (balert) {  alert(s); }

							xerr3=true;
	                    }
					
                       if (xerr3)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}

                    	f1.newvbsId[grpCnt-1].style.backgroundColor = xcol;
                        f1.newvbsId[grpCnt-1].title=s;

                        nrsid=f1.newrsId[grpCnt-1].value;

                      // if (nrsid=='0') {
	                  //      s = 'Line ' + grpCnt + ': New RSID Must Be Selected!';

	                   //     if (balert) {  alert(s); }

						//	xerr3a=true;
	                  //  }
					
                   //    if (xerr3a)
                   //     {
                   //        xcol='#FA8072';
                    //    }
					//	else
					//	{
                     //       xcol='white';
					//	}

                    	//f1.newrsId[grpCnt-1].style.backgroundColor = xcol;
                        //f1.newrsId[grpCnt-1].title=s;


						s='';
                  
                        min1=f1.maxcustefdt[grpCnt-1].value;                   
					    
						s1='Cust';
				        if (min1=='--none--')
						{
                          min1=f1.maxvendefdt[grpCnt-1].value;                   
					      s1='Vend';
						}

						if (min1.indexOf('.') > -1)
                              {
                                      min1=min1.replace('.', ' ');

                              };

					   nefdt=f1.newGrpEffectDt[grpCnt-1].value;
                       if (nefdt!='--tonight--')
                       {
					   if (nefdt.indexOf('.') > -1)
                              {
                                      nefdt=nefdt.replace('.',' ');

                               };

                       if (!isDateM(nefdt)) {
	                        s = 'Line ' + grpCnt + ': New Effect Date is Wrong!';
                            if (balert) {  alert(s); }
	                        xerr20=true;
	                    }
						else
						{
						  min1=dateAdd('s',1,min1);
					
						  if ( (new Date(nefdt)) <= (new Date(min1)) )
				            {
                                s= 'Wrong Effect Date : less then Max '+s1+' Effect Date';
							    if (balert) {  alert(s); }
	                       		xerr20=true;
				            }
						}
                        } 

                        if (xerr20)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}

                        f1.newGrpEffectDt[grpCnt-1].style.backgroundColor = xcol;

                        f1.newGrpEffectDt[grpCnt-1].title=s;

                         s='';

                        //f1.newGrpRetireDt[grpCnt-1].style.backgroundColor = xcol;

						max1=f1.maxvendrtdt[grpCnt-1].value;

						if (max1.indexOf('.') > -1)
                              {
                                      max1=max1.replace('.', ' ');

                              };


                       nrtdt=f1.newGrpRetireDt[grpCnt-1].value;
                       if (nrtdt!='--never--'&&nrtdt!='')
                       {
   					   if (nrtdt.indexOf('.') > -1)
                             {
                                      nrtdt=nrtdt.replace('.', ' ');

                               };

 
                  if (!isDateM(nrtdt)) {
	                        s = 'Line ' + grpCnt + ': New Retire Date is Wrong!';
							if (balert) {  alert(s); }
	                       	xerr2=true;
	                    }
						else
						{
                          
						  if (isDateM(nefdt))
						  {
						  min1=dateAdd('s',1,nefdt);
					
						  if ( (new Date(nrtdt)) <= (new Date(min1)) )
				            {
                                s='Wrong New Retire Date : less then New Effect Date'; 
								if (balert) {  alert(s); }
	                       		xerr2=true;
				            }
                          };

                          if (isDateM(max1))
						  {
						  //min1=dateAdd('s',1,nefdt);
					
						  if ( (new Date(max1)) <= (new Date(nrtdt)) )
				            {
                                s='Wrong New Retire Date : more then Max Vendor Retire Date'; 
                                if (balert) {  alert(s); }
	                       		
								xerr2=true;
				            }
                          };

						}
						}
                       
                        if (xerr2)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}


                        f1.newGrpRetireDt[grpCnt-1].style.backgroundColor = xcol;
                        f1.newGrpRetireDt[grpCnt-1].title=s;
                       
						fs.newCustPrice[grpCnt-1].value=f1.newCustPrice[grpCnt-1].value;
                        fs.newvbsId[grpCnt-1].value=f1.newvbsId[grpCnt-1].value; 
                        fs.newGrpEffectDt[grpCnt-1].value=f1.newGrpEffectDt[grpCnt-1].value;
                        fs.newGrpRetireDt[grpCnt-1].value=f1.newGrpRetireDt[grpCnt-1].value;
						fs.newCustPriceSave[grpCnt-1].value=f1.newCustPriceSave[grpCnt-1].value;
                        fs.newvbsIdSave[grpCnt-1].value=f1.newvbsIdSave[grpCnt-1].value; 
						fs.newvbsIdTextSave[grpCnt-1].value=f1.newvbsIdTextSave[grpCnt-1].value; 

                        fs.newGrpEffectDtSave[grpCnt-1].value=f1.newGrpEffectDtSave[grpCnt-1].value;
                        fs.newGrpRetireDtSave[grpCnt-1].value=f1.newGrpRetireDtSave[grpCnt-1].value;

						fs.newrsId[grpCnt-1].value=f1.newrsId[grpCnt-1].value; 
                    	fs.newrsIdSave[grpCnt-1].value=f1.newrsIdSave[grpCnt-1].value; 
                        fs.newrsIdColor[grpCnt-1].value=f1.newrsIdColor[grpCnt-1].value; 
                     
						fs.grpindex[grpCnt-1].value=f1.grpindex[grpCnt-1].value;
						
						}


						else // if(f1.newCustPrice.length != null) 
						{

					if (f1.cex.value!='')
					{

				    //fs.newCustPrice.value= '0'; // nprice;   //                     
					fs.skipgrp.value= 'y';

                     return false;

					}

					if (f1.skipgrp.checked)
					{

//					  fs.newCustPrice.value= '0'; // nprice;   //        

				        fs.newCustPrice.value= f1.newCustPrice.value;
					    fs.newvbsId.value=f1.newvbsId.value; 
                        fs.newGrpEffectDt.value=f1.newGrpEffectDt.value;
                        fs.newGrpRetireDt.value=f1.newGrpRetireDt.value;
						fs.newCustPriceSave.value=f1.newCustPriceSave.value;
                        fs.newvbsIdSave.value=f1.newvbsIdSave.value; 
						fs.newvbsIdTextSave.value=f1.newvbsIdTextSave.value; 
                        fs.newGrpEffectDtSave.value=f1.newGrpEffectDtSave.value;
                        fs.newGrpRetireDtSave.value=f1.newGrpRetireDtSave.value;
						
					    fs.newrsId.value=f1.newrsId.value; 
					    fs.newrsIdSave.value=f1.newrsIdSave.value; 
                        fs.newrsIdColor.value=f1.newrsIdColor.value; 
                     
						fs.grpindex.value=f1.grpindex.value;
						document.getElementById('idnp'+grpCnt).options.length=0;
						document.getElementById('idnp'+grpCnt).options[0]=new Option("SKIPPED", "0");           
						
   					    fs.skipgrp.value= 'y';

                        document.getElementById('rid'+grpCnt).style.backgroundColor='#b3c7d2';
                       
                      return false;

					};

                         document.getElementById('rid'+grpCnt).style.backgroundColor='';
                       
						 fs.skipgrp.value ='';

                         nprice=f1.newCustPrice.value;
	   

                          if (isNaN(nprice)) {
	                        s = 'Line ' + grpCnt + ': New Cust. Price Rate Must A Number!';
                            if (balert) {  alert(s); }

						    xerr1=true;
	                    }
					 
					 
	                    if ((!xerr1)&&(1*nprice <= 1*(f1.gvcost.value))) {
                            s = 'Line ' + grpCnt + ': New Cust. Rate Must > $' + f1.gvcost.value + '  - Vendor Rate!';
                            if (balert) {  alert(s); }

						    xerr1=true;
	                    }
					
                        if (xerr1)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						};

                       f1.newCustPrice.style.backgroundColor = xcol;
                       f1.newCustPrice.title = s;

                     if ((!xerr1)&&( (1*nprice) > (roundNumber(0.02 + 1*(f1.gvcost.value)) ))) {
                            s = 'Warning: New Cust.Rate ' + nprice + ' Is 2 cents more then Vendor Cost ' + f1.gvcost.value;
                           	
							v=document.getElementById('idnp'+grpCnt).value;
							l=document.getElementById('idnp'+grpCnt).options.length;

                            if (v=='0')
							{
                              if (balert) {  alert(s); };
							  xerr1=true;
							  xwarn=true;
							};
                            
							//document.getElementById('idnp'+grpCnt).style.backgroundColor='yellow';
                            //document.getElementById('idnp'+grpCnt).title=s;
                            document.getElementById('idnp'+grpCnt).options.length=0;
                            document.getElementById('idnp'+grpCnt).options[0]=new Option("Deny", "0");           
                 			document.getElementById('idnp'+grpCnt).options[1]=new Option("Allow", "1");

  
                            k=fs.nnnp.value;
                
							if (((v=='1')&&(l==2))||((k=='1')&&(l==0)))
                    	    {
							k=1;
                            document.getElementById('idnp'+grpCnt).options.selectedIndex = k; 

                            }
							else
							{
							k=0;
                            document.getElementById('idnp'+grpCnt).options.selectedIndex = k; 
							xerr1=true;  
							};


  						    document.getElementById('idtdnp'+grpCnt).title=s;

                            
                            fs.nnnp.value = k; 

/*
							if ((v=='1')&&(l==2))
                    	    {
                              document.getElementById('idnp'+grpCnt).options.selectedIndex = 1; 
  						    }
							else
							{
							document.getElementById('idnp'+grpCnt).options.selectedIndex = 0; 
							xerr1=true;
							};

  						    document.getElementById('idtdnp'+grpCnt).title=s;

*/
							//document.getElementById('idnp'+grpCnt).style.backgroundColor='yellow';
                            //document.getElementById('idnp'+grpCnt).title=s;

						   }
						else
						{
						    document.getElementById('idnp'+grpCnt).options.length=0;
							if (xerr1)
							{
							document.getElementById('idnp'+grpCnt).options[0]=new Option("ER", "0");           
							}
							else
							{
                            document.getElementById('idnp'+grpCnt).options[0]=new Option("OK", "1");           
							};
                        };

						if (xerr1)
						    {
							 //s='Error';
							 xcol='#FA8072';
						    }
							else
							{
						    s='OK'; 
							xcol='lightgreen';
							};

                        	document.getElementById('idnp'+grpCnt).style.backgroundColor=xcol;
                            document.getElementById('idtdnp'+grpCnt).title=s;

					 
					   s='';

                       nvbsid=f1.newvbsId.value;       
                       if (nvbsid=='0') {
	                        s = 'Line ' + grpCnt + ': New Billing Increment Must Be Selected!';

	                        if (balert) {  alert(s); }

							xerr3=true;
	                    }
					
                       if (xerr3)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}

                    	f1.newvbsId.style.backgroundColor = xcol;
						f1.newvbsId.title = s;

						
					   nrsid=f1.newrsId.value;

                     //  if (nrsid=='0') {
	                 //       s = 'Line ' + grpCnt + ': New RSID Must Be Selected!';

	                 //       if (balert) {  alert(s); }

					//		xerr3a=true;
	                //    }
					
                  //     if (xerr3a)
                  //      {
                  //         xcol='#FA8072';
                  //      }
				//		else
				//		{
                  //          xcol='white';
					//	}

                    	//f1.newrsId.style.backgroundColor = xcol;
                        //f1.newrsId.title=s;


						s=''; 
                        min1=f1.maxcustefdt.value;                   
   					    s1='Cust';
				        if (min1=='--none--')
						{
                          min1=f1.maxvendefdt.value;                   
					      s1='Vend';
						}
    
                    	if (min1.indexOf('.') > -1)
                              {
                                      min1=min1.replace('.', ' ');

                              };


					   nefdt=f1.newGrpEffectDt.value;
                       if (nefdt!='--tonight--')
                       {
					   if (nefdt.indexOf('.') > -1)
                              {
                                      nefdt=nefdt.replace('.', ' ');

                               };

                       if (!isDateM(nefdt)) {
	                        s = 'Line ' + grpCnt + ': New Effect Date is Wrong!';
                            if (balert) {  alert(s); }
	                        xerr20=true;
	                    }
						else
						{
						  min1=dateAdd('s',1,min1);
					
						  if ( (new Date(nefdt)) <= (new Date(min1)) )
				            {
                                s= 'Wrong Effect Date : less then Max '+s1+' Effect Date';
							    if (balert) {  alert(s); }
	                       		xerr20=true;
				            }
						}
                        } 

                        if (xerr20)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}

                        f1.newGrpEffectDt.style.backgroundColor = xcol;
                        f1.newGrpEffectDt.title=s;
                        //f1.newGrpRetireDt.style.backgroundColor = xcol;

						max1=f1.maxvendrtdt.value;

						if (max1.indexOf('.') > -1)
                              {
                                      max1=max1.replace('.', ' ');

                              };


                       nrtdt=f1.newGrpRetireDt.value;
                       if (nrtdt!='--never--'&&nrtdt!='')
                       {
   					   if (nrtdt.indexOf('.') > -1)
                             {
                                      nrtdt=nrtdt.replace('.', ' ');

                               };

 
                  if (!isDateM(nrtdt)) {
	                        s = 'Line ' + grpCnt + ': New Retire Date is Wrong!';
							if (balert) {  alert(s); }
	                       	xerr2=true;
	                    }
						else
						{
                          
						  if (isDateM(nefdt))
						  {
						  min1=dateAdd('s',1,nefdt);
					
						  if ( (new Date(nrtdt)) <= (new Date(min1)) )
				            {
                                s='Wrong New Retire Date : less then New Effect Date'; 
								if (balert) {  alert(s); }
	                       		xerr2=true;
				            }
                          };

                          if (isDateM(max1))
						  {
						  //min1=dateAdd('s',1,nefdt);
					
						  if ( (new Date(max1)) <= (new Date(nrtdt)) )
				            {
                                s='Wrong New Retire Date : more then Max Vendor Retire Date'; 
                                if (balert) {  alert(s); }
	                       		
								xerr2=true;
				            }
                          };

						}
						}
                       
                        if (xerr2)
                        {
                           xcol='#FA8072';
                        }
						else
						{
                            xcol='white';
						}


                        f1.newGrpRetireDt.style.backgroundColor = xcol;
                        f1.newGrpRetireDt.title=s;

                       	fs.newCustPrice.value=f1.newCustPrice.value;
                        fs.newvbsId.value=f1.newvbsId.value; 
                        fs.newGrpEffectDt.value=f1.newGrpEffectDt.value;
                        fs.newGrpRetireDt.value=f1.newGrpRetireDt.value;
						fs.newCustPriceSave.value=f1.newCustPriceSave.value;
                        fs.newvbsIdSave.value=f1.newvbsIdSave.value; 
						fs.newvbsIdTextSave.value=f1.newvbsIdTextSave.value; 
                        fs.newGrpEffectDtSave.value=f1.newGrpEffectDtSave.value;
                        fs.newGrpRetireDtSave.value=f1.newGrpRetireDtSave.value;
					    fs.newrsId.value=f1.newrsId.value; 
					    fs.newrsIdSave.value=f1.newrsIdSave.value; 
                        fs.newrsIdColor.value=f1.newrsIdColor.value; 
                     
						fs.grpindex.value=f1.grpindex.value;

						};

						
 
 if (xerr1||xerr2||xerr20||xerr3)
 {
 if(xwarn)
 {
 CheckDirty(grpCnt);
 }
 return true;
 }
 else
 {
 actcount=actcount+1;
 CheckDirty(grpCnt);
 return false;
 };

 }
 
function doSubCust(gCnt) {
    var i,xerr,xerr1,xerr2,xdirty;
	 
	 xerr=false;
	 xdirty=false;
	 
	 actcount=0;

     for(i = 1; i <= gCnt; i++) {

			  xerr1=ValidateGroup(i,''); 
			  xerr=xerr||xerr1;
			  if(!xerr1) 
			  {
			   xerr2=CheckDirty(i);
               xdirty=xdirty||xerr2;
	 }        };
	         
    if (xerr)
	{

	alert("Please correct errors!");
	            return false;
	}


//	var err=document.frmCust.rederrf.value;

//	if (err !='')
//	{
//	alert("Please correct customer rate problems marked with red color!");
//	            return false;
//	}

	if (xdirty)
	{
      alert('You have changes to codes marked with brown that are not applied.\nPlease apply all changes !')
      return false;

	};

  if (actcount==0)
  {
   alert('Nothing to do...')
   return false;
  };

	if(!confirm('Database is going to be changed. Proceed query?'))
          {
            return false;
          };

        fs.sIntention.value="saveall" //document.frmCust.isBack.value = 'true';
		fs.sgrpCnt.value=gCnt;
		KeepMainFilter();

					
        fs.submit();
        return true;
	}



function doApplyAll(gCnt) {
    var i,xerr;

 actcount=0;

	for(i = 1; i <= gCnt; i++) {

			  xerr1=ValidateGroup(i,''); 
			  xerr=xerr||xerr1;
	
	};

    if (xerr)
	{

	alert("Please correct errors!");
	            return false;
	}

  if (actcount==0)
  {
   alert('Nothing to do...')
   return false;
  };

    if(!confirm('Database is going to be changed. Proceed query?'))
          {
            return false;
          };

        

        fs.sIntention.value="addallgrpsave"; //document.frmCust.isBack.value = 'true';
		fs.sallgrpCnt.value=gCnt;
		
		KeepMainFilter();

		for(i = 1; i <= gCnt; i++) {

        if(fs.newCustPrice.length != null) {
		fs.newCustPriceSave[i-1].value=fs.newCustPrice[i-1].value;
        fs.newvbsIdSave[i-1].value=fs.newvbsId[i-1].value;
		fs.newGrpRetireDtSave[i-1].value=fs.newGrpRetireDt[i-1].value;
	    fs.newGrpEffectDtSave[i-1].value=fs.newGrpEffectDt[i-1].value;
	
		}else
		{
		//f1.newCustPriceSave.value='0';
		fs.newCustPriceSave.value=fs.newCustPrice.value;
        fs.newvbsIdSave.value=fs.newvbsId.value;
		fs.newGrpRetireDtSave.value=fs.newGrpRetireDt.value;
	    fs.newGrpEffectDtSave.value=fs.newGrpEffectDt.value;
	 
		};

        }

        fs.sKeepTempTable.value='y';

        SetAllSkipGroupFlags();               

		fs.CheckNewPrice2copy.value=	f1.CheckNewPrice2copy.options[f1.CheckNewPrice2copy.selectedIndex].value;
		fs.newCustPrice2copy.value=f1.newCustPrice2copy.value; 
		fs.newBi2copy.value=f1.newBi2copy.value;
		fs.newRetireDt2copy.value=f1.newRetireDt2copy.value;
		fs.newEffectDt2copy.value=f1.newEffectDt2copy.value;


        fs.submit();
        return true;

	}
					

  
		   
function doApplyCustGroup1(grpCnt) { //, voipuservendid, paramsql,paramfilt) {
    var s, xerrall;

       actcount=0;

       xerrall=ValidateGroup(grpCnt,'y');

	   
       if(xerrall)
		{
		 return false;
		}
		else
		{

  if (actcount==0)
  {
   alert('Nothing to do...')
   return false;
  };

		if(!confirm('Database is going to be changed. Proceed query?'))
		{
		return false;
		};

        };
		
		KeepMainFilter();
		fs.sIntention.value='addgrpsave';

	    fs.sgrpCnt.value=grpCnt;
        fs.snprice.value=nprice;
		fs.snvbsid.value=nvbsid;
 
        fs.snrsid.value=nrsid;

        fs.snrtdt.value=nrtdt;
        fs.snefdt.value=nefdt;
        fs.sKeepTempTable.value='y';

        SetAllSkipGroupFlags();               

		fs.CheckNewPrice2copy.value=f1.CheckNewPrice2copy.options[f1.CheckNewPrice2copy.selectedIndex].value;
		fs.newCustPrice2copy.value=f1.newCustPrice2copy.value; 
		fs.newBi2copy.value=f1.newBi2copy.value;
		fs.newRetireDt2copy.value=f1.newRetireDt2copy.value;
		fs.newEffectDt2copy.value=f1.newEffectDt2copy.value;

		fs.submit();
	    
		return true;
		
	}

 		
function doCopy2All(type) {
    var len,v;

		switch (type) {
		    case '0':
	        v=f1.CheckNewPrice2copy.selectedIndex;
			break;
		    case '1': 
			v=f1.newCustPrice2copy.value; 
			break;
			case '2':
			v=f1.newBi2copy.selectedIndex;
			break;
		    case '3':
            v=f1.newRetireDt2copy.value;
			break; 
            case '4':
            v=f1.newEffectDt2copy.value;
			break; 
			}

		len= f1.newCustPrice.length;  
   	
	    
        if(len != null) {
		for (i=1;i<=len;i++ )
		{
		if(!f1.skipgrp[i-1].checked)
		{
		switch(type) {
		case '0':
		if(document.getElementById('idnp'+i).options.length==2)
		{
		document.getElementById('idnp'+i).selectedIndex=v;
        fs.nnnp[i-1].value=v; 
        };
		break;
		case '1':
		//f1.newCustPriceSave[i-1].value=f1.newCustPrice[i-1].value;
		f1.newCustPrice[i-1].value=v; break;
        case '2':
        //f1.newvbsIdSave[i-1].value=f1.newvbsId[i-1].value;
	    f1.newvbsId[i-1].selectedIndex=v; break;
        break;
		case '3':
		//f1.newGrpRetireDtSave[i-1].value=f1.newGrpRetireDt[i-1].value;
		f1.newGrpRetireDt[i-1].value=v; break;
		case '4':
		//f1.newGrpEffectDtSave[i-1].value=f1.newGrpEffectDt[i-1].value;
		f1.newGrpEffectDt[i-1].value=v; break;

		}
		ValidateGroup(i,'');
		}
		}
		}
		else
		{
		if(!f1.skipgrp[i-1].checked)
		{
		switch(type) {
		case '0':
		if(document.getElementById('idnp'+1).options.length==2)
		{
		document.getElementById('idnp'+1).selectedIndex=v;
        fs.nnnp[0].value=v; 
        };
		break;

		case '1':
		//f1.newCustPriceSave.value=f1.newCustPrice.value;
		f1.newCustPrice.value=v; break;
        case '2':
        //f1.newvbsIdSave.value=f1.newvbsId.value;
		f1.newvbsId.selectedIndex=v; break;
       	break;
		case '3':
		//f1.newGrpRetireDtSave.value=f1.newGrpRetireDt.value;
		f1.newGrpRetireDt.value=v; break;
		case '4':
		//f1.newGrpEffectDtSave.value=f1.newGrpEffectDt.value;
		f1.newGrpEffectDt.value=v; break;

		}
  	    ValidateGroup(1,'');
        }
		};

	    return true;

}

	

 function doDialCode(p,prm) {
 var link,sp;
   
	if (fId != null)
			{
			return false;
			};

	link= prm ;

	sp=document.getElementById('idDstPattern').value;
	
	
   
	link = link +'&list='+sp ; //document.getElementById('idDstPattern').value;
	
   
  	return acctWin(p,link);

}


function ccheckskipdb() {
var vcheckskipdb;

if (f1.checkskipdb.value=='Check All')
{
vcheckskipdb='y';
f1.checkskipdb.value='Clear All'
}
else
{
vcheckskipdb='';
f1.checkskipdb.value='Check All'
};



 for (i=1;i<=irecpgdb;i++)
 {
       
          if(eval('f1.eskipdb'+i)=='[object]') {
		  if(vcheckskipdb!='') {
		    eval('f1.eskipdb'+i+'.checked=true');
			}
			else
			{
			eval('f1.eskipdb'+i+'.checked=false');
		     };
		  };
        
};	

return false;

};

	if (fId != null)
			{

           
	    f1.fX1CustId.disabled=true;
		f1.fvoipUserId.disabled=true;
		f1.fDestination.disabled=true;	
		f1.fDestinationType.disabled=true;			
	    f1.fDestinationMobileCarrier.disabled=true;
		f1.fDescription.disabled=true;
		f1.fStatusId.disabled=true;
        f1.fAddVendorId.disabled=true;
        //f1.fAddNewRate.disabled=true;
			};




</script>
<%
if workgroupCnt > 0 Then
                 
				For i=1 To workgroupCnt
				s="<script>ValidateGroup(" & i & ",''); </script>"
				Response.write s
			
				Next
End if				

%>


<!--#include file=../include/footer.asp-->

