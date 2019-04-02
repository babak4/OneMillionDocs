create user json_docs identified by json_docs default tablespace users temporary tablespace temp;
alter user json_docs quota unlimited on users;
GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO json_docs;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO json_docs;
GRANT execute ON sys.dbms_stats TO json_docs;

CONNECT json_docs/json_docs

create table onemilliondocs
(
    document    varchar2(300),
    constraint chk_json check (document is json)
);

create index onemilliondocs_id_idx on onemilliondocs a (a.document."_id");

exit
