--drop table payment_list_range

create table payment_list_range
(
  payment_id     number(30) not null,
  from_client_id number(30) not null,
  to_client_id   number(30) not null,
  status_id      varchar2(10 char) not null,
  payment_date   date not null,
  summa          number(20,2)
)
partition by list(status_id)
subpartition by range (summa)
subpartition template (
  subpartition p100 values less than (100),
  subpartition p1000 values less than (1000),
  subpartition pmax values less than (maxvalue)
)
(
  partition pPAYED values ('PAYED'),
  partition pCANCELED values ('CANCELED'),
  partition pNOT_PAYED values ('NOT_PAYED'),
  partition pERROR values ('ERROR')
);

alter table payment_list_range add constraint payment_status_chk
check (status_id in ('PAYED', 'CANCELED', 'NOT_PAYED', 'ERROR'));


insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (1, 2, 3, 'PAYED', sysdate, 46.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (2, 2, 3, 'CANCELED', sysdate, 46.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (3, 2, 3, 'NOT_PAYED', sysdate, 46.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (4, 2, 3, 'ERROR', sysdate, 46.767);

insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (5, 2, 3, 'PAYED', sysdate, 456.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (6, 2, 3, 'CANCELED', sysdate, 456.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (7, 2, 3, 'NOT_PAYED', sysdate, 456.767);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (8, 2, 3, 'ERROR', sysdate, 456.767);

insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (9, 2, 3, 'PAYED', sysdate, 454357);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (10, 2, 3, 'CANCELED', sysdate, 454357);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (11, 2, 3, 'NOT_PAYED', sysdate, 454357);
insert into payment_list_range (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (12, 2, 3, 'ERROR', sysdate, 454357);
commit;

select * from user_tab_partitions u where u.table_name = 'PAYMENT_LIST_RANGE';
select * from user_tab_subpartitions u where u.table_name = 'PAYMENT_LIST_RANGE';

select * from payment_list_range partition (PCANCELED);
select * from payment_list_range subpartition (PCANCELED_PMAX);
