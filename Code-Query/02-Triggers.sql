CREATE INDEX ord_sv ON orders(ship_via);
CREATE INDEX ord_ci ON orders(customer_id);
CREATE INDEX ord_ei ON orders(employee_id);
CREATE INDEX ord_oi ON orders(order_id);
CREATE INDEX ship_si ON shippers(shipper_id);
CREATE INDEX cust_si ON customers(customer_id);
CREATE INDEX emp_ei ON employees(employee_id);
CREATE INDEX ord_det_oi ON order_details(order_id);
CREATE INDEX ord_det_pi ON order_details(product_id);
CREATE INDEX pro_pi ON products(product_id);


create function get_price(uprice real, quantity int, disct real)
returns real
language plpgsql
as
$$
declare
	price real;
begin
	price := uprice * quantity * (1 - disct);
	return price;
end;
$$;

CREATE OR REPLACE FUNCTION ft_invoice_insert()
  RETURNS trigger AS
$$
BEGIN
         INSERT INTO invoice (SELECT b.order_id, 
					b.customer_id, 
					c.company_name, 
					c.address, 
					c.city,  
					c.postal_code, 
					c.country as CustomersCountryID, 
					concat(d.first_name,  ' ', d.last_name) as Salesperson,   
					a.company_name as ShippingVia, 
					e.product_id, 
					f.product_name, 
					e.quantity, 
					get_price(e.unit_price, e.quantity, e.discount) as ExtendedPrice
		from shippers a 
		inner join orders b on a.shipper_id = b.ship_via 
		inner join customers c on c.customer_id = b.customer_id
		inner join employees d on d.employee_id = b.employee_id
		inner join order_details e on b.order_id = e.order_id
		inner join products f on f.product_id = e.product_id
		where e.order_id = new.order_id and f.product_id = new.product_id);
 
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER invoice_insert
  AFTER INSERT
  ON order_details
  FOR EACH ROW
  EXECUTE PROCEDURE ft_invoice_insert();




DROP FUNCTION get_price(uprice real, quantity int, disct real);
DROP TRIGGER invoice_insert ON order_details;
DROP Function ft_invoice_insert();

DROP INDEX ord_sv;
DROP INDEX ord_ci;
DROP INDEX ord_ei;
DROP INDEX ord_oi;
DROP INDEX ship_si;
DROP INDEX cust_si;
DROP INDEX emp_ei;
DROP INDEX ord_det_oi;
DROP INDEX ord_det_pi;
DROP INDEX pro_pi;

SELECT * FROM invoice ORDER BY order_id DESC LIMIT 10;
SELECT * FROM order_details ORDER BY order_id DESC LIMIT 10;

INSERT INTO order_details Values(510249, 20, 58.12, 9, 0.35);

DELETE from order_details WHERE order_id = 510249 and product_id = 20;
DELETE from invoice WHERE order_id = 510249 and product_id = 20;

select * from invoice;
 