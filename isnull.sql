CREATE OR REPLACE FUNCTION ISNULL(la varchar(100), ra varchar(100)) RETURNS varchar(100)  AS '
DECLARE
        b varchar(100);
BEGIN

      b=la;
      if la is null then
       b=ra;
      end if;   
                
RETURN b;

END;' LANGUAGE 'plpgsql';
