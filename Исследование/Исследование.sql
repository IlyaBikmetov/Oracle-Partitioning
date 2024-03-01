Таблица логирования LOG(
  ...
  ACTIONTIME TIMESTAMP(6) not null,
  ...)

Секционировние по диапазону по времени вставки
partition by range (ACTIONTIME)

Локальный индекс по времени и клиенту
create index LOG_CLIENT_ID_IDX on LOG (ACTIONTIME, CLIENT_ID) local;
Глобальный индекс по договору
create index LOG_AGR_ID_IDX on LOG (AGR_ID);

-----------------------------------------------------------------------------------------------------------------

Таблица для исполнения методов WF_EXEC(
  ...
  CREATED TIMESTAMP(6) not null,
  ...)

Секционировние по диапазону по времени вставки
partition by range (CREATED)

Локальный индекс по времени и ID метода
create index WF_EXEC_IDX on WF_EXEC (EXEC_ID, CREATED) local;

-----------------------------------------------------------------------------------------------------------------

Таблица хранение результатов расчета баллов лояльности AGENT_BPOINTS(
  ...
  CREATED TIMESTAMP(6) not null,
  ...)

Секционировние по диапазону по времени вставки
partition by range (CREATED)

Локальный индекс по времени и клиенту
create index AGENT_BPOINTS_CLIENT_ID_IDX on AGENT_BPOINTS (CREATED, CLIENT_ID) local;

-----------------------------------------------------------------------------------------------------------------

Таблица-карта для хранения BLOB FILE_STORAGE(
  ...
  PARTID NUMBER not null,
  ...)

Секционировние по значению по ID хранилища 
partition by list (PARTID)

Локальный индекс по значению и названию файла
create index FILE_STORAGE_PARTID_IDX on FILE_STORAGE (PARTID, FILENAME) local;
Глобальный индекс по хеш файла
create index FILE_STORAGE_FILEHASH_IDX on FILE_STORAGE (FILEHASH);

----------------------------------------------------------------------------------------------------------------------------------

Таблица хранения логов сессий USER_SESSIONS(
  ...
  SESSIONSTART TIMESTAMP(9) not null,
  ...)

Секционировние по диапазону по времени начала сессии
partition by range (SESSIONSTART)

Локальный индекс по ID сессии
create index USER_SESSIONS_ID_IDX on USER_SESSIONS (HTTPSESSIONID) local;
Локальный индекс по времени и ID пользователя
create index USER_SESSIONS_HTTPSESSIONID_IDX on USER_SESSIONS (USER_ID, SESSIONSTART DESC) local;


Вывод: самый распространный способ секционирования по range
