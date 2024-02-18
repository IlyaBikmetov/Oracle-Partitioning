create table payment_system
(
  payment_id      number(30) not null,
  from_client_id  number(30) not null,
  to_client_id       number(30) not null,
  status_id       varchar2(10 char) not null,
  payment_date  date not null,
  summa         number(20,2)
) 
partition by system (
  partition p1,
  partition p2
);

insert into payment_system partition (p1) (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (5, 2, 3, 'PAYED', sysdate, 456.767);
insert into payment_system partition (p1) (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (6, 2, 3, 'CANCELED', sysdate, 456.767);
insert into payment_system partition (p2) (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (7, 2, 3, 'NOT_PAYED', sysdate, 456.767);
insert into payment_system partition (p2) (payment_id, from_client_id, to_client_id, status_id, payment_date, summa) values (8, 2, 3, 'ERROR', sysdate, 456.767);
commit;


select * from user_tab_partitions u where u.table_name = 'PAYMENT_SYSTEM';

select * from payment_system partition (p1);
select * from payment_system partition (p2);

---------------------------------------------------------------------------------------------------------------------------

create table payment_external
(
  payment_id    number(30) not null,
  from_client_id  number(30) not null,
  to_client_id   number(30) not null,
  status_id     varchar2(10 char) not null,
  payment_date  date not null
)
organization external
(type oracle_loader
  default directory data4load_dir
  access parameters
  ( records delimited by newline    
    nobadfile
    logfile data4load_dir:'payment_error.log'
    fields csv with embedded
    terminated by ";" optionally enclosed by '"'
    missing field values are null
    reject rows with all null fields
    date_format date mask "YYYY-MM-DD HH24:MI:SS"
  )
)
reject limit unlimited
partition by range (payment_date)
(
  partition p2019 values less than (to_date('01.01.2020', 'dd.mm.yyyy')) location ('year2019.csv'),
  partition p2020 values less than (to_date('01.01.2021', 'dd.mm.yyyy')) location ('year2020.csv'),
  partition p2021 values less than (to_date('01.04.2022', 'dd.mm.yyyy')) location ('year2021.csv')
);


select p.*, ora_partition_validation(rowid) from payment_external p;
