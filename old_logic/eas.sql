--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.5
-- Dumped by pg_dump version 9.4.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: box2d; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE box2d;


ALTER TYPE box2d OWNER TO combo;

--
-- Name: TYPE box2d; Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON TYPE box2d IS 'postgis type: A box composed of x min, ymin, xmax, ymax. Often used to return the 2d enclosing box of a geometry.';


--
-- Name: box3d; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE box3d;


ALTER TYPE box3d OWNER TO combo;

--
-- Name: TYPE box3d; Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON TYPE box3d IS 'postgis type: A box composed of x min, ymin, zmin, xmax, ymax, zmax. Often used to return the 3d extent of a geometry or collection of geometries.';


--
-- Name: box3d_extent; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE box3d_extent;


ALTER TYPE box3d_extent OWNER TO combo;

--
-- Name: TYPE box3d_extent; Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON TYPE box3d_extent IS 'postgis type: A box composed of x min, ymin, zmin, xmax, ymax, zmax. Often used to return the extent of a geometry.';


--
-- Name: chip; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE chip;


ALTER TYPE chip OWNER TO combo;

--
-- Name: geography; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE geography;


ALTER TYPE geography OWNER TO combo;

--
-- Name: TYPE geography; Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON TYPE geography IS 'postgis type: Ellipsoidal spatial data type.';


--
-- Name: geometry; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE geometry;


ALTER TYPE geometry OWNER TO combo;

--
-- Name: TYPE geometry; Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON TYPE geometry IS 'postgis type: Planar spatial data type.';


--
-- Name: gidx; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE gidx;


ALTER TYPE gidx OWNER TO combo;

--
-- Name: pgis_abs; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE pgis_abs;


ALTER TYPE pgis_abs OWNER TO combo;

--
-- Name: spheroid; Type: TYPE; Schema: public; Owner: combo
--

CREATE TYPE spheroid;


ALTER TYPE spheroid OWNER TO combo;

--
-- Name: addauth(text); Type: FUNCTION; Schema: public; Owner: combo
--

CREATE FUNCTION addauth(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$ 
DECLARE
	lockid alias for $1;
	okay boolean;
	myrec record;
BEGIN
	-- check to see if table exists
	--  if not, CREATE TEMP TABLE mylock (transid xid, lockcode text)
	okay := 'f';
	FOR myrec IN SELECT * FROM pg_class WHERE relname = 'temp_lock_have_table' LOOP
		okay := 't';
	END LOOP; 
	IF (okay <> 't') THEN 
		CREATE TEMP TABLE temp_lock_have_table (transid xid, lockcode text);
			-- this will only work from pgsql7.4 up
			-- ON COMMIT DELETE ROWS;
	END IF;

	--  INSERT INTO mylock VALUES ( $1)
--	EXECUTE 'INSERT INTO temp_lock_have_table VALUES ( '||
--		quote_literal(getTransactionID()) || ',' ||
--		quote_literal(lockid) ||')';

	INSERT INTO temp_lock_have_table VALUES (getTransactionID(), lockid);

	RETURN true::boolean;
END;
$_$;


ALTER FUNCTION public.addauth(text) OWNER TO combo;

--
-- Name: FUNCTION addauth(text); Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON FUNCTION addauth(text) IS 'args: auth_token - Add an authorization token to be used in current transaction.';


--
-- Name: addgeometrycolumn(character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: combo
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('','',$1,$2,$3,$4,$5) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, integer, character varying, integer) OWNER TO combo;

--
-- Name: FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer); Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) IS 'args: table_name, column_name, srid, type, dimension - Adds a geometry column to an existing table of attributes.';


--
-- Name: addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: combo
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $_$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('',$1,$2,$3,$4,$5,$6) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO combo;

--
-- Name: FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer); Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) IS 'args: schema_name, table_name, column_name, srid, type, dimension - Adds a geometry column to an existing table of attributes.';


--
-- Name: addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: combo
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$
DECLARE
	catalog_name alias for $1;
	schema_name alias for $2;
	table_name alias for $3;
	column_name alias for $4;
	new_srid alias for $5;
	new_type alias for $6;
	new_dim alias for $7;
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;

BEGIN

	-- Verify geometry type
	IF ( NOT ( (new_type = 'GEOMETRY') OR
			   (new_type = 'GEOMETRYCOLLECTION') OR
			   (new_type = 'POINT') OR
			   (new_type = 'MULTIPOINT') OR
			   (new_type = 'POLYGON') OR
			   (new_type = 'MULTIPOLYGON') OR
			   (new_type = 'LINESTRING') OR
			   (new_type = 'MULTILINESTRING') OR
			   (new_type = 'GEOMETRYCOLLECTIONM') OR
			   (new_type = 'POINTM') OR
			   (new_type = 'MULTIPOINTM') OR
			   (new_type = 'POLYGONM') OR
			   (new_type = 'MULTIPOLYGONM') OR
			   (new_type = 'LINESTRINGM') OR
			   (new_type = 'MULTILINESTRINGM') OR
			   (new_type = 'CIRCULARSTRING') OR
			   (new_type = 'CIRCULARSTRINGM') OR
			   (new_type = 'COMPOUNDCURVE') OR
			   (new_type = 'COMPOUNDCURVEM') OR
			   (new_type = 'CURVEPOLYGON') OR
			   (new_type = 'CURVEPOLYGONM') OR
			   (new_type = 'MULTICURVE') OR
			   (new_type = 'MULTICURVEM') OR
			   (new_type = 'MULTISURFACE') OR
			   (new_type = 'MULTISURFACEM')) )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM,
	or GEOMETRYCOLLECTIONM';
		RETURN 'fail';
	END IF;


	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <0) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;


	-- Verify SRID
	IF ( new_srid != -1 ) THEN
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumns() - invalid SRID';
			RETURN 'fail';
		END IF;
	END IF;


	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;


	-- Add geometry column to table
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD COLUMN ' || quote_ident(column_name) ||
		' geometry ';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM geometry_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||
		quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(table_name) ||
		' AND f_geometry_column = ' || quote_literal(column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add record in geometry_columns
	sql := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema,f_table_name,' ||
										  'f_geometry_column,coord_dimension,srid,type)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(table_name) || ',' ||
		quote_literal(column_name) || ',' ||
		new_dim::text || ',' ||
		new_srid::text || ',' ||
		quote_literal(new_type) || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add table CHECKs
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_srid_' || column_name)
		|| ' CHECK (ST_SRID(' || quote_ident(column_name) ||
		') = ' || new_srid::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_dims_' || column_name)
		|| ' CHECK (ST_NDims(' || quote_ident(column_name) ||
		') = ' || new_dim::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	IF ( NOT (new_type = 'GEOMETRY')) THEN
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
			quote_ident('enforce_geotype_' || column_name) ||
			' CHECK (GeometryType(' ||
			quote_ident(column_name) || ')=' ||
			quote_literal(new_type) || ' OR (' ||
			quote_ident(column_name) || ') is null)';
		RAISE DEBUG '%', sql;
		EXECUTE sql;
	END IF;

	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) OWNER TO combo;

--
-- Name: FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer); Type: COMMENT; Schema: public; Owner: combo
--

COMMENT ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) IS 'args: catalog_name, schema_name, table_name, column_name, srid, type, dimension - Adds a geometry column to an existing table of attributes.';


--
-- Name: characters_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE characters_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE characters_sequence OWNER TO combo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: characters; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE characters (
    id integer DEFAULT nextval('characters_sequence'::regclass),
    name text,
    alias text,
    attribute text,
    chackra integer DEFAULT 0,
    life integer,
    attack integer,
    defense integer,
    ninjutsu integer,
    resistance integer,
    id_json text,
    human_summon integer DEFAULT 1,
    summon_color text
);


ALTER TABLE characters OWNER TO combo;

--
-- Name: characters_skills_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE characters_skills_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE characters_skills_sequence OWNER TO combo;

--
-- Name: characters_skills; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE characters_skills (
    id integer DEFAULT nextval('characters_skills_sequence'::regclass),
    id_character integer,
    id_skill integer
);


ALTER TABLE characters_skills OWNER TO combo;

--
-- Name: skills_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE skills_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE skills_sequence OWNER TO combo;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE skills (
    id integer DEFAULT nextval('skills_sequence'::regclass),
    id_type integer,
    name text,
    chase_status text,
    hurt_status text,
    hurt_num integer,
    pic_url text,
    id_json text
);


ALTER TABLE skills OWNER TO combo;

--
-- Name: skills_statuses_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE skills_statuses_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE skills_statuses_sequence OWNER TO combo;

--
-- Name: skills_statuses; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE skills_statuses (
    id integer DEFAULT nextval('skills_statuses_sequence'::regclass),
    id_skill integer,
    id_status integer,
    chase_create integer
);


ALTER TABLE skills_statuses OWNER TO combo;

--
-- Name: skills_type_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE skills_type_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE skills_type_sequence OWNER TO combo;

--
-- Name: skills_type; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE skills_type (
    id integer DEFAULT nextval('skills_type_sequence'::regclass),
    name text
);


ALTER TABLE skills_type OWNER TO combo;

--
-- Name: statuses_sequence; Type: SEQUENCE; Schema: public; Owner: combo
--

CREATE SEQUENCE statuses_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE statuses_sequence OWNER TO combo;

--
-- Name: statuses; Type: TABLE; Schema: public; Owner: combo
--

CREATE TABLE statuses (
    id integer DEFAULT nextval('statuses_sequence'::regclass),
    name text,
    alias text
);


ALTER TABLE statuses OWNER TO combo;

