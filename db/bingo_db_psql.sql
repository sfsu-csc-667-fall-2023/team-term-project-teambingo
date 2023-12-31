--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

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
-- Name: bingodb; Type: SCHEMA; Schema: -; Owner: root
--

CREATE SCHEMA bingodb;


ALTER SCHEMA bingodb OWNER TO root;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: root
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO root;

--
-- Name: notify_lobby_gamechat(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.notify_lobby_gamechat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Notify the 'lobby_channel'
  PERFORM pg_notify('lobby_channel', 'New message in lobby');
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_lobby_gamechat() OWNER TO root;

--
-- Name: notify_lobby_message(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.notify_lobby_message() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Notify the 'lobby_channel' for any new message
  PERFORM pg_notify('lobby_channel', 'New message in lobby');
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_lobby_message() OWNER TO root;

--
-- Name: notify_new_message(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.notify_new_message() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM pg_notify('gamechat_channel', NEW.game_id::text);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_new_message() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bingo_ball; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.bingo_ball (
    id integer NOT NULL,
    letter character varying(1) NOT NULL
);


ALTER TABLE public.bingo_ball OWNER TO root;

--
-- Name: bingo_ball_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.bingo_ball_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bingo_ball_id_seq OWNER TO root;

--
-- Name: bingo_ball_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.bingo_ball_id_seq OWNED BY public.bingo_ball.id;


--
-- Name: card_spot; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.card_spot (
    bingo_ball_id integer NOT NULL,
    player_card_id integer NOT NULL,
    is_stamp boolean,
    id integer NOT NULL,
    spot_id smallint,
    CONSTRAINT card_spot_spot_id_check CHECK (((spot_id >= 1) AND (spot_id <= 25)))
);


ALTER TABLE public.card_spot OWNER TO root;

--
-- Name: card_spot_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.card_spot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.card_spot_id_seq OWNER TO root;

--
-- Name: card_spot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.card_spot_id_seq OWNED BY public.card_spot.id;


--
-- Name: game; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.game (
    game_code character varying(255) NOT NULL,
    game_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    connected_players integer DEFAULT 0,
    is_finished boolean DEFAULT false
);


ALTER TABLE public.game OWNER TO root;

--
-- Name: gamechat; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.gamechat (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    game_id character varying(255) NOT NULL,
    message character varying(255) NOT NULL,
    time_sent timestamp without time zone NOT NULL
);


ALTER TABLE public.gamechat OWNER TO root;

--
-- Name: gamechat_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.gamechat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gamechat_id_seq OWNER TO root;

--
-- Name: gamechat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.gamechat_id_seq OWNED BY public.gamechat.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.messages (
    message_id integer NOT NULL,
    player_name character varying(255) NOT NULL,
    message_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    message_content text NOT NULL
);


ALTER TABLE public.messages OWNER TO root;

--
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_message_id_seq OWNER TO root;

--
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.messages_message_id_seq OWNED BY public.messages.message_id;


--
-- Name: player; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.player (
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE public.player OWNER TO root;

--
-- Name: player_card; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.player_card (
    id integer NOT NULL,
    game_id character varying(255) NOT NULL,
    player_id character varying(255) NOT NULL,
    is_checked_in boolean,
    is_winner boolean
);


ALTER TABLE public.player_card OWNER TO root;

--
-- Name: player_card_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.player_card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_card_id_seq OWNER TO root;

--
-- Name: player_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.player_card_id_seq OWNED BY public.player_card.id;


--
-- Name: player_gamechat; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.player_gamechat (
    player_id character varying(255) NOT NULL,
    gamechat_id integer NOT NULL
);


ALTER TABLE public.player_gamechat OWNER TO root;

--
-- Name: pulled_balls; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.pulled_balls (
    game_id character varying(255) NOT NULL,
    bingo_ball_id integer NOT NULL,
    time_pulled timestamp without time zone NOT NULL
);


ALTER TABLE public.pulled_balls OWNER TO root;

--
-- Name: users; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255),
    password character varying(255),
    email character varying(255)
);


ALTER TABLE public.users OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: bingo_ball id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.bingo_ball ALTER COLUMN id SET DEFAULT nextval('public.bingo_ball_id_seq'::regclass);


--
-- Name: card_spot id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.card_spot ALTER COLUMN id SET DEFAULT nextval('public.card_spot_id_seq'::regclass);


--
-- Name: gamechat id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.gamechat ALTER COLUMN id SET DEFAULT nextval('public.gamechat_id_seq'::regclass);


--
-- Name: messages message_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.messages ALTER COLUMN message_id SET DEFAULT nextval('public.messages_message_id_seq'::regclass);


--
-- Name: player_card id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_card ALTER COLUMN id SET DEFAULT nextval('public.player_card_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: bingo_ball; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.bingo_ball (id, letter) FROM stdin;
1	B
2	B
3	B
4	B
5	B
6	B
7	B
8	B
9	B
10	B
11	B
12	B
13	B
14	B
15	B
16	I
17	I
18	I
19	I
20	I
21	I
22	I
23	I
24	I
25	I
26	I
27	I
28	I
29	I
30	I
31	N
32	N
33	N
34	N
35	N
36	N
37	N
38	N
39	N
40	N
41	N
42	N
43	N
44	N
45	N
46	G
47	G
48	G
49	G
50	G
51	G
52	G
53	G
54	G
55	G
56	G
57	G
58	G
59	G
60	G
61	O
62	O
63	O
64	O
65	O
66	O
67	O
68	O
69	O
70	O
71	O
72	O
73	O
74	O
75	O
\.


--
-- Name: bingo_ball_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.bingo_ball_id_seq', 79, true);


--
-- Name: card_spot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.card_spot_id_seq', 2628, true);


--
-- Name: gamechat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.gamechat_id_seq', 177, true);


--
-- Name: messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.messages_message_id_seq', 126, true);


--
-- Name: player_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.player_card_id_seq', 96, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.users_id_seq', 19, true);


--
-- Name: bingo_ball bingo_ball_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.bingo_ball
    ADD CONSTRAINT bingo_ball_pkey PRIMARY KEY (id);


--
-- Name: card_spot card_spot_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.card_spot
    ADD CONSTRAINT card_spot_pkey PRIMARY KEY (id);


--
-- Name: game game_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.game
    ADD CONSTRAINT game_pkey PRIMARY KEY (game_code);


--
-- Name: gamechat gamechat_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.gamechat
    ADD CONSTRAINT gamechat_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: player_card player_card_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_card
    ADD CONSTRAINT player_card_pkey PRIMARY KEY (id);


--
-- Name: player_gamechat player_gamechat_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_gamechat
    ADD CONSTRAINT player_gamechat_pkey PRIMARY KEY (player_id, gamechat_id);


--
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: player_card_game_id_player_id_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX player_card_game_id_player_id_idx ON public.player_card USING btree (game_id, player_id);


--
-- Name: pulled_balls_game_id_bingo_ball_id_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX pulled_balls_game_id_bingo_ball_id_idx ON public.pulled_balls USING btree (game_id, bingo_ball_id);


--
-- Name: gamechat new_message_trigger; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER new_message_trigger AFTER INSERT ON public.gamechat FOR EACH ROW EXECUTE FUNCTION public.notify_new_message();


--
-- Name: messages new_message_trigger; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER new_message_trigger AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.notify_lobby_message();


--
-- Name: card_spot card_spot_bingo_ball_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.card_spot
    ADD CONSTRAINT card_spot_bingo_ball_id_fkey FOREIGN KEY (bingo_ball_id) REFERENCES public.bingo_ball(id) ON DELETE CASCADE;


--
-- Name: card_spot card_spot_player_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.card_spot
    ADD CONSTRAINT card_spot_player_card_id_fkey FOREIGN KEY (player_card_id) REFERENCES public.player_card(id) ON DELETE CASCADE;


--
-- Name: gamechat gamechat_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.gamechat
    ADD CONSTRAINT gamechat_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.game(game_code) ON DELETE CASCADE;


--
-- Name: player_card player_card_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_card
    ADD CONSTRAINT player_card_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.game(game_code) ON DELETE CASCADE;


--
-- Name: player_card player_card_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_card
    ADD CONSTRAINT player_card_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(username) ON DELETE CASCADE;


--
-- Name: player_gamechat player_gamechat_gamechat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_gamechat
    ADD CONSTRAINT player_gamechat_gamechat_id_fkey FOREIGN KEY (gamechat_id) REFERENCES public.gamechat(id);


--
-- Name: player_gamechat player_gamechat_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.player_gamechat
    ADD CONSTRAINT player_gamechat_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(username);


--
-- Name: pulled_balls pulled_balls_bingo_ball_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.pulled_balls
    ADD CONSTRAINT pulled_balls_bingo_ball_id_fkey FOREIGN KEY (bingo_ball_id) REFERENCES public.bingo_ball(id) ON DELETE CASCADE;


--
-- Name: pulled_balls pulled_balls_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.pulled_balls
    ADD CONSTRAINT pulled_balls_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.game(game_code) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES  TO root;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES  TO root;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS  TO root;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO root;


--
-- PostgreSQL database dump complete
--

