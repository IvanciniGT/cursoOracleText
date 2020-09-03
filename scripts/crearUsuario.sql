/*
Permitir al usuario sys hacer cosas
*/
alter session set "_ORACLE_SCRIPT"=true;

/*
Crear usuario: USUARIO
*/
CREATE USER usuario IDENTIFIED BY password;

/*
Asignar permisos
*/
GRANT RESOURCE, CONNECT, DBA TO usuario;

/*
Crear un tablespace
*/
CREATE TABLESPACE usuario_tbs DATAFILE '/home/oracle/usuariotbs' SIZE 1G REUSE AUTOEXTEND ON NEXT 500M MAXSIZE 5G;
/*
Asignarle el tablespace
*/
ALTER USER usuario DEFAULT TABLESPACE usuario_tbs;
GRANT UNLIMITED TABLESPACE TO usuario;

/*
Queremos trabajar con Oracle TEXT:
Asignar una serie de permisos especiales al usuario
*/
GRANT EXECUTE ON CTXSYS.CTX_CLS TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_DDL TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_DOC TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_OUTPUT TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_QUERY TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_REPORT TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_THES TO usuario;
GRANT EXECUTE ON CTXSYS.CTX_ULEXER TO usuario;