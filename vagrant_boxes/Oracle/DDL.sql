create table onemilliondocs
(
    document    varchar2(300),
    constraint chk_json check (document is json)
);

create index onemilliondocs_id_idx on onemilliondocs a (a.document."_id");
