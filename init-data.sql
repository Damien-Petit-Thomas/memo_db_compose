--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Debian 16.2-1.pgdg120+2)
-- Dumped by pg_dump version 16.2 (Debian 16.2-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_style_by_content_type_id(integer); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.get_style_by_content_type_id(content_type_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT
    jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'name', s.name,
        'css', s.css,
        'created_at', s.created_at,
        'updated_at', s.updated_at
      )
    )
  INTO result
  FROM style s
  JOIN content_type ct ON s.id = ANY(ct.style_id)
  WHERE ct.id = content_type_id;

  RETURN result;
END;
$$;


ALTER FUNCTION public.get_style_by_content_type_id(content_type_id integer) OWNER TO memo;

--
-- Name: getalllinks(); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.getalllinks() RETURNS TABLE(id integer, name character varying, url character varying, "group" character varying, category_slug character varying, category_name character varying, category_id integer, memo_slug character varying, memo_title character varying, memo_id integer, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY (
    SELECT
      l.id,
      l.name,
      l.url,
      l."group",
      c.slug AS category_slug,
      c.name AS category_name,
      l.category_id,
      m.slug AS memo_slug,
      m.title AS memo_title,
      l.memo_id,
      l.created_at,
      l.updated_at
    FROM link l
    JOIN category c ON l.category_id = c.id
    JOIN memo m ON l.memo_id = m.id
    ORDER BY l.name
  );
END;
$$;


ALTER FUNCTION public.getalllinks() OWNER TO memo;

--
-- Name: getalllinksforuser(integer); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.getalllinksforuser(userid integer) RETURNS TABLE(id integer, name character varying, url character varying, "group" character varying, category_slug character varying, category_name character varying, category_id integer, memo_slug character varying, memo_title character varying, memo_id integer, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY (
    SELECT
      l.id,
      l.name,
      l.url,
      l."group",
      c.slug AS category_slug,
      c.name AS category_name,
      l.category_id,
      m.slug AS memo_slug,
      m.title AS memo_title,
      l.memo_id,
      l.created_at,
      l.updated_at
    FROM link l
    JOIN category c ON l.category_id = c.id
    JOIN memo m ON l.memo_id = m.id
    WHERE l.user_id = userId
    ORDER BY l.name
  );
END;
$$;


ALTER FUNCTION public.getalllinksforuser(userid integer) OWNER TO memo;

--
-- Name: getallmemos(); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.getallmemos() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT
    jsonb_agg(
      jsonb_build_object(
        'id', m.id,
        'title', m.title,
        'slug', m.slug,
        'category', jsonb_build_object(
          'id', m.category_id,
          'name', c.name,
          'slug', c.slug,
          'color', c.color,
          'created_at', c.created_at,
          'updated_at', c.updated_at
        ),
        'created_at', m.created_at,
        'updated_at', m.updated_at,
        'tags', (
          SELECT
            jsonb_agg(
              jsonb_build_object(
                'id', t.id,
                'name', t.name,
                'slug', t.slug,
                'color', t.color,
                'created_at', t.created_at,
                'updated_at', t.updated_at
              )
            )
          FROM memo_tag mt
          JOIN tag t ON mt.tag_id = t.id
          WHERE mt.memo_id = m.id
        ),
        'contents', (
          SELECT
            jsonb_agg(
              jsonb_build_object(
                'id', mc.id,
                'type', jsonb_build_object(
                  'id', ct.id,
                  'name', ct.name,
                  'created_at', ct.created_at,
                  'updated_at', ct.updated_at
                ),
                'style', jsonb_build_object(
                  'id', s.id,
                  'name', s.name,
                  'css', s.css,
                  'created_at', s.created_at,
                  'updated_at', s.updated_at
                ),
                'position', mc.position,
                'content', mc.content,
                'created_at', mc.created_at,
                'updated_at', mc.updated_at
              )
            )
          FROM memo_content mc
          JOIN content_type ct ON mc.type_id = ct.id
          JOIN style s ON mc.style_id = s.id
          WHERE mc.memo_id = m.id
        )
      )
    )
  INTO result
  FROM memo m
  LEFT JOIN category c ON m.category_id = c.id;



  RETURN result;
END;
$$;


ALTER FUNCTION public.getallmemos() OWNER TO memo;

--
-- Name: getallmemosforuser(integer); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE or replace FUNCTION public.getallmemosforuser(userid integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT
    jsonb_agg(
      jsonb_build_object(
        'id', m.id,
        'title', m.title,
        'slug', m.slug,
        'layout', m.layout,
        'slideId', m.slide_id,
        'page', m.page,
        'backgroundId', m.background_id,
        'type', m.type,
        'category', jsonb_build_object(
          'id', m.category_id,
          'name', c.name,
          'slug', c.slug,
          'color', c.color,
          'created_at', c.created_at,
          'updated_at', c.updated_at
        ),
        'created_at', m.created_at,
        'updated_at', m.updated_at,
        'tags', (
          SELECT
            jsonb_agg(
              jsonb_build_object(
                'id', t.id,
                'name', t.name,
                'slug', t.slug,
                'color', t.color,
                'created_at', t.created_at,
                'updated_at', t.updated_at
              )
            )
          FROM memo_tag mt
          JOIN tag t ON mt.tag_id = t.id
          WHERE mt.memo_id = m.id
        ),
        'contents', (
          SELECT
            jsonb_agg(
              jsonb_build_object(
                'id', mc.id,
                'type', jsonb_build_object(
                  'id', ct.id,
                  'name', ct.name,
                  'created_at', ct.created_at,
                  'updated_at', ct.updated_at
                ),
                'style', jsonb_build_object(
                  'id', s.id,
                  'name', s.name,
                  'css', s.css,
                  'created_at', s.created_at,
                  'updated_at', s.updated_at
                ),
                'customCss', jsonb_build_object(
                    'repeat', mc.repeat,
                    'duration', mc.duration,
                    'delay', mc.delay,
                    'easefonction', mc.easefonction,
                    'animation', mc.animation,
                    'opacity', mc.opacity,
                    'color', mc.color,
                    'fontfamily', mc.fontfamily,
                    'fontsize', mc.fontsize,
                    'backgroundcolor', mc.background
                ),
                'css', mc.css,
                'position', mc.position,
                'content', mc.content,
                'created_at', mc.created_at,
                'updated_at', mc.updated_at
              )
            )
          FROM memo_content mc
          JOIN content_type ct ON mc.type_id = ct.id
          JOIN style s ON mc.style_id = s.id
          WHERE mc.memo_id = m.id
        )
      )
    )
  INTO result
  FROM memo m
  LEFT JOIN category c ON m.category_id = c.id
  WHERE m.user_id = userId;

  RETURN result;
END;
$$;


ALTER FUNCTION public.getallmemosforuser(userid integer) OWNER TO memo;


CREATE OR REPLACE FUNCTION public.getallslidesforuser(userid integer) RETURNS jsonb
    LANGUAGE plpgsql
AS $$
DECLARE
  result jsonb;
BEGIN
  -- Sélectionner tous les slides de l'utilisateur
  SELECT
    jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'title', s.title,
        'slug', s.slug,
        'category_id', s.category_id,
        'category', (
          CASE
            WHEN s.category_id IS NOT NULL THEN
              jsonb_build_object(
                'id', s.category_id,
                'name', c.name,
                'slug', c.slug,
                'color', c.color,
                'created_at', c.created_at,
                'updated_at', c.updated_at
              )
            ELSE
              null
          END
        ),
        'memos', (
          SELECT
            jsonb_agg(
              jsonb_build_object(
                'id', m.id,
                'title', m.title,
                'slug', m.slug,
                'layout', m.layout,
                'slideId', m.slide_id,
                'page', m.page,
                'backgroundId', m.background_id,
                'type', m.type,
                'category', (
                  SELECT
                    jsonb_build_object(
                      'id', m.category_id,
                      'name', c.name,
                      'slug', c.slug,
                      'color', c.color,
                      'created_at', c.created_at,
                      'updated_at', c.updated_at
                    )
                ),
                'created_at', m.created_at,
                'updated_at', m.updated_at,
                'tags', (
                  SELECT
                    jsonb_agg(
                      jsonb_build_object(
                        'id', t.id,
                        'name', t.name,
                        'slug', t.slug,
                        'color', t.color,
                        'created_at', t.created_at,
                        'updated_at', t.updated_at
                      )
                    )
                  FROM memo_tag mt
                  JOIN tag t ON mt.tag_id = t.id
                  WHERE mt.memo_id = m.id
                ),
                'contents', (
                  SELECT
                    jsonb_agg(
                      jsonb_build_object(
                        'id', mc.id,
                        'type', jsonb_build_object(
                          'id', ct.id,
                          'name', ct.name,
                          'created_at', ct.created_at,
                          'updated_at', ct.updated_at
                        ),
                        'style', jsonb_build_object(
                          'id', s.id,
                          'name', s.name,
                          'css', s.css,
                          'created_at', s.created_at,
                          'updated_at', s.updated_at
                        ),
                        'position', mc.position,
                        'content', mc.content,
                        'created_at', mc.created_at,
                        'updated_at', mc.updated_at
                      )
                    )
                  FROM memo_content mc
                  JOIN content_type ct ON mc.type_id = ct.id
                  JOIN style s ON mc.style_id = s.id
                  WHERE mc.memo_id = m.id
                )
              )
            )
          FROM memo m
          WHERE m.slide_id = s.id
        )
      )
    )
  INTO result
  FROM slide s
  LEFT JOIN category c ON s.category_id = c.id
  WHERE s.user_id = userid;

  RETURN result;
END;
$$;



ALTER FUNCTION public.getallslidesforuser(userid integer) OWNER TO memo;
--
-- Name: getmemo(integer); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.getmemo(memo_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result jsonb;
BEGIN
  

  SELECT
    jsonb_build_object(
      'id', m.id,
      'title', m.title,
      'slug', m.slug,
      'category', jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'slug', c.slug,
        'color', c.color,
        'created_at', c.created_at,
        'updated_at', c.updated_at
      ),
      'created_at', m.created_at,
      'updated_at', m.updated_at,
      'tags', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', t.id,
            'name', t.name,
            'slug', t.slug,
            'color', t.color,
            'created_at', t.created_at,
            'updated_at', t.updated_at
          )
        )
        FROM memo_tag mt
        JOIN tag t ON mt.tag_id = t.id
        WHERE mt.memo_id = m.id
      ),
      'contents', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', mc.id,
            'type', jsonb_build_object(
              'id', ct.id,
              'name', ct.name,
              'css', ct.css,
              'created_at', ct.created_at,
              'updated_at', ct.updated_at
            ),
              'position', mc.position,
            'content', mc.content,
            'created_at', mc.created_at,
            'updated_at', mc.updated_at
          )ORDER BY mc.position
        )
        FROM memo_content mc
        JOIN content_type ct ON mc.type_id = ct.id
        WHERE mc.memo_id = m.id
     
      )
    )
  INTO result
  FROM
    memo AS m
    LEFT JOIN category AS c ON m.category_id = c.id
    
  WHERE
    m.id = memo_id;

  RETURN result;