--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY characters (id, name, alias, attribute, chackra, life, attack, defense, ninjutsu, resistance, id_json, human_summon, summon_color) FROM stdin;
269	Ukon Sakon	Ukon Sakon	fire	0	535	741	941	562	526	11002801	1	\N
270			fire	0	692	628	709	764	562	11011201	1	\N
271			water	0	944	457	598	827	598	11006901	1	\N
272	Kimimaro	Kimimaro	ltng	0	891	777	875	290	573	11002501	1	\N
273			fire	0	873	561	561	537	537	10000201	1	\N
275			fire	0	842	577	578	665	730	11006801	1	\N
278	Kankuro[Great Ninja War]	Kankuro	wind	0	1273	703	875	363	574	11001531	1	\N
279	Jiraiya[Sage Mode]	Jiraiya	fire	0	842	293	578	948	730	11002211	1	\N
280			wind	0	537	870	681	676	540	11004401	1	\N
281	Zabuza[	Zabuza	water	0	535	896	941	407	526	11001711	1	\N
283	Kiba[Great Ninja War]	Kiba	earth	0	1040	762	393	785	622	11001021	1	\N
284	Naruto[	Naruto	wind	0	943	592	597	691	597	11000161	1	\N
285	Chiyo 	Chiyo 	earth	0	751	848	853	353	560	11005011	1	\N
286	Hataka[	Hataka	water	0	617	526	558	1073	558	11009401	1	\N
287	Yamanaka	Yamanaka	fire	0	873	514	582	700	734	11007701	1	\N
288	Udon	Udon	water	0	872	631	524	631	524	11004601	1	\N
289	Shizune	Shizune	earth	0	798	351	555	680	994	11004201	1	\N
290	Gaara[	Gaara	wind	0	991	375	592	726	748	11001311	1	\N
291	Chiyo 	Chiyo 	earth	0	751	774	853	428	559	11005001	1	\N
292	Kimimaro[	Kimimaro	ltng	0	891	777	875	290	573	11002601	1	\N
293	Udon[	Shiro	water	0	609	497	543	848	828	11001801	1	\N
294			ltng	0	725	510	567	876	686	11011501	1	\N
295			earth	0	991	375	593	726	748	11007801	1	\N
296	Pain - Animal Path	Pain - Animal Path	water	0	609	497	543	849	828	11005801	1	\N
297			water	0	506	543	505	543	1204	11009101	1	\N
298	Itachi Uchiha[		fire	0	342	536	491	871	1008	11003101	1	\N
299	Pain - Tendo	Pain - Tendo	ltng	0	842	442	578	800	730	11006501	1	\N
300			ltng	0	617	466	528	636	1084	11008401	1	\N
302			earth	0	751	510	853	691	560	11008701	1	\N
303			fire	0	537	581	540	966	682	11010801	1	\N
304	Hinata[Great Ninja War]	Hinata	ltng	0	891	703	875	363	574	11001221	1	\N
305	Jirobo	Jirobo	earth	0	667	537	542	627	970	11002701	1	\N
306			wind	0	698	955	569	561	569	11011301	1	\N
307	Tayuya	Tayuya	fire	0	667	494	542	669	970	11003001	1	\N
308			ltng	0	781	574	579	863	579	11010101	1	\N
309			earth	0	842	948	730	293	578	11007401	1	\N
311	Kakuzu[	Kakuzu	earth	0	781	449	579	988	579	11005431	1	\N
312	Naruto[Sage Mode]	Naruto	wind	0	1103	521	613	618	613	11000171	1	\N
313			ltng	0	610	850	829	498	544	11009801	1	\N
314	Sasori[	Sasori	fire	0	690	876	708	513	560	11004801	1	\N
315			earth	0	921	562	379	688	532	10000501	1	\N
316			fire	0	617	799	558	799	558	11009001	1	\N
317			wind	0	698	569	569	947	569	11009501	1	\N
318			water	0	1008	876	604	350	604	11011401	1	\N
319			ltng	0	943	738	597	545	597	11010201	1	\N
320			earth	0	872	351	581	861	734	11008101	1	\N
321	Tobirama Senju[	Tobirama Senju[	water	0	751	428	559	774	853	11003401	1	\N
323	Yamanaka	Yamanaka	earth	0	877	607	728	607	582	11008801	1	\N
324			wind	0	537	870	681	676	540	11004411	1	\N
325			wind	0	751	428	559	774	853	11009601	1	\N
326			ltng	0	944	827	598	457	598	11007001	1	\N
327	Pain - Gakido	Pain - Gakido	earth	0	800	681	995	352	556	11006401	1	\N
328	Pain - Ningendo	Pain - Ningendo	ltng	0	609	809	828	538	543	11005901	1	\N
331			fire	0	770	555	1032	468	550	11009301	1	\N
334			water	0	617	466	528	636	1084	11008001	1	\N
335			fire	0	798	351	555	680	994	11002401	1	\N
336			ltng	0	987	956	708	434	560	11007601	1	\N
337	Ino[	Ino	earth	0	695	696	562	696	702	11000731	1	\N
338			earth	0	993	552	594	552	750	11011601	1	\N
339	Kakashi[	Kakashi	ltng	0	401	554	507	899	907	11001611	1	\N
340	Temari[Great Ninja War]	Temari	wind	0	684	434	560	956	708	11001431	1	\N
341			fire	0	837	852	975	483	632	11003611	1	\N
342			earth	0	872	631	524	631	524	11004701	1	\N
343	Sasuke[	Sasuke	ltng	0	690	513	560	876	708	11000221	1	\N
344	Shikamaru[Great Ninja War]	Shikamaru	earth	0	751	511	560	692	854	11000841	1	\N
345	Asuma[	Asuma	wind	0	751	353	560	849	854	11003911	1	\N
346			ltng	0	873	514	582	700	734	11008301	1	\N
347			fire	0	851	428	559	774	853	19004711	1	\N
348	Sai	Sai	water	0	842	442	578	799	730	11005601	1	\N
350			wind	0	681	463	552	811	842	11010501	1	\N
351			earth	0	902	685	584	499	737	11011101	1	\N
352			fire	0	890	584	590	720	621	11011701	1	\N
354			ltng	0	1024	789	606	423	606	11010301	1	\N
355			water	0	690	956	708	434	560	11007611	1	\N
330	Shino[Shippuden]	Shino	earth	0	751	510	560	691	853	11001111	1	\N
349	Lee[Shippuden]	Lee	earth	0	609	995	828	350	543	11000411	1	\N
356	Naruto[Shippuden]	Naruto	wind	0	1103	521	613	618	613	11000141	1	\N
277	Hinata[Big Sister]	Hinata	ltng	0	781	817	579	620	579	11001231	1	\N
276	Hinata[1 star]	Hinata	ltng	0	891	702	875	363	573	11001201	1	\N
274	Kiba[1 star]	Kiba	earth	0	842	799	730	442	578	11001001	1	\N
301	Choji[1 star]	Choji	fire	0	567	684	1302	255	505	11000901	1	\N
310	Ino[1 star]	Ino	earth	0	751	510	560	691	853	11000701	1	\N
322	Neji[1 star]	Neji	earth	0	798	752	994	281	555	11000501	1	\N
332	Lee[1 star]	Lee	earth	0	609	995	828	350	543	11000401	1	\N
357			earth	0	972	639	589	457	775	11003311	1	\N
359	Hidan[	Hidan	fire	0	891	777	875	290	573	11005501	1	\N
361	Deidara[	Deidara	earth	0	781	449	579	988	579	11004921	1	\N
362	Shino[Great Ninja War]	Shino	earth	0	891	445	574	622	875	11001121	1	\N
365			ltng	0	627	838	813	241	813	11010701	1	\N
366	Obito[	Obito	fire	0	843	528	579	715	731	11010401	1	\N
367	Enma	Enma	earth	0	798	602	994	430	555	19004801	1	\N
368	Chiza Akimichi	Chiza Akimichi	earth	0	992	803	749	300	593	11006601	1	\N
369	Anko	Anko	fire	0	535	606	526	698	941	11004001	1	\N
370			earth	0	798	752	555	281	994	11003301	1	\N
371	Lee[	Lee	earth	0	609	995	828	350	543	11000421	1	\N
372			ltng	0	842	800	730	442	578	11007501	1	\N
373	Lee[Great Ninja War]	Lee	earth	0	609	995	828	350	543	11000441	1	\N
375	Asuma	Asuma	wind	0	535	642	526	661	941	11003901	1	\N
376	Tobi[	Tobi	fire	0	751	353	560	848	853	11006001	1	\N
377	Karin	Karin	fire	0	842	527	578	714	730	11005101	1	\N
378	Tsunade[	Tsunade	water	0	667	822	970	342	542	11002301	1	\N
379	Naruto[	Naruto	wind	0	1103	521	613	618	613	11000151	1	\N
380	Konan[	Konan	wind	0	609	497	543	849	828	11006101	1	\N
381	Deidara[	Deidara	earth	0	466	493	523	1005	797	11004901	1	\N
382	Shikamaru[	Shikamaru	earth	0	842	573	578	668	730	11000831	1	\N
383	Baki	Baki	wind	0	535	562	526	741	941	11004301	1	\N
384	Tenten[	Tenten	water	0	667	772	840	516	550	11000631	1	\N
385	Sakura[		water	0	781	668	579	769	579	11000341	1	\N
386			earth	0	1052	434	599	616	756	11008201	1	\N
388	Jugo	Jugo	earth	0	667	822	970	342	542	11005301	1	\N
391	Jiraiya[Sannin War]	Jiraiya	fire	0	751	353	560	848	853	11002201	1	\N
392	Temari[	Temari	wind	0	617	390	528	713	1084	11001451	1	\N
393	Kakuzu[	Kakuzu	earth	0	609	421	543	925	828	11005401	1	\N
394	Naruto[Nine Tails Chakra]	Naruto	wind	0	1103	521	613	618	613	11000131	1	\N
395	Kabuto[	Kabuto	water	0	1103	570	613	570	613	11002011	1	\N
396	Sasuke[	Sasuke	ltng	0	991	375	593	726	748	11000251	1	\N
397	Itachi Uchiha[		fire	0	690	956	708	434	560	11008501	1	\N
398	Kidomaru	Kidomaru	wind	0	751	510	560	691	853	11002901	1	\N
399	Suigetsu	Suigetsu	water	0	891	663	573	403	875	11005201	1	\N
400	Kisame Hoshigaki[	Kisame Hoshigaki	water	0	667	749	970	414	542	11003201	1	\N
404	Guy[	Guy	ltng	0	467	933	1045	329	509	11001901	1	\N
405	Kakashi[	Kakashi	ltng	0	723	661	556	758	556	11001621	1	\N
406	Asuma[	Asuma	wind	0	813	417	575	855	727	11003921	1	\N
407	Zabuza[	Zabuza	water	0	842	442	578	799	730	11001701	1	\N
408	Orochimaru[	Orochimaru	wind	0	746	824	1107	467	611	11002101	1	\N
409			ltng	0	494	603	526	840	833	11010901	1	\N
410			ltng	0	690	513	560	876	708	11007301	1	\N
411	Sakura[Great Ninja War]		water	0	781	668	579	769	579	11000331	1	\N
412	Naruto[	Naruto	wind	0	977	628	602	628	602	11000181	1	\N
413	Shiro[	Shiro	water	0	609	581	543	766	828	11001821	1	\N
414			earth	0	992	300	593	803	749	11009901	1	\N
415	Orochimaru[Sannin War]	Orochimaru	wind	0	746	824	1107	467	611	11002111	1	\N
416	Sasuke[	Sasuke	ltng	0	842	442	578	800	730	11000261	1	\N
417	Hidan[	Hidan	fire	0	992	803	749	300	593	11005511	1	\N
419			water	0	690	1027	708	362	560	11007901	1	\N
420	Gaara[	Gaara	wind	0	1138	314	606	658	765	11001331	1	\N
421	Pain - Shurado	Pain - Shurado	fire	0	466	1007	799	494	524	11006301	1	\N
422			fire	0	991	375	593	726	748	11007201	1	\N
424			water	0	933	531	625	587	741	10000101	1	\N
425			earth	0	699	659	569	858	569	11009201	1	\N
427			wind	0	781	718	579	718	579	11010001	1	\N
428			ltng	0	842	800	730	442	578	11007511	1	\N
429			earth	0	842	442	578	800	730	11007101	1	\N
430	Naruto[	Naruto	wind	0	1103	521	613	618	613	11000101	1	\N
431	Zabuza[	Zabuza	water	0	595	856	825	504	541	11001731	1	\N
432			wind	0	1042	550	608	648	608	11010601	1	\N
435	Sai[Great Ninja War]	Sai	water	0	846	598	587	776	587	11005611	1	\N
436	Shiro[	Shiro	water	0	609	497	543	848	828	11001811	1	\N
437	Konohamaru[	Konohamaru	fire	0	690	600	560	790	708	11004511	1	\N
438	Yamato	Yamato	earth	0	798	351	555	680	994	11005701	1	\N
439	Kisame Hoshigaki[	Kisame Hoshigaki	water	0	945	868	598	416	598	11003211	1	\N
440	Choji[Great Ninja War]	Choji	fire	0	568	684	1303	255	505	11000921	1	\N
441	Konohamaru	Konohamaru	fire	0	872	631	524	631	524	11004501	1	\N
442			water	0	1161	526	609	452	738	11011001	1	\N
360	Shikamaru[Shippuden]	Shikamaru	earth	0	842	573	578	668	730	11000821	1	\N
363	Kiba[Shippuden]	Kiba	earth	0	842	799	730	442	578	11001011	1	\N
364	Hinata[Shippuden]	Hinata	ltng	0	891	702	875	363	573	11001211	1	\N
374	Gaara[Shippuden]	Gaara	wind	0	991	375	592	726	748	11001321	1	\N
402	Ino[Shippuden]	Ino	earth	0	751	510	560	691	853	11000711	1	\N
418	Choji[Shippuden]	Choji	fire	0	567	684	1302	255	505	11000911	1	\N
387	Shikamaru[1 star]	Shikamaru	earth	0	842	573	578	668	730	11000801	1	\N
390	Temari[1 star]	Temari	wind	0	609	458	543	887	828	11001411	1	\N
403	Obito[1 star]	Obito	fire	0	1103	570	613	570	613	11003501	1	\N
423	Sasuke[1 star]	Sasuke	ltng	0	690	513	560	876	708	11000211	1	\N
426	Kankuro[1 star]	Kankuro	wind	0	751	774	853	428	559	11001511	1	\N
433	Kabuto[1 star]	Kabuto	water	0	798	507	555	525	994	11002001	1	\N
443	Sasori[	Sasori	fire	0	711	523	792	534	798	11004831	1	\N
444	Temari[	Temari	wind	0	695	379	553	879	844	11001461	1	\N
446	Pain - Jigokudo	Pain - Jigokudo	wind	0	690	600	560	790	708	11006201	1	\N
447	Kurenai	Kurenai	fire	0	667	414	542	749	970	11004101	1	\N
448	Kakashi[	Kakashi	ltng	0	468	796	1045	466	509	11001631	1	\N
449		ltng	ltng	0	710	803	473	519	519	10000401	1	\N
450	Sasori[	Sasori	fire	0	842	799	730	442	578	11004811	1	\N
451	Neji[Great Ninja War]	Neji	earth	0	798	752	994	281	555	11000521	1	\N
453	Ino[Great Ninja War]	Ino	earth	0	751	510	560	691	853	11000721	1	\N
454			fire	0	851	428	559	774	853	19004701	1	\N
455	Tsunade[Sannin War]	Tsunade	water	0	667	822	970	342	542	11002311	1	\N
456			wind	0	539	500	685	382	767	10000301	1	\N
457			water	0	617	526	558	1073	558	11009701	1	\N
458	Tenten[Great Ninja War]	Tenten	water	0	1116	620	579	817	579	11000621	1	\N
460	Crimson Fist	Crimson Fist	earth	0	\N	\N	\N	\N	\N	\N	1	\N
434	Sasuke[Shippuden]	Sasuke	ltng	0	690	513	560	876	708	11000231	1	\N
461	Chameleon	Chameleon	\N	0	20	10	8	10	\N	\N	2	purple
459	Neji[Shippuden]	Neji	earth	0	798	752	994	281	555	11000511	1	\N
329	Kankuro[Shippuden]	Kankuro	wind	0	751	774	853	428	559	11001521	1	\N
353	Sakura[Shippuden]	Sakura	water	0	690	790	708	600	560	11000321	1	\N
358	Tenten[Shippuden]	Tenten	water	0	609	848	828	497	543	11000611	1	\N
389	Temari[Shippuden]	Temari	wind	0	609	458	543	887	828	11001421	1	\N
445	Kakashi[Copy Ninja]	Kakashi	ltng	0	467	466	509	796	1045	11001601	1	\N
282	Shino[1 star]	Shino	earth	0	751	510	560	691	853	11001101	1	\N
333	Tenten[1 star]	Tenten	water	0	609	848	828	497	543	11000601	1	\N
401	Naruto[1 star]	Naruto	wind	0	1103	521	613	618	613	11000111	1	\N
452	Sakura[1 star]	Sakura	water	0	690	790	708	600	560	11000301	1	\N
\.


--
-- Name: characters_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('characters_sequence', 461, true);


--
-- Data for Name: characters_skills; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY characters_skills (id, id_character, id_skill) FROM stdin;
1	229	1
2	230	1
3	230	2
4	231	1
5	231	2
6	231	3
7	234	1
8	234	2
9	234	3
10	234	4
11	234	5
12	236	1
13	236	2
14	236	3
15	236	4
16	236	5
17	237	6
18	238	1
19	238	2
20	238	3
21	238	4
22	238	5
23	239	6
24	239	7
25	240	9
26	240	10
27	240	11
28	240	12
29	240	13
30	241	14
31	241	15
32	241	16
33	241	17
34	241	18
35	242	19
36	242	20
37	242	21
38	243	22
39	243	23
40	243	24
41	243	25
42	243	26
43	244	27
44	244	28
45	244	29
46	244	30
47	244	31
48	245	32
49	245	33
50	245	34
51	245	35
52	246	37
53	246	38
54	246	39
55	246	40
56	246	41
57	247	42
58	247	43
59	247	44
60	247	45
61	247	46
62	248	47
63	248	48
64	248	49
65	248	50
66	248	51
67	249	52
68	249	38
69	249	53
70	249	54
71	249	41
72	250	55
73	250	56
74	250	57
75	250	58
76	250	59
77	251	60
78	251	38
79	251	61
80	251	62
81	252	63
82	252	64
83	252	65
84	252	66
85	253	68
86	253	69
87	253	70
88	253	71
89	253	72
90	254	73
91	254	74
92	254	75
93	254	76
94	254	77
95	255	78
96	255	79
97	255	80
98	255	81
99	255	82
100	256	83
101	256	69
102	256	84
103	256	85
104	256	72
105	257	86
106	257	87
107	257	88
108	257	89
109	257	90
110	258	91
111	258	69
112	258	92
113	258	93
114	259	94
115	259	95
116	259	96
117	259	97
118	260	99
119	260	100
120	260	101
121	260	102
122	260	103
123	261	104
124	261	105
125	261	106
126	261	107
127	261	108
128	262	109
129	262	110
130	262	111
131	262	112
132	262	113
133	263	114
134	263	100
135	263	115
136	263	116
137	263	103
138	264	117
139	264	118
140	264	119
141	264	120
142	264	121
143	265	122
144	265	100
145	265	123
146	265	124
147	266	125
148	266	126
149	266	127
150	266	128
151	266	129
152	267	130
153	267	100
154	267	131
155	267	132
156	268	133
157	268	134
158	268	135
159	269	137
160	269	138
161	269	139
162	269	140
163	269	141
164	270	142
165	270	143
166	270	144
167	270	145
168	270	146
169	271	147
170	271	148
171	271	149
172	271	150
173	271	151
174	272	152
175	272	138
176	272	153
177	272	154
178	272	141
179	273	155
180	273	156
181	273	157
182	273	158
183	273	159
184	274	160
185	274	138
186	274	161
187	274	162
188	275	163
189	275	164
190	275	165
191	275	166
192	275	167
193	276	168
194	276	138
195	276	169
196	276	170
197	277	171
198	277	172
199	277	173
200	277	174
201	277	175
202	278	176
203	278	177
204	278	178
205	278	179
206	278	180
207	279	181
208	279	182
209	279	183
210	279	184
211	279	185
212	280	186
213	280	187
214	280	188
215	280	189
216	280	190
217	281	191
218	281	138
219	281	192
220	281	193
221	281	194
222	282	195
223	282	196
224	282	197
225	282	198
226	283	199
227	283	138
228	283	162
229	283	161
230	283	160
231	284	200
232	284	201
233	284	202
234	284	203
235	284	204
236	285	205
237	285	206
238	285	207
239	285	208
240	285	209
241	286	210
242	286	211
243	286	212
244	286	213
245	286	214
246	287	215
247	287	216
248	287	217
249	287	218
250	287	219
251	288	220
252	288	221
253	288	222
254	289	223
255	289	224
256	289	225
257	289	226
258	289	227
259	290	228
260	290	229
261	290	230
262	290	231
263	290	232
264	291	233
265	291	138
266	291	234
267	291	235
268	291	236
269	292	152
270	292	138
271	292	237
272	292	154
273	292	141
274	293	238
275	293	138
276	293	239
277	293	240
278	293	241
279	294	242
280	294	243
281	294	244
282	294	245
283	294	246
284	295	247
285	295	248
286	295	249
287	295	250
288	295	251
289	296	252
290	296	253
291	296	254
292	296	255
293	296	256
294	297	257
295	297	258
296	297	259
297	297	260
298	297	261
299	298	262
300	298	263
301	298	264
302	298	265
303	298	266
304	299	267
305	299	138
306	299	268
307	299	269
308	299	270
309	300	271
310	300	272
311	300	273
312	300	274
313	300	275
314	301	276
315	301	138
316	301	277
317	301	278
318	302	279
319	302	280
320	302	281
321	302	282
322	302	283
323	303	284
324	303	285
325	303	286
326	303	287
327	303	288
328	304	289
329	304	290
330	304	291
331	304	292
332	304	293
333	305	294
334	305	138
335	305	295
336	305	141
337	305	296
338	306	297
339	306	298
340	306	299
341	306	300
342	306	301
343	307	302
344	307	303
345	307	304
346	307	305
347	307	141
348	308	306
349	308	307
350	308	308
351	308	309
352	308	310
353	309	311
354	309	312
355	309	313
356	309	314
357	309	315
358	310	316
359	310	138
360	310	317
361	310	318
362	311	319
363	311	320
364	311	321
365	311	322
366	311	323
367	312	324
368	312	325
369	312	182
370	312	326
371	312	184
372	313	327
373	313	328
374	313	329
375	313	330
376	313	331
377	314	332
378	314	333
379	314	334
380	314	318
381	314	335
382	315	336
383	315	337
384	315	294
385	315	338
386	315	339
387	316	340
388	316	341
389	316	342
390	316	343
391	316	344
392	317	345
393	317	346
394	317	347
395	317	348
396	317	349
397	318	350
398	318	351
399	318	352
400	318	353
401	318	354
402	319	355
403	319	356
404	319	357
405	319	358
406	319	359
407	320	360
408	320	361
409	320	362
410	320	363
411	320	364
412	321	365
413	321	138
414	321	366
415	321	367
416	321	368
417	322	369
418	322	138
419	322	370
420	322	371
421	323	372
422	323	373
423	323	374
424	323	375
425	323	376
426	324	377
427	324	378
428	324	379
429	324	380
430	324	381
431	325	382
432	325	383
433	325	384
434	325	385
435	325	386
436	326	387
437	326	388
438	326	389
439	326	390
440	326	391
441	327	392
442	327	138
443	327	393
444	327	295
445	327	256
446	328	394
447	328	138
448	328	395
449	328	265
450	328	256
451	329	396
452	329	138
453	329	397
454	329	398
455	329	399
456	330	400
457	330	196
458	330	197
459	330	198
460	330	401
461	331	402
462	331	403
463	331	404
464	331	405
465	331	406
466	332	407
467	332	138
468	332	408
469	332	409
470	333	410
471	333	138
472	333	411
473	333	412
474	334	413
475	334	414
476	334	415
477	334	416
478	334	417
479	335	418
480	335	419
481	335	420
482	335	421
483	335	422
484	336	423
485	336	424
486	336	425
487	336	426
488	337	427
489	337	428
490	337	429
491	337	430
492	337	431
493	338	432
494	338	433
495	338	434
496	338	435
497	338	436
498	339	437
499	339	138
500	339	194
501	339	265
502	339	189
503	340	438
504	340	439
505	340	440
506	340	441
507	340	442
508	341	443
509	341	444
510	341	445
511	341	446
512	341	447
513	342	296
514	342	448
515	342	449
516	343	450
517	343	138
518	343	451
519	343	452
520	343	141
521	344	453
522	344	454
523	344	455
524	344	456
525	344	457
526	345	458
527	345	459
528	345	460
529	345	461
530	345	338
531	346	462
532	346	463
533	346	464
534	346	465
535	346	466
536	347	467
537	347	468
538	347	469
539	347	470
540	347	471
541	348	472
542	348	138
543	348	473
544	348	474
545	348	209
546	349	475
547	349	138
548	349	408
549	349	476
550	349	241
551	350	477
552	350	478
553	350	479
554	350	480
555	350	481
556	351	482
557	351	483
558	351	484
559	351	485
560	351	486
561	352	487
562	352	488
563	352	489
564	352	490
565	352	491
566	353	492
567	353	138
568	353	412
569	353	224
570	353	318
571	354	493
572	354	494
573	354	495
574	354	496
575	354	497
576	355	498
577	355	499
578	355	500
579	355	501
580	356	502
581	356	503
582	356	504
583	356	505
584	356	506
585	357	507
586	357	508
587	357	509
588	357	510
589	357	511
590	358	410
591	358	138
592	358	512
593	358	411
594	358	412
595	359	513
596	359	514
597	359	515
598	359	339
599	359	516
600	360	339
601	360	517
602	360	518
603	360	367
604	360	519
605	361	520
606	361	521
607	361	522
608	361	523
609	361	524
610	362	525
611	362	526
612	362	527
613	362	528
614	362	529
615	363	530
616	363	138
617	363	161
618	363	162
619	363	160
620	364	168
621	364	138
622	364	170
623	364	531
624	364	506
625	365	532
626	365	533
627	365	534
628	365	535
629	365	536
630	366	537
631	366	538
632	366	539
633	366	540
634	366	541
635	367	542
636	367	138
637	367	543
638	367	371
639	367	318
640	368	544
641	368	545
642	368	277
643	368	295
644	368	276
645	369	546
646	369	138
647	369	547
648	369	506
649	369	141
650	370	548
651	370	549
652	370	516
653	370	550
654	370	551
655	371	552
656	371	138
657	371	408
658	371	241
659	371	407
660	372	553
661	372	554
662	372	555
663	372	556
664	372	557
665	373	558
666	373	559
667	373	560
668	373	561
669	373	562
670	374	563
671	374	229
672	374	230
673	374	564
674	374	565
675	375	566
676	375	138
677	375	460
678	375	461
679	375	459
680	376	567
681	376	568
682	376	569
683	376	570
684	376	543
685	377	571
686	377	138
687	377	224
688	377	222
689	377	572
690	378	451
691	378	224
692	378	227
693	378	550
694	378	573
695	379	574
696	379	138
697	379	575
698	379	551
699	379	339
700	380	576
701	380	577
702	380	578
703	380	579
704	380	580
705	381	581
706	381	582
707	381	583
708	381	517
709	381	584
710	382	585
711	382	586
712	382	587
713	382	588
714	382	589
715	383	153
716	383	590
717	383	368
718	383	591
719	383	592
720	384	593
721	384	594
722	384	595
723	384	596
724	384	597
725	385	598
726	385	599
727	385	600
728	385	601
729	385	602
730	386	603
731	386	604
732	386	605
733	386	606
734	386	607
735	387	518
736	387	138
737	387	608
738	387	295
739	388	609
740	388	138
741	388	610
742	388	192
743	388	141
744	389	611
745	389	138
746	389	460
747	389	612
748	389	613
749	390	611
750	390	138
751	390	613
752	390	612
753	391	614
754	391	615
755	391	185
756	391	616
757	391	617
758	392	618
759	392	619
760	392	620
761	392	621
762	392	622
763	393	623
764	393	624
765	393	625
766	393	626
767	393	627
768	394	628
769	394	138
770	394	575
771	394	551
772	395	629
773	395	630
774	395	631
775	395	632
776	395	633
777	396	634
778	396	635
779	396	636
780	396	637
781	396	638
782	397	639
783	397	640
784	397	641
785	397	642
786	397	643
787	398	644
788	398	138
789	398	183
790	398	542
791	398	141
792	399	645
793	399	138
794	399	193
795	399	646
796	399	194
797	400	647
798	400	648
799	400	295
800	400	649
801	400	650
802	401	504
803	401	138
804	401	651
805	401	505
806	402	316
807	402	224
808	402	317
809	402	318
810	402	652
811	403	653
812	403	138
813	403	157
814	403	460
815	404	654
816	404	138
817	404	655
818	404	656
819	404	409
820	405	657
821	405	658
822	405	659
823	405	660
824	406	661
825	406	662
826	406	663
827	406	664
828	406	665
829	407	666
830	407	138
831	407	192
832	407	193
833	407	667
834	408	668
835	408	138
836	408	669
837	408	547
838	408	670
839	409	671
840	409	672
841	409	673
842	409	674
843	409	675
844	410	676
845	410	677
846	410	678
847	410	679
848	410	680
849	411	681
850	411	682
851	411	683
852	411	684
853	411	685
854	412	686
855	412	687
856	412	688
857	412	689
858	412	690
859	413	691
860	413	692
861	413	693
862	413	694
863	413	695
864	414	696
865	414	697
866	414	698
867	414	699
868	414	700
869	415	701
870	415	702
871	415	669
872	415	547
873	415	670
874	416	703
875	416	704
876	416	705
877	416	706
878	416	707
879	417	708
880	417	709
881	417	710
882	417	711
883	417	712
884	418	276
885	418	506
886	418	277
887	418	278
888	418	545
889	419	713
890	419	714
891	419	715
892	419	716
893	419	717
894	420	718
895	420	719
896	420	720
897	420	721
898	420	722
899	421	723
900	421	138
901	421	724
902	421	725
903	421	256
904	422	726
905	422	727
906	422	728
907	422	729
908	422	669
909	423	730
910	423	138
911	423	222
912	423	452
913	424	731
914	424	732
915	424	193
916	424	227
917	424	667
918	425	733
919	425	734
920	425	735
921	425	736
922	425	737
923	426	738
924	426	138
925	426	398
926	426	400
927	427	739
928	427	740
929	427	741
930	427	742
931	428	743
932	428	744
933	428	745
934	428	746
935	428	747
936	429	748
937	429	749
938	429	750
939	429	751
940	429	752
941	430	753
942	430	138
943	430	503
944	430	505
945	430	506
946	431	754
947	431	755
948	431	756
949	431	757
950	431	758
951	432	759
952	432	760
953	432	761
954	432	762
955	432	763
956	433	764
957	433	224
958	433	225
959	433	765
960	433	655
961	434	766
962	434	767
963	434	768
964	434	769
965	434	770
966	435	771
967	435	772
968	435	773
969	435	774
970	435	775
971	436	776
972	436	138
973	436	239
974	436	240
975	437	777
976	437	138
977	437	778
978	437	209
979	437	503
980	438	779
981	438	138
982	438	780
983	438	781
984	438	551
985	439	782
986	439	783
987	439	784
988	439	785
989	439	786
990	440	787
991	440	788
992	440	789
993	440	790
994	440	791
995	441	792
996	441	138
997	441	778
998	442	793
999	442	794
1000	442	795
1001	442	796
1002	442	797
1003	443	798
1004	443	799
1005	443	800
1006	443	801
1007	443	802
1008	444	803
1009	444	804
1010	444	805
1011	444	806
1012	444	807
1013	445	808
1014	445	809
1015	445	667
1016	445	157
1017	445	189
1018	446	810
1019	446	224
1020	446	811
1021	446	669
1022	446	256
1023	447	812
1024	447	813
1025	447	814
1026	447	815
1027	447	816
1028	448	817
1029	448	818
1030	448	819
1031	448	820
1032	448	821
1033	449	822
1034	449	823
1035	449	824
1036	449	613
1037	449	401
1038	450	825
1039	450	334
1040	450	826
1041	450	827
1042	450	828
1043	451	829
1044	451	830
1045	451	831
1046	451	832
1047	451	833
1048	452	731
1049	452	138
1050	452	512
1051	452	318
1052	453	834
1053	453	835
1054	453	836
1055	453	837
1056	453	838
1057	454	839
1058	454	840
1059	454	841
1060	454	842
1061	454	843
1062	455	844
1063	455	138
1064	455	731
1065	455	573
1066	455	550
1067	456	590
1068	456	845
1069	456	846
1070	456	847
1071	456	848
1072	457	849
1073	457	850
1074	457	851
1075	457	852
1076	457	853
1077	458	854
1078	458	855
1079	458	856
1080	458	857
1081	458	858
1082	459	170
1083	459	138
1084	459	370
1085	459	859
1086	459	860
1087	461	864
1088	460	861
1089	460	862
1090	460	863
\.


--
-- Name: characters_skills_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('characters_skills_sequence', 1090, true);


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY skills (id, id_type, name, chase_status, hurt_status, hurt_num, pic_url, id_json) FROM stdin;
137	1	\N			1	NarutoBeta1.0Build300	21002804
138	3	\N		low_float	1	NarutoBeta1.0Build300	20000101
139	2	\N	knockdown	low_float ignition	0	NarutoBeta1.0Build300	21002805
140	4	\N			0	NarutoBeta1.0Build300	21002806
141	4	\N			0	NarutoBeta1.0Build300	21000230
142	1	\N		ignition	3	NarutoBeta2.61Build300	21011207
143	3	\N		repulse	3	201607m2.c5b1f0fe41b7444179e1bbc104ce94c4	21011201
144	2	\N	knockdown	repulse ignition	1	201607m2.5542b9214d99a660702cde8a2574817b	21011204
145	4	\N			0	201607m2.fe4346b4b3d9a4e09d5c54a702b92ab6	21011205
146	4	\N			0	NarutoBeta2.61Build300	21011206
147	1	\N		low_float ignition	4	NarutoBeta1.17Build300	21206907
148	3	\N		knockdown acupuncture	3	201503m2.9aca7df364ae387c6a06bb905e292453	21006903
149	4	\N			0	201503m2.55773f4dd6170f64cde7c3a26ff9ba7a	21006904
150	3	\N		poisoning	0	201503m2.71e7957fe137ba344d3fa292212c690c	21006910
151	2	\N	knockdown	low_float immobile	1	NarutoBeta1.17Build300	21006906
152	1	\N		high_float	2	NarutoBeta1.0Build300	21002507
153	2	\N	high_float	repulse	2	NarutoBeta1.0Build300	21004304
154	4	\N			0	NarutoBeta1.0Build300	21002505
155	1	\N		ignition	2	201607m3.8caf50819e7ffba731133a6fa3a60d94	20000210
156	3	\N		low_float ignition	3	201501m3.8a1fedd141cd16626458501f1c777b04	20000203
157	2	\N	high_float	low_float ignition	1	NarutoBeta1.0Build300	20000216
158	3	\N			0	201512m2.a3b1f4333a9bce5a962a86ae22149fcf	20000213
159	4	\N			0	201501m3.f4a40735b3b39fa5c1801492cf1c7adb	20000240
160	1	\N		repulse	5	NarutoBeta1.0Build300	21001004
161	4	\N		knockdown	0	NarutoBeta1.0Build300	21001005
162	4	\N			0	NarutoBeta1.0Build300	21001006
163	1	\N		poisoning	1	NarutoBeta1.17Build300	21006807
164	3	\N		high_combo poisoning	10	201502m2.56dbe34e7f23e8d1e1e241ea2557f493	21006803
165	4	\N			0	NarutoBeta1.17Build300	21006804
166	2	\N	knockdown	knockdown immobile ignition	1	201502m2.9429df22af38122797170c4174da5835	21006805
167	2	\N	-	poisoning	3	201502m2.7013930914fc3b85bc3abda659c53804	21006806
168	1	\N			0	NarutoBeta1.0Build300	21001204
169	2	\N	repulse	acupuncture	1	NarutoBeta1.0Build300	21001205
170	2	\N	knockdown		2	NarutoBeta1.0Build300	21000517
171	1	\N		repulse acupuncture high_combo	16	201606m3.dbdfb41e0c04832155764fb01de205b2	21001237
172	3	\N		knockdown	3	201606m3.60a030a6e7b6c3257675ef853853f7ce	21001231
173	2	\N	knockdown	knockdown	1	201606m3.c438bd7b06eaddefcc4449882e3b5765	21001234
174	2	\N	30combo	high_combo	3	201606m3.06515f920da89e11efc924b7878b0d8d	21001235
175	4	\N			0	201606m3.671701e379b4060c2f31b9fd87348278	21001236
176	1	\N		high_float ignition 	4	201601m3.7e29fc18b210719056669e2a32335151	21001537
177	3	\N		low_float	1	201502m2.555661e573ea55b9567ae41cd97d0cb2	21001533
178	2	\N	knockdown	low_float	1	201502m2.c72aa2aecc83c302e658c55f1a040fad	21001534
179	4	\N		low_float ignition	2	201505m1.140692dec88d0672cc063581d01b363f	21001536
180	4	\N			0	201601m3.3ec3ae3b997f20001ae2aa0c6c8ff060	21001535
181	1	\N		repulse ignition	2	201601m3.ed59918426fbc2e69cc01e0a76969c1d	21002217
182	3	\N		repulse	1	NarutoBeta1.0Build300	20000312
183	2	\N	repulse	low_float	1	NarutoBeta1.0Build300	21002905
184	4	\N			0	NarutoBeta1.2Build300	21000176
185	2	\N	knockdown	low_float	3	NarutoBeta1.0Build300	21002205
186	1	\N		knockdown 	1	201601m3.5c360df003e8958bc61a5a99e617fd7e	21104407
187	3	\N		low_float 	10	NarutoBeta1.0Build300	20000318
188	4	\N			1	NarutoBeta1.0Build300	21004404
189	2	\N	low_float	knockdown 	2	NarutoBeta1.0Build300	20000411
190	4	\N			0	NarutoBeta1.0Build300	21004406
191	1	\N		immobile	1	NarutoBeta1.0Build300	21001704
192	4	\N			0	NarutoBeta1.0Build300	21001705
193	2	\N	low_float	repulse	1	NarutoBeta1.0Build300	20000116
194	4	\N			0	NarutoBeta1.0Build300	20000415
195	1	\N		knockdown	5	NarutoBeta1.0Build300	21001104
196	3	\N			3	NarutoBeta1.0Build300	21001103
197	4	\N			0	NarutoBeta1.0Build300	21001105
198	4	\N			2	NarutoBeta1.0Build300	21001106
199	1	\N		repulse	2	201511m3.5cf3add5a3ad317b190586e9b25351a8	21001007
200	1	\N		ignition repulse	5	201510m1.fd39d9b5135406242508ce132ac7d0c4	21000164
201	3	\N		low_float ignition	1	201510m1.3a6565f80acc3a0b7b1282e5786532d9	21000161
202	4	\N		ignition	0	201510m1.2b6110f1f48feddf1db28c2608bb4871	21000165
203	4	\N			0	201510m1.513b8b46d7b7ae6dd8ab71ac2de16107	21000166
204	4	\N			0	201510m1.b99ce298bccace7e7cd2f97dd2fb62d9	21000168
205	1	\N		knockdown	3	NarutoBeta1.0Build300	21005018
206	3	\N		high_float	3	NarutoBeta1.0Build300	21005013
207	2	\N	knockdown	high_float	2	NarutoBeta1.0Build300	21005015
208	2	\N	high_float	repulse	2	NarutoBeta1.0Build300	21005016
209	4	\N	knockdown	knockdown	0	NarutoBeta1.0Build300	20000219
210	1	\N		knockdown	1	NarutoBeta2.17Build302	21009407
211	3	\N		high_combo	10	NarutoBeta2.17Build302	21009401
212	2	\N	20combo	poisoning	1	NarutoBeta2.17Build302	21009406
213	2	\N	knockdown	repulse	1	201509m1.58acbcdbf93b5a5b8dce6eddbae2aa69	21009405
214	4	\N			0	201509m1.1b09658056e81281747af4594695d41e	21009404
215	1	\N		chaos	1	201503m2.de97a7ef8db7559ece7badc3132e00e3	21007707
216	3	\N		low_float	5	201503m2.126372c1d2bcd2dd08464c83e7d70a56	21007703
217	3	\N			0	201503m2.7053a8b360bf31b509e4b37ba4ad5add	21007704
218	4	\N		chaos	0	NarutoBeta1.21Build300	21007705
219	3	\N			0	201503m2.3ecbd5e961fd45fe679fa9b7eec70aa6	21007706
220	1	\N		high_float	1	NarutoBeta1.0Build300	23000204
221	3	\N		high_float	1	201501m3.7dac6f026e7ff3e6c87062c38414479f	21004601
222	2	\N	low_float	repulse	1	NarutoBeta1.0Build300	21000206
223	1	\N		poisoning	0	NarutoBeta1.0Build300	20000111
224	4	\N			0	NarutoBeta1.0Build300	20000104
225	2	\N	knockdown	high_float	1	NarutoBeta1.0Build300	20000118
226	4	\N			1	NarutoBeta1.0Build300	21004206
227	4	\N			0	NarutoBeta1.0Build300	20000115
228	1	\N			2	NarutoBeta1.0Build300	21001304
229	3	\N		high_float	3	NarutoBeta1.0Build300	21001303
230	4	\N			0	NarutoBeta1.0Build300	20000215
231	2	\N	high_float		1	NarutoBeta1.0Build300	21001307
232	4	\N			0	NarutoBeta1.0Build300	21001306
233	1	\N			0	201512m1.ec6321ffec3945da578bc214684661a4	21005008
234	2	\N	high_float	low_float	2	NarutoBeta1.0Build300	21005007
235	4	\N		low_float poisoning	3	NarutoBeta1.0Build300	21005005
236	4	\N			0	NarutoBeta1.0Build300	21005004
237	2	\N	high_float	repulse	1	NarutoBeta1.0Build300	21002604
238	1	\N		low_float	0	NarutoBeta1.0Build300	21001804
239	4	\N			0	NarutoBeta1.0Build300	20000221
240	2	\N	repulse	low_float	2	NarutoBeta1.0Build300	21001806
241	4	\N			0	NarutoBeta1.0Build300	21000425
242	1	\N			1	201607m2.9c531ed898443083e4fb7d87c2d3f7d8	21011507
243	3	\N		low_float 	3	201607m2.d0e16603fe43927ac65b9b8fd91efd48	21011501
244	2	\N	10combo		1	201607m2.b67d44aada7fdc9ec74cc8391daa9b4b	21011504
245	4	\N			0	201607m2.526619110826e0cc2fbbbce410803d05	21011505
246	4	\N			0	NarutoBeta2.61Build300	21011506
247	1	\N		poisoning	9	201503m2.26b0f96fc1163d1c3e15b2dfc892c7e0	21007807
248	3	\N		repulse	3	201503m2.dfd8ef594605a9499e2fe4c0d14a168c	21007803
249	2	\N	repulse	low_float poisoning	1	201503m2.38d72b69d54635fbe006222c9a43868d	21007804
250	3	\N			0	201503m2.8ba1e52caae20a09b451e62fdfe59a1d	21007805
251	4	\N		poisoning	0	201503m2.40e91b464a24e5d7e7282a3fc498fb87	21007806
252	1	\N			0	NarutoBeta1.0Build305	21005807
253	3	\N			0	201501m3.c9fb89a6397a6e205d10690cfe234583	21005801
254	2	\N	-		3	NarutoBeta1.0Build305	21005804
255	4	\N			0	NarutoBeta1.0Build305	21005805
256	4	\N			0	NarutoBeta1.2Build300	21005806
257	1	\N			0	NarutoBeta2.13Build301	21009107
258	3	\N		low_float	7	201508m1.7e020631ddce77e67b6f97449782e23c	21009101
259	2	\N	knockdown	low_float	1	NarutoBeta2.13Build301	21009104
260	2	\N	-	5combo	5	201508m1.39c62319ebe525f9556e170c3cb9b9f3	21009105
261	4	\N			0	201508m1.60d1b13cfb09a03ae702211467941761	21009106
262	1	\N			0	NarutoBeta1.0Build300	21003104
263	3	\N		high_float 	3	NarutoBeta1.0Build300	21003103
264	4	\N			0	NarutoBeta1.0Build300	21003105
265	4	\N			0	NarutoBeta1.0Build300	21003106
266	2	\N	high_float	low_float ignition	10	NarutoBeta1.0Build300	21003108
267	1	\N		knockdown	4	NarutoBeta1.0Build305	21006507
268	2	\N	knockdown	knockdown acupuncture	2	NarutoBeta1.2Build300	21006504
269	4	\N			0	NarutoBeta2.17Build302	21006505
270	2	\N	repulse	knockdown	1	NarutoBeta1.0Build305	21006506
271	1	\N		knockdown	1	201503m2.c033d940de4c0bedfe3cca4e3bfb9e8f	21008407
272	3	\N			0	201503m2.24b227db88e9d1e11ab090af06d4da5e	21008403
273	3	\N			0	201503m2.21cb08c26a9ad5191e1e7dc45828240c	21008404
274	2	\N	knockdown	knockdown	1	201503m2.08a1c39f764691ebb802f9cec912820e	21008405
275	3	\N			0	NarutoBeta1.21Build300	21008406
276	2	\N	low_float	knockdown	7	NarutoBeta1.0Build300	21000904
277	4	\N			0	NarutoBeta1.0Build300	21000905
278	4	\N			0	NarutoBeta1.0Build300	21000906
279	1	\N			1	201510m3.351ee4e1d858a79b400fc36946174636	21008707
280	3	\N		knockdown	1	201510m3.973347636c76c7aeab47ffe2dbbe026f	21008701
281	4	\N			0	201510m3.9addc90184ed6653669c9582f8b19752	21008704
282	2	\N	repulse	knockdown immobile	1	201510m3.6fca1a101c31924e87c3a788e8c2c5ff	21008706
283	4	\N			0	201510m3.dfdc52e7c9ec21c3bacd41d21341fb4e	21008705
284	1	\N		ignition knockdown	4	NarutoBeta2.61Build300	21010809
285	3	\N		low_float	3	201607m2.6e3c2b8e88597f027a66d7127a4dbc7d	21010801
286	2	\N	knockdown	low_float ignition immobile	1	NarutoBeta2.61Build300	21010804
287	4	\N			0	201607m2.7dbb1a88f344f0edfc25edabd26ef157	21010805
288	4	\N			0	201607m2.13b223eaf9e4e4a9a281884a6d75e11f	21010807
289	1	\N			3	201509m3.c976fd75b6f1ded26a15263f48b2445b	21001227
290	3	\N		repulse	3	201509m3.18e5c0b1adbb63fb0f3e6fb0d7650f3f	21001223
291	2	\N	repulse	acupuncture knockdown	1	201509m3.9e2d9ca6aa2ca1391827a036238d4fdf	21001224
292	2	\N	knockdown	knockdown	1	201509m3.48bee07a1b3cfaef6becb5ef8ff8197f	21001225
293	4	\N			0	201510m3.b3146eb999f45913ee08bc2f8c817d08	21001226
294	2	\N	knockdown	low_float	0	NarutoBeta1.0Build300	20000517
295	4	\N			0	NarutoBeta1.0Build300	20000113
296	2	\N	repulse	knockdown	2	NarutoBeta1.0Build300	20000519
297	1	\N		immobile knockdown	4	NarutoBeta2.61Build300	21011307
298	3	\N		repulse	1	201607m2.4d5eef3096735166af3b7e8e1118fd83	21011301
299	2	\N	repulse	knockdown	1	201607m2.2b953262a2b79d6bd513b4a4dbed5a28	21011304
300	4	\N			0	201607m2.be35d820ac0b589fc95ef97a77e16721	21011305
301	4	\N			0	NarutoBeta2.61Build300	21011306
302	1	\N			0	NarutoBeta1.0Build300	21003007
303	3	\N			3	NarutoBeta1.0Build300	21003003
304	4	\N			0	NarutoBeta1.0Build300	21003004
305	2	\N	low_float	high_float	2	NarutoBeta1.0Build300	20000204
306	1	\N		5combo	5	201512m1.b2fc25c763f69e5e8e778e01da6a4832	21010108
307	3	\N		high_float	2	201512m1.e8cd4859ce63d848d1cabec9509fbb25	21010101
308	2	\N	low_float	knockdown immobile	1	NarutoBeta2.31Build300	21010104
309	4	\N			0	NarutoBeta2.31Build300	21010105
310	4	\N		ignition	0	201512m1.21c1db4ee12cf358f7dc03014bfc8b82	21010106
311	1	\N		knockdown	4	NarutoBeta1.17Build300	21007407
312	3	\N		knockdown	1	201503m2.a6fd4b0e67a2c802bbd695efce68f031	21007403
313	3	\N			0	201503m2.43905886676dda55a25233c657e31a32	21007404
314	4	\N			0	201503m2.0a6783fdbd983388acc9351fc00fc77a	21007405
315	2	\N	knockdown	knockdown	1	201503m2.902fae4d344ce99fae0b775bb04977aa	21007406
316	1	\N		chaos	1	NarutoBeta1.0Build300	21000704
317	2	\N	immobile 	chaos	1	NarutoBeta1.0Build300	21000705
318	4	\N			0	NarutoBeta1.0Build300	21000306
319	1	\N			2	NarutoBeta2.44Build300	21005437
320	3	\N		repulse	1	201603m3.b4c70b48c92a74f5f2e3587c97b72f9f	21005431
321	2	\N	20combo		2	201603m3.b5f3a87c3fee705f467703c43bcc49ca	21005434
322	4	\N			0	201603m3.42d1832b67df24d2af9f7e86b5e3de69	21005435
323	4	\N			0	201603m3.f2c4524829a5902790caebf5f652ef04	21005436
324	1	\N		high_combo repulse	10	NarutoBeta1.2Build300	21000177
325	3	\N		low_float	0	NarutoBeta1.2Build300	21000171
326	2	\N	repulse	knockdown	1	NarutoBeta1.0Build300	20000317
327	1	\N			1	NarutoBeta2.43Build300	21009808
328	3	\N		knockdown	3	201603m1.96ad1944e2516338236afb6d008d8442	21009801
329	2	\N	knockdown	low_float	1	201603m1.aad331c5e4ace1dbc2ca0c29a2fee976	21009804
330	4	\N			0	201603m1.2a09233049b1c22edcb1db8a696d6f1c	21009805
331	4	\N			0	201603m1.1ab9e807b6a722b21649c255e26d2875	21009806
332	1	\N			0	NarutoBeta1.0Build300	21004807
333	3	\N		poisoning	0	NarutoBeta1.0Build300	21004801
334	4	\N			0	NarutoBeta1.0Build300	21004805
335	2	\N	-		2	NarutoBeta1.0Build300	21004804
336	1	\N		knockdown	1	NarutoBeta1.0Build300	20000502
337	3	\N		high_float	5	201501m3.591e31c6cba248bfe728d9bc3ade8d5f	20000507
338	4	\N			0	NarutoBeta1.0Build300	20000515
339	4	\N			0	NarutoBeta1.0Build300	20000520
340	1	\N		high_float	1	NarutoBeta2.13Build301	21009007
341	3	\N		high_combo	10	201507m3.8de75bf081d592e1e9444c4b918af4ec	21009001
342	2	\N	20combo	high_combo	5	201507m3.6c35a2782f682a1dcdd453598be9e688	21009004
343	4	\N			0	201507m3.5dccde3fb646ea4f6a6a1d02a6525ba9	21009005
344	4	\N			0	201507m3.c3805f16150ce2aaebd59b60061a79a1	21009006
345	1	\N			7	NarutoBeta2.17Build302	21009507
346	3	\N			1	201509m1.20fa8debb1c028ca813fb60fb679b911	21009501
347	2	\N	high_float	knockdown	1	201509m1.a0fa282835833e759fcd0274ab04b845	21009504
348	4	\N			0	201509m1.83ffee95ad39108483a2544134d3c95d	21009506
349	4	\N			0	201509m1.15941900d9507079e1bc02a4bc3b1b16	21009505
350	1	\N			0	NarutoBeta2.61Build300	21011407
351	3	\N		low_float	1	201607m2.cf934b4f24517b5df236285c27446302	21011401
352	2	\N	repulse	knockdown	1	201607m2.a25bac164ab27046877b2cd9022f38b8	21011404
353	4	\N			0	201607m2.85fdd07c6c60bf13cc7ee1819850e483	21011405
354	4	\N			0	201607m2.8706eff84d7f1e3ae781ad4533178235	21011406
355	1	\N		immobile	1	NarutoBeta2.31Build300	21010207
356	3	\N		repulse acupuncture	2	201512m1.bfa4bd4ed9c1cf8143d64e277490805f	21010201
357	2	\N	knockdown	low_float acupuncture	1	NarutoBeta2.31Build300	21010204
358	4	\N			0	201512m1.fed83928e597f406b2bd4033fe410a9d	21010205
359	4	\N			0	201512m1.c806845bfb38b447ba8d16e5d2541e5c	21010206
360	1	\N			4	NarutoBeta1.21Build300	21008107
361	3	\N			0	201503m2.1672ff000ea0d0c4c8bfb1b2c2bb8267	21008103
362	2	\N	repulse	low_float	1	201503m2.226d923434633465eefc9464ad023b51	21008104
363	2	\N	-	high_combo	10	201503m2.c8ae6847ccf4b3040c5da053cb200f9a	21008105
364	4	\N			0	201503m2.57777c17e83b8d3a93975053260e16fa	21008106
365	1	\N		knockdown high_combo	10	NarutoBeta1.0Build300	21003404
366	2	\N	high_float	repulse	1	NarutoBeta1.0Build300	21003405
367	4	\N			0	NarutoBeta1.0Build300	21000826
368	4	\N			1	NarutoBeta1.0Build300	21003407
369	1	\N		repulse acupuncture	4	NarutoBeta1.0Build300	21000504
370	4	\N			2	NarutoBeta1.0Build300	21000505
371	4	\N			0	NarutoBeta1.0Build300	21000506
372	1	\N		chaos	0	201602m3.67924ac715bc2721cd49e7d9edc21764	21008807
373	3	\N			4	201602m3.d87d5416705d797103fc7052131a7450	21008801
374	2	\N	immobile 	chaos	3	201602m3.414860b7008a01ef7f30fc265280b1a4	21008804
375	4	\N			1	201602m3.4446f389319a093819d3b14e21e4b62f	21008805
376	4	\N			0	201602m3.23c6f4cf918f00cf12f9e2442ff27cb2	21008806
377	1	\N			6	201602m1.89083c611d11f61207d0f4a37b0bcd73	21004429
378	3	\N		knockdown 6combo	6	201602m1.11aeb5df922c5533d128a1d8f06d4f5b	21004421
379	2	\N	knockdown	repulse	1	201602m1.d439e9850fa749e130817e88efadbdc4	21004425
380	4	\N			0	201602m1.57fb46ee67fffe7cb7f5e610a02d18f2	21004426
381	4	\N			0	201602m1.0e4125787a63664df31ff729b509439b	21004427
382	1	\N		4combo repulse	4	201511m1.f470154eaf2b27fe918d1be1ac8c09c8	21009607
383	3	\N		knockdown chaos	1	201511m1.aa926ef3bb3c41a0ca899fe566173652	21009601
384	2	\N	10combo		1	201511m1.833d67d20673836debac8b0ccaa8dc25	21009604
385	2	\N	repulse	knockdown ignition	1	201511m1.56a306db93048779ea8474a3948f56e2	21009606
386	4	\N			0	201511m1.d8d2741b1a6c2454c3c6c1f983ca84f8	21009605
387	1	\N			3	201503m2.abf4350e6224525a87931bf8eabf5dd5	21007007
388	3	\N		high_float 	3	201503m2.d2be123e6b6bb450ea74ec79ee67db95	21007003
389	3	\N		high_float	0	NarutoBeta1.15Build301	21007004
390	4	\N			0	201503m2.5770d04d734eb7e7c0dafb9cc3f282f8	21007005
391	2	\N	high_float	knockdown 	1	201503m2.ebc8112ccf981affcc060c341492f580	21007006
392	1	\N			0	201512m2.1d1f8bba77da3ec6eab8e5652c6fdf1e	21006407
393	2	\N	knockdown	low_float	2	NarutoBeta1.0Build300	23000108
394	1	\N		knockdown chaos	2	NarutoBeta1.0Build305	21005908
395	2	\N	repulse	knockdown immobile	2	NarutoBeta1.0Build305	21005904
396	1	\N		high_float poisoning	4	NarutoBeta1.0Build300	21001529
397	2	\N	knockdown	low_float	2	NarutoBeta1.0Build300	21001524
398	4	\N		low_float poisoning	2	NarutoBeta1.0Build300	21001506
399	4	\N			0	201601m3.b4b78966f494b5928ccb98337adfdb86	21001504
400	1	\N		knockdown	4	NarutoBeta1.0Build300	21001114
401	4	\N			0	NarutoBeta1.0Build300	20000423
402	1	\N		knockdown	1	NarutoBeta2.17Build302	21009307
403	3	\N		knockdown	1	201509m1.0de500d7a9752f4e753ec25eaae10c27	21009301
404	4	\N			0	NarutoBeta2.17Build302	21009304
405	2	\N	low_float	knockdown	1	201509m1.eb4f3def3ca053d265499642f5e52134	21009305
406	4	\N			0	201509m1.504ab49239dec9266b16ca58761faa08	21009306
407	4	\N			0	NarutoBeta1.0Build300	21000404
408	2	\N	high_float	knockdown	2	NarutoBeta1.0Build300	20000518
409	4	\N			0	NarutoBeta1.0Build300	21000406
410	1	\N		high_combo	10	NarutoBeta1.0Build300	21000604
411	2	\N	-		2	NarutoBeta1.0Build300	21000605
412	2	\N	repulse	high_float	2	NarutoBeta1.0Build300	21000324
413	1	\N		acupuncture	2	201503m2.82a731828dbea8443a5f389feb5ab27c	21008008
414	3	\N		low_float	3	201503m2.33904ba79226ddff3a71922b9230e4c6	21008003
415	2	\N	knockdown	repulse acupuncture	1	201503m2.4c239668a03c8e3166c09ec01c221c3e	21008004
416	3	\N			0	201503m2.504101a988a929927d894b79d17faaa6	21008005
417	3	\N			0	NarutoBeta1.21Build300	21008006
418	1	\N		knockdown	1	NarutoBeta1.0Build300	21002404
419	3	\N		high_float	1	201505m1.c2cd96de8ab2ce36506731db869ee1fc	21002401
420	4	\N			0	201505m1.accc50d306eb642e95d1e3ade177a701	21002405
421	3	\N			0	NarutoBeta1.0Build300	21002406
422	4	\N			1	NarutoBeta1.0Build300	21002407
423	1	\N			3	201502m2.8540901a1f06917d0802205af37a60b7	21007606
424	3	\N		high_float	3	201502m2.daf85b3913e14157eecbf986ffcf1379	21007603
425	2	\N	repulse	high_float	1	201502m2.4aa68d81cf7dc3da489c2b04e5f6029a	21007604
426	4	\N		high_float	0	201502m2.045904fe94ad734b003f4214214e406c	21007605
427	1	\N		chaos	1	201507m1.32937ac710b15f6964f33aa933bb60b0	21000737
428	3	\N			0	201507m1.af28d269d1be9294f1fcc58e7136ed6b	21000731
429	2	\N	immobile 	chaos	1	201507m1.36a7df344f46fa6c398cc8fb6cfb363f	21000734
430	4	\N			0	201507m1.d9a83fe72d47dc7bb1145e301044f2c3	21000735
431	4	\N			0	201507m1.d0caf7839ff97abd1212645e49a91a2c	21000736
432	1	\N			0	NarutoBeta2.61Build300	21011613
433	3	\N			0	201607m2.d0921d15c2742a28493b2db92db8b1c6	21011601
434	2	\N	20combo	poisoning	4	NarutoBeta2.61Build300	21011606
435	4	\N			0	NarutoBeta2.61Build300	21011607
436	4	\N			0	201607m2.f42383f1c84a9e233681fbc42f4c032c	21011611
437	1	\N		knockdown	0	NarutoBeta1.15Build301	21001644
438	1	\N			1	NarutoBeta2.17Build302	21001437
439	3	\N		high_float	10	201508m3.bf10d92c57e83bf942e1eb38ffad3cd7	21001431
440	2	\N	low_float	repulse	1	201508m3.efa14595990d06af65a1326ecdc66d0c	21001434
441	4	\N			0	201508m3.ed3a565b99998ecbf4248897f7674990	21001435
442	2	\N	20	5	5	201508m3.3672891bf14c83a7240a2509261c901a	21001436
443	1	\N			1	201504m3.f9b118f9dad986b1617a543b1fba15c4	21003618
444	3	\N		low_float	3	201504m3.74b78393e84b9fb28d1187240e081a23	21003611
445	4	\N			0	201504m3.109e3cffd2c5d0f8efba87e5138e5849	21003614
446	4	\N			0	201504m3.4db860c66bdabc3e611236c790c5552a	21003615
447	2	\N			1	201504m3.15449a4fed604432d1e97c95ab6881e7	21003617
448	3	\N		low_float	1	201501m3.b5c55e9cf274258aa2289169197734b1	21004701
449	2	\N	high_float		1	NarutoBeta1.0Build300	21003604
450	1	\N		knockdown	1	NarutoBeta1.0Build300	21000224
451	1	\N		low_float	1	NarutoBeta1.0Build300	21000226
452	2	\N	-		2	NarutoBeta1.0Build300	20000217
453	1	\N		immobile	1	201609m2.30f5138c1331f6c8e84e7bf52de00e5b	21000848
454	3	\N		knockdown immobile	2	201609m2.9fa1b18336535afa8d634450fd47d75d	21000841
455	2	\N	repulse	knockdown immobile	1	201609m2.e921e40b760b756e9b63fc1de1b3f388	21000844
456	4	\N			0	201609m2.06d911731dbf32985d09e837fe0d3126	21000845
457	4	\N			0	201609m2.be4943d0d1175b6b58f83d0dedefced7	21000846
458	1	\N		knockdown	1	201601m3.cd41308c0a693a449ee9ca14fe7164a2	21003918
459	4	\N			0	NarutoBeta1.0Build300	21003907
460	4	\N			0	NarutoBeta1.0Build300	20000313
461	2	\N	repulse	knockdown blindness	1	NarutoBeta1.0Build300	21003906
462	1	\N		blindness	1	NarutoBeta1.21Build300	21008307
463	3	\N		knockdown blindness	1	201503m2.d327112a5688c54a6c83702925a116fc	21008303
464	3	\N			0	201503m2.c16af5fc5f27adbd9ba418e5b5202928	21008304
465	4	\N			0	201503m2.c73c69e0e87308e9e8fc7fc77e6ab6ed	21008305
466	4	\N			0	201503m2.ad03679a45140b56f09e058d5283b46c	21008306
467	1	\N			2	201504m1.4e615ab9a0bf30df00387f30aa5d1be1	29004714
468	3	\N		high_float	2	201504m1.4f99bd4cb76d83cb3aa7a5d4f698bdd1	29004711
469	3	\N			0	201504m1.7725251754c78386ba3f8c54db996e9c	29004716
470	4	\N		poisoning	0	201504m1.186cf231776f4e519950cbff6e0f5102	29004717
471	4	\N			0	201504m1.43a86beb1e42cb1cb27ad25ce6287b4d	29004715
472	1	\N			0	NarutoBeta1.0Build300	21005607
473	2	\N	knockdown	repulse	2	NarutoBeta1.0Build300	21005604
474	4	\N		high_float	2	NarutoBeta1.0Build300	21005605
475	1	\N			0	201512m1.718e82b7d24e3190b25db8e0274b922f	21000420
476	4	\N			0	201512m1.6c19fbf796a329dc784fc9146eb8a6a6	21000418
477	1	\N		knockdown immobile	1	NarutoBeta2.31Build300	21010507
478	3	\N		low_float immobile	1	NarutoBeta2.31Build300	21010501
479	2	\N		high_float	1	NarutoBeta2.31Build300	21010504
480	2	\N	20combo		4	NarutoBeta2.31Build300	21010505
481	4	\N			0	201512m1.45354192910d9626b16f0574570d10d6	21010506
482	1	\N		low_float 	1	NarutoBeta2.61Build300	21011107
483	3	\N		knockdown	3	201607m2.137a3e5091cfc23f7adfbaf6095ecae4	21011101
484	2	\N	knockdown	low_float	1	201607m2.89b51134add14598248ce3cf51edee48	21011104
485	2	\N	20combo		1	201607m2.4ab107a83eed188dc1f3478bf14b786b	21011105
486	4	\N			0	NarutoBeta2.61Build300	21011106
487	1	\N		ignition knockdown	8	NarutoBeta2.61Build300	21011707
488	3	\N		knockdown	2	NarutoBeta2.61Build300	21011701
489	2	\N	knockdown	high_float ignition	1	NarutoBeta2.61Build300	21011704
490	4	\N			0	201607m2.032f8f4d72e1fc3ce581ddcdcf583b69	21011705
491	4	\N			0	201607m2.5a24216051e43b42dd8c7b50e58c99ce	21011706
492	1	\N			0	201601m3.aba0745fc0888533aebdba6e30bacc53	21000327
493	1	\N			1	NarutoBeta2.43Build300	21010308
494	3	\N			1	201603m1.54f01f4cb076504ba745bf013ff94023	21010301
495	2	\N	repulse	high_float 	3	201603m1.324af554942636a0b87973139d11a663	21010304
496	2	\N	high_float	knockdown immobile	1	201603m1.fc8907a0fda0c0fcd5d33330c7223f00	21010305
497	4	\N			0	201603m1.a48ecbd5cb91f514ea68e487dc393da5	21010306
498	1	\N		chaos	1	201601m3.b6dc8c72cca1822a21e3210a15a87e95	21007616
499	3	\N		knockdown	1	201601m3.68620fb1bea0f96f1ab9ec85544b548b	21007611
500	2	\N	high_float	knockdown	1	201601m3.e551e9ac655bf0c71cca512ef9fa6bf3	21007614
501	4	\N			0	201601m3.a0cf1a6db9c11683303182c735aaf506	21007615
502	1	\N		repulse	1	201601m3.45b63227f61a5178329a9270bba7df8c	21000147
503	4	\N			0	NarutoBeta1.0Build300	21000105
504	4	\N			0	NarutoBeta1.0Build300	21000114
505	4	\N		low_float	5	NarutoBeta1.0Build300	21000106
506	4	\N			0	NarutoBeta1.0Build300	21000913
507	1	\N		high_combo knockdown	12	NarutoBeta2.61Build303	21003317
508	3	\N		low_float	3	201607m2.324e181429b897edaf20facfcc0fab15	21003311
509	2	\N	knockdown	low_float immobile	1	NarutoBeta2.61Build303	21003314
510	2	\N	30combo	immobile	2	NarutoBeta2.61Build300	21003315
511	4	\N			0	201607m2.459b9f9bb1a8035638e4242e9aa258e0	21003316
512	2	\N	repulse		1	NarutoBeta1.0Build300	21000305
513	1	\N			0	NarutoBeta1.0Build300	21005507
514	3	\N		repulse 	3	NarutoBeta1.0Build300	21005503
515	2	\N	high_float	10combo repulse	10	NarutoBeta1.0Build300	21005504
516	4	\N			0	NarutoBeta1.0Build300	21004806
517	3	\N		knockdown	3	NarutoBeta1.0Build300	21000823
518	1	\N		immobile	1	NarutoBeta1.0Build300	21000804
519	4	\N			1	NarutoBeta1.0Build300	20000218
520	1	\N		knockdown	1	NarutoBeta2.26Build300	21004927
521	3	\N			1	201511m1.847440870fde1fa2c57abf26aec9c2d0	21004921
522	2	\N	low_float	repulse	1	201511m1.7906fe8529264e61067aeb0656f831d2	21004924
523	4	\N			0	201606m1.e7fd8c74b1dcd32de221d572138f36b2	21004925
524	4	\N		ignition	0	201511m1.20f2c24b4871f91ce0135cf25e04a4c6	21004926
525	1	\N		knockdown	3	201503m1.47f2e61c31e10db8225891e364047f05	21001127
526	3	\N			3	201503m1.0336a790b8a34b81619a02473075fdaf	21001123
527	4	\N			0	201503m1.63e5abf0f4423306759933c541993028	21001124
528	4	\N			0	201503m1.0f98c852d1b0c0814904a6f0eca992e1	21001125
529	4	\N			0	201503m1.8c9fd8d569432aae3677375d11dd3eb6	21001126
530	1	\N		repulse	2	NarutoBeta1.0Build300	21001014
531	2	\N	knockdown	knockdown	2	NarutoBeta1.0Build300	21001216
532	1	\N			0	NarutoBeta2.43Build300	21010707
533	3	\N			3	201603m1.e30c77115a2575c02db83d7d26a4ba5f	21010701
534	2	\N	low_float	high_float	1	201603m1.22dbbb1005707547e1c7442b10da73b5	21010704
535	4	\N			0	201603m1.182518ad689827afa973f5fe63e4907f	21010705
536	4	\N			0	201603m1.ae3e54b9f3bfab13cdcc9f5467c65c8f	21010706
537	1	\N		immobile	1	201602m1.50090aecd0b868ecf934940e67d7c1a7	21010408
538	3	\N		repulse	3	201602m1.c8b71730731e828953573e87df079db7	21010401
539	2	\N	repulse	immobile low_float	1	201602m1.55a3a8a9e9a5fe30bdca684126ff5731	21010404
540	4	\N			3	201602m1.8ff8ceea5f4c14878cbec71c6d0a5ec4	21010405
541	4	\N			0	201602m1.7c903e10168f5c58e450a73b6d7e7f81	21010407
542	1	\N			0	NarutoBeta1.0Build300	21002906
543	4	\N			0	NarutoBeta1.0Build300	21000146
544	1	\N		knockdown	0	NarutoBeta1.0Build300	20000114
545	2	\N	knockdown	knockdown	2	NarutoBeta1.0Build300	21000917
546	1	\N			0	NarutoBeta1.0Build300	21004004
547	2	\N	high_float	knockdown poisoning	11	NarutoBeta1.0Build300	21002106
548	1	\N		immobile	0	NarutoBeta1.0Build300	21003304
549	3	\N		low_float	3	NarutoBeta1.0Build300	21003303
550	2	\N	low_float	high_float	1	NarutoBeta1.0Build300	21002306
551	4	\N			0	NarutoBeta1.0Build300	21000136
552	1	\N			0	NarutoBeta1.0Build300	21000427
553	1	\N			2	NarutoBeta1.17Build300	21007508
554	3	\N		knockdown	7	201503m2.1580e80487528a48742e6cee75493567	21007503
555	3	\N			0	201503m2.1e11d864ce4e3d37b321e9350ce89c18	21007504
556	3	\N			0	NarutoBeta1.15Build301	21007506
557	2	\N	knockdown	high_float 	1	201503m2.b53dbf3274d6bd799d8e0c1227eaa86d	21007507
558	1	\N			3	201601m3.64c6284832528c896c5ce603d4ea5a2a	21000447
559	3	\N		repulse	1	201601m3.0f29d0066f597cc6acf1b37547b842ab	21000441
560	2	\N	high_float	knockdown ignition	1	201601m3.f0dd18da3c7fc54907e6ae3a1c5621d0	21000444
561	2	\N	knockdown	high_float	1	201601m3.a1c27b1b286d27dd4c670baf0a307a54	21000445
562	4	\N			0	201601m3.f709b119124f867fab9db73f1883f874	21000446
563	1	\N		knockdown	2	201601m3.06248cc8f667af87ee8f15f4c4e0936c	21001327
564	4	\N			0	NarutoBeta1.0Build300	21001325
565	2	\N	high_float	knockdown	2	NarutoBeta1.0Build300	21001326
566	1	\N		knockdown	1	NarutoBeta1.0Build300	21003904
567	1	\N		high_combo	10	NarutoBeta1.0Build300	21006007
568	3	\N		high_float ignition	2	NarutoBeta1.0Build300	21006003
569	2	\N	knockdown	low_float ignition	2	NarutoBeta1.0Build300	21006004
570	4	\N			0	NarutoBeta1.0Build300	21006005
571	1	\N		poisoning	0	NarutoBeta1.0Build300	21005104
572	2	\N	-	poisoning	2	NarutoBeta1.0Build300	21005105
573	4	\N		chaos	0	NarutoBeta1.0Build300	21002307
574	1	\N		repulse ignition	5	201601m3.f8dd6733fe2f5572d8176493c618280a	21000154
575	4	\N		ignition	2	NarutoBeta1.0Build300	21000135
576	1	\N		knockdown	0	NarutoBeta1.0Build305	21006107
577	3	\N		knockdown 	3	201501m3.46d5e711a1e734efadb46671e0b41d97	21006101
578	4	\N			0	NarutoBeta1.0Build305	21006104
579	4	\N			0	NarutoBeta1.0Build305	21006105
580	2	\N	knockdown	knockdown 	10	NarutoBeta1.0Build305	21006106
581	1	\N			1	NarutoBeta1.0Build300	21004907
582	3	\N		ignition	3	NarutoBeta1.0Build300	21004903
583	4	\N			0	NarutoBeta1.0Build300	20000220
584	2	\N	-	ignition	2	NarutoBeta1.0Build300	21004904
585	1	\N			1	201503m3.60bc52a4ae24060ee410a2f9bed86afd	21000837
586	3	\N		knockdown	3	201503m3.557891e7a3df8839cb0b14c2dc56590a	11000831
587	2	\N	repulse	knockdown ignition	1	201503m3.14f9cc69805923a3967fb33f02d29367	21000834
588	4	\N			0	201503m3.91fff0f8f30653e600157a3fdc34de1b	21000835
589	2	\N	knockdown	immobile	1	201503m3.b2b2587370b13f9078c015adcf01fdf2	21000836
590	3	\N			2	NarutoBeta1.0Build300	20000310
591	3	\N			0	NarutoBeta1.0Build300	20000320
592	2	\N	high_float	repulse	1	NarutoBeta1.0Build300	20000107
593	1	\N		high_combo	5	NarutoBeta2.21Build300	21000637
594	3	\N		knockdown	4	201509m3.ec13bc38fad936e7d60eaab7fc72797d	21000633
595	2	\N	20combo		4	201509m3.171895c5c235fb815b98f1e65ea1cd74	21000634
596	2	\N	repulse	high_float	1	201509m3.37a18311ea78d076a3e43f4e0f70c15b	21000635
597	4	\N			0	201509m3.e90852f69d66735b24cb1c08c4d83331	21000636
598	1	\N			0	201502m2.f5a32a88f4651c297ee6c152b22b20ad	21000347
599	3	\N			0	201502m2.2962fa25b579a7a4e7ec81fe46639516	21000343
600	2	\N	repulse	high_float	1	201502m2.cd8f30e6b9b90bff186b259267e9afee	21000344
601	4	\N			0	201502m2.7087cd783e9829db2adc60ea65d7dd23	21000345
602	4	\N			0	201502m2.7d21cb52a471c216dd663676449a6878	21000346
603	1	\N		knockdown	1	201503m2.e655da4dce5e5c354f6b2b6fbb1a58af	21008208
604	3	\N			0	201503m2.d04d44706359f10239dadab8184c521e	21008203
605	2	\N	repulse	knockdown	2	201503m2.0f198d0928805aa87dc5357bfd2880fb	21008204
606	3	\N			0	201503m2.480058451265ff8711fbad18c5dc5432	21008206
607	3	\N			0	NarutoBeta1.21Build300	21008205
608	2	\N	knockdown	immobile	1	201504m1.6acc783463c9e6e7f9f1fbb4f471acbf	21000805
609	1	\N		knockdown	3	NarutoBeta1.0Build300	21005305
610	2	\N	repulse	knockdown	2	NarutoBeta1.0Build300	21005304
611	1	\N		repulse	2	201511m3.cc6976831b3de22f11bc08f672de878b	21001414
612	2	\N	low_float	high_float	2	NarutoBeta1.0Build300	21001406
613	4	\N			0	NarutoBeta1.0Build300	20000414
614	1	\N		knockdown ignition	2	NarutoBeta1.0Build300	21002204
615	3	\N			1	NarutoBeta1.0Build300	21002203
616	4	\N			0	NarutoBeta1.0Build300	21002206
617	4	\N			0	NarutoBeta1.0Build300	21002207
618	1	\N		low_float	2	201503m2.4f55136fa70a60a3718894f27f85654c	21001458
619	3	\N		repulse	1	201503m2.35d1526878cc26246260c5f51add29ce	21001453
620	4	\N			0	201503m2.4838e935db8c7bcb65535d6c8a980460	21001454
621	2	\N	low_float	repulse	1	201503m2.0e3af7d9004bf47c14d979c9bb60dea6	21001455
622	3	\N			0	NarutoBeta1.21Build300	21001456
623	1	\N		repulse	4	NarutoBeta1.0Build300	21005407
624	3	\N		high_float	3	NarutoBeta1.0Build300	21005403
625	4	\N		repulse	1	NarutoBeta1.0Build300	21005404
626	2	\N	repulse	high_float	2	NarutoBeta1.0Build300	21005405
627	2	\N	high_float	low_float 7combo	10	NarutoBeta1.0Build300	21005406
628	1	\N		repulse ignition	5	NarutoBeta1.0Build300	21000134
629	1	\N			0	201510m2.295c27e6ae00eb9d745383c0b98098c4	21002019
630	3	\N		high_float	0	201510m2.43e62ab7535096525d77b2e84ffec9a4	21002012
631	2	\N	low_float	high_float 	1	201510m2.77c3f6a8b89ce3e749214463cc37248a	21002015
632	4	\N			0	201510m2.9bc8eb99510395f5ffb78d14aaf4e57c	21002016
633	2	\N	30combo	poisoning	1	201510m2.336c93957a8633b4106cab01991c9455	21002017
634	1	\N		repulse	4	NarutoBeta1.17Build300	21000257
635	3	\N		low_float	3	201503m2.711b1c8e366e1956b093cafbb152ee4d	21000253
636	4	\N			0	201503m2.33f4de654dbeceaa4c1b38e876f6b6a0	21000254
637	2	\N	-		2	NarutoBeta1.17Build300	21000255
638	2	\N	low_float	high_float ignition	1	201503m2.bf97e85db4887e8bc0b44c83e816f113	21000256
639	1	\N		chaos	1	201503m2.b42ccb940c8c518241b56462bc8baf0f	21008507
640	3	\N		repulse	1	201503m2.4033b905238b19dae47fb62f1b426e51	21008503
641	2	\N	repulse	low_float	2	NarutoBeta1.21Build300	21008504
642	2	\N	high_float	low_float ignition	10	201503m2.9dff88a5f734e6f326832bcd54a11a66	21008505
643	4	\N			0	201503m2.2150f1a2863e58787f591b237a435982	21008506
644	1	\N			1	NarutoBeta1.0Build300	21002904
645	1	\N		high_float 	2	NarutoBeta1.0Build300	21005205
646	4	\N			0	NarutoBeta1.0Build300	21005206
647	1	\N		knockdown	1	201601m3.64310f66b11897dd81d797bd74e48a79	21003204
648	3	\N		low_float acupuncture	3	NarutoBeta1.0Build300	21003203
649	2	\N	repulse	low_float	1	NarutoBeta1.0Build300	20000117
650	4	\N			0	NarutoBeta1.0Build300	21003207
651	4	\N			0	NarutoBeta1.0Build300	21000116
652	4	\N			0	NarutoBeta1.0Build300	21000717
653	1	\N		ignition	2	NarutoBeta1.0Build300	20000223
654	1	\N		repulse	1	NarutoBeta1.0Build300	21001904
655	4	\N			1	NarutoBeta1.0Build300	21001905
656	2	\N	high_float	low_float	1	NarutoBeta1.0Build300	21001906
657	1	\N		knockdown	1	201506m1.65fb472bbcfb74e0e8a54d0433bfadc5	21001628
658	3	\N		high_float	1	201506m1.02507efdb62790c3447c1071ed54f7e0	21001621
659	4	\N			0	201506m1.9949107a33c5b13941d2571851639a74	21001625
660	4	\N			0	201506m1.78530d5af10c87d62ad67d8a28020844	21001626
661	1	\N		knockdown blindness ignition	1	201606m1.9367a850c0f511b80dcfcecf0d90c933	21003928
662	3	\N		repulse	3	201606m1.a754905a062d05b04047d8a7eda98875	21003921
663	2	\N	knockdown	repulse	1	201606m1.fbb8a936de05561b9d187a7726d108a4	21003924
664	4	\N			0	201606m1.b712e3aa8898e2480cada14073948992	21003925
665	4	\N			0	201606m1.515c3a98448d8560190b7e9a6d83645a	21003927
666	1	\N		blindness	1	NarutoBeta1.0Build300	21001714
667	4	\N		high_float	0	NarutoBeta1.0Build300	20000119
668	1	\N			0	NarutoBeta1.0Build300	21002118
669	4	\N			0	NarutoBeta1.0Build300	21002114
670	4	\N			0	NarutoBeta1.0Build300	21002107
671	1	\N			1	NarutoBeta2.61Build300	21010907
672	3	\N		repulse 10combo	10	201607m2.4a391c3614820646c8208834bced6ee8	21010901
673	2	\N	low_float	repulse 	1	NarutoBeta2.61Build300	21010904
674	4	\N			0	201607m2.1c8afb3d357ecbc843f8a3e6af1b8e49	21010905
675	4	\N			0	201607m2.16233b19de24e3f7cf500baacb98d842	21010906
676	1	\N		knockdown 	7	201503m2.54cee37bf5196bac9935068f7364f68f	21207307
677	3	\N		high_float 	3	201503m2.a8c6dcd8515ec8f375f9e7f757e3088d	21007303
678	2	\N	10combo		3	201604m3.178ea85f1da07a17acdd7a364419ef01	21007305
679	2	\N	high_float	repulse	1	201503m2.09033f7c988772652f94e187c021bfc5	21007306
680	3	\N			0	NarutoBeta1.17Build300	21007309
681	1	\N			0	201511m3.dc7f705232bb72813b3cac5e2396a5cc	21000337
682	3	\N		high_float	1	201511m3.3cd97bda22668aab526f494caa6d8069	21000331
683	2	\N	knockdown		1	201511m3.11e0a1cefae158a9ec8d6c9b1bc7ea31	21000334
684	4	\N			0	201511m3.4f4885319272137bdfa8ca08e34e260b	21000335
685	4	\N			0	201511m3.044ae7e7726ef48780de48f18923b460	21000336
686	1	\N		high_combo repulse	10	NarutoBeta2.61Build300	21000187
687	3	\N		ignition high_combo repulse	10	201607m2.c02d3cba9c2dd2e7c5c2f8b1b85078a9	21000181
688	2	\N	repulse	low_float immobile	2	NarutoBeta2.61Build300	21000184
689	4	\N			0	201607m2.ce77f6df126be929ee035d85215314fa	21000185
690	4	\N			0	201607m2.0ae47ad54e47f50a6bae908ee560a83b	21000186
691	1	\N		low_float	1	201512m3.97a254c1bb78d7059f29b34169d6ddcf	21001837
692	3	\N		low_float acupuncture	3	201512m3.b7a520a85a273cb5db99ec12ab1e8641	21001833
693	2	\N	repulse	low_float acupuncture	1	201512m3.3a813138ee85e7e5da9b0d7df7aff71c	21001834
694	4	\N			0	201512m3.9eba37010b453a4a08902def5d99bed6	21001835
695	4	\N			0	201512m3.297136a9d7fc057e1c25716c06a77f85	21001836
696	1	\N		knockdown	1	NarutoBeta2.23Build301	21009907
697	3	\N		low_float	1	201510m2.8deb3c8224fc62c2f099e3edca151943	21009901
698	2	\N	knockdown	knockdown immobile	1	201510m2.1a0830c4a434ccb9d990d17265bd6743	21009904
699	4	\N			0	201510m2.86ed32163e7a19648bb3b885de3a9b29	21009905
700	4	\N			0	201510m2.72566dac477ae54d4adaa4d5500a07e2	21009906
701	1	\N		high_float	0	NarutoBeta1.0Build300	21002104
702	3	\N		repulse	3	NarutoBeta1.0Build300	21002103
703	1	\N			4	201502m2.59f4b7c301b1a3a91ee2311cde99b7ce	21000268
704	3	\N		high_float	2	201502m2.8fb1e8b0cd5093a508fcc65b0eda0a31	21000263
705	4	\N			0	201502m2.9d59560346e5ea29b746813d5600f88a	21000266
706	2	\N	-		2	201502m2.f002af1fe1299ce26d69595623fbab4e	21000267
707	2	\N	low_float	high_float ignition	1	201502m2.1e14a6fb381e568c36ec3068fbb93611	21000265
708	1	\N			10	201507m1.8d37381728beb318be12a01cd9e7f042	21005527
709	3	\N			1	201510m3.36103bedcff41aea456eb5fc9935a612	21005521
710	2	\N	high_float	repulse 10	10	201510m3.e7728a3a709180921a533ac40b80f579	21005524
711	4	\N			0	201507m1.994b92967819e6dc429db2e6fe60d3d7	21005525
712	4	\N			0	201507m1.77124f6a170782ad90df0efe3bc2c738	21005526
713	1	\N		high_float	4	NarutoBeta1.21Build300	21007907
714	3	\N		repulse	3	201503m2.b366ec623809075bc62c42455edce8c8	21007903
715	4	\N			0	201503m2.99c5cfb78003e3d3447457f29968ac52	21007904
716	2	\N	high_float	repulse	1	201503m2.687c8113bf1f8c53f1cf4f927144d74e	21007905
717	4	\N			0	201503m2.31d98bbb1073241a9bd928dd387d4b6a	21007906
718	1	\N		knockdown	4	201503m2.1a245a26133580b501deae0c36f62e21	21201338
719	3	\N		high_float	3	201503m2.55b9b0492e61a682b3b5bb63ef25d7b7	21001333
720	4	\N			0	201501m3.7bfc5b523281bdf3a947e4e618abf64e	21001334
721	2	\N	high_float	knockdown	2	201501m3.da2d06f51eca36f720c619af27011d23	21001337
722	3	\N			0	201503m2.4ca2b8e1b1e2a534b831349771d2ef17	21001340
723	1	\N		ignition	1	201512m1.36f0587b5522f27992e5e133c0e0b537	21006307
724	2	\N	high_float	repulse	2	NarutoBeta1.2Build300	21006304
725	2	\N	low_float	high_float ignition high_combo	10	NarutoBeta1.0Build305	21006305
726	1	\N			0	NarutoBeta1.17Build300	21007207
727	3	\N		repulse	3	201503m2.b0e6f99ea66366360b12cfdb98eedc23	21007203
728	3	\N		chaos	0	NarutoBeta1.15Build301	21007204
809	3	\N		knockdown	1	NarutoBeta1.0Build300	20000412
729	2	\N	repulse	knockdown immobile	1	201503m2.ce282376396cdc97a30e2b4954331b95	21007205
730	1	\N			1	201512m1.c33ea7bb72eb293e30ab25b9d207a193	21000214
731	1	\N			0	NarutoBeta1.0Build300	20000110
732	3	\N		low_float	3	201501m3.91925989e39a33fcee7324c45802144a	20000103
733	1	\N		knockdown	1	NarutoBeta2.13Build301	21009207
734	3	\N		low_float	3	201507m3.a9b09b46b0ef2698c002d4cccf933a95	21009201
735	2	\N	30combo	ignition	4	201507m3.bd7b1999ab6acf8d17e08f760af61cae	21009204
736	4	\N		ignition	0	NarutoBeta2.13Build301	21009205
737	4	\N			0	201507m3.17b9852706aedc222db53b9a2edc67f8	21009206
738	1	\N			0	NarutoBeta1.0Build300	21001505
739	1	\N		repulse	1	201605m3.8ec81d487ece0ffeb0b8b8fd245181d1	21010004
740	3	\N			1	201605m3.2b52d97dd55f9a246c6f2e75c2960950	21010001
741	2	\N	repulse		1	201605m3.c97edb00069212e1eaea01c5f757a940	21010005
742	4	\N			0	201605m3.d00f31b8f62235dcc559d3499ad378f4	21010006
743	1	\N			2	201507m3.f5bbef8bb1e00e6dffe54189f749fb17	21007518
744	3	\N		low_float acupuncture	1	201507m3.44eb554cb4f459a5768c792fc08afaea	21007511
745	4	\N			0	201507m3.f55d2814a24eae62bbd967586adb06e1	21007514
746	3	\N			0	201507m3.4c4a6bd80d89879dc960f96ec2c66181	21007515
747	2	\N	knockdown	high_float 	1	201507m3.be169a3cd90d44af7dc1105abb467665	21007517
748	1	\N		knockdown	4	NarutoBeta1.17Build300	21007108
749	3	\N		repulse	1	201503m2.cbcb4b5c73c23deaad8af900a22dc7d9	21007103
750	3	\N			0	201503m2.d88f2a347148763d9b3950432cb144d6	21007104
751	2	\N	knockdown	high_float	1	NarutoBeta1.15Build301	21007107
752	3	\N			0	201503m2.0454e073e7707780f6d320b4d3593f3e	21007110
753	1	\N		repulse	1	201601m3.0794db6745927763a1d0de442ebb2943	21000104
754	1	\N		blindness	0	201607m2.01d80b50a59c0ef0018bf604031d8d51	21001737
755	3	\N		low_float	1	201607m2.1ffd78ed8bce4ce4c19757f4363edd43	21001731
756	4	\N	low_float	repulse	1	201607m2.bc17526b2c96ce88facc980af5e9b22d	21001734
757	2	\N	20combo	high_combo	3	201607m2.db7f17d75efb790ecb6b1840884c20bd	21001735
758	4	\N			0	201607m2.29e2aceaa702c2c8ecb74ed80508fbd9	21001736
759	1	\N		high_float	1	NarutoBeta2.50Build300	21010607
760	3	\N		repulse	0	201605m1.94978a0822b637a7f40d5e9d8a179673	21010601
761	2	\N	repulse	knockdown immobile	1	201605m1.8ec0534e7d2da039b0cb62c972b72b95	21010604
762	4	\N			5	201605m1.0804180e7f75bf81c56ef7ad872f315d	21010605
763	4	\N			0	201605m1.1d3482f8562a58185197e6f3af83f5d9	21010610
764	1	\N			0	NarutoBeta1.0Build300	21002004
765	4	\N			0	201605m1.b3f03d8812e74fcb25060d4a2acecaf2	21002006
766	1	\N		knockdown	1	NarutoBeta1.0Build300	21000237
767	3	\N		low_float	3	NarutoBeta1.0Build300	20000404
768	2	\N	low_float	repulse	1	201512m1.ab7c06e0b579cbffc3c65b361b1646df	21000246
769	2	\N	high_float	low_float 10combo 	10	NarutoBeta1.0Build300	20000421
771	1	\N		knockdown immobile	1	201506m3.8d80429f7bdc5ae48f9ccf7078c5992a	21005617
772	3	\N		high_float	1	201506m3.a904eb70f0dbf5df77aea550e8b97f7a	21005611
773	2	\N	knockdown	repulse	0	201506m3.ce558c6f0434b84c6dae1cfce4c476c0	21005614
774	4	\N			0	201506m3.b10d96c380da1554d245d9fa462e00fa	21005615
775	4	\N			0	201506m3.6f011227dcf3d171f61d2aa4791f5ac0	21005616
776	1	\N		low_float	0	201512m1.704275cd63b0971f3aba9672aa8de4fd	21001814
777	1	\N		knockdown	1	201601m3.4aacb73315a96d59fcd21a40050730c1	21004516
778	2	\N	low_float		1	NarutoBeta1.2Build300	21004502
779	1	\N		repulse	3	201601m3.53252878914581c22b93af746eb348bc	21005707
780	2	\N	high_float	repulse	2	NarutoBeta1.0Build300	21005704
781	4	\N			0	NarutoBeta1.0Build300	21005705
782	1	\N			0	NarutoBeta2.48Build300	21003217
783	3	\N		10combo repulse	10	NarutoBeta2.48Build300	21003213
784	2	\N	20combo		1	201604m2.e157c03ba2adacd4e6097280076b3204	21003214
785	4	\N			0	NarutoBeta2.48Build300	21003215
786	4	\N			0	201604m2.8503f9a4db5743effc20b66164f626e4	21003216
787	1	\N		knockdown	1	201504m3.a4813628b50ca84d8f31c839aaebdca5	21000927
788	3	\N		knockdown	1	201504m3.fc5c767585479df60b6021c586c4724b	21000921
789	2	\N	knockdown	knockdown	10	201504m3.a1d41e12e550eaf2d34d6966f35f4eea	21000924
790	4	\N			0	201504m3.39fc9df4f567b7e4b3340c91473161f5	21000925
791	4	\N			0	201504m3.09161286e86d584f05a00010bcbe96f3	21000926
792	1	\N		knockdown	1	201511m3.b0f2a8b9573994dc60971437f6a2b9de	21004505
793	1	\N		high_combo repulse	10	NarutoBeta2.61Build300	21011007
794	3	\N		low_float	3	201607m2.fa515e3a0515c81b18011e05e3acea84	21011001
795	2	\N	low_float	high_float 	2	201607m2.4a559cec0243b7a7a0f37713a3ef477f	21011004
796	4	\N			0	201607m2.0745044a7fbaed21e2d907f9ed7d1c39	21011005
797	4	\N			0	201607m2.2ddaba777ab9cf0104b5467b1a0c5df5	21011006
798	1	\N			0	201605m1.5f7d094be101515f6732f60710aa2848	21004838
799	3	\N		poisoning	1	201605m1.e6df17b17519cf54e9a86c4341d6f98e	21004831
800	4	\N		chaos	1	201605m1.5a59e26744e9d451a3205aaa84177706	21004834
801	4	\N			0	201605m1.8294e424555bb299091fd07cdbcad7d5	21004836
802	4	\N			0	201605m1.c0e51466d02670ac3d71aad6fa80ce21	21004837
803	1	\N		high_combo high_float	5	201608m2.a4028838ea8d717bd719f67ff7373d78	21001467
804	3	\N		low_float	3	201608m2.029f9375f1a44e1a22f1a5d223ee2cad	21001461
805	2	\N	low_float	repulse blindness	2	201608m2.3b75fba276297d56ffcacb2959faff12	21001464
806	4	\N			0	201608m2.963d273d4ed3a92d6624eea35a3030b6	21001465
807	4	\N			0	201608m2.4eb1880bbe1161efc5b352c4b4b3913c	21001466
808	1	\N		low_float	3	NarutoBeta1.0Build300	21001604
810	1	\N			0	201511m3.3d93bece6eea32edd7026d3a19678ea0	21006207
811	2	\N	low_float	knockdown	2	NarutoBeta1.2Build300	21006204
812	1	\N			0	NarutoBeta1.0Build300	21004104
813	3	\N		knockdown	1	201604m1.8df08a437f89a62c8e4bcefe48799f06	21004101
814	4	\N			0	201604m1.cf15b23d047c7998e9c3b268289f669b	21004105
815	2	\N	knockdown	repulse	1	NarutoBeta1.0Build300	21004106
816	4	\N			0	201604m1.654625b0ac7d79b846f468ae4f3e364f	21004107
817	1	\N		high_float acupuncture	1	NarutoBeta1.0Build300	21001634
818	3	\N		high_float	3	201511m1.be7085c3e4adf98ec25e91788423a027	21001631
819	4	\N			0	201511m1.7914e971b5b829a42789d0be6e3fef25	21001635
820	4	\N			0	NarutoBeta1.0Build300	21001636
821	4	\N			0	201511m1.a6eae104dc9bba2eb21317bd6939e5d1	21001637
822	1	\N		acupuncture	1	NarutoBeta1.0Build300	20000410
823	3	\N		repulse	3	201501m3.6dbec7b90ef93f64af86a6ea7325eea0	20000403
824	2	\N	repulse	knockdown	2	NarutoBeta1.0Build300	20000420
825	1	\N		knockdown 	4	NarutoBeta1.0Build300	21004811
826	4	\N		high_float poisoning	0	NarutoBeta1.0Build300	21004813
827	2	\N	knockdown	low_float poisoning	2	NarutoBeta1.0Build300	21004816
828	4	\N			0	201601m3.ad504a978484e4d4047770a2b27fe1e1	21004812
829	1	\N		high_combo acupuncture	10	201505m3.b623746c0997a6ad45b5c3f25de2b740	21000528
830	3	\N		high_float	1	201505m3.5f82ea98f9e9e2c706b1ab488fa0ac7a	21000522
831	2	\N	knockdown	high_float acupuncture	1	201505m3.0cc07f79b6a99300eaf3d3df5260a0b9	21000525
832	4	\N			0	201505m3.58da5e466ce698422b16202b582a9638	21000526
833	4	\N			0	201505m3.171cca169b762fe98cce75d1754f5f06	21000527
834	1	\N		chaos	1	201512m3.3a609dd5b85ef6051acebf7bdf22b1f0	21000727
835	3	\N			0	201512m3.88f0626a0e7674c16be7382a705bdee8	21000723
836	4	\N			0	201512m3.f640e22f7a2fd94407ffd4f9a8081b16	21000724
837	2	\N	immobile 	chaos	1	201512m3.953588bacda1c81153bb9c5cbc34304d	21000725
838	4	\N			0	201512m3.a3c6a27043063a199cc32816cd6a5b40	21000726
839	1	\N			2	201504m1.fb7e4b669c629a16c0212f552e3d00a4	29004704
840	3	\N		high_float	2	201504m1.a3859046b95c097be9ff7941ee0905c1	29004701
841	3	\N			0	201504m1.c01046040485c7c5c9a7a1a3fdb41640	29004706
842	4	\N		poisoning	0	201504m1.86394debdd40a3c111833515d3d46b2f	29004707
843	4	\N			0	201504m1.4a66ee1290215ddb7e6fe84108004632	29004705
844	1	\N			1	NarutoBeta1.0Build300	21002314
845	3	\N		low_float	6	201501m3.b00216688396a67ca8f85f194052c7a1	20000306
846	2	\N	low_float	high_float	1	NarutoBeta1.0Build300	20000316
847	3	\N			0	201501m3.aee6a2091935ab02ed10de7cb5f3bb78	20000329
848	4	\N			0	NarutoBeta1.0Build300	20000315
849	1	\N		knockdown ignition	2	NarutoBeta2.23Build301	21009707
850	3	\N		10combo repulse	10	NarutoBeta2.23Build301	21009701
851	2	\N	repulse	knockdown	1	201510m2.7fd64e4fff6f78cc0d1dae11373f65c2	21009704
852	4	\N			0	NarutoBeta2.23Build301	21009705
853	4	\N			0	201512m2.595a3bca8bf052e0c92bb3a8e255c8cf	21009706
854	1	\N		high_combo	5	NarutoBeta1.17Build300	21000627
855	3	\N		knockdown	4	201502m2.5cbdd1c0500242fd9a627e277e864ffe	21000623
856	2	\N	repulse	high_float	1	NarutoBeta1.16Build301	21000624
857	2	\N	high_combo		1	201502m2.d0dd0a86819deca7424de151563a7b7d	21000625
858	4	\N			0	201502m2.92def1e46a3ddad8c1da8d3e971b66ea	21000626
859	4	\N			0	201512m1.5da8989cee895598054a4f1afaf32f55	21000519
860	2	\N	knockdown	high_float	2	NarutoBeta1.0Build300	21000521
861	1	Earth Style - Stone Fist Jutsu	\N	\N	0	\N	\N
862	3	Earth Style - Petrifying Jutsu	\N	\N	0	\N	\N
863	2	Earth Style - Stone Fist Jutsu - Fall	\N	\N	1	\N	\N
864	2	Chameleon skill	\N	\N	2	\N	\N
770	2	\N	high_combo	ignition	1	NarutoBeta1.0Build300	20000212
\.


--
-- Name: skills_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('skills_sequence', 864, true);


--
-- Data for Name: skills_statuses; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY skills_statuses (id, id_skill, id_status, chase_create) FROM stdin;
145	138	3	2
146	139	1	1
147	139	3	2
148	139	9	2
149	142	9	2
150	143	2	2
151	144	1	1
152	144	2	2
153	144	9	2
154	147	3	2
155	147	9	2
156	148	1	2
157	148	12	2
158	150	6	2
159	151	1	1
160	151	3	2
161	151	13	2
162	152	4	2
163	153	4	1
164	153	2	2
165	155	9	2
166	156	3	2
167	156	9	2
168	157	4	1
169	157	3	2
170	157	9	2
171	160	2	2
172	161	1	2
173	163	6	2
174	164	5	2
175	164	6	2
176	166	1	1
177	166	1	2
178	166	13	2
179	166	9	2
180	167	6	2
181	169	2	1
182	169	12	2
183	170	1	1
184	171	2	2
185	171	12	2
186	171	5	2
187	172	1	2
188	173	1	1
189	173	1	2
190	174	5	2
191	176	4	2
192	176	9	2
193	177	3	2
194	178	1	1
195	178	3	2
196	179	3	2
197	179	9	2
198	181	2	2
199	181	9	2
200	182	2	2
201	183	2	1
202	183	3	2
203	185	1	1
204	185	3	2
205	186	1	2
206	187	3	2
207	189	3	1
208	189	1	2
209	191	13	2
210	193	3	1
211	193	2	2
212	195	1	2
213	199	2	2
214	200	9	2
215	200	2	2
216	201	3	2
217	201	9	2
218	202	9	2
219	205	1	2
220	206	4	2
221	207	1	1
222	207	4	2
223	208	4	1
224	208	2	2
225	209	1	1
226	209	1	2
227	210	1	2
228	211	5	2
229	212	6	2
230	213	1	1
231	213	2	2
232	216	3	2
233	220	4	2
234	221	4	2
235	222	3	1
236	222	2	2
237	223	6	2
238	225	1	1
239	225	4	2
240	229	4	2
241	231	4	1
242	234	4	1
243	234	3	2
244	235	3	2
245	235	6	2
246	237	4	1
247	237	2	2
248	238	3	2
249	240	2	1
250	240	3	2
251	242	13	2
252	242	1	2
253	243	3	2
254	244	13	2
255	247	6	2
256	248	2	2
257	249	2	1
258	249	3	2
259	249	6	2
260	251	6	2
261	258	3	2
262	259	1	1
263	259	3	2
264	263	4	2
265	266	4	1
266	266	3	2
267	266	9	2
268	267	1	2
269	268	1	1
270	268	1	2
271	268	12	2
272	270	2	1
273	270	1	2
274	271	1	2
275	274	1	1
276	274	1	2
277	276	3	1
278	276	1	2
279	280	1	2
280	282	2	1
281	282	1	2
282	282	13	2
283	284	9	2
284	284	1	2
285	285	3	2
286	286	1	1
287	286	3	2
288	286	9	2
289	286	13	2
290	290	2	2
291	291	2	1
292	291	12	2
293	291	1	2
294	292	1	1
295	292	1	2
296	294	1	1
297	294	3	2
298	296	2	1
299	296	1	2
300	297	13	2
301	297	1	2
302	298	2	2
303	299	2	1
304	299	1	2
305	305	3	1
306	305	4	2
307	307	4	2
308	308	3	1
309	308	1	2
310	308	13	2
311	310	9	2
312	311	1	2
313	312	1	2
314	315	1	1
315	315	1	2
316	317	13	1
317	320	2	2
318	324	5	2
319	324	2	2
320	325	3	2
321	326	2	1
322	326	1	2
323	328	1	2
324	329	1	1
325	329	3	2
326	333	6	2
327	336	1	2
328	337	4	2
329	340	4	2
330	341	5	2
331	342	5	2
332	345	9	2
333	347	4	1
334	347	1	2
335	351	3	2
336	352	2	1
337	352	1	2
338	355	13	2
339	356	2	2
340	356	12	2
341	357	1	1
342	357	3	2
343	357	12	2
344	362	2	1
345	362	3	2
346	363	5	2
347	365	1	2
348	365	5	2
349	366	4	1
350	366	2	2
351	369	2	2
352	369	12	2
353	374	13	1
354	377	1	2
355	378	1	2
356	379	1	1
357	379	2	2
358	382	2	2
359	383	1	2
360	385	2	1
361	385	1	2
362	385	9	2
363	388	4	2
364	389	4	2
365	391	4	1
366	391	1	2
367	393	1	1
368	393	3	2
369	394	1	2
370	395	2	1
371	395	1	2
372	395	13	2
373	396	4	2
374	396	6	2
375	397	1	1
376	397	3	2
377	398	3	2
378	398	6	2
379	400	1	2
380	402	1	2
381	403	1	2
382	405	3	1
383	405	1	2
384	408	4	1
385	408	1	2
386	410	5	2
387	412	2	1
388	412	4	2
389	413	12	2
390	414	3	2
391	415	1	1
392	415	2	2
393	415	12	2
394	418	1	2
395	419	4	2
396	424	4	2
397	425	2	1
398	425	4	2
399	426	4	2
400	429	13	1
401	434	6	2
402	437	1	2
403	439	4	2
404	440	3	1
405	440	2	2
406	444	3	2
407	448	3	2
408	449	4	1
409	450	1	2
410	451	3	2
411	453	13	2
412	454	1	2
413	454	13	2
414	455	2	1
415	455	1	2
416	455	13	2
417	458	1	2
418	461	2	1
419	461	1	2
420	461	11	2
421	462	11	2
422	463	1	2
423	463	11	2
424	468	4	2
425	470	6	2
426	473	1	1
427	473	2	2
428	474	4	2
429	477	1	2
430	477	13	2
431	478	3	2
432	478	13	2
433	479	4	2
434	482	3	2
435	483	1	2
436	484	1	1
437	484	3	2
438	487	9	2
439	487	1	2
440	488	1	2
441	489	1	1
442	489	4	2
443	489	9	2
444	493	2	2
445	494	2	2
446	495	2	1
447	495	4	2
448	496	4	1
449	496	1	2
450	496	13	2
451	499	1	2
452	500	4	1
453	500	1	2
454	502	2	2
455	505	3	2
456	507	5	2
457	507	1	2
458	508	3	2
459	509	1	1
460	509	3	2
461	509	13	2
462	510	13	2
463	512	2	1
464	514	2	2
465	515	4	1
466	515	2	2
467	517	1	2
468	518	13	2
469	520	1	2
470	522	3	1
471	522	2	2
472	524	9	2
473	525	1	2
474	530	2	2
475	531	1	1
476	531	1	2
477	533	2	2
478	534	3	1
479	534	4	2
480	537	13	2
481	538	2	2
482	539	2	1
483	539	13	2
484	539	3	2
485	544	1	2
486	545	1	1
487	545	1	2
488	547	4	1
489	547	1	2
490	547	6	2
491	548	13	2
492	549	3	2
493	550	3	1
494	550	4	2
495	554	1	2
496	557	1	1
497	557	4	2
498	559	2	2
499	560	4	1
500	560	1	2
501	560	9	2
502	561	1	1
503	561	4	2
504	563	1	2
505	565	4	1
506	565	1	2
507	566	1	2
508	567	5	2
509	568	4	2
510	568	9	2
511	569	1	1
512	569	3	2
513	569	9	2
514	571	6	2
515	572	6	2
516	574	2	2
517	574	9	2
518	575	9	2
519	576	1	2
520	577	1	2
521	580	1	1
522	580	1	2
523	580	5	2
524	582	9	2
525	584	9	2
526	586	1	2
527	587	2	1
528	587	1	2
529	587	9	2
530	589	1	1
531	589	13	2
532	592	4	1
533	592	2	2
534	593	5	2
535	594	1	2
536	596	2	1
537	596	4	2
538	600	2	1
539	600	4	2
540	603	1	2
541	605	2	1
542	605	1	2
543	608	1	1
544	608	13	2
545	609	1	2
546	610	2	1
547	610	1	2
548	611	2	2
549	612	3	1
550	612	4	2
551	614	1	2
552	614	9	2
553	618	3	2
554	619	2	2
555	621	3	1
556	621	2	2
557	623	2	2
558	624	4	2
559	625	2	2
560	626	2	1
561	626	4	2
562	627	4	1
563	627	3	2
564	628	2	2
565	628	9	2
566	630	4	2
567	631	3	1
568	631	4	2
569	633	6	2
570	634	2	2
571	635	3	2
572	638	3	1
573	638	4	2
574	638	9	2
575	640	2	2
576	641	2	1
577	641	3	2
578	642	4	1
579	642	3	2
580	642	9	2
581	645	4	2
582	647	1	2
583	648	3	2
584	648	12	2
585	649	2	1
586	649	3	2
587	653	9	2
588	654	2	2
589	656	4	1
590	656	3	2
591	657	1	2
592	658	4	2
593	661	1	2
594	661	11	2
595	661	9	2
596	662	2	2
597	663	1	1
598	663	2	2
599	666	11	2
600	667	4	2
601	671	13	2
602	671	3	2
603	672	2	2
604	673	3	1
605	673	2	2
606	676	1	2
607	677	4	2
608	679	4	1
609	679	2	2
610	682	4	2
611	683	1	1
612	686	5	2
613	686	2	2
614	687	9	2
615	687	5	2
616	687	2	2
617	688	2	1
618	688	3	2
619	688	13	2
620	691	3	2
621	692	3	2
622	692	12	2
623	693	2	1
624	693	3	2
625	693	12	2
626	696	1	2
627	697	3	2
628	698	1	1
629	698	1	2
630	698	13	2
631	701	4	2
632	702	2	2
633	703	1	2
634	704	4	2
635	707	3	1
636	707	4	2
637	707	9	2
638	710	4	1
639	710	2	2
640	713	4	2
641	714	2	2
642	716	4	1
643	716	2	2
644	718	1	2
645	719	4	2
646	721	4	1
647	721	1	2
648	723	9	2
649	724	4	1
650	724	2	2
651	725	3	1
652	725	4	2
653	725	9	2
654	725	5	2
655	727	2	2
656	729	2	1
657	729	1	2
658	729	13	2
659	732	3	2
660	733	1	2
661	734	3	2
662	735	9	2
663	736	9	2
664	739	2	2
665	741	2	1
666	744	3	2
667	744	12	2
668	747	1	1
669	747	4	2
670	748	1	2
671	749	2	2
672	751	1	1
673	751	4	2
674	753	2	2
675	754	11	2
676	755	3	2
677	756	3	1
678	756	2	2
679	757	5	2
680	759	4	2
681	760	2	2
682	761	2	1
683	761	1	2
684	761	13	2
685	766	1	2
686	767	3	2
687	768	3	1
688	768	2	2
689	769	4	1
690	769	3	2
691	770	9	2
692	771	1	2
693	771	13	2
694	772	4	2
695	773	1	1
696	773	2	2
697	776	3	2
698	777	1	2
699	778	3	1
700	779	2	2
701	780	4	1
702	780	2	2
703	783	2	2
704	787	1	2
705	788	1	2
706	789	1	1
707	789	1	2
708	792	1	2
709	793	5	2
710	793	2	2
711	794	3	2
712	795	3	1
713	795	4	2
714	799	6	2
715	803	5	2
716	803	4	2
717	804	3	2
718	805	3	1
719	805	2	2
720	805	11	2
721	808	3	2
722	809	1	2
723	811	3	1
724	811	1	2
725	813	1	2
726	815	1	1
727	815	2	2
728	817	4	2
729	817	12	2
730	818	4	2
731	822	12	2
732	823	2	2
733	824	2	1
734	824	1	2
735	825	1	2
736	826	4	2
737	826	6	2
738	827	1	1
739	827	3	2
740	827	6	2
741	829	5	2
742	829	12	2
743	830	4	2
744	831	1	1
745	831	4	2
746	831	12	2
747	837	13	1
748	840	4	2
749	842	6	2
750	845	3	2
751	846	3	1
752	846	4	2
753	849	1	2
754	849	9	2
755	850	2	2
756	851	2	1
757	851	1	2
758	854	5	2
759	855	1	2
760	856	2	1
761	856	4	2
762	857	5	1
763	860	1	1
764	860	4	2
765	863	1	1
766	863	3	2
767	864	5	1
768	770	5	1
\.


--
-- Name: skills_statuses_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('skills_statuses_sequence', 768, true);


--
-- Data for Name: skills_type; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY skills_type (id, name) FROM stdin;
1	mistery
2	chase
3	standard
4	passive
\.


--
-- Name: skills_type_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('skills_type_sequence', 4, true);


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: combo
--

COPY statuses (id, name, alias) FROM stdin;
1	Knock Down	knockdown
2	Repulse	repulse
3	Low Float	low_float
4	High Float	high_float
5	High Combo	high_combo
6	Poisoning	poisoning
7	Sleeping	sleeping
8	Paralysis	paralysis
9	Ignition	ignition
10	Tag	tag
11	Blindness	blindness
12	Acupuncture	acupuncture
13	Immobile	immobile
\.


--
-- Name: statuses_sequence; Type: SEQUENCE SET; Schema: public; Owner: combo
--

SELECT pg_catalog.setval('statuses_sequence', 13, true);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

