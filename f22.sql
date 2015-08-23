CREATE FUNCTION TRUNCDSTP(dst VARCHAR(50)) RETURNS VARCHAR(50)  AS '
DECLARE
        r VARCHAR(50);
BEGIN

      r='''';

      r=(SELECT CASE WHEN (SELECT substring(dst,1,1))=''1'' THEN

      substring(dst,1,7) ELSE 
      CASE WHEN substring((SELECT substring(dst,4,7)),1,1)=''1'' 
      
      THEN (SELECT substring(dst,4,7)) ELSE '''' END END);



RETURN r;

END;' LANGUAGE 'plpgsql';

