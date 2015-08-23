CREATE OR REPLACE FUNCTION ISNULL(la boolean, ra boolean) RETURNS boolean  AS '
DECLARE
        b boolean;
BEGIN

      b=la;
      if la is null then
       b=ra;
      end if;   
                
RETURN b;

END;' LANGUAGE 'plpgsql';
