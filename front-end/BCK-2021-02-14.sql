PGDMP     3    "                y            contracts_linexperts    12.5    12.5 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    17106    contracts_linexperts    DATABASE     �   CREATE DATABASE contracts_linexperts WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_Canada.1252' LC_CTYPE = 'English_Canada.1252';
 $   DROP DATABASE contracts_linexperts;
                postgres    false                        2615    17107    linexpert_schema    SCHEMA         CREATE SCHEMA linexpert_schema;
    DROP SCHEMA linexpert_schema;
                postgres    false            �           0    0    SCHEMA linexpert_schema    ACL     0   GRANT ALL ON SCHEMA linexpert_schema TO PUBLIC;
                   postgres    false    8                        3079    25741    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2            z           1247    17109    id_doc    TYPE     p   CREATE TYPE public.id_doc AS ENUM (
    'SSN Number',
    'Identification Card',
    'Passport',
    'Other'
);
    DROP TYPE public.id_doc;
       public          postgres    false            }           1247    17118    work_status    TYPE     l   CREATE TYPE public.work_status AS ENUM (
    'Retired',
    'Active',
    'Suspended',
    'On Vacation'
);
    DROP TYPE public.work_status;
       public          postgres    false            ,           1255    17671    add_new_cext_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.add_new_cext_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  def_con_ext varchar :='001';
  def_initial_values numeric :=0;   
BEGIN
 INSERT INTO linexpert_schema.contract_extension(con_id, cext_id, cext_start_date,cext_end_date, cext_closure_date, cext_status, cext_total_cost, cext_invoiced_cost) 
  VALUES (NEW.con_id, def_con_ext,NEW.con_start_date,NEW.con_end_date,NULL,NEW.con_status,def_initial_values,def_initial_values);
RETURN NEW;
END;
 $$;
 4   DROP FUNCTION linexpert_schema.add_new_cext_func();
       linexpert_schema          postgres    false    8            -           1255    17673    update_con_enddat_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.update_con_enddat_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE linexpert_schema.contract_header
    SET "con_end_date"= NEW.cext_end_date 
	WHERE (con_id=NEW.con_id) AND (NEW.cext_end_date >= 
	    (SELECT MAX(cext_end_date)
       FROM linexpert_schema.contract_extension 
	   WHERE con_id=NEW.con_id));
   RETURN NEW;
END;
$$;
 9   DROP FUNCTION linexpert_schema.update_con_enddat_func();
       linexpert_schema          postgres    false    8            3           1255    25780    valid_add_cext_constat_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_add_cext_constat_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF ((SELECT con_status FROM linexpert_schema.contract_header as ch
	WHERE ch.con_id=NEW.con_id)='Terminado') 
	THEN
     RAISE EXCEPTION 'A contract extensions can not be added under a terminated contract, choose an active contract';
	 END IF;
	 IF (SELECT con_start_date FROM linexpert_schema.contract_header as sc
	WHERE sc.con_id=NEW.con_id)> NEW.cext_start_date
	THEN
     RAISE EXCEPTION 'The start date of a contract extension must be equal or later than the  contract start date';
	 END IF;
   RETURN NEW;
   END;
  $$;
 >   DROP FUNCTION linexpert_schema.valid_add_cext_constat_func();
       linexpert_schema          postgres    false    8            5           1255    25786    valid_cext_closure_func()    FUNCTION     F  CREATE FUNCTION linexpert_schema.valid_cext_closure_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF NEW.con_status='Terminado' AND (NEW.cext_closure_date IS NULL) 
	 THEN
	   RAISE EXCEPTION 'An addendum being terminated must have a closure date, this is null';
	 END IF;  
   RETURN NEW;
   END;
  $$;
 :   DROP FUNCTION linexpert_schema.valid_cext_closure_func();
       linexpert_schema          postgres    false    8            8           1255    26224    valid_client_cont_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_client_cont_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
   IF ((SELECT count(con_id) FROM linexpert_schema.contract_header AS ch
where con_status != 'Terminado' AND ch.clt_id=NEW.clt_id)>0 AND           (NEW.clt_status='Inactivo'))
	 THEN
     RAISE EXCEPTION 'A client having active contracts can not be deactivated, this client has active contracts';
 END IF;
RETURN NEW;
END;
 $$;
 9   DROP FUNCTION linexpert_schema.valid_client_cont_func();
       linexpert_schema          postgres    false    8            0           1255    17667    valid_client_stat_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_client_stat_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
   IF ((SELECT count(clt_id)  FROM linexpert_schema.client AS cl WHERE clt_status='Activo' AND cl.group_id=NEW.group_id)>0 AND (NEW.group_status='Inactivo'))
	 THEN
     RAISE EXCEPTION 'A group having active clients can not be deactivated, this group has active clients';
 END IF;
RETURN NEW;
END;
$$;
 9   DROP FUNCTION linexpert_schema.valid_client_stat_func();
       linexpert_schema          postgres    false    8            4           1255    25784    valid_con_cext_status_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_con_cext_status_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF NEW.con_status='Terminado' AND (NEW.con_closure_date IS NULL) 
	 THEN
	   RAISE EXCEPTION 'A contract being terminated must have a closure date, this is null';
	 END IF;  
	 IF ((SELECT COUNT(cext_id) FROM linexpert_schema.contract_extension as ce
	WHERE cext_status!='Terminado' AND ce.con_id=NEW.con_id)>0 AND (NEW.con_status='Terminado'))
	THEN
     RAISE EXCEPTION 'A contract having active contract extensions can not be deactivated, this contract has active contract extensions';
	 END IF;
   RETURN NEW;
   END;
  $$;
 =   DROP FUNCTION linexpert_schema.valid_con_cext_status_func();
       linexpert_schema          postgres    false    8            6           1255    26202    valid_dates_serv_con_func()    FUNCTION       CREATE FUNCTION linexpert_schema.valid_dates_serv_con_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF ((SELECT cext_start_date FROM linexpert_schema.contract_extension as ce
	WHERE ce.con_id=NEW.con_id AND ce.cext_id=NEW.cext_id)>NEW.ser_start_date) 
	THEN
     RAISE EXCEPTION 'The start date of a service on a contract extension must be equal or later than the main contract extension start date';
	 END IF;
	   IF ((SELECT cext_end_date FROM linexpert_schema.contract_extension as ce
	WHERE ce.con_id=NEW.con_id AND ce.cext_id=NEW.cext_id)<NEW.ser_end_date) 
	THEN
     RAISE EXCEPTION 'The end date of a service on a contract extension must be equal or earlier than the main contract extension end date';
	 END IF;
	 RETURN NEW;
   END;
   $$;
 <   DROP FUNCTION linexpert_schema.valid_dates_serv_con_func();
       linexpert_schema          postgres    false    8            2           1255    17684    valid_dates_wrk_srv_func()    FUNCTION     1  CREATE FUNCTION linexpert_schema.valid_dates_wrk_srv_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF ((SELECT ser_start_date FROM linexpert_schema.service_by_contract as sc
	WHERE sc.con_id=NEW.con_id AND sc.cext_id=NEW.cext_id AND sc.ser_id=NEW.ser_id)>NEW.wrk_ser_start_date) 
	THEN
     RAISE EXCEPTION 'The start date of a workforce assigned to a service  must be equal or later than the service by contract start date';
	 END IF;
	      IF ((SELECT ser_end_date FROM linexpert_schema.service_by_contract as sc
	WHERE sc.con_id=NEW.con_id AND sc.cext_id=NEW.cext_id AND sc.ser_id=NEW.ser_id)<NEW.wrk_ser_end_date) 
	THEN
     RAISE EXCEPTION 'The end date of a workforce assigned to a service  must be equal or earlier than the service by contract end date';
	 END IF;
	 RETURN NEW;
   END;
$$;
 ;   DROP FUNCTION linexpert_schema.valid_dates_wrk_srv_func();
       linexpert_schema          postgres    false    8            /           1255    17665    valid_group_stat_func()    FUNCTION     w  CREATE FUNCTION linexpert_schema.valid_group_stat_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF (SELECT group_status FROM linexpert_schema.corporate_group AS gr
       WHERE gr.group_id = NEW.group_id)='Inactivo' THEN
     RAISE EXCEPTION 'A client must be assigned to an active group, this one is inactive';
   END IF;
   RETURN NEW;
   END;
   $$;
 8   DROP FUNCTION linexpert_schema.valid_group_stat_func();
       linexpert_schema          postgres    false    8            7           1255    26208    valid_wrk_q_ass_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_wrk_q_ass_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
  IF (SELECT COUNT(wq.wrk_id) FROM linexpert_schema.workforce_on_service   AS wq  WHERE wq.ser_id=NEW.ser_id AND wq.wrk_id=NEW.wrk_id)>0
THEN
     RAISE EXCEPTION 'This workforce has at least one assignement for this qualification on a contract. It can not be deleted';
	 END IF;
	 RETURN NEW;
   END;
   $$;
 7   DROP FUNCTION linexpert_schema.valid_wrk_q_ass_func();
       linexpert_schema          postgres    false    8            1           1255    17686    valid_wrk_srv_q_func()    FUNCTION     �  CREATE FUNCTION linexpert_schema.valid_wrk_srv_q_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
     IF (SELECT COUNT(wq.wrk_id) FROM linexpert_schema.workforce_qualification AS wq
	     WHERE wq.ser_id=NEW.ser_id AND wq.wrk_id=NEW.wrk_id)=0
	THEN
     RAISE EXCEPTION 'This workforce resource does not have the qualification for the service assigned';
	 END IF;
	 RETURN NEW;
   END;
