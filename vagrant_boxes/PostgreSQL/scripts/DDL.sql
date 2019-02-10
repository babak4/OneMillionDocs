-- Table: public.onemilliondocs

-- DROP TABLE public.onemilliondocs;

CREATE TABLE public.onemilliondocs
(
    "Document" jsonb
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.onemilliondocs
    OWNER to postgres;

-- Index: onemilliondocs_expr_idx

-- DROP INDEX public.onemilliondocs_expr_idx;

CREATE INDEX onemilliondocs_expr_idx
    ON public.onemilliondocs USING btree
    (("Document" ->> '_id'::text) COLLATE pg_catalog."default")
    TABLESPACE pg_default;