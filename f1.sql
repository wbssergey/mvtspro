CREATE FUNCTION CDCOMP(la CHARACTER, ra timestamp without time zone) RETURNS BOOLEAN  AS '
DECLARE
        b boolean;
BEGIN

      b= (SELECT la= CAST(ra AS CHARACTER) );
        
                
RETURN b;

END;' LANGUAGE 'plpgsql';