$$;
 7   DROP FUNCTION linexpert_schema.valid_wrk_srv_q_func();
       linexpert_schema          postgres    false    8            .           1255    17680    valid_wrk_stat_assig_func()    FUNCTION     v  CREATE FUNCTION linexpert_schema.valid_wrk_stat_assig_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   BEGIN
     IF (SELECT wrk_status FROM linexpert_schema.workforce AS wf
	     WHERE wf.wrk_id = NEW.wrk_id)='En Retiro' THEN
     RAISE EXCEPTION 'Workforce resource must not be retired to be assigned. This one is retired';
	 END IF;
   RETURN NEW; 
   END;
  $$;
 <   DROP FUNCTION linexpert_schema.valid_wrk_stat_assig_func();
       linexpert_schema          postgres    false    8            �            1259    17127    client    TABLE     �  CREATE TABLE linexpert_schema.client (
    clt_id character varying(30) NOT NULL,
    group_id character varying(30) NOT NULL,
    clt_identification character varying(45) NOT NULL,
    clt_official_name character varying(40) NOT NULL,
    clt_commercial_name character varying(40) NOT NULL,
    clt_first_name character varying(40) NOT NULL,
    clt_last_name character varying(40) NOT NULL,
    clt_address character varying(50) NOT NULL,
    clt_city character varying(20) NOT NULL,
    clt_region character varying(20) NOT NULL,
    clt_country character varying(20) NOT NULL,
    clt_phone_no character varying(20) NOT NULL,
    clt_cell_no character varying(20) DEFAULT 'No Number Saved'::character varying,
    clt_email_addr character varying(55) DEFAULT 'TBD'::character varying,
    clt_status character varying(10),
    CONSTRAINT "Clt_id_type" CHECK (((clt_identification)::text = ANY (ARRAY['CC- CEDULA DE CIUDADANIA'::text, 'CE- CEDULA DE EXTRANJERIA'::text, 'NIT- NUM. DE IDENTIF. TRIBUTARIA'::text, 'RUT- REGISTRO UNICO TRIBUTARIO'::text, 'TI- TARJETA DE IDENTIDAD'::text, 'SSN- SOCIAL SECURITY NUMBER'::text, 'PPN- PASAPORTE INTERNACIONAL'::text, 'CRCPF- CEDULA PERSONAL FISICA'::text, 'CPJ- CEDULA PERSONAL JURIDICA'::text, 'DIMEX- DOC. IDENTIF. MIGRACION Y EXTRANJERIA'::text, 'DIDI- DOC. IDENTIF. DIPLOMATICOS'::text]))),
    CONSTRAINT "clt_status Values" CHECK (((clt_status)::text = ANY (ARRAY['Activo'::text, 'Inactivo'::text])))
);
 $   DROP TABLE linexpert_schema.client;
       linexpert_schema         heap    postgres    false    8            �           0    0 "   CONSTRAINT "Clt_id_type" ON client    COMMENT     c   COMMENT ON CONSTRAINT "Clt_id_type" ON linexpert_schema.client IS 'Accepted values for Client_ID';
          linexpert_schema          postgres    false    204            �           0    0 (   CONSTRAINT "clt_status Values" ON client    COMMENT     [   COMMENT ON CONSTRAINT "clt_status Values" ON linexpert_schema.client IS 'Values accepted';
          linexpert_schema          postgres    false    204            �            1259    17152    contract_extension    TABLE     �  CREATE TABLE linexpert_schema.contract_extension (
    con_id character varying(30) NOT NULL,
    cext_id character varying(27) NOT NULL,
    cext_start_date date NOT NULL,
    cext_end_date date NOT NULL,
    cext_closure_date date,
    cext_status character varying(16) NOT NULL,
    cext_total_cost numeric(13,2),
    cext_invoiced_cost numeric(13,2) DEFAULT 0.00,
    CONSTRAINT "Status_Values" CHECK (((cext_status)::text = ANY (ARRAY['En Tramite'::text, 'Vigente'::text, 'Terminado'::text]))),
    CONSTRAINT cext_date_closure_date CHECK ((cext_closure_date >= cext_end_date)),
    CONSTRAINT cext_end_date CHECK ((cext_end_date > cext_start_date))
);
 0   DROP TABLE linexpert_schema.contract_extension;
       linexpert_schema         heap    postgres    false    8            �           0    0 0   CONSTRAINT "Status_Values" ON contract_extension    COMMENT     c   COMMENT ON CONSTRAINT "Status_Values" ON linexpert_schema.contract_extension IS 'Values accepted';
          linexpert_schema          postgres    false    207            �           0    0 7   CONSTRAINT cext_date_closure_date ON contract_extension    COMMENT     {   COMMENT ON CONSTRAINT cext_date_closure_date ON linexpert_schema.contract_extension IS 'Accepted values for closure date';
          linexpert_schema          postgres    false    207            �           0    0 .   CONSTRAINT cext_end_date ON contract_extension    COMMENT     s   COMMENT ON CONSTRAINT cext_end_date ON linexpert_schema.contract_extension IS 'Accepted values for cext_end_date';
          linexpert_schema          postgres    false    207            �            1259    17142    contract_header    TABLE     �  CREATE TABLE linexpert_schema.contract_header (
    con_id character varying(30) NOT NULL,
    clt_id character varying(30) NOT NULL,
    con_description character varying(300),
    con_start_date date NOT NULL,
    con_end_date date NOT NULL,
    con_closure_date date,
    con_status character varying(11),
    sent_to_rup boolean DEFAULT false,
    date_sent_to_rup date,
    CONSTRAINT "Contract_Status" CHECK (((con_status)::text = ANY (ARRAY['En Tramite'::text, 'Vigente'::text, 'Terminado'::text]))),
    CONSTRAINT "Start_Date_validation" CHECK ((con_start_date < con_end_date)),
    CONSTRAINT con_closure_date_validation CHECK ((con_closure_date >= con_end_date)),
    CONSTRAINT con_end_date_validation CHECK ((con_end_date > con_start_date))
);
 -   DROP TABLE linexpert_schema.contract_header;
       linexpert_schema         heap    postgres    false    8            �           0    0 /   CONSTRAINT "Contract_Status" ON contract_header    COMMENT     b   COMMENT ON CONSTRAINT "Contract_Status" ON linexpert_schema.contract_header IS 'Accepted Values';
          linexpert_schema          postgres    false    206            �            1259    17133    corporate_group    TABLE     k  CREATE TABLE linexpert_schema.corporate_group (
    group_id character varying(30) NOT NULL,
    group_name character varying(40) NOT NULL,
    group_address character varying(50) NOT NULL,
    group_city character varying(20) NOT NULL,
    group_region character varying(20) NOT NULL,
    group_country character varying(20) NOT NULL,
    group_phone_no character varying(20) NOT NULL,
    group_email character varying(55) NOT NULL,
    group_identification character varying(45),
    group_status character varying(10),
    CONSTRAINT "Corporate_group_Id" CHECK (((group_identification)::text = ANY (ARRAY['CC- CEDULA DE CIUDADANIA'::text, 'CE- CEDULA DE EXTRANJERIA'::text, 'NIT- NUM. DE IDENTIF. TRIBUTARIA'::text, 'RUT- REGISTRO UNICO TRIBUTARIO'::text, 'SSN- SOCIAL SECURITY NUMBER'::text, 'PPN- PASAPORTE INTERNACIONAL'::text, 'CRCPF- CEDULA PERSONAL FISICA'::text, 'CPJ- CEDULA PERSONAL JURIDICA'::text, 'DIMEX- DOC. IDENTIF. MIGRACION Y EXTRANJERIA'::text, 'DIDI- DOC. IDENTIF. DIPLOMATICOS'::text]))),
    CONSTRAINT "Group_Staus_Values" CHECK (((group_status)::text = ANY (ARRAY['Activo'::text, 'Inactivo'::text])))
);
 -   DROP TABLE linexpert_schema.corporate_group;
       linexpert_schema         heap    postgres    false    8            �           0    0 2   CONSTRAINT "Corporate_group_Id" ON corporate_group    COMMENT     r   COMMENT ON CONSTRAINT "Corporate_group_Id" ON linexpert_schema.corporate_group IS 'Identification type accepted';
          linexpert_schema          postgres    false    205            �           0    0 2   CONSTRAINT "Group_Staus_Values" ON corporate_group    COMMENT     e   COMMENT ON CONSTRAINT "Group_Staus_Values" ON linexpert_schema.corporate_group IS 'Values Accepted';
          linexpert_schema          postgres    false    205            �            1259    26089    linexperts_user    TABLE       CREATE TABLE linexpert_schema.linexperts_user (
    id integer NOT NULL,
    email_address character varying(255) NOT NULL,
    encrypte_password character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    role_id integer
);
 -   DROP TABLE linexpert_schema.linexperts_user;
       linexpert_schema         heap    postgres    false    8            �            1259    26087    linexperts_user_id_seq    SEQUENCE     �   CREATE SEQUENCE linexpert_schema.linexperts_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE linexpert_schema.linexperts_user_id_seq;
       linexpert_schema          postgres    false    8    239            �           0    0    linexperts_user_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE linexpert_schema.linexperts_user_id_seq OWNED BY linexpert_schema.linexperts_user.id;
          linexpert_schema          postgres    false    238            �            1259    25910 
   privileges    TABLE     o   CREATE TABLE linexpert_schema.privileges (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);
 (   DROP TABLE linexpert_schema.privileges;
       linexpert_schema         heap    postgres    false    8            �            1259    26100    role    TABLE     a   CREATE TABLE linexpert_schema.role (
    id integer NOT NULL,
    name character varying(255)
);
 "   DROP TABLE linexpert_schema.role;
       linexpert_schema         heap    postgres    false    8            �            1259    26098    role_id_seq    SEQUENCE     �   CREATE SEQUENCE linexpert_schema.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE linexpert_schema.role_id_seq;
       linexpert_schema          postgres    false    8    241            �           0    0    role_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE linexpert_schema.role_id_seq OWNED BY linexpert_schema.role.id;
          linexpert_schema          postgres    false    240            �            1259    26106    roles_privileges    TABLE     t   CREATE TABLE linexpert_schema.roles_privileges (
    role_id integer NOT NULL,
    privilege_id integer NOT NULL
);
 .   DROP TABLE linexpert_schema.roles_privileges;
       linexpert_schema         heap    postgres    false    8            �            1259    17156    service    TABLE     a  CREATE TABLE linexpert_schema.service (
    ser_id integer NOT NULL,
    ser_name character varying(50) NOT NULL,
    ser_description character varying(150) DEFAULT 'Empty'::character varying,
    ser_tariff numeric(9,2) DEFAULT 0 NOT NULL,
    ser_unit character varying(10),
    CONSTRAINT service_ser_tarrif_ck CHECK ((ser_tariff > (0)::numeric))
);
 %   DROP TABLE linexpert_schema.service;
       linexpert_schema         heap    postgres    false    8            �           0    0 +   CONSTRAINT service_ser_tarrif_ck ON service    COMMENT     ^   COMMENT ON CONSTRAINT service_ser_tarrif_ck ON linexpert_schema.service IS 'Accepted values';
          linexpert_schema          postgres    false    208            �            1259    17166    service_by_contract    TABLE     �  CREATE TABLE linexpert_schema.service_by_contract (
    con_id character varying(30) NOT NULL,
    cext_id character varying(27) NOT NULL,
    ser_id integer NOT NULL,
    ser_start_date date NOT NULL,
    ser_end_date date,
    unit_crt integer DEFAULT 0,
    tot_serv integer DEFAULT 0,
    CONSTRAINT "Tot_serv" CHECK ((tot_serv > 0)),
    CONSTRAINT "Units_by_serv" CHECK ((unit_crt > 0))
);
 1   DROP TABLE linexpert_schema.service_by_contract;
       linexpert_schema         heap    postgres    false    8            �           0    0 ,   CONSTRAINT "Tot_serv" ON service_by_contract    COMMENT     _   COMMENT ON CONSTRAINT "Tot_serv" ON linexpert_schema.service_by_contract IS 'Accepted values';
          linexpert_schema          postgres    false    209            �           0    0 1   CONSTRAINT "Units_by_serv" ON service_by_contract    COMMENT     d   COMMENT ON CONSTRAINT "Units_by_serv" ON linexpert_schema.service_by_contract IS 'Accepted values';
          linexpert_schema          postgres    false    209            �            1259    17169    service_ser_id_seq    SEQUENCE     �   CREATE SEQUENCE linexpert_schema.service_ser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE linexpert_schema.service_ser_id_seq;
       linexpert_schema          postgres    false    208    8            �           0    0    service_ser_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE linexpert_schema.service_ser_id_seq OWNED BY linexpert_schema.service.ser_id;
          linexpert_schema          postgres    false    210            �            1259    26192    users    TABLE     �   CREATE TABLE linexpert_schema.users (
    email_address character varying(255) NOT NULL,
    user_password character varying(255),
    user_role character varying(255)
);
 #   DROP TABLE linexpert_schema.users;
       linexpert_schema         heap    postgres    false    8            �            1259    17623    vw_client_group    VIEW     ~  CREATE VIEW linexpert_schema.vw_client_group AS
 SELECT corporate_group.group_id,
    corporate_group.group_identification,
    corporate_group.group_name,
    corporate_group.group_address,
    corporate_group.group_city,
    corporate_group.group_region,
    corporate_group.group_country,
    corporate_group.group_phone_no,
    corporate_group.group_email,
    corporate_group.group_status,
    client.clt_id,
    client.clt_identification,
    client.clt_official_name,
    client.clt_commercial_name,
    client.clt_address,
    client.clt_first_name,
    client.clt_last_name,
    client.clt_phone_no,
    client.clt_cell_no,
    client.clt_email_addr,
    client.clt_status,
    client.clt_region,
    client.clt_country,
    client.clt_city
   FROM (linexpert_schema.corporate_group
     JOIN linexpert_schema.client ON (((corporate_group.group_id)::text = (client.group_id)::text)));
 ,   DROP VIEW linexpert_schema.vw_client_group;
       linexpert_schema          postgres    false    204    204    204    204    204    204    204    204    204    204    204    204    204    204    204    205    205    205    205    205    205    205    205    205    205    8            �            1259    25715    vw_cont_clt_gr_vl    VIEW     �  CREATE VIEW linexpert_schema.vw_cont_clt_gr_vl AS
 SELECT vwc.group_id,
    vwc.group_name,
    vwc.group_region,
    vwc.group_country,
    vwc.group_city,
    vwc.group_status,
    cont_h.clt_id,
    vwc.clt_region,
    vwc.clt_country,
    vwc.clt_city,
    vwc.clt_status,
    vwc.clt_official_name,
    vwc.clt_commercial_name,
    con_ext.con_id,
    cont_h.con_description,
    cont_h.con_start_date,
    cont_h.con_end_date,
    cont_h.con_closure_date,
    cont_h.con_status,
    cont_h.sent_to_rup,
    cont_h.date_sent_to_rup,
    con_ext.cext_id,
    con_ext.cext_start_date,
    con_ext.cext_end_date,
    con_ext.cext_closure_date,
    con_ext.cext_status,
    con_ext.cext_total_cost,
    con_ext.cext_invoiced_cost
   FROM ((linexpert_schema.contract_extension con_ext
     JOIN linexpert_schema.contract_header cont_h ON (((con_ext.con_id)::text = (cont_h.con_id)::text)))
     JOIN linexpert_schema.vw_client_group vwc ON (((cont_h.clt_id)::text = (vwc.clt_id)::text)));
 .   DROP VIEW linexpert_schema.vw_cont_clt_gr_vl;
       linexpert_schema          postgres    false    207    218    218    218    218    218    218    218    218    218    218    218    218    206    206    206    206    206    206    207    207    218    207    207    207    207    206    206    206    207    8            �            1259    26214    vw_ser_cont_detail    VIEW     P  CREATE VIEW linexpert_schema.vw_ser_cont_detail AS
 SELECT vc.con_id,
    vc.cext_id,
    vc.group_id,
    vc.group_name,
    vc.group_status,
    vc.clt_id,
    vc.clt_official_name,
    vc.clt_status,
    vc.clt_commercial_name,
    vc.con_description,
    vc.con_status,
    vc.cext_status,
    vc.con_start_date,
    vc.cext_start_date,
    vc.con_end_date,
    vc.cext_end_date,
    vc.cext_total_cost,
    vc.cext_invoiced_cost,
    sbc.ser_id,
    sv.ser_name,
    sv.ser_description,
    sbc.ser_start_date,
    sbc.ser_end_date,
    sbc.unit_crt,
    sbc.tot_serv
   FROM ((linexpert_schema.vw_cont_clt_gr_vl vc
     LEFT JOIN linexpert_schema.service_by_contract sbc ON ((((vc.con_id)::text = (sbc.con_id)::text) AND ((vc.cext_id)::text = (sbc.cext_id)::text))))
     LEFT JOIN linexpert_schema.service sv ON ((sbc.ser_id = sv.ser_id)));
 /   DROP VIEW linexpert_schema.vw_ser_cont_detail;
       linexpert_schema          postgres    false    219    219    219    219    219    219    219    219    219    219    219    219    219    219    219    219    219    209    209    209    209    209    209    209    208    208    208    219    8            �            1259    17171 	   workforce    TABLE       CREATE TABLE linexpert_schema.workforce (
    wrk_id character varying(30) NOT NULL,
    wrk_address character varying(45),
    wrk_cell_no character varying(20),
    wrk_city character varying(25),
    wrk_country character varying(25),
    wrk_corp_email character varying(55),
    wrk_first_name character varying(30),
    wrk_last_name character varying(30),
    wrk_sec_last_name character varying(30),
    wrk_mid_name character varying(30),
    wrk_phone_no character varying(20),
    wrk_region character varying(25),
    wrk_status character varying(25),
    CONSTRAINT "Wrkforce_Status" CHECK (((wrk_status)::text = ANY (ARRAY['En Labor'::text, 'En Incapacidad'::text, 'En Vacaciones'::text, 'En Licencia no remunerada'::text, 'En Licencia remunerada'::text, 'En Retiro'::text])))
);
 '   DROP TABLE linexpert_schema.workforce;
       linexpert_schema         heap    postgres    false    8            �           0    0 )   CONSTRAINT "Wrkforce_Status" ON workforce    COMMENT     l   COMMENT ON CONSTRAINT "Wrkforce_Status" ON linexpert_schema.workforce IS 'Acceptable status for workforce';
          linexpert_schema          postgres    false    211            �            1259    17177    workforce_on_service    TABLE     �  CREATE TABLE linexpert_schema.workforce_on_service (
    con_id character varying(30) NOT NULL,
    cext_id character varying(27) NOT NULL,
    ser_id integer NOT NULL,
    wrk_id character varying(30) NOT NULL,
    assigned_date date,
    wrk_ser_start_date date NOT NULL,
    wrk_ser_end_date date,
    CONSTRAINT wrk_assigned_date_ck CHECK ((assigned_date <= wrk_ser_start_date)),
    CONSTRAINT wrk_end_date_ck CHECK ((wrk_ser_end_date > wrk_ser_start_date))
);
 2   DROP TABLE linexpert_schema.workforce_on_service;
       linexpert_schema         heap    postgres    false    8            �            1259    26219    vw_wrk_assigned    VIEW     1  CREATE VIEW linexpert_schema.vw_wrk_assigned AS
 SELECT vs.con_id,
    vs.con_description,
    vs.con_status,
    vs.cext_id,
    vs.group_id,
    vs.group_name,
    vs.clt_id,
    vs.clt_official_name,
    vs.clt_commercial_name,
    vs.clt_status,
    vs.cext_status,
    vs.con_start_date,
    vs.cext_start_date,
    vs.con_end_date,
    vs.cext_end_date,
    vs.cext_total_cost,
    vs.cext_invoiced_cost,
    vs.ser_id,
    vs.ser_name,
    vs.ser_description,
    wrk_sv.wrk_id,
    wrk.wrk_first_name,
    wrk.wrk_last_name,
    wrk.wrk_status,
    wrk_sv.assigned_date,
    wrk_sv.wrk_ser_start_date,
    wrk_sv.wrk_ser_end_date
   FROM ((linexpert_schema.vw_ser_cont_detail vs
     LEFT JOIN linexpert_schema.workforce_on_service wrk_sv ON ((((vs.con_id)::text = (wrk_sv.con_id)::text) AND ((vs.cext_id)::text = (wrk_sv.cext_id)::text) AND (vs.ser_id = wrk_sv.ser_id))))
     LEFT JOIN linexpert_schema.workforce wrk ON (((wrk.wrk_id)::text = (wrk_sv.wrk_id)::text)))
  ORDER BY vs.group_name, vs.clt_commercial_name, vs.con_id, wrk_sv.ser_id, wrk.wrk_last_name;
 ,   DROP VIEW linexpert_schema.vw_wrk_assigned;
       linexpert_schema          postgres    false    250    211    211    211    211    212    212    212    212    212    212    212    250    250    250    250    250    250    250    250    250    250    250    250    250    250    250    250    250    250    250    8            �            1259    17182    workforce_qualification    TABLE     �   CREATE TABLE linexpert_schema.workforce_qualification (
    ser_id integer NOT NULL,
    wrk_id character varying(30) NOT NULL
);
 5   DROP TABLE linexpert_schema.workforce_qualification;
       linexpert_schema         heap    postgres    false    8            �            1259    17586    vw_wrk_qualif    VIEW     �  CREATE VIEW linexpert_schema.vw_wrk_qualif AS
 SELECT wf.wrk_id,
    wf.wrk_first_name,
    wf.wrk_last_name,
    wf.wrk_sec_last_name,
    wf.wrk_mid_name,
    wf.wrk_status,
    wq.ser_id,
    sv.ser_name,
    sv.ser_description
   FROM ((linexpert_schema.workforce wf
     JOIN linexpert_schema.workforce_qualification wq ON (((wf.wrk_id)::text = (wq.wrk_id)::text)))
     JOIN linexpert_schema.service sv ON ((wq.ser_id = sv.ser_id)))
  ORDER BY wf.wrk_id, wq.ser_id;
 *   DROP VIEW linexpert_schema.vw_wrk_qualif;
       linexpert_schema          postgres    false    211    211    211    211    213    213    208    208    208    211    211    8            �            1259    26131    batch_job_execution    TABLE     �  CREATE TABLE public.batch_job_execution (
    job_execution_id bigint NOT NULL,
    version bigint,
    job_instance_id bigint NOT NULL,
    create_time timestamp without time zone NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    status character varying(10),
    exit_code character varying(2500),
    exit_message character varying(2500),
    last_updated timestamp without time zone,
    job_configuration_location character varying(2500)
);
 '   DROP TABLE public.batch_job_execution;
       public         heap    postgres    false            �            1259    26178    batch_job_execution_context    TABLE     �   CREATE TABLE public.batch_job_execution_context (
    job_execution_id bigint NOT NULL,
    short_context character varying(2500) NOT NULL,
    serialized_context text
);
 /   DROP TABLE public.batch_job_execution_context;
       public         heap    postgres    false            �            1259    26144    batch_job_execution_params    TABLE     `  CREATE TABLE public.batch_job_execution_params (
    job_execution_id bigint NOT NULL,
    type_cd character varying(6) NOT NULL,
    key_name character varying(100) NOT NULL,
    string_val character varying(250),
    date_val timestamp without time zone,
    long_val bigint,
    double_val double precision,
    identifying character(1) NOT NULL
);
 .   DROP TABLE public.batch_job_execution_params;
       public         heap    postgres    false            �            1259    17482    batch_job_execution_seq    SEQUENCE     �   CREATE SEQUENCE public.batch_job_execution_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.batch_job_execution_seq;
       public          postgres    false            �            1259    26124    batch_job_instance    TABLE     �   CREATE TABLE public.batch_job_instance (
    job_instance_id bigint NOT NULL,
    version bigint,
    job_name character varying(100) NOT NULL,
    job_key character varying(32) NOT NULL
);
 &   DROP TABLE public.batch_job_instance;
       public         heap    postgres    false            �            1259    17484    batch_job_seq    SEQUENCE     v   CREATE SEQUENCE public.batch_job_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.batch_job_seq;
       public          postgres    false            �            1259    26152    batch_step_execution    TABLE     �  CREATE TABLE public.batch_step_execution (
    step_execution_id bigint NOT NULL,
    version bigint NOT NULL,
    step_name character varying(100) NOT NULL,
    job_execution_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    status character varying(10),
    commit_count bigint,
    read_count bigint,
    filter_count bigint,
    write_count bigint,
    read_skip_count bigint,
    write_skip_count bigint,
    process_skip_count bigint,
    rollback_count bigint,
    exit_code character varying(2500),
    exit_message character varying(2500),
    last_updated timestamp without time zone
);
 (   DROP TABLE public.batch_step_execution;
       public         heap    postgres    false            �            1259    26165    batch_step_execution_context    TABLE     �   CREATE TABLE public.batch_step_execution_context (
    step_execution_id bigint NOT NULL,
    short_context character varying(2500) NOT NULL,
    serialized_context text
);
 0   DROP TABLE public.batch_step_execution_context;
       public         heap    postgres    false            �            1259    17480    batch_step_execution_seq    SEQUENCE     �   CREATE SEQUENCE public.batch_step_execution_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.batch_step_execution_seq;
       public          postgres    false            �            1259    25966    client    TABLE     �  CREATE TABLE public.client (
    clt_id character varying(255) NOT NULL,
    clt_address character varying(255),
    clt_cell_no character varying(255),
    clt_city character varying(255),
    clt_commercial_name character varying(255),
    clt_country character varying(255),
    clt_email_addr character varying(255),
    clt_first_name character varying(255),
    clt_identification character varying(255),
    clt_last_name character varying(255),
    clt_official_name character varying(255),
    clt_phone_no character varying(255),
    clt_region character varying(255),
    clt_status character varying(255),
    group_id character varying(255)
);
    DROP TABLE public.client;
       public         heap    postgres    false            �            1259    25974    contract_extension    TABLE     I  CREATE TABLE public.contract_extension (
    cext_id character varying(255) NOT NULL,
    con_id character varying(255) NOT NULL,
    cext_closure_date date,
    cext_end_date date,
    cext_invoiced_cost double precision,
    cext_start_date date,
    cext_status character varying(255),
    cext_total_cost double precision
);
 &   DROP TABLE public.contract_extension;
       public         heap    postgres    false            �            1259    25982    contract_header    TABLE     I  CREATE TABLE public.contract_header (
    con_id character varying(255) NOT NULL,
    clt_id character varying(255),
    con_closure_date date,
    con_description character varying(255),
    con_end_date date,
    con_start_date date,
    con_status character varying(255),
    date_sent_to_rup date,
    sent_to_rup boolean
);
 #   DROP TABLE public.contract_header;
       public         heap    postgres    false            �            1259    25990    corporate_group    TABLE     �  CREATE TABLE public.corporate_group (
    group_id character varying(255) NOT NULL,
    group_address character varying(255),
    group_city character varying(255),
    group_country character varying(255),
    group_email character varying(255),
    group_identification character varying(255),
    group_name character varying(255),
    group_phone_no character varying(255),
    group_region character varying(255),
    group_status character varying(255)
);
 #   DROP TABLE public.corporate_group;
       public         heap    postgres    false            �            1259    26000    linexperts_user    TABLE       CREATE TABLE public.linexperts_user (
    id integer NOT NULL,
    email_address character varying(255) NOT NULL,
    encrypte_password character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    role_id integer
);
 #   DROP TABLE public.linexperts_user;
       public         heap    postgres    false            �            1259    25998    linexperts_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.linexperts_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.linexperts_user_id_seq;
       public          postgres    false    230            �           0    0    linexperts_user_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.linexperts_user_id_seq OWNED BY public.linexperts_user.id;
          public          postgres    false    229            �            1259    25936 
   privileges    TABLE     f   CREATE TABLE public.privileges (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);
    DROP TABLE public.privileges;
       public         heap    postgres    false            �            1259    25934    privileges_id_seq    SEQUENCE     �   CREATE SEQUENCE public.privileges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.privileges_id_seq;
       public          postgres    false    222            �           0    0    privileges_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.privileges_id_seq OWNED BY public.privileges.id;
          public          postgres    false    221            �            1259    25944    role    TABLE     W   CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(255)
);
    DROP TABLE public.role;
       public         heap    postgres    false            �            1259    25942    role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.role_id_seq;
       public          postgres    false    224            �           0    0    role_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;
          public          postgres    false    223            �            1259    26009    roles_privileges    TABLE     j   CREATE TABLE public.roles_privileges (
    role_id integer NOT NULL,
    privilege_id integer NOT NULL
);
 $   DROP TABLE public.roles_privileges;
       public         heap    postgres    false            �            1259    26014    service    TABLE     �   CREATE TABLE public.service (
    ser_id integer NOT NULL,
    ser_description character varying(255),
    ser_name character varying(255),
    ser_tariff double precision,
    ser_unit character varying(255)
);
    DROP TABLE public.service;
       public         heap    postgres    false            �            1259    26023    service_by_contract    TABLE     �   CREATE TABLE public.service_by_contract (
    cext_id character varying(255) NOT NULL,
    con_id character varying(255) NOT NULL,
    ser_id integer NOT NULL,
    ser_start_date date,
    ser_end_date date
);
 '   DROP TABLE public.service_by_contract;
       public         heap    postgres    false            �            1259    26012    service_ser_id_seq    SEQUENCE     �   CREATE SEQUENCE public.service_ser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.service_ser_id_seq;
       public          postgres    false    233            �           0    0    service_ser_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.service_ser_id_seq OWNED BY public.service.ser_id;
          public          postgres    false    232            �            1259    26031 	   workforce    TABLE     9  CREATE TABLE public.workforce (
    wrk_id character varying(255) NOT NULL,
    wrk_address character varying(255),
    wrk_cell_no character varying(255),
    wrk_city character varying(255),
    wrk_corp_email character varying(255),
    wrk_country character varying(255),
    wrk_first_name character varying(255),
    wrk_last_name character varying(255),
    wrk_mid_name character varying(255),
    wrk_phone_no character varying(255),
    wrk_region character varying(255),
    wrk_sec_last_name character varying(255),
    wrk_status character varying(255)
);
    DROP TABLE public.workforce;
       public         heap    postgres    false            �            1259    26039    workforce_on_service    TABLE       CREATE TABLE public.workforce_on_service (
    cext_id character varying(255) NOT NULL,
    con_id character varying(255) NOT NULL,
    ser_id integer NOT NULL,
    wrk_id character varying(255) NOT NULL,
    assigned_date date,
    wrk_ser_end_date date,
    wrk_ser_start_date date
);
 (   DROP TABLE public.workforce_on_service;
       public         heap    postgres    false            �            1259    26047    workforce_qualification    TABLE     y   CREATE TABLE public.workforce_qualification (
    ser_id integer NOT NULL,
    wrk_id character varying(255) NOT NULL
);
 +   DROP TABLE public.workforce_qualification;
       public         heap    postgres    false            �           2604    26092    linexperts_user id    DEFAULT     �   ALTER TABLE ONLY linexpert_schema.linexperts_user ALTER COLUMN id SET DEFAULT nextval('linexpert_schema.linexperts_user_id_seq'::regclass);
 K   ALTER TABLE linexpert_schema.linexperts_user ALTER COLUMN id DROP DEFAULT;
       linexpert_schema          postgres    false    239    238    239            �           2604    26103    role id    DEFAULT     v   ALTER TABLE ONLY linexpert_schema.role ALTER COLUMN id SET DEFAULT nextval('linexpert_schema.role_id_seq'::regclass);
 @   ALTER TABLE linexpert_schema.role ALTER COLUMN id DROP DEFAULT;
       linexpert_schema          postgres    false    241    240    241            �           2604    17191    service ser_id    DEFAULT     �   ALTER TABLE ONLY linexpert_schema.service ALTER COLUMN ser_id SET DEFAULT nextval('linexpert_schema.service_ser_id_seq'::regclass);
 G   ALTER TABLE linexpert_schema.service ALTER COLUMN ser_id DROP DEFAULT;
       linexpert_schema          postgres    false    210    208            �           2604    26003    linexperts_user id    DEFAULT     x   ALTER TABLE ONLY public.linexperts_user ALTER COLUMN id SET DEFAULT nextval('public.linexperts_user_id_seq'::regclass);
 A   ALTER TABLE public.linexperts_user ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229    230            �           2604    25939    privileges id    DEFAULT     n   ALTER TABLE ONLY public.privileges ALTER COLUMN id SET DEFAULT nextval('public.privileges_id_seq'::regclass);
 <   ALTER TABLE public.privileges ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    222    222            �           2604    25947    role id    DEFAULT     b   ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);
 6   ALTER TABLE public.role ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    223    224    224            �           2604    26017    service ser_id    DEFAULT     p   ALTER TABLE ONLY public.service ALTER COLUMN ser_id SET DEFAULT nextval('public.service_ser_id_seq'::regclass);
 =   ALTER TABLE public.service ALTER COLUMN ser_id DROP DEFAULT;
       public          postgres    false    232    233    233            �          0    17127    client 
   TABLE DATA           �   COPY linexpert_schema.client (clt_id, group_id, clt_identification, clt_official_name, clt_commercial_name, clt_first_name, clt_last_name, clt_address, clt_city, clt_region, clt_country, clt_phone_no, clt_cell_no, clt_email_addr, clt_status) FROM stdin;
    linexpert_schema          postgres    false    204   �c      �          0    17152    contract_extension 
   TABLE DATA           �   COPY linexpert_schema.contract_extension (con_id, cext_id, cext_start_date, cext_end_date, cext_closure_date, cext_status, cext_total_cost, cext_invoiced_cost) FROM stdin;
    linexpert_schema          postgres    false    207   �g      �          0    17142    contract_header 
   TABLE DATA           �   COPY linexpert_schema.contract_header (con_id, clt_id, con_description, con_start_date, con_end_date, con_closure_date, con_status, sent_to_rup, date_sent_to_rup) FROM stdin;
    linexpert_schema          postgres    false    206   �i      �          0    17133    corporate_group 
   TABLE DATA           �   COPY linexpert_schema.corporate_group (group_id, group_name, group_address, group_city, group_region, group_country, group_phone_no, group_email, group_identification, group_status) FROM stdin;
    linexpert_schema          postgres    false    205   kk      �          0    26089    linexperts_user 
   TABLE DATA           y   COPY linexpert_schema.linexperts_user (id, email_address, encrypte_password, first_name, last_name, role_id) FROM stdin;
    linexpert_schema          postgres    false    239   �n      �          0    25910 
   privileges 
   TABLE DATA           8   COPY linexpert_schema.privileges (id, name) FROM stdin;
    linexpert_schema          postgres    false    220   $o      �          0    26100    role 
   TABLE DATA           2   COPY linexpert_schema.role (id, name) FROM stdin;
    linexpert_schema          postgres    false    241   do      �          0    26106    roles_privileges 
   TABLE DATA           K   COPY linexpert_schema.roles_privileges (role_id, privilege_id) FROM stdin;
    linexpert_schema          postgres    false    242   �o      �          0    17156    service 
   TABLE DATA           d   COPY linexpert_schema.service (ser_id, ser_name, ser_description, ser_tariff, ser_unit) FROM stdin;
    linexpert_schema          postgres    false    208   �o      �          0    17166    service_by_contract 
   TABLE DATA           �   COPY linexpert_schema.service_by_contract (con_id, cext_id, ser_id, ser_start_date, ser_end_date, unit_crt, tot_serv) FROM stdin;
    linexpert_schema          postgres    false    209   �p      �          0    26192    users 
   TABLE DATA           R   COPY linexpert_schema.users (email_address, user_password, user_role) FROM stdin;
    linexpert_schema          postgres    false    249   �r      �          0    17171 	   workforce 
   TABLE DATA           �   COPY linexpert_schema.workforce (wrk_id, wrk_address, wrk_cell_no, wrk_city, wrk_country, wrk_corp_email, wrk_first_name, wrk_last_name, wrk_sec_last_name, wrk_mid_name, wrk_phone_no, wrk_region, wrk_status) FROM stdin;
    linexpert_schema          postgres    false    211   �r      �          0    17177    workforce_on_service 
   TABLE DATA           �   COPY linexpert_schema.workforce_on_service (con_id, cext_id, ser_id, wrk_id, assigned_date, wrk_ser_start_date, wrk_ser_end_date) FROM stdin;
    linexpert_schema          postgres    false    212   =v      �          0    17182    workforce_qualification 
   TABLE DATA           K   COPY linexpert_schema.workforce_qualification (ser_id, wrk_id) FROM stdin;
    linexpert_schema          postgres    false    213   �x      �          0    26131    batch_job_execution 
   TABLE DATA           �   COPY public.batch_job_execution (job_execution_id, version, job_instance_id, create_time, start_time, end_time, status, exit_code, exit_message, last_updated, job_configuration_location) FROM stdin;
    public          postgres    false    244   hy      �          0    26178    batch_job_execution_context 
   TABLE DATA           j   COPY public.batch_job_execution_context (job_execution_id, short_context, serialized_context) FROM stdin;
    public          postgres    false    248   �y      �          0    26144    batch_job_execution_params 
   TABLE DATA           �   COPY public.batch_job_execution_params (job_execution_id, type_cd, key_name, string_val, date_val, long_val, double_val, identifying) FROM stdin;
    public          postgres    false    245   �y      �          0    26124    batch_job_instance 
   TABLE DATA           Y   COPY public.batch_job_instance (job_instance_id, version, job_name, job_key) FROM stdin;
    public          postgres    false    243   �y      �          0    26152    batch_step_execution 
   TABLE DATA           (  COPY public.batch_step_execution (step_execution_id, version, step_name, job_execution_id, start_time, end_time, status, commit_count, read_count, filter_count, write_count, read_skip_count, write_skip_count, process_skip_count, rollback_count, exit_code, exit_message, last_updated) FROM stdin;
    public          postgres    false    246   �y      �          0    26165    batch_step_execution_context 
   TABLE DATA           l   COPY public.batch_step_execution_context (step_execution_id, short_context, serialized_context) FROM stdin;
    public          postgres    false    247   �y      �          0    25966    client 
   TABLE DATA           �   COPY public.client (clt_id, clt_address, clt_cell_no, clt_city, clt_commercial_name, clt_country, clt_email_addr, clt_first_name, clt_identification, clt_last_name, clt_official_name, clt_phone_no, clt_region, clt_status, group_id) FROM stdin;
    public          postgres    false    225   z      �          0    25974    contract_extension 
   TABLE DATA           �   COPY public.contract_extension (cext_id, con_id, cext_closure_date, cext_end_date, cext_invoiced_cost, cext_start_date, cext_status, cext_total_cost) FROM stdin;
    public          postgres    false    226   3z      �          0    25982    contract_header 
   TABLE DATA           �   COPY public.contract_header (con_id, clt_id, con_closure_date, con_description, con_end_date, con_start_date, con_status, date_sent_to_rup, sent_to_rup) FROM stdin;
    public          postgres    false    227   Pz      �          0    25990    corporate_group 
   TABLE DATA           �   COPY public.corporate_group (group_id, group_address, group_city, group_country, group_email, group_identification, group_name, group_phone_no, group_region, group_status) FROM stdin;
    public          postgres    false    228   mz      �          0    26000    linexperts_user 
   TABLE DATA           o   COPY public.linexperts_user (id, email_address, encrypte_password, first_name, last_name, role_id) FROM stdin;
    public          postgres    false    230   �z      �          0    25936 
   privileges 
   TABLE DATA           .   COPY public.privileges (id, name) FROM stdin;
    public          postgres    false    222   �z      �          0    25944    role 
   TABLE DATA           (   COPY public.role (id, name) FROM stdin;
    public          postgres    false    224   �z      �          0    26009    roles_privileges 
   TABLE DATA           A   COPY public.roles_privileges (role_id, privilege_id) FROM stdin;
    public          postgres    false    231   1{      �          0    26014    service 
   TABLE DATA           Z   COPY public.service (ser_id, ser_description, ser_name, ser_tariff, ser_unit) FROM stdin;
    public          postgres    false    233   N{      �          0    26023    service_by_contract 
   TABLE DATA           d   COPY public.service_by_contract (cext_id, con_id, ser_id, ser_start_date, ser_end_date) FROM stdin;
    public          postgres    false    234   k{      �          0    26031 	   workforce 
   TABLE DATA           �   COPY public.workforce (wrk_id, wrk_address, wrk_cell_no, wrk_city, wrk_corp_email, wrk_country, wrk_first_name, wrk_last_name, wrk_mid_name, wrk_phone_no, wrk_region, wrk_sec_last_name, wrk_status) FROM stdin;
    public          postgres    false    235   �{      �          0    26039    workforce_on_service 
   TABLE DATA           �   COPY public.workforce_on_service (cext_id, con_id, ser_id, wrk_id, assigned_date, wrk_ser_end_date, wrk_ser_start_date) FROM stdin;
    public          postgres    false    236   �{      �          0    26047    workforce_qualification 
   TABLE DATA           A   COPY public.workforce_qualification (ser_id, wrk_id) FROM stdin;
    public          postgres    false    237   �{      �           0    0    linexperts_user_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('linexpert_schema.linexperts_user_id_seq', 1, true);
          linexpert_schema          postgres    false    238            �           0    0    role_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('linexpert_schema.role_id_seq', 1, false);
          linexpert_schema          postgres    false    240            �           0    0    service_ser_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('linexpert_schema.service_ser_id_seq', 117, true);
          linexpert_schema          postgres    false    210            �           0    0    batch_job_execution_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.batch_job_execution_seq', 71, true);
          public          postgres    false    215            �           0    0    batch_job_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.batch_job_seq', 71, true);
          public          postgres    false    216            �           0    0    batch_step_execution_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.batch_step_execution_seq', 71, true);
          public          postgres    false    214            �           0    0    linexperts_user_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.linexperts_user_id_seq', 1, false);
          public          postgres    false    229            �           0    0    privileges_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.privileges_id_seq', 1, false);
          public          postgres    false    221            �           0    0    role_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.role_id_seq', 1, false);
          public          postgres    false    223            �           0    0    service_ser_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.service_ser_id_seq', 1, false);
          public          postgres    false    232            �           2606    17193    client client_clt_id_key 
   CONSTRAINT     _   ALTER TABLE ONLY linexpert_schema.client
    ADD CONSTRAINT client_clt_id_key UNIQUE (clt_id);
 L   ALTER TABLE ONLY linexpert_schema.client DROP CONSTRAINT client_clt_id_key;
       linexpert_schema            postgres    false    204            �           2606    17195    client client_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY linexpert_schema.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (clt_id, group_id);
 F   ALTER TABLE ONLY linexpert_schema.client DROP CONSTRAINT client_pkey;
       linexpert_schema            postgres    false    204    204            z           2606    26204    contract_header con_date_rup    CHECK CONSTRAINT     �   ALTER TABLE linexpert_schema.contract_header
    ADD CONSTRAINT con_date_rup CHECK ((date_sent_to_rup <= CURRENT_DATE)) NOT VALID;
 K   ALTER TABLE linexpert_schema.contract_header DROP CONSTRAINT con_date_rup;
       linexpert_schema          postgres    false    206    206            �           2606    17199 *   contract_extension contract_extension_pkey 
   CONSTRAINT        ALTER TABLE ONLY linexpert_schema.contract_extension
    ADD CONSTRAINT contract_extension_pkey PRIMARY KEY (con_id, cext_id);
 ^   ALTER TABLE ONLY linexpert_schema.contract_extension DROP CONSTRAINT contract_extension_pkey;
       linexpert_schema            postgres    false    207    207            �           2606    17297 $   contract_header contract_header_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY linexpert_schema.contract_header
    ADD CONSTRAINT contract_header_pkey PRIMARY KEY (con_id);
 X   ALTER TABLE ONLY linexpert_schema.contract_header DROP CONSTRAINT contract_header_pkey;
       linexpert_schema            postgres    false    206            �           2606    17201 /   corporate_group corporate_group_group_email_key 
   CONSTRAINT     {   ALTER TABLE ONLY linexpert_schema.corporate_group
    ADD CONSTRAINT corporate_group_group_email_key UNIQUE (group_email);
 c   ALTER TABLE ONLY linexpert_schema.corporate_group DROP CONSTRAINT corporate_group_group_email_key;
       linexpert_schema            postgres    false    205            �           2606    17203 $   corporate_group corporate_group_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY linexpert_schema.corporate_group
    ADD CONSTRAINT corporate_group_pkey PRIMARY KEY (group_id);
 X   ALTER TABLE ONLY linexpert_schema.corporate_group DROP CONSTRAINT corporate_group_pkey;
       linexpert_schema            postgres    false    205            �           2606    26097 $   linexperts_user linexperts_user_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY linexpert_schema.linexperts_user
    ADD CONSTRAINT linexperts_user_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY linexpert_schema.linexperts_user DROP CONSTRAINT linexperts_user_pkey;
       linexpert_schema            postgres    false    239            �           2606    25914    privileges privileges_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY linexpert_schema.privileges
    ADD CONSTRAINT privileges_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY linexpert_schema.privileges DROP CONSTRAINT privileges_pkey;
       linexpert_schema            postgres    false    220            �           2606    26105    role role_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY linexpert_schema.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY linexpert_schema.role DROP CONSTRAINT role_pkey;
       linexpert_schema            postgres    false    241            �           2606    17205 ,   service_by_contract service_by_contract_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.service_by_contract
    ADD CONSTRAINT service_by_contract_pkey PRIMARY KEY (con_id, cext_id, ser_id);
 `   ALTER TABLE ONLY linexpert_schema.service_by_contract DROP CONSTRAINT service_by_contract_pkey;
       linexpert_schema            postgres    false    209    209    209            �           2606    17207    service service_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY linexpert_schema.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (ser_id);
 H   ALTER TABLE ONLY linexpert_schema.service DROP CONSTRAINT service_pkey;
       linexpert_schema            postgres    false    208            �           2606    26199    users users_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY linexpert_schema.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (email_address);
 D   ALTER TABLE ONLY linexpert_schema.users DROP CONSTRAINT users_pkey;
       linexpert_schema            postgres    false    249            �           2606    17209 .   workforce_on_service workforce_on_service_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_on_service
    ADD CONSTRAINT workforce_on_service_pkey PRIMARY KEY (con_id, cext_id, ser_id, wrk_id);
 b   ALTER TABLE ONLY linexpert_schema.workforce_on_service DROP CONSTRAINT workforce_on_service_pkey;
       linexpert_schema            postgres    false    212    212    212    212            �           2606    17211    workforce workforce_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY linexpert_schema.workforce
    ADD CONSTRAINT workforce_pkey PRIMARY KEY (wrk_id);
 L   ALTER TABLE ONLY linexpert_schema.workforce DROP CONSTRAINT workforce_pkey;
       linexpert_schema            postgres    false    211            �           2606    17213 4   workforce_qualification workforce_qualification_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_qualification
    ADD CONSTRAINT workforce_qualification_pkey PRIMARY KEY (ser_id, wrk_id);
 h   ALTER TABLE ONLY linexpert_schema.workforce_qualification DROP CONSTRAINT workforce_qualification_pkey;
       linexpert_schema            postgres    false    213    213            �           2606    26185 <   batch_job_execution_context batch_job_execution_context_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.batch_job_execution_context
    ADD CONSTRAINT batch_job_execution_context_pkey PRIMARY KEY (job_execution_id);
 f   ALTER TABLE ONLY public.batch_job_execution_context DROP CONSTRAINT batch_job_execution_context_pkey;
       public            postgres    false    248            �           2606    26138 ,   batch_job_execution batch_job_execution_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.batch_job_execution
    ADD CONSTRAINT batch_job_execution_pkey PRIMARY KEY (job_execution_id);
 V   ALTER TABLE ONLY public.batch_job_execution DROP CONSTRAINT batch_job_execution_pkey;
       public            postgres    false    244            �           2606    26128 *   batch_job_instance batch_job_instance_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.batch_job_instance
    ADD CONSTRAINT batch_job_instance_pkey PRIMARY KEY (job_instance_id);
 T   ALTER TABLE ONLY public.batch_job_instance DROP CONSTRAINT batch_job_instance_pkey;
       public            postgres    false    243            �           2606    26172 >   batch_step_execution_context batch_step_execution_context_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.batch_step_execution_context
    ADD CONSTRAINT batch_step_execution_context_pkey PRIMARY KEY (step_execution_id);
 h   ALTER TABLE ONLY public.batch_step_execution_context DROP CONSTRAINT batch_step_execution_context_pkey;
       public            postgres    false    247            �           2606    26159 .   batch_step_execution batch_step_execution_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.batch_step_execution
    ADD CONSTRAINT batch_step_execution_pkey PRIMARY KEY (step_execution_id);
 X   ALTER TABLE ONLY public.batch_step_execution DROP CONSTRAINT batch_step_execution_pkey;
       public            postgres    false    246            �           2606    25973    client client_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (clt_id);
 <   ALTER TABLE ONLY public.client DROP CONSTRAINT client_pkey;
       public            postgres    false    225            �           2606    25981 *   contract_extension contract_extension_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.contract_extension
    ADD CONSTRAINT contract_extension_pkey PRIMARY KEY (cext_id, con_id);
 T   ALTER TABLE ONLY public.contract_extension DROP CONSTRAINT contract_extension_pkey;
       public            postgres    false    226    226            �           2606    25989 $   contract_header contract_header_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.contract_header
    ADD CONSTRAINT contract_header_pkey PRIMARY KEY (con_id);
 N   ALTER TABLE ONLY public.contract_header DROP CONSTRAINT contract_header_pkey;
       public            postgres    false    227            �           2606    25997 $   corporate_group corporate_group_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.corporate_group
    ADD CONSTRAINT corporate_group_pkey PRIMARY KEY (group_id);
 N   ALTER TABLE ONLY public.corporate_group DROP CONSTRAINT corporate_group_pkey;
       public            postgres    false    228            �           2606    26130    batch_job_instance job_inst_un 
   CONSTRAINT     f   ALTER TABLE ONLY public.batch_job_instance
    ADD CONSTRAINT job_inst_un UNIQUE (job_name, job_key);
 H   ALTER TABLE ONLY public.batch_job_instance DROP CONSTRAINT job_inst_un;
       public            postgres    false    243    243            �           2606    26008 $   linexperts_user linexperts_user_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.linexperts_user
    ADD CONSTRAINT linexperts_user_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.linexperts_user DROP CONSTRAINT linexperts_user_pkey;
       public            postgres    false    230            �           2606    25941    privileges privileges_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.privileges
    ADD CONSTRAINT privileges_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.privileges DROP CONSTRAINT privileges_pkey;
       public            postgres    false    222            �           2606    25949    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public            postgres    false    224            �           2606    26030 ,   service_by_contract service_by_contract_pkey 
   CONSTRAINT        ALTER TABLE ONLY public.service_by_contract
    ADD CONSTRAINT service_by_contract_pkey PRIMARY KEY (cext_id, con_id, ser_id);
 V   ALTER TABLE ONLY public.service_by_contract DROP CONSTRAINT service_by_contract_pkey;
       public            postgres    false    234    234    234            �           2606    26022    service service_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (ser_id);
 >   ALTER TABLE ONLY public.service DROP CONSTRAINT service_pkey;
       public            postgres    false    233            �           2606    26067 ,   corporate_group uk_2vq4mkdacicp7h95mpgv330jy 
   CONSTRAINT     q   ALTER TABLE ONLY public.corporate_group
    ADD CONSTRAINT uk_2vq4mkdacicp7h95mpgv330jy UNIQUE (group_phone_no);
 V   ALTER TABLE ONLY public.corporate_group DROP CONSTRAINT uk_2vq4mkdacicp7h95mpgv330jy;
       public            postgres    false    228            �           2606    26065 ,   corporate_group uk_9152ghexcyoe3ikmocehtynyj 
   CONSTRAINT     m   ALTER TABLE ONLY public.corporate_group
    ADD CONSTRAINT uk_9152ghexcyoe3ikmocehtynyj UNIQUE (group_name);
 V   ALTER TABLE ONLY public.corporate_group DROP CONSTRAINT uk_9152ghexcyoe3ikmocehtynyj;
       public            postgres    false    228            �           2606    26061 /   contract_extension uk_9lgor8cwj4o7ha3u8p0i4roen 
   CONSTRAINT     l   ALTER TABLE ONLY public.contract_extension
    ADD CONSTRAINT uk_9lgor8cwj4o7ha3u8p0i4roen UNIQUE (con_id);
 Y   ALTER TABLE ONLY public.contract_extension DROP CONSTRAINT uk_9lgor8cwj4o7ha3u8p0i4roen;
       public            postgres    false    226            �           2606    26057 #   client uk_eq9uhc6rfw4vpi0ctraupm36x 
   CONSTRAINT     h   ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_eq9uhc6rfw4vpi0ctraupm36x UNIQUE (clt_email_addr);
 M   ALTER TABLE ONLY public.client DROP CONSTRAINT uk_eq9uhc6rfw4vpi0ctraupm36x;
       public            postgres    false    225            �           2606    26053 #   client uk_gdeuxelfl81c0881afvqetggl 
   CONSTRAINT     e   ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_gdeuxelfl81c0881afvqetggl UNIQUE (clt_address);
 M   ALTER TABLE ONLY public.client DROP CONSTRAINT uk_gdeuxelfl81c0881afvqetggl;
       public            postgres    false    225            �           2606    26059 #   client uk_jh66q8xbhp33yqg66seaec0ed 
   CONSTRAINT     f   ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_jh66q8xbhp33yqg66seaec0ed UNIQUE (clt_phone_no);
 M   ALTER TABLE ONLY public.client DROP CONSTRAINT uk_jh66q8xbhp33yqg66seaec0ed;
       public            postgres    false    225            �           2606    26069 %   workforce uk_ju2g733a57vv2i7iwy9okvt1 
   CONSTRAINT     g   ALTER TABLE ONLY public.workforce
    ADD CONSTRAINT uk_ju2g733a57vv2i7iwy9okvt1 UNIQUE (wrk_cell_no);
 O   ALTER TABLE ONLY public.workforce DROP CONSTRAINT uk_ju2g733a57vv2i7iwy9okvt1;
       public            postgres    false    235            �           2606    26055 #   client uk_ns3l12rtg8n84q1b00ka69376 
   CONSTRAINT     e   ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_ns3l12rtg8n84q1b00ka69376 UNIQUE (clt_cell_no);
 M   ALTER TABLE ONLY public.client DROP CONSTRAINT uk_ns3l12rtg8n84q1b00ka69376;
       public            postgres    false    225            �           2606    26063 ,   corporate_group uk_pl580611nv7gd1pja7lhwuw35 
   CONSTRAINT     n   ALTER TABLE ONLY public.corporate_group
    ADD CONSTRAINT uk_pl580611nv7gd1pja7lhwuw35 UNIQUE (group_email);
 V   ALTER TABLE ONLY public.corporate_group DROP CONSTRAINT uk_pl580611nv7gd1pja7lhwuw35;
       public            postgres    false    228            �           2606    26071 &   workforce uk_t8suegsjc2yefbe8uqdd28mua 
   CONSTRAINT     k   ALTER TABLE ONLY public.workforce
    ADD CONSTRAINT uk_t8suegsjc2yefbe8uqdd28mua UNIQUE (wrk_corp_email);
 P   ALTER TABLE ONLY public.workforce DROP CONSTRAINT uk_t8suegsjc2yefbe8uqdd28mua;
       public            postgres    false    235            �           2606    26046 .   workforce_on_service workforce_on_service_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.workforce_on_service
    ADD CONSTRAINT workforce_on_service_pkey PRIMARY KEY (cext_id, con_id, ser_id, wrk_id);
 X   ALTER TABLE ONLY public.workforce_on_service DROP CONSTRAINT workforce_on_service_pkey;
       public            postgres    false    236    236    236    236            �           2606    26038    workforce workforce_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.workforce
    ADD CONSTRAINT workforce_pkey PRIMARY KEY (wrk_id);
 B   ALTER TABLE ONLY public.workforce DROP CONSTRAINT workforce_pkey;
       public            postgres    false    235            �           2606    26051 4   workforce_qualification workforce_qualification_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.workforce_qualification
    ADD CONSTRAINT workforce_qualification_pkey PRIMARY KEY (ser_id, wrk_id);
 ^   ALTER TABLE ONLY public.workforce_qualification DROP CONSTRAINT workforce_qualification_pkey;
       public            postgres    false    237    237            �           1259    17216    idx_cext_closure    INDEX     f   CREATE INDEX idx_cext_closure ON linexpert_schema.contract_extension USING btree (cext_closure_date);
 .   DROP INDEX linexpert_schema.idx_cext_closure;
       linexpert_schema            postgres    false    207            �           1259    17217    idx_cext_total_cost    INDEX     p   CREATE INDEX idx_cext_total_cost ON linexpert_schema.contract_extension USING btree (cext_id, cext_total_cost);
 1   DROP INDEX linexpert_schema.idx_cext_total_cost;
       linexpert_schema            postgres    false    207    207            �           1259    17218    idx_contr_closure    INDEX     c   CREATE INDEX idx_contr_closure ON linexpert_schema.contract_header USING btree (con_closure_date);
 /   DROP INDEX linexpert_schema.idx_contr_closure;
       linexpert_schema            postgres    false    206            �           1259    17219    idx_contr_rup_sent    INDEX     q   CREATE INDEX idx_contr_rup_sent ON linexpert_schema.contract_header USING btree (sent_to_rup, date_sent_to_rup);
 0   DROP INDEX linexpert_schema.idx_contr_rup_sent;
       linexpert_schema            postgres    false    206    206            �           1259    17220    idx_service_end    INDEX     a   CREATE INDEX idx_service_end ON linexpert_schema.service_by_contract USING btree (ser_end_date);
 -   DROP INDEX linexpert_schema.idx_service_end;
       linexpert_schema            postgres    false    209                       2620    17672     contract_header add_new_cext_trg    TRIGGER     �   CREATE TRIGGER add_new_cext_trg AFTER INSERT ON linexpert_schema.contract_header FOR EACH ROW EXECUTE FUNCTION linexpert_schema.add_new_cext_func();
 C   DROP TRIGGER add_new_cext_trg ON linexpert_schema.contract_header;
       linexpert_schema          postgres    false    206    300                       2620    17674 (   contract_extension update_con_enddat_trg    TRIGGER     �   CREATE TRIGGER update_con_enddat_trg AFTER INSERT OR UPDATE ON linexpert_schema.contract_extension FOR EACH ROW EXECUTE FUNCTION linexpert_schema.update_con_enddat_func();
 K   DROP TRIGGER update_con_enddat_trg ON linexpert_schema.contract_extension;
       linexpert_schema          postgres    false    301    207                       2620    25781 -   contract_extension valid_add_cext_constat_trg    TRIGGER     �   CREATE TRIGGER valid_add_cext_constat_trg BEFORE INSERT ON linexpert_schema.contract_extension FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_add_cext_constat_func();
 P   DROP TRIGGER valid_add_cext_constat_trg ON linexpert_schema.contract_extension;
       linexpert_schema          postgres    false    207    307                        2620    26225    client valid_client_cont_trg    TRIGGER     �   CREATE TRIGGER valid_client_cont_trg BEFORE UPDATE ON linexpert_schema.client FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_client_cont_func();
 ?   DROP TRIGGER valid_client_cont_trg ON linexpert_schema.client;
       linexpert_schema          postgres    false    204    312                       2620    17668 %   corporate_group valid_client_stat_trg    TRIGGER     �   CREATE TRIGGER valid_client_stat_trg BEFORE UPDATE ON linexpert_schema.corporate_group FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_client_stat_func();
 H   DROP TRIGGER valid_client_stat_trg ON linexpert_schema.corporate_group;
       linexpert_schema          postgres    false    205    304                       2620    25785 )   contract_header valid_con_cext_status_trg    TRIGGER     �   CREATE TRIGGER valid_con_cext_status_trg BEFORE UPDATE ON linexpert_schema.contract_header FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_con_cext_status_func();
 L   DROP TRIGGER valid_con_cext_status_trg ON linexpert_schema.contract_header;
       linexpert_schema          postgres    false    308    206                       2620    26203 ,   service_by_contract valid_dates_serv_con_trg    TRIGGER     �   CREATE TRIGGER valid_dates_serv_con_trg BEFORE INSERT OR UPDATE ON linexpert_schema.service_by_contract FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_dates_serv_con_func();
 O   DROP TRIGGER valid_dates_serv_con_trg ON linexpert_schema.service_by_contract;
       linexpert_schema          postgres    false    209    310            	           2620    17685 ,   workforce_on_service valid_dates_wrk_srv_trg    TRIGGER     �   CREATE TRIGGER valid_dates_wrk_srv_trg BEFORE INSERT OR UPDATE ON linexpert_schema.workforce_on_service FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_dates_wrk_srv_func();
 O   DROP TRIGGER valid_dates_wrk_srv_trg ON linexpert_schema.workforce_on_service;
       linexpert_schema          postgres    false    212    306                       2620    17666    client valid_group_stat_trg    TRIGGER     �   CREATE TRIGGER valid_group_stat_trg BEFORE INSERT OR UPDATE ON linexpert_schema.client FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_group_stat_func();
 >   DROP TRIGGER valid_group_stat_trg ON linexpert_schema.client;
       linexpert_schema          postgres    false    204    303                       2620    26209 +   workforce_qualification valid_wrk_q_ass_trg    TRIGGER     �   CREATE TRIGGER valid_wrk_q_ass_trg BEFORE DELETE ON linexpert_schema.workforce_qualification FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_wrk_q_ass_func();
 N   DROP TRIGGER valid_wrk_q_ass_trg ON linexpert_schema.workforce_qualification;
       linexpert_schema          postgres    false    311    213            
           2620    17687 (   workforce_on_service valid_wrk_srv_q_trg    TRIGGER     �   CREATE TRIGGER valid_wrk_srv_q_trg BEFORE INSERT OR UPDATE ON linexpert_schema.workforce_on_service FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_wrk_srv_q_func();
 K   DROP TRIGGER valid_wrk_srv_q_trg ON linexpert_schema.workforce_on_service;
       linexpert_schema          postgres    false    212    305                       2620    17681 -   workforce_on_service valid_wrk_stat_assig_trg    TRIGGER     �   CREATE TRIGGER valid_wrk_stat_assig_trg BEFORE INSERT OR UPDATE ON linexpert_schema.workforce_on_service FOR EACH ROW EXECUTE FUNCTION linexpert_schema.valid_wrk_stat_assig_func();
 P   DROP TRIGGER valid_wrk_stat_assig_trg ON linexpert_schema.workforce_on_service;
       linexpert_schema          postgres    false    212    302            �           2606    17291    contract_header clt_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.contract_header
    ADD CONSTRAINT clt_id_fk FOREIGN KEY (clt_id) REFERENCES linexpert_schema.client(clt_id);
 M   ALTER TABLE ONLY linexpert_schema.contract_header DROP CONSTRAINT clt_id_fk;
       linexpert_schema          postgres    false    204    2962    206            �           2606    17298    contract_extension con_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.contract_extension
    ADD CONSTRAINT con_id_fk FOREIGN KEY (con_id) REFERENCES linexpert_schema.contract_header(con_id);
 P   ALTER TABLE ONLY linexpert_schema.contract_extension DROP CONSTRAINT con_id_fk;
       linexpert_schema          postgres    false    207    206    2970            �           2606    17222    client corp_grp_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.client
    ADD CONSTRAINT corp_grp_fk FOREIGN KEY (group_id) REFERENCES linexpert_schema.corporate_group(group_id);
 F   ALTER TABLE ONLY linexpert_schema.client DROP CONSTRAINT corp_grp_fk;
       linexpert_schema          postgres    false    205    2968    204            �           2606    26114 ,   roles_privileges fk5duhoc7rwt8h06avv41o41cfy    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.roles_privileges
    ADD CONSTRAINT fk5duhoc7rwt8h06avv41o41cfy FOREIGN KEY (privilege_id) REFERENCES linexpert_schema.privileges(id);
 `   ALTER TABLE ONLY linexpert_schema.roles_privileges DROP CONSTRAINT fk5duhoc7rwt8h06avv41o41cfy;
       linexpert_schema          postgres    false    220    242    2989            �           2606    26119 ,   roles_privileges fk9h2vewsqh8luhfq71xokh4who    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.roles_privileges
    ADD CONSTRAINT fk9h2vewsqh8luhfq71xokh4who FOREIGN KEY (role_id) REFERENCES linexpert_schema.role(id);
 `   ALTER TABLE ONLY linexpert_schema.roles_privileges DROP CONSTRAINT fk9h2vewsqh8luhfq71xokh4who;
       linexpert_schema          postgres    false    241    242    3037            �           2606    17227 "   workforce_qualification fk_service    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_qualification
    ADD CONSTRAINT fk_service FOREIGN KEY (ser_id) REFERENCES linexpert_schema.service(ser_id);
 V   ALTER TABLE ONLY linexpert_schema.workforce_qualification DROP CONSTRAINT fk_service;
       linexpert_schema          postgres    false    208    213    2978            �           2606    17232 $   workforce_qualification fk_workforce    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_qualification
    ADD CONSTRAINT fk_workforce FOREIGN KEY (wrk_id) REFERENCES linexpert_schema.workforce(wrk_id);
 X   ALTER TABLE ONLY linexpert_schema.workforce_qualification DROP CONSTRAINT fk_workforce;
       linexpert_schema          postgres    false    213    211    2983            �           2606    26109 +   linexperts_user fksmm3boekkc331t7g93bej8lr0    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.linexperts_user
    ADD CONSTRAINT fksmm3boekkc331t7g93bej8lr0 FOREIGN KEY (role_id) REFERENCES linexpert_schema.role(id);
 _   ALTER TABLE ONLY linexpert_schema.linexperts_user DROP CONSTRAINT fksmm3boekkc331t7g93bej8lr0;
       linexpert_schema          postgres    false    241    3037    239            �           2606    17242 %   service_by_contract ser_by_service_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.service_by_contract
    ADD CONSTRAINT ser_by_service_fk FOREIGN KEY (ser_id) REFERENCES linexpert_schema.service(ser_id);
 Y   ALTER TABLE ONLY linexpert_schema.service_by_contract DROP CONSTRAINT ser_by_service_fk;
       linexpert_schema          postgres    false    2978    208    209            �           2606    17247 (   workforce_on_service wrk_service_cext_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_on_service
    ADD CONSTRAINT wrk_service_cext_fk FOREIGN KEY (con_id, cext_id) REFERENCES linexpert_schema.contract_extension(con_id, cext_id);
 \   ALTER TABLE ONLY linexpert_schema.workforce_on_service DROP CONSTRAINT wrk_service_cext_fk;
       linexpert_schema          postgres    false    2974    212    207    212    207            �           2606    17252 '   workforce_on_service wrk_service_emp_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_on_service
    ADD CONSTRAINT wrk_service_emp_fk FOREIGN KEY (wrk_id) REFERENCES linexpert_schema.workforce(wrk_id);
 [   ALTER TABLE ONLY linexpert_schema.workforce_on_service DROP CONSTRAINT wrk_service_emp_fk;
       linexpert_schema          postgres    false    2983    212    211            �           2606    17257 2   workforce_on_service wrk_service_service_master_fk    FK CONSTRAINT     �   ALTER TABLE ONLY linexpert_schema.workforce_on_service
    ADD CONSTRAINT wrk_service_service_master_fk FOREIGN KEY (ser_id) REFERENCES linexpert_schema.service(ser_id);
 f   ALTER TABLE ONLY linexpert_schema.workforce_on_service DROP CONSTRAINT wrk_service_service_master_fk;
       linexpert_schema          postgres    false    208    212    2978            �           2606    26077 ,   roles_privileges fk5duhoc7rwt8h06avv41o41cfy    FK CONSTRAINT     �   ALTER TABLE ONLY public.roles_privileges
    ADD CONSTRAINT fk5duhoc7rwt8h06avv41o41cfy FOREIGN KEY (privilege_id) REFERENCES public.privileges(id);
 V   ALTER TABLE ONLY public.roles_privileges DROP CONSTRAINT fk5duhoc7rwt8h06avv41o41cfy;
       public          postgres    false    231    2991    222            �           2606    26082 ,   roles_privileges fk9h2vewsqh8luhfq71xokh4who    FK CONSTRAINT     �   ALTER TABLE ONLY public.roles_privileges
    ADD CONSTRAINT fk9h2vewsqh8luhfq71xokh4who FOREIGN KEY (role_id) REFERENCES public.role(id);
 V   ALTER TABLE ONLY public.roles_privileges DROP CONSTRAINT fk9h2vewsqh8luhfq71xokh4who;
       public          postgres    false    231    224    2993            �           2606    26072 +   linexperts_user fksmm3boekkc331t7g93bej8lr0    FK CONSTRAINT     �   ALTER TABLE ONLY public.linexperts_user
    ADD CONSTRAINT fksmm3boekkc331t7g93bej8lr0 FOREIGN KEY (role_id) REFERENCES public.role(id);
 U   ALTER TABLE ONLY public.linexperts_user DROP CONSTRAINT fksmm3boekkc331t7g93bej8lr0;
       public          postgres    false    230    2993    224            �           2606    26186 +   batch_job_execution_context job_exec_ctx_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.batch_job_execution_context
    ADD CONSTRAINT job_exec_ctx_fk FOREIGN KEY (job_execution_id) REFERENCES public.batch_job_execution(job_execution_id);
 U   ALTER TABLE ONLY public.batch_job_execution_context DROP CONSTRAINT job_exec_ctx_fk;
       public          postgres    false    3043    248    244            �           2606    26147 -   batch_job_execution_params job_exec_params_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.batch_job_execution_params
    ADD CONSTRAINT job_exec_params_fk FOREIGN KEY (job_execution_id) REFERENCES public.batch_job_execution(job_execution_id);
 W   ALTER TABLE ONLY public.batch_job_execution_params DROP CONSTRAINT job_exec_params_fk;
       public          postgres    false    3043    244    245            �           2606    26160 %   batch_step_execution job_exec_step_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.batch_step_execution
    ADD CONSTRAINT job_exec_step_fk FOREIGN KEY (job_execution_id) REFERENCES public.batch_job_execution(job_execution_id);
 O   ALTER TABLE ONLY public.batch_step_execution DROP CONSTRAINT job_exec_step_fk;
       public          postgres    false    244    3043    246            �           2606    26139 $   batch_job_execution job_inst_exec_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.batch_job_execution
    ADD CONSTRAINT job_inst_exec_fk FOREIGN KEY (job_instance_id) REFERENCES public.batch_job_instance(job_instance_id);
 N   ALTER TABLE ONLY public.batch_job_execution DROP CONSTRAINT job_inst_exec_fk;
       public          postgres    false    3039    243    244            �           2606    26173 -   batch_step_execution_context step_exec_ctx_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.batch_step_execution_context
    ADD CONSTRAINT step_exec_ctx_fk FOREIGN KEY (step_execution_id) REFERENCES public.batch_step_execution(step_execution_id);
 W   ALTER TABLE ONLY public.batch_step_execution_context DROP CONSTRAINT step_exec_ctx_fk;
       public          postgres    false    246    247    3045            �   �  x���Qo�8��o��WD60o!��2�f�I��J�b�%�1vאv3�~/IVM�a��4����|�{�]��o�<��y̡��| ���%��	����x����2����o'd�����r�×�']ii�U�2Zٞ0(\�*�?���2�i�q����F%�$%w�J�mK����'�w�߷�TU������4�b�Y*B�x�Y^�Z��VV�ʵ�W�~qW"�����Y���(��q�����u�+��[Yz]IR+D!�½�Z�;嬄���#׮նqP����2GzAr�p��f�q��bkkme+}�?�qm��\)�)M���A;�c�i��0M}�e�7�� Xݥ?�.����ܥc�R����`�Zi!	Y9��S=Y�^���������ս���Uw4�&A��{!�Q�h�w���g�Lueܶ>���t�{�2�p�8���IX�V{��]�*�V���=�큉LI������z��W~ڴR�3d�/!�F�"��^zX83X��^�ڽ��EM��le�wq淶{�շwx,<L��&����RV�N[u��`��a"��5�G0�Ы�q�ݶ���4!72S�ڼ:W�B��((�Z�^���b���5˲cC�$�M[	t�4!�(KD"��H��Vn����'�k`�<���6��o��z�[Q��D�xH8�Ϻﻩt��7��1K/46�M0���6r0�3"J�\#�Y�c�c���#n]��g�^�]Y5ƕ�L�p�w��&�a�مm��`�p�U7��[���An���Yr�'0�����e���	w,J?-ƶ4���1��F�����6Θ"Rl�7�x	�a���{�?�f�s�O���4�r��r�q|�u�_�m�Fx3����ŵ�� *��Ψ}����L�;�~L{����@f��M�l|Q�:�������       �     x��T�n�0=;_�`!R�$��ح�`ء���E�%%ےeK`G��G>>r������� )e���4��1<����<��
��s����� ���p|{=�_~��0;���r����H13�"K�2P}ǨKH����x�tx{y=�'�D�h�+E&`�S��B����
-+���?ǳ�S�\��G�O(��b����$����Z���V���U��l$Z�N�����tX�.�Է��~���6�rb��� �M9+�^ 	A�Xdrn�κh�<�v�4ť�t��n2 BҶu򕲘M�pa���/)�����=|�2Y�k��l���/��?�/v��)f^Ul��zI~	�(@'=s�M9�V˦�y�����
�ݏe����7!���2l�Q���)t4��p����\nw٘����FYRS�Ɡ+���ǧr�S��������0F�խݳ�Y���?��Mt�^�Q�Pƚ�+���¦/�Ec.
=�k@�[H-������}~��v����      �   �  x���QK�0ǟ�O�/p��&i�(�PA'h�ɗ��Qp�t��^�vu����������%{��O�Y
���-�&���t�C
�X�Zi%&~�������8�_M|�k/H�D@׆�K���K��e���DY��d���$�0f-H^:`0�$Oc,8C@D �t��������(LE��uQΗ�h�Ϯ;H1ƀV{p2J���������~`����g�UeS�M|�lq�����y2<(��(��81}�W�����Mղ=New!7�a��L��z%�����K92�!c�,����_��B��i�-U�C�Qgb@�����g�E�Z �c��	��s'1���*���;A���YL���NU���0�� j#^�F��������iH�{ֆ�v8=�n�����
4�0lI��^EQ��K[g      �   *  x���K��F��5���G~c�`���3�\
��]��6��ӧ=)�DZr������Q�~Y-q�]����(��"/���W{�57�U�����9�qb<kye�lpb�� �b<��Q�[\{����beEE�Eq\B���y�Չo�`1�D���o��gw�����7�٧�f��M`�xu���ߐy��U^䰴�)������qfN�|N��Y������΁�Ųq��b��"dR�Eg#h�hw<�Ol�bn�k@��.���a��9�^�'�ʐi�"�q��=�7xg�'#_OJk���1_B���Z���q~,��"�kE�<)��-��b_!��"��Mp?/�W-̇#.������J�a:Vu�����Fݸ��Z�*J�"���Q�dI$sGe�[aN�rb�E�F�S��38��"'Z:1����=�i���Һ�{���''�p8��y���ʈ��Է\�T�n�-}{�XI�q�W�Mv�.����)D�+���0��st�y�LC[���Q%YmG�0v�f�eG�����8Ϊ�*�<��5����;	V����`˨�a<��0	1|��x�io�P��l��;��0vH\U�CV�f1����J�q�ՊF��Aљ1r"��ه���/�d#x7}.�*��$�P-9w���geT��i�{�y���LcޮMC �*�C/5�;��"�Y50��d���YSh:�&�v���FL�� <��� AG������<1`�+��Iz7(�$i�,����K��z6�qH�V��5������(��
���{s:3������͟���      �   o   x�3����K��L��u�M���K���T1JT14P	���3�3r��(�,�4/�K-KN-����4(3I3�L	�*ҳ�I*�L���s5I��L�I��,N�)KL�/�4����� �T t      �   0   x�3���v�rv��u�st�u��2�ttv����s����� �	�      �   :   x�3�ttv����s�2��pr�����u�st�u��2�tw�
� ���qqq �       �      x�3�4�2�4�2��@�h��c���� ;�7      �   �   x����n1E��W�P2�G�@%�DAj�l����f�Q�Am���j����,r�}tm`C��)2��Ib!��6�.9/�Ɵ	��LO��Ӌ�����i����X��	ǈ�yE�\�2�fp�-}ӝ�8�邷��X��f�a������nY�LR�!��c��)�"T߃%�Qw	���ԅ��[s�l^M�hx��	��w�
vt�1c����.�+�xf��.�r�Կ��/�fMu�(�~ l �-      �   �  x����n�0���]<%��8�	��IS;���cv�6�a
����>�߿���~�|�/���������ox�� � �!k�ء	<x=+.�����<``�{��]Pd�Æ��!H	���>�%�(A�T���Xh��o��j2>\�h'�[�F(��35�X��2Z��U�����K�|i�c}	�ߗ0�2qȈ���;מ[��2�E�&c)Λ4k
A�D�L��-����JF��D\������)5@S��V�hŲ*F5T��֭�]���7[�n�޼�7��x�#Z�
<�c:��X��h���f����d:��N��eǴ��2J�N�a:�z�n0��H��x����k�y��á�cm�{sғ����FV���@�1����՞X�zr��������
�D���-I<Jrh�Kw��̔��}^��ia/]oު�/�4� ���      �      x������ � �      �   U  x���Ms�H���_1�vG��|q[Kq�I,�+9�R��8L3Z@��_��1��%R�=O��v�z�x��j�X��V,��8!g��ڔ�,�����&LQ!��)��kw��03��ކ�/+��������f�U�+��.H�y�����9g�,l��p����q�y���"�)ݵ�?  }<�!�L`i�W�<@�}NO�)��ס���3�`��k��CD�Ed(Qs�]����d�~@����72 e�X��f���x8$��\�Ԯ�_�m=������:6m�p�q���fv�)�<F��M�g��lӒ�k���{1� VJ5SpU��:�9�#E3������i���`T}��S��7/�&��Oh1��(��8Ts]�P�E09�̩DG\زAi�������a��4��v-�Af��V�{VU��Si�S�u�AȄ�LY5Eԗ4����ҵ-�[���1馵����6Yp�vY���&2���"
�2�)#0��
[Ú�@���ɓ�.�[�޺��#��m�)vpU�*+��z�S���X*� c�#@E�&��޷ţ�{K�g�D��'��2���|�x昐�_�&9-����C��(�pW���*ؤJpiKrVVw!�5{4���0��#�;L���ڙ�i*w܁8�E:��C0����݆'g�e�ZwaMcK�{��sL�]j��}�m�gƩ���!q:Jc��z]���)y:�����А�����ו���0�
��FD�ÐQ�4�{��Ch��u����4H�<�Kp�-��|�.�|���ՠ�|�\�A~�߭<{sz(Jt(�R����4����b�!4�uY���>MNNN�/�D�      �   \  x��VɎ!=��R�Qp���iF�����#�=�x��i?a����O�o�?O��(&P% �é�ï����F|�����?�AJLRǁ&(t��C>�%RbEe$~5"�0"�@�"y���t�*E�u�WOɿ�H��qEO'���5��LQ��W*�/?�?=^`u�o ���m h��w�wŉg(�>x�	XJ��4y�Ie�l�v9ۗ���Ʉ7�1����#��(#R1��r�PTxϨ�ǁx�Y��MR�'Z=�;<�� �a�)֡&W�B3�5vH- ��;�oTW��3����7�X-�!'K����%�!�zG�,��h�Ҹ�5� 1�i,��-���<w�l�Ϟ�v��f�7�jt�ќ4{�x�����n>;j�5�����K���F��<k��wˍ�(�|Q��jX�����M��J��슘y#o�ojN�0�"m�M�ݢDnظAc;F[U������|�ip�[/k'v5xQ�R��:�����!����l��69��h�l�2`5��A+����ގ��F��h�5N����k��b,�i��}Q3����+�6[\�ǯ���?��      �   �   x�}�=B1�g{���8���x�sH_��jh�� _^������(�����Nl�,F&Ħ���
��9{hvmzb*L�GL����{���~��N��3��$�/����9.��M7Wu��p�9��Tsy�c��JV�4�$!H22�+O�R-�-	������1���ȴ/}_[k��x      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   0   x�3���v�rv��u�st�u��2�ttv����s����� �	�      �   :   x�3�ttv����s�2��pr�����u�st�u��2�tw�
� ���qqq �       �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �     