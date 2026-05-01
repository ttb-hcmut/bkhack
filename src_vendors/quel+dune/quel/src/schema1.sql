/* Setup Instruction for PostgreSQL

First, run a front-end of PostgreSQL
>psql

Create a database:
> create database example owner user1 encoding 'utf8';

`example` is database name, `user1` is the owner user of the database.

Change the database:
> \c example user1;

Run this file:
> \i schema1.sql

*/
 

/* setup and initialize tables */
drop table products;
drop table orders;

create table products(
    pid integer,
    name text,
    price integer
);

create table orders(
    oid integer,
    pid integer,
    qty integer
);

insert into products(pid, name, price)
values(1,'Tablet',500);

insert into products(pid, name, price)
values(2,'Laptop',1000);

insert into products(pid, name, price)
values(3,'Desktop',1000);

insert into products(pid, name, price)
values(4,'Router',150);

insert into products(pid, name, price)
values(5,'HDD',100);

insert into products(pid, name, price)
values(6,'SSD',500);

insert into orders(oid, pid, qty)
values(1, 1, 5);

insert into orders(oid, pid, qty)
values(1, 2, 5);

insert into orders(oid, pid, qty)
values(1, 4, 2);

insert into orders(oid, pid, qty)
values(2, 5, 10);

insert into orders(oid, pid, qty)
values(2, 6, 20);

insert into orders(oid, pid, qty)
values(3, 2, 50);


/* examples */

/* Q1 */
SELECT o.*
FROM orders AS o
WHERE o.oid = $oid$

/* Q2 */
SELECT p.pid AS pid,
       p.name AS name,
       p.price * $o.qty$ AS sale
FROM products AS p
WHERE p.pid = $o.pid$

/* Q3 */
SELECT p.pid AS pid,
       p.name AS name,
       p.price * o.qty AS sale
FROM products AS p, orders AS o
WHERE p.pid = o.pid AND o.oid = $oid$

/* Q4 */
/*
SELECT p.category AS category, SUM(p.price*o.qty) AS summary
FROM orders AS o, products AS p
WHERE o.pid = p.pid AND p.price > 200
GROUP BY p.category
HAVING SUM(qty/10) > 1;
*/

SELECT p.price, SUM(p.price * o.qty)
FROM products AS p, orders AS o
WHERE p.pid = o.pid
  AND p.price > 100 /* HDD is excluded */
GROUP BY p.price
HAVING SUM(p.price * o.qty) > 500;  /* a group of price 150 is excluded */
/* Result:
 price |  sum
-------+-------
  1000 | 55000
   500 | 12500
*/
