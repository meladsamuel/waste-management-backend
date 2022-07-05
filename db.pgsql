--
-- PostgreSQL database dump
--

-- Dumped from database version 12.11 (Ubuntu 12.11-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.11 (Ubuntu 12.11-0ubuntu0.20.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.areas (
    code integer NOT NULL,
    name character varying NOT NULL,
    size double precision NOT NULL,
    longitude character varying NOT NULL,
    latitude character varying NOT NULL,
    city character varying NOT NULL
);


ALTER TABLE public.areas OWNER TO postgres;

--
-- Name: areas_code_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.areas_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.areas_code_seq OWNER TO postgres;

--
-- Name: areas_code_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.areas_code_seq OWNED BY public.areas.code;


--
-- Name: basket_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basket_section (
    height smallint NOT NULL,
    width smallint NOT NULL,
    length smallint NOT NULL,
    wastes_height smallint,
    category character varying NOT NULL,
    basket_id integer NOT NULL
);


ALTER TABLE public.basket_section OWNER TO postgres;

--
-- Name: baskets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.baskets (
    id integer NOT NULL,
    longitude double precision NOT NULL,
    latitude double precision NOT NULL,
    software_version character varying NOT NULL,
    wastes_height integer NOT NULL,
    area_code integer,
    micro_controller character varying NOT NULL
);


ALTER TABLE public.baskets OWNER TO postgres;

--
-- Name: baskets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.baskets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.baskets_id_seq OWNER TO postgres;

--
-- Name: baskets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.baskets_id_seq OWNED BY public.baskets.id;


--
-- Name: collect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collect (
    plate_number integer NOT NULL,
    basket_id integer NOT NULL,
    "DOC" timestamp without time zone NOT NULL
);


ALTER TABLE public.collect OWNER TO postgres;

--
-- Name: complaint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaint (
    user_id integer NOT NULL,
    basket_id integer NOT NULL,
    date_of_compliant timestamp without time zone NOT NULL,
    compliant_message character varying
);


ALTER TABLE public.complaint OWNER TO postgres;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    "SSN" bigint NOT NULL,
    full_name character varying NOT NULL,
    user_name character varying NOT NULL,
    password character varying NOT NULL,
    "DOB" timestamp without time zone NOT NULL,
    phone character varying,
    "supervise_SSN" bigint
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_SSN_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."employees_SSN_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."employees_SSN_seq" OWNER TO postgres;

--
-- Name: employees_SSN_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."employees_SSN_seq" OWNED BY public.employees."SSN";


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles_permissions (
    role_name character varying NOT NULL,
    permission_name character varying NOT NULL
);


ALTER TABLE public.roles_permissions OWNER TO postgres;

--
-- Name: software_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.software_versions (
    version character varying NOT NULL,
    file bytea,
    date timestamp without time zone DEFAULT now(),
    basket_id integer NOT NULL
);


ALTER TABLE public.software_versions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    user_name character varying,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    gender character varying NOT NULL,
    "DOB" timestamp without time zone,
    phone character varying,
    area_code integer,
    is_active boolean DEFAULT false,
    role_name character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    plate_number integer NOT NULL,
    container_size double precision,
    tank_level double precision,
    tank_size double precision,
    "employee_SSN" bigint
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: vehicles_plate_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicles_plate_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehicles_plate_number_seq OWNER TO postgres;

--
-- Name: vehicles_plate_number_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicles_plate_number_seq OWNED BY public.vehicles.plate_number;


--
-- Name: wastes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wastes (
    id integer NOT NULL,
    height double precision,
    size double precision,
    "DOC" timestamp without time zone DEFAULT now(),
    basket_id integer,
    category character varying
);


ALTER TABLE public.wastes OWNER TO postgres;

--
-- Name: wastes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wastes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wastes_id_seq OWNER TO postgres;

--
-- Name: wastes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wastes_id_seq OWNED BY public.wastes.id;


--
-- Name: areas code; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas ALTER COLUMN code SET DEFAULT nextval('public.areas_code_seq'::regclass);


--
-- Name: baskets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baskets ALTER COLUMN id SET DEFAULT nextval('public.baskets_id_seq'::regclass);


--
-- Name: employees SSN; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN "SSN" SET DEFAULT nextval('public."employees_SSN_seq"'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicles plate_number; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN plate_number SET DEFAULT nextval('public.vehicles_plate_number_seq'::regclass);


--
-- Name: wastes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wastes ALTER COLUMN id SET DEFAULT nextval('public.wastes_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
3769bc4bf199
\.


--
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.areas (code, name, size, longitude, latitude, city) FROM stdin;
\.


--
-- Data for Name: basket_section; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.basket_section (height, width, length, wastes_height, category, basket_id) FROM stdin;
90	40	40	0	organic	1
90	40	40	30	metal	1
90	40	40	0	organic	3
90	40	40	0	paper	3
120	30	20	0	organic	4
120	30	20	0	metal	4
120	30	20	0	paper	4
120	30	20	0	organic	5
120	30	20	0	metal	5
120	30	20	0	paper	5
120	30	20	0	organic	6
120	30	20	0	metal	6
120	30	20	0	paper	6
120	30	20	0	organic	7
120	30	20	0	paper	7
120	30	20	0	organic	8
120	30	20	0	paper	8
120	30	20	0	organic	9
120	30	20	0	paper	9
120	30	20	0	organic	10
120	30	20	0	organic	11
120	30	20	0	organic	12
120	30	20	0	organic	13
120	30	20	0	organic	14
120	20	30	0	organic	15
120	20	30	0	organic	2
120	30	30	0	paper	2
120	20	30	0	organic	16
120	20	30	0	metal	17
90	20	30	0	organic	18
90	20	30	0	paper	18
90	30	20	0	organic	19
1	1	1	0	bio	20
1	1	1	0	bio	21
1	1	1	0	bio	22
90	40	40	0	paper	23
90	40	40	0	metal	23
\.


--
-- Data for Name: baskets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.baskets (id, longitude, latitude, software_version, wastes_height, area_code, micro_controller) FROM stdin;
1	31.606558	30.159488	0.1.0	30	\N	nodeMCU
3	31.707338523768982	30.288860344706325	0.0.0	0	\N	nodeMCU
4	31.606146338819443	30.161443487450576	0.0.0	0	\N	nodeMCU
5	31.607798579572616	30.163391489586274	0.0.0	0	\N	nodeMCU
6	31.60945082032579	30.163632668125427	0.0.0	0	\N	nodeMCU
7	31.611768248914657	30.162760712156047	0.0.0	0	\N	nodeMCU
8	31.609515193342148	30.162352559903617	0.0.0	0	\N	nodeMCU
9	31.60794878327745	30.162092825772334	0.0.0	0	\N	nodeMCU
10	31.605631354688583	30.163131758191994	0.0.0	0	\N	nodeMCU
11	31.610523703931747	30.160812697557404	0.0.0	0	\N	nodeMCU
12	31.612369063733993	30.161072435060973	0.0.0	0	\N	nodeMCU
13	31.612562182783066	30.15977374070088	0.0.0	0	\N	nodeMCU
14	31.610824111341415	30.159532552722123	0.0.0	0	\N	nodeMCU
15	31.606720976805278	30.158629745508716	0.0.0	0	\N	nodeMCU
2	31.615654	30.185843	0.0.0	0	\N	nodeMCU
16	31.614103758886877	30.15993432516449	0.0.0	0	\N	nodeMCU
17	31.615455331535756	30.160241957001567	0.0.0	0	\N	nodeMCU
18	31.61720411503373	30.160603152507623	0.0.0	0	\N	nodeMCU
19	31.618338242654627	30.160946929868754	0.0.0	0	\N	nodeMCU
20	31.620197737768713	30.161381438291194	0.0.0	0	\N	nodeMCU
21	31.625218833044592	30.16639051202758	0.0.0	0	\N	nodeMCU
22	31.637192214087072	30.166538925144945	0.0.0	0	\N	nodeMCU
23	31.65521665866715	30.218321451524446	0.0.0	0	\N	nodeMCU
\.


--
-- Data for Name: collect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collect (plate_number, basket_id, "DOC") FROM stdin;
\.


--
-- Data for Name: complaint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complaint (user_id, basket_id, date_of_compliant, compliant_message) FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees ("SSN", full_name, user_name, password, "DOB", phone, "supervise_SSN") FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (name, description) FROM stdin;
baskets:read	show all basket from the system
basket:create	add one basket on the system
basket:update	add one basket on the system
users:create	add one basket on the system
users:read	add one basket on the system
roles:read	show all roles
role:read	show role details
permissions:read	show role details
permissions:crate	show role details
permissions:create	show role details
permission:read	show role details
driver	the person who responsible for the collect the waste from basket
waste:collect	collect the waste from the basket
basket:read	show basket details
basket:sofware-update	update the software of basket
basket:software-update	update the software of basket
basket:update-software	update the software of basket
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (name, description) FROM stdin;
admin	the person who responsible for the application
driver	the person who responsible for the collect the waste from basket
software engineer	response for update and  maintenance the microcontroller    
\.


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles_permissions (role_name, permission_name) FROM stdin;
admin	permissions:read
admin	permission:read
admin	role:read
admin	roles:read
admin	basket:software-update
admin	baskets:read
admin	basket:create
admin	basket:update
admin	users:create
admin	users:read
admin	permissions:crate
admin	permissions:create
admin	driver
admin	waste:collect
software engineer	basket:update
admin	basket:update-software
software engineer	baskets:read
software engineer	basket:create
admin	basket:read
admin	basket:sofware-update
driver	waste:collect
software engineer	basket:sofware-update
software engineer	basket:software-update
software engineer	basket:update-software
\.


--
-- Data for Name: software_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.software_versions (version, file, date, basket_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, user_name, first_name, last_name, email, password, gender, "DOB", phone, area_code, is_active, role_name) FROM stdin;
2	ali_ahmed	ali	ahmed	c7ru2484bh@the23app.com	$2b$12$3GG.qkHYY0rBsOvH9NEAtOZGG6dJQMrHkAWdDXhZ2LAeNJX9dknhe	male	\N	\N	\N	t	\N
3	rokaia23	Rokaia	Ehab	rokaia728@gmail.com	$2b$12$rE49CRpUQJ0fjTW7TB/66O1Ft3BWxfqD9d3j5yGo1CQkm6ZKGb.B6	female	\N	\N	\N	t	admin
9	admin	Joseph	Gakunga	josehwilddog@gmail.com	$2b$12$Yb1AQjfA5WeXq4wMyd/JE.TTFV5iVIR/Kc1g5o/9OR3t.LgPRNs.O	male	\N	\N	\N	f	admin
5	Hagernabil	Hager	Nabil	hagernabil1998@gmail.com	$2b$12$aelG2pV3K36hfr04MXjjs.A0gkxkoFpby7VP66mn.Wld0bU7hhxvK	female	\N	\N	\N	f	admin
4	abdo	abdo	ibrahim	abdelrahman202220@gmail.com	$2b$12$aPaC8sQAjznxGx16wCyy4.5z9pIb20KEalp4x8SDAzzcp.qrg/pY2	male	\N	\N	\N	t	driver
6	melad	Melad	Samuel	bsztaqqjrnclavm@solarunited.net	$2b$12$0w4hP9mMDwGAgRfFKe.tqum27VIq8sc30qg90F5VjtDePxovkGASG	male	\N	\N	\N	t	software engineer
7	Abdelrazek33	Abdelrazek	Maged	Abdelrazekmaged99@gmail.com	$2b$12$rxf1GKJ9DIOj/j8uWoyyLuiTx2qM8pk0YKAC24BYfr6cLgJ/VpbD.	male	\N	\N	\N	t	\N
8	test3	test	test	hopob26493@silbarts.com	$2b$12$TgErOdkwHKY8eViJrm6u8.z7FR8OJAPs37zJTDzAf7Xmao9rhgR7e	male	\N	\N	\N	f	\N
1	meladsamuel	Melad	Samuel	meladsamuel2@gmail.com	$2b$12$RLoncPoj8onCKimCf.XIWuMwItF7ShE4OxRMvExUlYkFlA1HAyyYm	male	\N	\N	\N	t	admin
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (plate_number, container_size, tank_level, tank_size, "employee_SSN") FROM stdin;
\.


--
-- Data for Name: wastes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wastes (id, height, size, "DOC", basket_id, category) FROM stdin;
27	10	10	2021-06-24 14:22:15.635391	\N	metal
28	10	10	2021-06-24 14:22:24.627703	\N	metal
29	10	10	2021-06-24 14:23:16.023659	\N	metal
30	10	10	2021-06-24 14:23:17.567806	\N	metal
31	20	20	2021-06-24 14:23:22.860135	\N	metal
32	10	10	2021-06-24 14:23:26.849854	\N	metal
33	20	20	2021-06-24 14:23:31.706535	\N	metal
34	10	10	2021-06-24 14:23:39.29221	\N	metal
35	10	10	2021-06-24 14:29:01.501358	\N	metal
36	10	16000	2021-06-24 14:30:29.672357	1	metal
37	10	16000	2021-06-24 14:30:31.376858	1	metal
38	10	16000	2021-06-24 14:30:32.916186	1	metal
\.


--
-- Name: areas_code_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.areas_code_seq', 1, false);


--
-- Name: baskets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.baskets_id_seq', 23, true);


--
-- Name: employees_SSN_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."employees_SSN_seq"', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- Name: vehicles_plate_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vehicles_plate_number_seq', 1, false);


--
-- Name: wastes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wastes_id_seq', 38, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: areas areas_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_name_key UNIQUE (name);


--
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (code);


--
-- Name: basket_section basket_section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basket_section
    ADD CONSTRAINT basket_section_pkey PRIMARY KEY (category, basket_id);


--
-- Name: baskets baskets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baskets
    ADD CONSTRAINT baskets_pkey PRIMARY KEY (id);


--
-- Name: collect collect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collect
    ADD CONSTRAINT collect_pkey PRIMARY KEY (plate_number, basket_id, "DOC");


--
-- Name: complaint complaint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaint
    ADD CONSTRAINT complaint_pkey PRIMARY KEY (user_id, basket_id, date_of_compliant);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY ("SSN");


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (name);


--
-- Name: roles_permissions roles_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_pkey PRIMARY KEY (role_name, permission_name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (name);


--
-- Name: software_versions software_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_versions
    ADD CONSTRAINT software_versions_pkey PRIMARY KEY (version, basket_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_name_key UNIQUE (user_name);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (plate_number);


--
-- Name: wastes wastes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wastes
    ADD CONSTRAINT wastes_pkey PRIMARY KEY (id);


--
-- Name: basket_section basket_section_basket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basket_section
    ADD CONSTRAINT basket_section_basket_id_fkey FOREIGN KEY (basket_id) REFERENCES public.baskets(id);


--
-- Name: baskets baskets_area_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baskets
    ADD CONSTRAINT baskets_area_code_fkey FOREIGN KEY (area_code) REFERENCES public.areas(code);


--
-- Name: collect collect_basket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collect
    ADD CONSTRAINT collect_basket_id_fkey FOREIGN KEY (basket_id) REFERENCES public.baskets(id);


--
-- Name: collect collect_plate_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collect
    ADD CONSTRAINT collect_plate_number_fkey FOREIGN KEY (plate_number) REFERENCES public.vehicles(plate_number);


--
-- Name: complaint complaint_basket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaint
    ADD CONSTRAINT complaint_basket_id_fkey FOREIGN KEY (basket_id) REFERENCES public.baskets(id);


--
-- Name: complaint complaint_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaint
    ADD CONSTRAINT complaint_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: employees employees_supervise_SSN_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT "employees_supervise_SSN_fkey" FOREIGN KEY ("supervise_SSN") REFERENCES public.employees("SSN");


--
-- Name: roles_permissions roles_permissions_permission_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_permission_name_fkey FOREIGN KEY (permission_name) REFERENCES public.permissions(name);


--
-- Name: roles_permissions roles_permissions_role_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_role_name_fkey FOREIGN KEY (role_name) REFERENCES public.roles(name);


--
-- Name: software_versions software_versions_basket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_versions
    ADD CONSTRAINT software_versions_basket_id_fkey FOREIGN KEY (basket_id) REFERENCES public.baskets(id);


--
-- Name: users users_area_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_area_code_fkey FOREIGN KEY (area_code) REFERENCES public.areas(code);


--
-- Name: users users_role_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_name_fkey FOREIGN KEY (role_name) REFERENCES public.roles(name);


--
-- Name: vehicles vehicles_employee_SSN_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT "vehicles_employee_SSN_fkey" FOREIGN KEY ("employee_SSN") REFERENCES public.employees("SSN");


--
-- Name: wastes wastes_basket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wastes
    ADD CONSTRAINT wastes_basket_id_fkey FOREIGN KEY (basket_id, category) REFERENCES public.basket_section(basket_id, category);


--
-- PostgreSQL database dump complete
--

