CREATE SEQUENCE auths_id_seq;
CREATE TABLE
IF NOT EXISTS auths
(
    "id" integer NOT NULL DEFAULT nextval('auths_id_seq'::regclass),
    email character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "password" character varying(1024) COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT auths_pkey PRIMARY KEY ("id"),
    CONSTRAINT auths_email_key UNIQUE (email)
);

CREATE SEQUENCE users_id_seq;
CREATE TABLE
IF NOT EXISTS users
(
    "id" integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    email character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "password" character varying(1024) COLLATE pg_catalog."default",
    first_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    phone character varying(20) COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY ("id"),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_phone_key UNIQUE (phone)
);

CREATE SEQUENCE property_types_id_seq;
CREATE TABLE
IF NOT EXISTS property_types
(
    "id" integer NOT NULL DEFAULT nextval('property_types_id_seq'::regclass),
    name character varying(16) COLLATE pg_catalog."default" NOT NULL,
    "desc" character varying(128) COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT property_types_pkey PRIMARY KEY ("id"),
    CONSTRAINT property_types_property_name_key UNIQUE (name)
);

CREATE SEQUENCE status_periods_id_seq;
CREATE TABLE
IF NOT EXISTS status_periods
(
    "id" integer NOT NULL DEFAULT nextval('status_periods_id_seq'::regclass),
    name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "desc" text COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT status_period_pkey PRIMARY KEY ("id"),
    CONSTRAINT status_periods_period_name_key UNIQUE (name)
);

CREATE SEQUENCE status_types_id_seq;
CREATE TABLE
IF NOT EXISTS status_types
(
    "id" integer NOT NULL DEFAULT nextval('status_types_id_seq'::regclass),
    name character varying(20) COLLATE pg_catalog."default",
    "desc" text COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT status_type_pkey PRIMARY KEY ("id"),
    CONSTRAINT status_types_status_name_key UNIQUE (name)
);

