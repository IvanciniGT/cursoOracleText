
CREATE TABLE documentos_en_bd (
    id          INTEGER ,
    fichero     VARCHAR2(500),
    contenido   BLOB
);


CREATE OR REPLACE DIRECTORY CARPETA_FICHEROS AS '/home/oracle/documents/pdf';
CREATE OR REPLACE PROCEDURE cargar_fichero(input_id IN INTEGER, input_fichero IN VARCHAR2) IS
        fichero_en_so           BFILE;
        blob_para_guardar       BLOB;
        longitud_del_fichero    BINARY_INTEGER;
    BEGIN
        INSERT INTO documentos_en_bd 
            (id,fichero,contenido)
        VALUES
            (input_id, input_fichero, EMPTY_BLOB() )
        RETURNING 
            contenido INTO blob_para_guardar;
    
        fichero_en_so := bfilename( 'CARPETA_FICHEROS' , input_fichero);
        DBMS_LOB.OPEN( fichero_en_so , DBMS_LOB.FILE_READONLY);
        longitud_del_fichero := DBMS_LOB.getlength(fichero_en_so);
        DBMS_LOB.LOADFROMFILE (blob_para_guardar,  fichero_en_so , longitud_del_fichero);
        DBMS_LOB.CLOSE( fichero_en_so );
        COMMIT;
    END cargar_fichero;
    /

exec cargar_fichero (1,'java.pdf');
exec cargar_fichero (2,'jenkins.pdf');
exec cargar_fichero (3,'Python Quick Guide - Tutorialspoint.pdf');



/*
Paso 2- Crear el indicide más completo que podais sobre la columna nombre_fichero
*/
exec ctx_ddl.create_preference('mi_blob_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'mi_blob_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'mi_blob_lexer', 'INDEX_STEMS', 'ENGLISH');        
exec ctx_ddl.set_attribute(    'mi_blob_lexer', 'MIXED_CASE', 'TRUE');        
/* Me permite hacer búsquedas con el signo $ */

exec ctx_ddl.create_preference('mi_blob_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'STEMMER', 'ENGLISH');        
/* Me permite hacer búsquedas con el signo $ */
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_MATCH', 'ENGLISH');    
/* Si quiero busquedas para usuarios que escriben de aquella manera */
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_SCORE', '1');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'FUZZY_NUMRESULTS', '5000');
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
/* Búsquedas con el % por DETRAS -> AUTOCOMPLETAR */
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
/* Dependerá de cómo monte los formularios de búsqueda */ 
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
/* Dependerá de los CONTENIDOS que indexe*/
exec ctx_ddl.set_attribute(    'mi_blob_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_stoplist('blob_palabras_vacias');
exec ctx_ddl.add_stopword(   'blob_palabras_vacias', 'the');
exec ctx_ddl.add_stopword(   'blob_palabras_vacias', 'a');
exec ctx_ddl.add_stopword(   'blob_palabras_vacias', 'an');
exec ctx_ddl.add_stopword(   'blob_palabras_vacias', 'these');

exec ctx_ddl.create_preference('mi_blob_datasource_ficheros' , 'DIRECT_DATASTORE');

exec ctx_ddl.create_section_group('mi_seccionador_blob' , 'NULL_SECTION_GROUP'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'SENTENCE'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_blob' , 'PARAGRAPH'); 

DROP INDEX fichero_blob_idx;
CREATE INDEX fichero_blob_idx ON documentos_en_bd (contenido)
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
/* NOTA: sync(on commit) SOLO PARA EJEMPLOS DURANTE EL CURSO O DESARROLLO. NUNCA PRODUCCION*/

/*
Identificar errores en la indexación
*/
select * from ctx_user_index_errors;
delete from ctx_user_index_errors;

select fichero 
    from documentos_en_bd
    where
        contains (contenido , 'java' , 1) > 0;