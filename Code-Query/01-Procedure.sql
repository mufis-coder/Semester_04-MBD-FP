ALTER TABLE orders
ADD delivery_time character varying(20);

UPDATE orders 
  SET delivery_time = 	CASE WHEN(required_date - shipped_date) <= 30 THEN 'Short'
  						WHEN (required_date - shipped_date) > 30 AND (required_date - shipped_date) <= 60 THEN 'Medium'
						WHEN (required_date - shipped_date) > 60 THEN 'Long'
						END;

CREATE INDEX ind_rd ON orders(required_date); 
CREATE INDEX ind_sd ON orders(shipped_date);

CREATE PROCEDURE proc_dt()
LANGUAGE SQL
AS $$
  UPDATE orders 
  SET delivery_time = 	CASE WHEN(required_date - shipped_date) <= 30 THEN 'Short'
  						WHEN (required_date - shipped_date) > 30 AND (required_date - shipped_date) <= 60 THEN 'Medium'
						WHEN (required_date - shipped_date) > 60 THEN 'Long'
						END;
$$;

CALL proc_dt();
select * from orders;

DROP PROCEDURE proc_dt();
DROP INDEX ind_rd;
DROP INDEX ind_sd;
ALTER TABLE orders DROP COLUMN delivery_time;