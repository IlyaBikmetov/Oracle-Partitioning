drop table payment_list;

create table payment_list
(
  payment_id    number(30) not null,
  from_client_id  number(30) not null,
  to_client_id   number(30) not null,
  status_id     varchar2(10 char) not null,
  payment_date  date not null
)
partition by list(status_id) automatic
(
partition p_valid values ('VALID')
);

alter table payment add constraint payment_list check (status_id in ('PAYED', 'CANCELED', 'NOT_PAYED', 'ERROR'));

-- 10 записей
insert into payment_list
select level, level+10, level+20, 'VALID', date'2021-05-30'+level  
  from dual connect by level <= 10;

-- 10 записей
insert into payment_list
select level, level+10, level+20, 'PAYED', date'2021-05-30'+level  
  from dual connect by level <= 10;

-- 10 записей
insert into payment_list
select level, level+10, level+20, 'CANCELED', date'2021-05-30'+level  
  from dual connect by level <= 10;

-- 10 записей
insert into payment_list
select level, level+10, level+20, 'NOT_PAYED', date'2021-05-30'+level  
  from dual connect by level <= 10;

-- 10 записей
insert into payment_list
select level, level+10, level+20, 'ERROR', date'2021-05-30'+level  
  from dual connect by level <= 10;
commit;

------------------------------------------------rename--------------------------------------------------------

declare
  v_new_name user_tab_partitions.partition_name%type;
  v_sql      varchar2(1000 char);
begin
  for p in (select t.table_name
                 , t.partition_name as old_name
                 , t.high_value
              from user_tab_partitions t
             where t.table_name = 'PAYMENT_LIST'
               and t.partition_name like 'SYS%') loop

    v_new_name := 'P_' || replace(substr(p.high_value, 1, 1000), '''', '');
    v_sql := 'alter table '|| p.table_name ||' rename partition '|| p.old_name ||' to '|| v_new_name;
    execute immediate v_sql;
  end loop;
end;
/

select * from user_tab_partitions t where t.table_name = 'PAYMENT_LIST'

------------------------------------------------drop--------------------------------------------------------

alter table PAYMENT_LIST drop partition P_PAYED;

select * from user_tab_partitions t where t.table_name = 'PAYMENT_LIST'

----------------------------------------------truncate------------------------------------------------------

select * from PAYMENT_LIST partition (P_CANCELED);

alter table PAYMENT_LIST truncate partition P_CANCELED;

----------------------------------------------change-p.-----------------------------------------------------

create index payment_list_to_client_id_loc_idx on payment_list(to_client_id) local;

create table payment_list_stage
(
  payment_id    number(30) not null,
  from_client_id  number(30) not null,
  to_client_id   number(30) not null,
  status_id     varchar2(10 char) not null,
  payment_date  date not null
);


insert into payment_list_stage
select 1000*level, 1000*level+10, 1000*level+20, 'VALID', date'2023-05-30'+level  
  from dual connect by level <= 10;
commit;


alter table payment_list exchange partition P_VALID with table payment_list_stage
excluding indexes
with validation;


select * from payment_list_stage;
select * from payment_list;

select t.status, t.* from user_ind_partitions t where t.index_name = 'PAYMENT_LIST_TO_CLIENT_ID_LOC_IDX'; 

alter index PAYMENT_LIST_TO_CLIENT_ID_LOC_IDX rebuild partition P_VALID;
