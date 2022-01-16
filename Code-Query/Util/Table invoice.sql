CREATE TABLE invoice AS (SELECT       b.order_id, 
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
            e.unit_price * e.quantity * (1 - e.discount) as ExtendedPrice
from shippers a 
inner join orders b on a.shipper_id = b.ship_via 
inner join customers c on c.customer_id = b.customer_id
inner join employees d on d.employee_id = b.employee_id
inner join order_details e on b.order_id = e.order_id
inner join products f on f.product_id = e.product_id
order by b.order_id); 