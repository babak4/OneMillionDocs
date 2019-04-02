-- Table: public.onemilliondocs
CREATE TABLE onemilliondocs
(
    "Document" jsonb
)
TABLESPACE pg_default;

--ALTER TABLE onemilliondocs
--    OWNER to postgres;

-- Index: onemilliondocs_expr_idx

CREATE UNIQUE INDEX onemilliondocs_expr_idx
    ON onemilliondocs (("Document" ->> '_id'))
    TABLESPACE pg_default;