END;
$$;


ALTER FUNCTION public.getmemo(memo_id integer) OWNER TO memo;

--
-- Name: getmemobyslug(text); Type: FUNCTION; Schema: public; Owner: memo
--

CREATE FUNCTION public.getmemobyslug(p_slug text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT
    jsonb_agg(
      jsonb_build_object(
        'id', m.id,
        'title', m.title,
        'slug', m.slug,
        'category', jsonb_build_object(
          'id', c.id,
          'name', c.name,
          'slug', c.slug,
          'color', c.color,
          'created_at', c.created_at,
          'updated_at', c.updated_at
        ),
        'created_at', m.created_at,
        'updated_at', m.updated_at,
        'tags', (
          SELECT jsonb_agg(
            jsonb_build_object(
              'id', t.id,
              'name', t.name,
              'slug', t.slug,
              'color', t.color,
              'created_at', t.created_at,
              'updated_at', t.updated_at
            )
          )
          FROM memo_tag mt
          JOIN tag t ON mt.tag_id = t.id
          WHERE mt.memo_id = m.id
        ),
        'contents', (
          SELECT jsonb_agg(
            jsonb_build_object(
              'id', mc.id,
              'type', jsonb_build_object(
                'id', ct.id,
                'name', ct.name,
                'css', ct.css,
                'created_at', ct.created_at,
                'updated_at', ct.updated_at
              ),
              'content', mc.content,
              'created_at', mc.created_at,
              'updated_at', mc.updated_at
            )
          )
          FROM memo_content mc
          JOIN content_type ct ON mc.type_id = ct.id
          WHERE mc.memo_id = m.id
        )
      )
    )
  INTO result
  FROM
    memo AS m
    LEFT JOIN category AS c ON m.category_id = c.id
  WHERE m.slug = p_slug;

  RETURN result;
END;
$$;


ALTER FUNCTION public.getmemobyslug(p_slug text) OWNER TO memo;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    color character varying(7) DEFAULT '#000000'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    user_id integer
);


