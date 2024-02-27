drop table log_message


-- Таблица для логирования
create table log_message
(
  id             number(30) not null,
  dtime          date, --timestamp(6) default systimestamp not null,
  message_type   char(1 char) not null,
  message        varchar2(2000 char) not null,
  message_source varchar2(2000 char) not null,
  sid            number(10) not null,
  serial         number(10) not null,
  pid            number(10) not null,
  osuser         varchar2(200 char) not null,
  oracle_user    varchar2(200 char) not null,
  call_stack     varchar2(4000 char) not null
)
partition by range (dtime) interval (numtodsinterval(1, 'DAY'))
subpartition by list (message_type) 
subpartition template  (
  subpartition pINFO values ('I'),
  subpartition pERROR values ('E'),
  subpartition pWARNING values ('W')
  )
(
  partition part_min values less than (to_date('01.01.2024 00:00:00', 'dd.mm.yyyy HH24:MI:SS'))
);

alter table log_message add constraint log_message_message_type_chk check (message_type in ('I', 'E', 'W'));

create index log_message_message_source_idx on log_message(dtime desc, message_type, message_source) local;
create index log_message_message_idx on log_message(dtime desc, message_type, substr(message, 1, 100)) local;

comment on table log_message is 'Лог событий в БД';
comment on column log_message.id is 'UID';
comment on column log_message.dtime is 'Дата события';
comment on column log_message.message_type is 'Тип сообщения: I - инфо, E - ошибка, W - предупреждение';
comment on column log_message.message is 'Текст сообщения';
comment on column log_message.message_source is 'Место из которого логируется';
comment on column log_message.sid is 'ID сессии';
comment on column log_message.pid is 'ID процесса Oracle';
comment on column log_message.osuser is 'Пользователь ОС';
comment on column log_message.oracle_user is 'Пользователь БД';
comment on column log_message.call_stack is 'Стек вызова';

-- Sequence
create sequence log_message_pk_seq start with 1 increment by 1 cache 1000 cycle maxvalue 99999999999999999999999999999;

---------------------------------------------------------------------------------------------------------------------------------------

declare
  ind number;
begin
  for ind in 0 .. 1200
  loop 
    log_message_pack.info(p_message        => 'log_message_' || ind / 15,
                          p_message_source => 'log_project_' || ind / 5,
                          p_message_dtime  => sysdate - ind / 24);
    log_message_pack.warning(p_message        => 'log_message_' || ind / 12,
                             p_message_source => 'log_project_' || ind / 5,
                             p_message_dtime  => sysdate - ind / 24);
    log_message_pack.error(p_message        => 'log_message_' || ind / 11,
                           p_message_source => 'log_project_' || ind / 5,
                           p_message_dtime  => sysdate - ind / 24);
  end loop;
end;

select * from user_tab_partitions u where u.table_name = 'LOG_MESSAGE';

select * from user_tab_subpartitions u where u.table_name = 'LOG_MESSAGE';
