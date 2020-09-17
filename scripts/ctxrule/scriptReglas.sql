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
    contenido   CLOB,
    PRIMARY KEY (id)
);    

DROP SEQUENCE multilenguaje_id;
CREATE SEQUENCE multilenguaje_id;

CREATE OR REPLACE DIRECTORY CARPETA_FICHEROS_TXT AS '/home/oracle/documents/text';



CREATE OR REPLACE PROCEDURE cargar_fichero_por_idiomas
    (idioma IN VARCHAR2, CARPETA_FICHEROS IN VARCHAR2, input_fichero IN VARCHAR2, new_id OUT INTEGER) IS
        fichero_en_so           BFILE;
        blob_para_guardar       CLOB;
BEGIN
    INSERT INTO multilenguaje 
        (id,fichero,idioma,contenido)
    VALUES
        (multilenguaje_id.nextval, input_fichero, idioma, EMPTY_CLOB() )
    RETURNING 
        id, contenido INTO new_id, blob_para_guardar;

    fichero_en_so := bfilename( CARPETA_FICHEROS, input_fichero);
    DBMS_LOB.OPEN( fichero_en_so , DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE (blob_para_guardar,  fichero_en_so , DBMS_LOB.getlength(fichero_en_so));
    DBMS_LOB.CLOSE( fichero_en_so );
    COMMIT;
    
END cargar_fichero_por_idiomas;
/

SET SERVEROUTPUT ON;

DECLARE 
    new_id INTEGER;
BEGIN

    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_TXT',  'carrilleras.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'java.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'jenkins.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'spanish' , 'CARPETA_FICHEROS_TXT',  'pisto.txt'  , new_id);
    cargar_fichero_por_idiomas ( 'english' , 'CARPETA_FICHEROS_TXT',  'python.txt'  , new_id);

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
exec ctx_ddl.set_attribute(    'en_mi_blob_lexer', 'INDEX_THEMES', 'TRUE');        
exec ctx_ddl.set_attribute(    'en_mi_blob_lexer', 'MIXED_CASE', 'TRUE');        
/*LEXER  ESPAÑOL*/
exec ctx_ddl.create_preference('es_mi_blob_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'INDEX_STEMS', 'SPANISH');        
exec ctx_ddl.set_attribute(    'es_mi_blob_lexer', 'MIXED_CASE', 'TRUE');        
/* MULTILEXER*/
exec ctx_ddl.create_preference('mi_blob_lexer_multi_idioma', 'MULTI_LEXER');
exec ctx_ddl.add_sub_lexer(    'mi_blob_lexer_multi_idioma' , 'default', 'en_mi_blob_lexer'); 
exec ctx_ddl.add_sub_lexer(    'mi_blob_lexer_multi_idioma' , 'english', 'en_mi_blob_lexer'); 
exec ctx_ddl.add_sub_lexer(    'mi_blob_lexer_multi_idioma' , 'spanish', 'es_mi_blob_lexer'); 

/*WORDLIST*/
/*exec ctx_ddl.create_stoplist('ml_blob_palabras_vacias', 'BASIC_STOPLIST');*/
exec ctx_ddl.create_stoplist('ml_blob_palabras_vacias', 'MULTI_STOPLIST');
    /*Palabras en ingles*/
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'the' , 'english');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'a'   , 'english');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'an'  , 'english');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'these' , 'english');
    /*Palabras en español*/
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'un'  , 'spanish');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'una' , 'spanish');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'el'  , 'spanish');
exec ctx_ddl.add_stopword(   'ml_blob_palabras_vacias', 'la'  , 'spanish');

/*Preferencias genericas*/
exec ctx_ddl.create_preference('mi_blob_datasource_ficheros' , 'DIRECT_DATASTORE');

exec ctx_ddl.create_preference('mi_blob_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'STEMMER', 'AUTO');        
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_MATCH', 'AUTO');    
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_SCORE', '10');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_NUMRESULTS', '10');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_section_group('mi_seccionador_blob' , 'NULL_SECTION_GROUP'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'SENTENCE'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'PARAGRAPH'); 




DROP INDEX multilenguaje_blob_idx;
CREATE INDEX multilenguaje_blob_idx ON multilenguaje (contenido)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'
    filter ctxsys.AUTO_FILTER
    datastore mi_blob_datasource_ficheros
    section group mi_seccionador_blob
    sync(on commit) 
    lexer mi_blob_lexer_multi_idioma
    language column idioma
    wordlist mi_blob_wordlist
    stoplist ml_blob_palabras_vacias
'
); 


select id || ' ' || fichero from multilenguaje 
where
    contains( contenido , 'bonito' , 1 ) > 0;
    

select id || ' ' || fichero from multilenguaje 
where
    contains( contenido , 'about(programming languaje)' , 1 ) > 0;



DROP TABLE categorias;
CREATE TABLE categorias (
    id NUMBER PRIMARY KEY,
    categoria VARCHAR2(50),
    query VARCHAR2(4000)
);

INSERT INTO categorias VALUES (1, 'Lenguajes de Programación', 'ABOUT(programming languages)');
INSERT INTO categorias VALUES (2, 'Comidas',                   'bonito or carrilleras or ingredientes');

DROP INDEX categorias_idx;
CREATE INDEX categorias_idx ON categorias (query) INDEXTYPE IS ctxsys.CTXRULE;


SELECT id, ( SELECT categoria
             FROM categorias
             WHERE MATCHES(query , contenido) >0)
FROM MULTILENGUAJE;

/*                                ^ VARCHAR2 o CLOBS*/