ALTER TABLE public.category OWNER TO memo;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: content_type; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.content_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    type character varying(50) DEFAULT NULL::character varying,
    available_style integer[]
);


ALTER TABLE public.content_type OWNER TO memo;

--
-- Name: content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.content_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.image (
    id integer NOT NULL,
    original character varying(500) NOT NULL,
    thumbnail character varying(500) NOT NULL,
    user_id integer
);


ALTER TABLE public.image OWNER TO memo;

--
-- Name: image_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.image ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lexicon; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.lexicon (
    id integer NOT NULL,
    word character varying(100) NOT NULL,
    definition text NOT NULL,
    category_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    user_id integer
);


ALTER TABLE public.lexicon OWNER TO memo;

--
-- Name: lexicon_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.lexicon ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.lexicon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: link; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.link (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    url character varying(100) NOT NULL,
    "group" character varying(100) DEFAULT 'divers'::character varying NOT NULL,
    category_id integer NOT NULL,
    memo_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    user_id integer
);


ALTER TABLE public.link OWNER TO memo;

--
-- Name: link_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.link ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: memo; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.memo (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    category_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    slug character varying,
    user_id integer,
    layout jsonb,
    background_id integer,
    type character varying(50) DEFAULT 'memo'::character varying NOT NULL,
    page smallint DEFAULT 1 NOT NULL,
    slide_id integer
);


