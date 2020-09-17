/*
multilenguaje
    id
    nombrefichero
    documento
    idioma. (spanish, english)
*/    
DROP TABLE multilenguaje;
CREATE TABLE multilenguaje (
    id          INTEGER ,
    fichero     VARCHAR2(500),
    idioma      VARCHAR2(20),
    contenido   BLOB,
    PRIMARY KEY (id)
);    

DROP SEQUENCE multilenguaje_id;
CREATE SEQUENCE multilenguaje_id;

CREATE OR REPLACE DIRECTORY CARPETA_FICHEROS_PDF AS '/home/oracle/documents/pdf';
CREATE OR REPLACE DIRECTORY CARPETA_FICHEROS_HTML AS '/home/oracle/documents/html';
CREATE OR REPLACE DIRECTORY CARPETA_FICHEROS_TXT AS '/home/oracle/documents/text';

CREATE OR REPLACE PROCEDURE cargar_fichero_por_idiomas
    (idioma IN VARCHAR2, CARPETA_FICHEROS IN VARCHAR2, input_fichero IN VARCHAR2, new_id OUT INTEGER) IS
        fichero_en_so           BFILE;
        blob_para_guardar       BLOB;
        longitud_del_fichero    BINARY_INTEGER;
BEGIN
    INSERT INTO multilenguaje 
        (id,fichero,idioma,contenido)
    VALUES
        (multilenguaje_id.nextval, input_fichero, idioma, EMPTY_BLOB() )
    RETURNING 
        id, contenido INTO new_id, blob_para_guardar;

    fichero_en_so := bfilename( CARPETA_FICHEROS, input_fichero);
    DBMS_LOB.OPEN( fichero_en_so , DBMS_LOB.FILE_READONLY);
    longitud_del_fichero := DBMS_LOB.getlength(fichero_en_so);
    DBMS_LOB.LOADFROMFILE (blob_para_guardar,  fichero_en_so , longitud_del_fichero);
    DBMS_LOB.CLOSE( fichero_en_so );
    COMMIT;
END cargar_fichero_por_idiomas;
/

SET SERVEROUTPUT ON;

DECLARE 
    new_id INTEGER;
BEGIN

    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_PDF',  'jenkins.pdf'  , new_id );
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_PDF',  'java.pdf' , new_id );
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_TXT',  'carrilleras.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'java.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'jenkins.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_TXT',  'pisto.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'python.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_HTML', 'bonito_con_pisto.html'  , new_id);
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_HTML', 'carrilleras.html'  , new_id);
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_HTML', 'pisto.html'  , new_id);

    DBMS_OUTPUT.PUT_LINE('Nuevo id' || new_id);
END; 
/
COMMIT;
