CREATE TABLE log_change_address (
    order_id int,
	change_date date,
	change_time time,
    status character varying(15) NOT NULL
);

create function cek_date(oid int)
returns character varying(5)
language plpgsql
as
$$
declare
	shippeddate date;
	status character varying(5);
begin
	select shipped_date into shippeddate 
	from orders where order_id = oid;
	if shippeddate - current_date <0 then
		status := 'no';
	else
		status := 'yes';
	end if;
	return status;
end;
$$;

CREATE PROCEDURE change_address(oid int, address character varying(100), 
								city character varying(100), 
								region character varying(100), 
								postal_code character varying(100), 
								country character varying(100))
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE orders
	SET ship_address = address,
	ship_city = city,
	ship_region = region, 
	ship_postal_code = postal_code,
	ship_country = country
	WHERE order_id = oid;
	INSERT INTO log_change_address VALUES(oid, current_date, current_time, 'success');
	IF cek_date(oid) = 'no' THEN
		ROLLBACK;
		INSERT INTO log_change_address VALUES(oid, current_date, current_time, 'failed');
	end if;
	COMMIT;
end;
$$;

CALL change_address(10248, '59 rue de lAbbaye', 'Reims', 'RJ', '51100', 'France');
CALL change_address(10250, 'Rua do Paço, 67', 'Rio de Janeiro', 'RJ', '05454-876', 'Japan');
select * from log_change_address;

select * from orders
where order_id in (10248, 10250);

update orders
set shipped_date = TO_DATE('2021-07-09', 'YYYY-MM-DD')
where order_id = 10250;

drop table log_change_address;
drop function cek_date;
drop procedure change_address;