ALTER TABLE public.memo OWNER TO memo;

--
-- Name: memo_content; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.memo_content (
    id integer NOT NULL,
    type_id integer NOT NULL,
    memo_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    "position" integer,
    style_id integer DEFAULT 3,
    css text,
    fontfamily character varying(255),
    fontsize integer,
    color character varying(255),
    background character varying(255),
    delay integer,
    duration integer,
    animation_name character varying(255),
    opacity smallint,
    animation character varying(50),
    repeat character varying(50) DEFAULT 1,
    easefonction character varying(60) DEFAULT 'linear'::character varying
);


ALTER TABLE public.memo_content OWNER TO memo;

--
-- Name: memo_content_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.memo_content ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.memo_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: memo_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.memo ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.memo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: memo_tag; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.memo_tag (
    memo_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.memo_tag OWNER TO memo;

--
-- Name: result; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.result (
    jsonb_agg jsonb
);


ALTER TABLE public.result OWNER TO memo;

--
-- Name: slide; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.slide (
    id integer NOT NULL,
    user_id integer,
    title character varying(100) NOT NULL,
    slug character varying(100) NOT NULL
);


ALTER TABLE public.slide OWNER TO memo;

--
-- Name: slide_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

CREATE SEQUENCE public.slide_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_id_seq OWNER TO memo;

--
-- Name: slide_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: memo
--

ALTER SEQUENCE public.slide_id_seq OWNED BY public.slide.id;


--
-- Name: style; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.style (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    css text NOT NULL
);


ALTER TABLE public.style OWNER TO memo;

--
-- Name: style_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.style ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.style_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tag; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.tag (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    color character varying(7) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    user_id integer
);


ALTER TABLE public.tag OWNER TO memo;

--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.tag ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: todo; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public.todo (
    id integer NOT NULL,
    description text NOT NULL,
    done boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    user_id integer
);


ALTER TABLE public.todo OWNER TO memo;

--
-- Name: todo_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public.todo ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.todo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: memo
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT user_email_check CHECK ((email ~ '^[a-z0-9!#$%&''*+/=?^_‘{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_‘{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$'::text))
);


