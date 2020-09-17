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

    DBMS_OUTPUT.PUT_LINE('Nuevo id: ' || new_id);
END; 
/
COMMIT;


/*
INDICES
*/

/*LEXER INGLES*/
exec ctx_ddl.create_preference('en_mi_blob_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'en_mi_blob_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'en_mi_blob_lexer', 'INDEX_STEMS', 'ENGLISH');        
exec ctx_ddl.set_attribute(    'en_mi_blob_lexer', 'MIXED_CASE', 'TRUE');        
/*LEXER  ESPAÑOL*/
exec ctx_ddl.create_preference('es_mi_blob_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'INDEX_STEMS', 'SPANISH');        
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'MIXED_CASE', 'TRUE');        
/* MULTILEXER*/
exec ctx_ddl.create_preference('mi_blob_lexer_multi_idioma', 'MULTI_LEXER');
exec ctx_ddl.add_sub_lexer(    'mi_blob_lexer_multi_idioma' , 'english', 'en_mi_blob_lexer'); 
exec ctx_ddl.add_sub_lexer(    'mi_blob_lexer_multi_idioma' , 'spanish', 'es_mi_blob_lexer'); 

/*WORDLIST*/
exec ctx_ddl.create_stoplist('en_blob_palabras_vacias');
exec ctx_ddl.add_stopword(   'en_blob_palabras_vacias', 'the');
exec ctx_ddl.add_stopword(   'en_blob_palabras_vacias', 'a');
exec ctx_ddl.add_stopword(   'en_blob_palabras_vacias', 'an');
exec ctx_ddl.add_stopword(   'en_blob_palabras_vacias', 'these');

exec ctx_ddl.create_stoplist('es_blob_palabras_vacias');
exec ctx_ddl.add_stopword(   'es_blob_palabras_vacias', 'the');
exec ctx_ddl.add_stopword(   'es_blob_palabras_vacias', 'a');
exec ctx_ddl.add_stopword(   'es_blob_palabras_vacias', 'an');
exec ctx_ddl.add_stopword(   'es_blob_palabras_vacias', 'these');

/*Preferencias genericas*/
exec ctx_ddl.create_preference('mi_blob_datasource_ficheros' , 'DIRECT_DATASTORE');

exec ctx_ddl.create_preference('mi_blob_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'STEMMER', 'ENGLISH');        
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_MATCH', 'ENGLISH');    
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_SCORE', '1');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_NUMRESULTS', '5000');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_section_group('mi_seccionador_blob' , 'NULL_SECTION_GROUP'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'SENTENCE'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'PARAGRAPH'); 




DROP INDEX fichero_blob_idx;
CREATE INDEX fichero_blob_idx ON multilenguaje (contenido)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'
    filter ctxsys.AUTO_FILTER
    datastore mi_blob_datasource_ficheros
    section group mi_seccionador_blob
    sync(on commit) 
    lexer mi_blob_lexer
    wordlist mi_blob_wordlist
    stoplist blob_palabras_vacias
'
); 