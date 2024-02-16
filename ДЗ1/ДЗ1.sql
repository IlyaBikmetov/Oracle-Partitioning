create table payment_range
(
  payment_id      number(30) not null,
  from_client_id  number(30) not null,
  to_client_id    number(30) not null,
  status_id       varchar2(10 char) not null,
  payment_date    date not null,
  summa           number(20,2)
)
partition by range (payment_date) (
  partition pJan values less than (to_date('01.02.2024', 'dd.mm.yyyy')),
  partition pFeb values less than (to_date('01.03.2024', 'dd.mm.yyyy')),
  partition pMar values less than (to_date('01.04.2024', 'dd.mm.yyyy')),
  partition pApr values less than (to_date('01.05.2024', 'dd.mm.yyyy'))
);

insert into payment_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (1, 2, 3, 'PAYED', sysdate - 24, 456.767);
insert into payment_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (2, 2, 3, 'CANCELED', sysdate, 4767);
insert into payment_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (3, 2, 3, 'ERROR', sysdate + 24, 47);
commit;

select * from payment_range partition (pJan);
select * from payment_range partition (pFeb);
select * from payment_range partition (pMar);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

create table payment_interval
(
  payment_id      number(30) not null,
  from_client_id  number(30) not null,
  to_client_id    number(30) not null,
  status_id       varchar2(10 char) not null,
  payment_date    date not null,
  summa           number(20,2)
)
partition by range (payment_date)
interval (numtoyminterval(1, 'MONTH'))
(
  partition part_01 values less than (to_date('01.01.2024', 'dd.mm.yyyy'))
);

insert into payment_interval (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (1, 2, 3, 'PAYED', sysdate - 24, 456.767);
insert into payment_interval (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (2, 2, 3, 'CANCELED', sysdate, 4767);
insert into payment_interval (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (3, 2, 3, 'ERROR', sysdate + 24, 47);
commit;

select * from user_tab_partitions u where u.table_name = 'PAYMENT_INTERVAL'; -- ...SYS_P6441...

select * from payment_interval partition (SYS_P6441);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

create table payment_list
(
  payment_id      number(30) not null,
  from_client_id  number(30) not null,
  to_client_id    number(30) not null,
  status_id       varchar2(10 char) not null,
  payment_date    date not null,
  summa           number(20,2)
)
partition by list (status_id) ( 
  partition pNotOk values ('CANCELED', 'ERROR'),
  partition pPayed values ('PAYED'),
  partition pNotPayed values ('NOT_PAYED')
);

alter table payment_list add constraint payment_status_chk
check (status_id in ('PAYED', 'CANCELED', 'NOT_PAYED', 'ERROR'));

insert into payment_list (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (1, 2, 3, 'PAYED', sysdate - 24, 456.767);
insert into payment_list (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (2, 2, 3, 'CANCELED', sysdate, 4767);
insert into payment_list (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (3, 2, 3, 'NOT_PAYED', sysdate + 24, 47);
commit;


select * from payment_list partition (pNotOk);
select * from payment_list partition (pPayed);
select * from payment_list partition (pNotPayed);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

create table payment_hash
(
  payment_id      number(30) not null,
  from_client_id  number(30) not null,
  to_client_id    number(30) not null,
  status_id       varchar2(10 char) not null,
  payment_date    date not null,
  summa           number(20,2)
)
partition by hash (payment_id)
partitions 2;


insert into payment_hash (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (1, 2, 3, 'PAYED', sysdate - 24, 456.767);
insert into payment_hash (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (2, 2, 3, 'CANCELED', sysdate, 4767);
insert into payment_hash (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (3, 2, 3, 'NOT_PAYED', sysdate + 24, 47);
commit;


select * from user_tab_partitions u where u.table_name = 'PAYMENT_HASH'; --SYS_P6443, SYS_P6444

select * from payment_hash partition (SYS_P6444);