CREATE SEQUENCE properties_id_seq;
CREATE TABLE
IF NOT EXISTS properties
(
    "id" integer NOT NULL DEFAULT nextval('properties_id_seq'::regclass),
    address character varying(56) COLLATE pg_catalog."default" NOT NULL,
    lga character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "state" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    price numeric NOT NULL,
    "desc" text COLLATE pg_catalog."default",
    owner_id integer NOT NULL,
    status_id integer NOT NULL,
    period_id integer NOT NULL,
    type_id integer NOT NULL,
    email character varying(100) COLLATE pg_catalog."default",
    phone character varying(20) COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT properties_pkey PRIMARY KEY ("id"),
    CONSTRAINT properties_users_id_fkey FOREIGN KEY (owner_id)
        REFERENCES public.users ("id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT type_id FOREIGN KEY (type_id)
        REFERENCES public.property_types ("id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT period_id_fkey FOREIGN KEY (period_id)
        REFERENCES public.status_periods ("id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT status_id_fkey FOREIGN KEY (status_id)
        REFERENCES public.status_types ("id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
);

CREATE SEQUENCE images_id_seq;
CREATE TABLE
IF NOT EXISTS images
(
    "id" integer NOT NULL DEFAULT nextval('images_id_seq'::regclass),
    image_url text COLLATE pg_catalog."default" NOT NULL,
    property_id integer NOT NULL,
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT images_pkey PRIMARY KEY ("id"),
    CONSTRAINT images_property_id_fkey FOREIGN KEY (property_id)
        REFERENCES public.properties ("id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE SEQUENCE features_id_seq;
CREATE TABLE
IF NOT EXISTS features
(
    "id" integer NOT NULL DEFAULT nextval('features_id_seq'::regclass),
    feature_name character varying(32) COLLATE pg_catalog."default" NOT NULL,
    "desc" text COLLATE pg_catalog."default",
    date_time_created timestamptz NOT NULL,
    date_time_modified timestamptz NOT NULL,
    CONSTRAINT features_pkey PRIMARY KEY ("id"),
    CONSTRAINT features_feature_name_key UNIQUE (feature_name)
);

CREATE SEQUENCE properties_and_features_id_seq;
CREATE TABLE
IF NOT EXISTS properties_and_features
(
    "id" integer NOT NULL DEFAULT nextval('properties_and_features_id_seq'::regclass),
    property_id integer NOT NULL,
    feature_id integer NOT NULL,
    date_time_created timestamptz NOT NULL,
    CONSTRAINT properties_features_pkey PRIMARY KEY ("id"),
    CONSTRAINT features_feature_id_fkey FOREIGN KEY (feature_id)
        REFERENCES public.features ("id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT properties_features_property_id_fkey FOREIGN KEY (property_id)
        REFERENCES public.properties ("id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE FUNCTION public.timestamp_on_create()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
	NEW.date_time_created := CURRENT_TIMESTAMP;
	RETURN NEW;
END;$BODY$;

COMMENT ON FUNCTION public.timestamp_on_create()
    IS 'Time stamp to track the date and time of creation of a table row data';

CREATE FUNCTION public.timestamp_on_modify()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN
	NEW.date_time_modified := CURRENT_TIMESTAMP;
	RETURN NEW;
END;$BODY$;

COMMENT ON FUNCTION public.timestamp_on_modify()
    IS 'Time stamp to track the date and time of modification of a table row data';

CREATE TRIGGER auths_timestamp_on_create
    BEFORE INSERT
    ON public.auths
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER auths_timestamp_on_create ON public.auths
    IS 'Date and time of creation of a user authentication detail';


CREATE TRIGGER auths_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.auths
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER auths_timestamp_on_modify ON public.auths
    IS 'Date and time of modification of a user authentication detail';

CREATE TRIGGER users_timestamp_on_create
    BEFORE INSERT
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER users_timestamp_on_create ON public.users
    IS 'Date and time of creation of a user account';


CREATE TRIGGER users_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.users
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER users_timestamp_on_modify ON public.users
    IS 'Date and time of modification of a user account';

CREATE TRIGGER properties_timestamp_on_create
    BEFORE INSERT
    ON public.properties
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER properties_timestamp_on_create ON public.properties
    IS 'Date and time of creation of a property';


CREATE TRIGGER properties_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.properties
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER properties_timestamp_on_modify ON public.properties
    IS 'Date and time of modification of a property';

CREATE TRIGGER images_timestamp_on_create
    BEFORE INSERT
    ON public.images
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER images_timestamp_on_create ON public.images
    IS 'Date and time of creation of an image';


CREATE TRIGGER images_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.images
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER images_timestamp_on_modify ON public.images
    IS 'Date and time of modification of an image';

CREATE TRIGGER property_types_timestamp_on_create
    BEFORE INSERT
    ON public.property_types
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER property_types_timestamp_on_create ON public.property_types
    IS 'Date and time of creation of a type of property';


CREATE TRIGGER property_types_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.property_types
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER property_types_timestamp_on_modify ON public.property_types
    IS 'Date and time of modification of a type of property';

CREATE TRIGGER status_periods_timestamp_on_create
    BEFORE INSERT
    ON public.status_periods
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER status_periods_timestamp_on_create ON public.status_periods
    IS 'Date and time of creation of a type of period';


CREATE TRIGGER status_periods_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.status_periods
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER status_periods_timestamp_on_modify ON public.status_periods
    IS 'Date and time of modification of a type of period';

CREATE TRIGGER status_types_timestamp_on_create
    BEFORE INSERT
    ON public.status_types
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER status_types_timestamp_on_create ON public.status_types
    IS 'Date and time of creation of a type of status';


CREATE TRIGGER status_types_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.status_types
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER status_types_timestamp_on_modify ON public.status_types
    IS 'Date and time of modification of a type of status';

CREATE TRIGGER features_timestamp_on_create
    BEFORE INSERT
    ON public.features
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER features_timestamp_on_create ON public.features
    IS 'Date and time of creation of a feature';


CREATE TRIGGER features_timestamp_on_modify
    BEFORE INSERT OR UPDATE 
    ON public.features
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_modify();

COMMENT ON TRIGGER features_timestamp_on_modify ON public.features
    IS 'Date and time of modification of a feature';

CREATE TRIGGER properties_and_features_timestamp_on_create
    BEFORE INSERT
    ON public.properties_and_features
    FOR EACH ROW
    EXECUTE PROCEDURE public.timestamp_on_create();

COMMENT ON TRIGGER properties_and_features_timestamp_on_create ON public.properties_and_features
    IS 'Date and time of creation of a feature for a property';