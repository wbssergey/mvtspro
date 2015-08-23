CREATE FUNCTION  fnGetUSState(
    varchar(20) ) RETURNS varchar(2)

AS '
select npa."Location" from "tblVoIPDestinationUSA" ds
join npa on npa."NPA"=substr(lpad($1,4),2)
;' LANGUAGE 'sql';
