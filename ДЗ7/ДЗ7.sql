drop table payment_plan;

create table payment_plan
(
  payment_id    number(30) not null,
  from_client_id  number(30) not null,
  to_client_id   number(30) not null,
  status_id     varchar2(10 char) not null,
  payment_date  date not null
)
partition by range(payment_date) interval (interval '1' day)
(
partition pmin values less than (date '2021-06-01')
);

-- 30 записей
insert into payment_plan
select level, level+10, level+20, 'PAYED', date'2021-05-30'+level  
  from dual connect by level <= 30;
commit;

call dbms_stats.gather_table_stats(ownname => user, tabname => 'payment_plan');



----------------------------------------Запрос 1.---------------------------------------------
select * from payment_plan t
 where t.payment_id = 1;

-- Решение
create index payment_plan_id_glob_idx on payment_plan(payment_id);

----------------------------------------Запрос 2.---------------------------------------------
select * from payment_plan t
 where t.payment_date = date '2021-06-01'+3;

-- Решение
-- Всё Ок!

----------------------------------------Запрос 3.---------------------------------------------
select * from payment_plan t
 where t.payment_date >= date '2021-06-01';

-- Решение
Добавить 'and t.payment_date <= sysdate', чтоб ограничить итератор сверху


----------------------------------------Запрос 4.---------------------------------------------
select * from payment_plan t
 where trunc(t.payment_date) = date '2021-06-01';

-- Решение
Убрать функцию trunc с ключа секционирования
