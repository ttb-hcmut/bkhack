/* Setup Instruction for PostgreSQL

First, run a front-end of PostgreSQL
>psql

Create a database:
> create database example owner user1 encoding 'utf8';

`example` is database name, `user1` is the owner user of the database.

Change the database:
> \c example user1;

Run this file:
> \i schema_tlinq.sql

*/

/* setup and initialize tables */
drop table people;

create table people(
    name text,
    age integer
);

insert into people(name, age)
values('Alex', 60);

insert into people(name, age)
values('Bert', 55);

insert into people(name, age)
values('Cora', 33);

insert into people(name, age)
values('Drew', 31);

insert into people(name, age)
values('Edna', 21);

insert into people(name, age)
values('Fred', 60);

/* Compose */
SELECT z.name AS name
FROM people AS x, people AS y, people AS z
WHERE true AND y.name = 'Bert'
AND (x.age < z.age OR x.age = z.age)
AND z.age < y.age
AND x.name = 'Edna'