ALTER TABLE public."user" OWNER TO memo;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: memo
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: slide id; Type: DEFAULT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.slide ALTER COLUMN id SET DEFAULT nextval('public.slide_id_seq'::regclass);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: content_type content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.content_type
    ADD CONSTRAINT content_type_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: lexicon lexicon_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.lexicon
    ADD CONSTRAINT lexicon_pkey PRIMARY KEY (id);


--
-- Name: link link_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (id);


--
-- Name: link link_url_key; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_url_key UNIQUE (url);


--
-- Name: memo_content memo_content_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_content
    ADD CONSTRAINT memo_content_pkey PRIMARY KEY (id);


--
-- Name: memo memo_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT memo_pkey PRIMARY KEY (id);


--
-- Name: memo_tag memo_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_tag
    ADD CONSTRAINT memo_tag_pkey PRIMARY KEY (memo_id, tag_id);


--
-- Name: slide slide_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (id);


--
-- Name: slide slide_slug_key; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.slide
    ADD CONSTRAINT slide_slug_key UNIQUE (slug);


--
-- Name: slide slide_title_key; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.slide
    ADD CONSTRAINT slide_title_key UNIQUE (title);


--
-- Name: style style_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.style
    ADD CONSTRAINT style_pkey PRIMARY KEY (id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: todo todo_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: lexicon word_must_be_unique; Type: CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.lexicon
    ADD CONSTRAINT word_must_be_unique UNIQUE (word);


--
-- Name: category category_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: memo fk_memo_category; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT fk_memo_category FOREIGN KEY (category_id) REFERENCES public.category(id) ON DELETE CASCADE;


--
-- Name: lexicon lexicon_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.lexicon
    ADD CONSTRAINT lexicon_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) ON DELETE CASCADE;


--
-- Name: lexicon lexicon_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.lexicon
    ADD CONSTRAINT lexicon_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: link link_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) ON DELETE CASCADE;


--
-- Name: link link_memo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_memo_id_fkey FOREIGN KEY (memo_id) REFERENCES public.memo(id) ON DELETE CASCADE;


--
-- Name: link link_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: memo memo_background_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT memo_background_id_fkey FOREIGN KEY (background_id) REFERENCES public.image(id);


--
-- Name: memo memo_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT memo_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) ON DELETE CASCADE;


--
-- Name: memo_content memo_content_memo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_content
    ADD CONSTRAINT memo_content_memo_id_fkey FOREIGN KEY (memo_id) REFERENCES public.memo(id) ON DELETE CASCADE;


