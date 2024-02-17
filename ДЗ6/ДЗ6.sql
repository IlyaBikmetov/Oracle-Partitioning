drop table payment_virtual;

create table payment_virtual
(
  payment_id  number(30) not null,
  from_client_id  number(30) not null,
  to_client_id number(30) not null,
  status_id   varchar2(10 char) not null,
  payment_date date not null,
  payment_date_dd date as (trunc(payment_date, 'dd'))
)
partition by range(payment_date_dd)
interval(numtodsinterval(1, 'DAY'))
(
  partition pmin values less than (date '2024-01-01')
);

insert into payment_virtual (payment_id, from_client_id, to_client_id, status_id, payment_date) values (5, 2, 3, 'PAYED', to_date('01.02.2024', 'dd.mm.yyyy'));
insert into payment_virtual (payment_id, from_client_id, to_client_id, status_id, payment_date) values (6, 2, 3, 'CANCELED', to_date('02.02.2024', 'dd.mm.yyyy'));
insert into payment_virtual (payment_id, from_client_id, to_client_id, status_id, payment_date) values (7, 2, 3, 'NOT_PAYED', to_date('03.02.2024', 'dd.mm.yyyy'));
insert into payment_virtual (payment_id, from_client_id, to_client_id, status_id, payment_date) values (8, 2, 3, 'ERROR', to_date('04.02.2024', 'dd.mm.yyyy'));
commit;


select * from user_tab_partitions u where u.table_name = 'PAYMENT_VIRTUAL';


alter table payment_virtual enable row movement;

update payment_virtual p set p.payment_date = to_date('14.02.2024', 'dd.mm.yyyy') where p.payment_id = 8;

----------------------------

alter table payment_virtual modify partition SYS_P6548 read only;

select u.table_name, u.partition_name, u.read_only from user_tab_partitions u where u.table_name = 'PAYMENT_VIRTUAL';

insert into payment_virtual (payment_id, from_client_id, to_client_id, status_id, payment_date)
values (9, 2, 3, 'NOT_PAYED', to_date('14.02.2024', 'dd.mm.yyyy'));
