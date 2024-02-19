create table payment
(
  payment_id        number(30) not null,
  from_client_id  number(30) not null,
  to_client_id       number(30) not null,
  status_id         varchar2(10 char) not null,
  payment_date  date not null
)
partition by range(payment_date)
interval (interval '1' day)
(
  partition pmin values less than (date '2021-06-01')
);

-- Global index
create unique index ind_payment_id_global on payment(payment_id) global;

alter table payment add constraint payment_pk primary key (payment_id) using index ind_payment_id_global;
alter table payment drop constraint payment_pk;


-- Local indexes
drop index ind_payment_payment_date_local;

create index ind_payment_client_id_local on payment(from_client_id) local;
create index ind_payment_payment_date_local on payment(trunc(payment_date, 'mi'), payment_date) local;

insert into payment
select level, level+10, level+20, 'PAYED', date'2021-05-30'+level  
  from dual connect by level <= 1000;
commit;



call dbms_stats.gather_table_stats(ownname => user, tabname => 'payment');

------------------------------------------Запрос 1.--------------------------------------------
select * from payment t 
  where t.payment_id = 180;

-- Глобальный уникальный индекс, одна запись по ROWID
SELECT STATEMENT, GOAL = ALL_ROWS     2 1 26    
 TABLE ACCESS BY GLOBAL INDEX ROWID BIKMETOV  PAYMENT 2 1 26  ROW LOCATION  ROW LOCATION
  INDEX UNIQUE SCAN BIKMETOV  IND_PAYMENT_ID_GLOBAL 1 1     


------------------------------------------Запрос 2.--------------------------------------------
select * from payment t 
  where t.payment_date = date'2021-05-30'+500
    and t.from_client_id = 510;

-- Используется partition pruning, далее используется локальный индекс (уникальный/неуникальный) в конкретной партиции
SELECT STATEMENT, GOAL = ALL_ROWS     2 1 33    
 PARTITION RANGE SINGLE     2 1 33  500 500
  TABLE ACCESS BY LOCAL INDEX ROWID BATCHED BIKMETOV  PAYMENT 2 1 33  500 500
   INDEX RANGE SCAN BIKMETOV  IND_PAYMENT_PAYMENT_DATE_LOCAL  1 1   500 500



------------------------------------------Запрос 3.--------------------------------------------
select * from payment t 
  where trunc(payment_date, 'mi') = trunc(date'2021-05-30'+500, 'mi');

-- Поиск по всем партициям
SELECT STATEMENT, GOAL = ALL_ROWS     2 1 34    
 PARTITION RANGE ALL      2 1 34  1 1048575
  TABLE ACCESS BY LOCAL INDEX ROWID BATCHED BIKMETOV  PAYMENT 2 1 34  1 1048575
   INDEX RANGE SCAN BIKMETOV  IND_PAYMENT_PAYMENT_DATE_LOCAL  1 1   1 1048575

-- Решение: добавить условие для partition pruning
select * from payment t 
  where trunc(payment_date, 'mi') = trunc(date'2021-05-30'+500, 'mi')
    and t.payment_date = date'2021-05-30'+500;

SELECT STATEMENT, GOAL = ALL_ROWS     2 1 33    
 PARTITION RANGE SINGLE     2 1 33  500 500
  TABLE ACCESS BY LOCAL INDEX ROWID BATCHED BIKMETOV  PAYMENT 2 1 33  500 500
   INDEX RANGE SCAN BIKMETOV  IND_PAYMENT_PAYMENT_DATE_LOCAL  1 1   500 500