--
-- Name: memo_content memo_content_memo_id_key; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_content
    ADD CONSTRAINT memo_content_memo_id_key FOREIGN KEY (memo_id) REFERENCES public.memo(id) ON DELETE CASCADE;


--
-- Name: memo_content memo_content_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_content
    ADD CONSTRAINT memo_content_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.content_type(id);


--
-- Name: memo_tag memo_tag_memo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_tag
    ADD CONSTRAINT memo_tag_memo_id_fkey FOREIGN KEY (memo_id) REFERENCES public.memo(id) ON DELETE CASCADE;


--
-- Name: memo_tag memo_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo_tag
    ADD CONSTRAINT memo_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- Name: memo memo_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT memo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: memo slide_foreign_key; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.memo
    ADD CONSTRAINT slide_foreign_key FOREIGN KEY (slide_id) REFERENCES public.slide(id) ON DELETE CASCADE;


--
-- Name: slide slide_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.slide
    ADD CONSTRAINT slide_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: tag tag_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: todo todo_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: memo
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;

COPY public.content_type (id, name, created_at, updated_at, type, available_style) FROM stdin;
2	paragraphe	2023-11-28 13:42:04.720384+01	2023-11-29 13:35:59.136335+01	\N	\N
4	blockquote	2023-11-29 13:31:52.929831+01	2023-12-10 21:49:27.226328+01	\N	\N
5	code	2023-12-15 01:22:59.879496+01	\N	\N	\N
6	detail	2023-12-15 15:59:07.606761+01	\N	\N	\N
7	summary	2023-12-16 15:08:13.142715+01	\N	\N	\N
10	noteCard	2023-12-17 23:12:25.576574+01	2023-12-17 23:52:00.542548+01	\N	{1,2}
\.




COPY public.image (original, thumbnail) FROM stdin;
https://cdn.pixabay.com/photo/2012/03/03/23/06/wall-21534_960_720.jpg	https://cdn.pixabay.com/photo/2012/03/03/23/06/wall-21534_960_720.jpg
https://cdn.pixabay.com/photo/2016/11/21/13/28/wood-1845389_960_720.jpg	https://cdn.pixabay.com/photo/2016/11/21/13/28/wood-1845389_960_720.jpg
https://cdn.pixabay.com/photo/2022/11/08/01/34/background-7577472_960_720.jpg	https://cdn.pixabay.com/photo/2022/11/08/01/34/background-7577472_960_720.jpg
https://cdn.pixabay.com/photo/2016/08/03/09/48/banners-1566213_960_720.jpg	https://cdn.pixabay.com/photo/2016/08/03/09/48/banners-1566213_960_720.jpg
https://cdn.pixabay.com/photo/2019/04/10/11/56/watercolor-4116932_960_720.png	https://cdn.pixabay.com/photo/2019/04/10/11/56/watercolor-4116932_960_720.png
https://cdn.pixabay.com/photo/2021/10/29/13/41/template-6751973_960_720.png	https://cdn.pixabay.com/photo/2021/10/29/13/41/template-6751973_960_720.png
https://cdn.pixabay.com/photo/2016/07/03/07/03/presentation-1494380_640.jpg	https://cdn.pixabay.com/photo/2016/07/03/07/03/presentation-1494380_640.jpg
https://cdn.pixabay.com/photo/2016/07/03/07/10/background-1494381_640.jpg	https://cdn.pixabay.com/photo/2016/07/03/07/10/background-1494381_640.jpg
https://cdn.pixabay.com/photo/2021/10/29/07/19/background-6751263_640.jpg	https://cdn.pixabay.com/photo/2021/10/29/07/19/background-6751263_640.jpg
\.


insert into public.style (name, css) values
('note', 'background-color: #09273; border-left: 4px solid #5E9EF;'),
('warning', 'background-color: #712828; border-left: 4px solid #935656;'),
('default', '');



--
-- PostgreSQL database dump complete
--



















































