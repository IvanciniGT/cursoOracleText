
/*
Paso 1 crear Tabla: ficheros_texto
    2 columnas: 
        - Id
        - Nombre_fichero
        
    Cargar en la tabla los nombres de los ficheros
*/
DROP TABLE ficheros_texto;
CREATE TABLE ficheros_texto (
    id INTEGER PRIMARY KEY,
    nombre_fichero VARCHAR2(50)
);

INSERT INTO ficheros_texto VALUES ( 1 , 'bonito_con_pisto.txt' );
INSERT INTO ficheros_texto VALUES ( 2 , 'carrilleras.txt' );
INSERT INTO ficheros_texto VALUES ( 3 , 'java.txt' );
INSERT INTO ficheros_texto VALUES ( 4 , 'jenkins.txt' );
INSERT INTO ficheros_texto VALUES ( 5 , 'pisto.txt' );
INSERT INTO ficheros_texto VALUES ( 6 , 'python.txt' );

COMMIT;

/*
Paso 2- Crear el indicide más completo que podais sobre la columna nombre_fichero
*/
exec ctx_ddl.create_preference('mi_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'mi_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'mi_lexer', 'INDEX_STEMS', 'SPANISH');        
/* Me permite hacer búsquedas con el signo $ */

exec ctx_ddl.create_preference('mi_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'STEMMER', 'SPANISH');        
/* Me permite hacer búsquedas con el signo $ */
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'FUZZY_MATCH', 'SPANISH');    
/* Si quiero busquedas para usuarios que escriben de aquella manera */
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'FUZZY_SCORE', '1');
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'FUZZY_NUMRESULTS', '5000');
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
/* Búsquedas con el % por DETRAS -> AUTOCOMPLETAR */
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
/* Dependerá de cómo monte los formularios de búsqueda */ 
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
/* Dependerá de los CONTENIDOS que indexe*/
exec ctx_ddl.set_attribute(    'mi_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_stoplist('palabras_vacias');
exec ctx_ddl.add_stopword(   'palabras_vacias', 'de');
exec ctx_ddl.add_stopword(   'palabras_vacias', 'la');
exec ctx_ddl.add_stopword(   'palabras_vacias', 'las');
exec ctx_ddl.add_stopword(   'palabras_vacias', 'los');

exec ctx_ddl.create_preference('mi_datasource_ficheros_txt' , 'FILE_DATASTORE');
exec ctx_ddl.set_attribute(    'mi_datasource_ficheros_txt' , 'PATH', '/home/oracle/documents/text');

/*
    Como superusuario de la base de datos
*/
connect sys as sysdba;
alter session set "_ORACLE_SCRIPT"=true;
/* 
Creamos un role, llamo como nos de la gana, que vamos a:
- asignar a nuestro usuario
- dar de alta en oracle text, como role requerido para usar datastores de tipo FILE_DATASTORE
*/
create role FILE_ACCESS;
exec ctxsys.ctx_adm.set_parameter('FILE_ACCESS_ROLE','FILE_ACCESS');
grant FILE_ACCESS TO usuario;

connect usuario;

DROP INDEX fichero_idx;
CREATE INDEX fichero_idx ON ficheros_texto (nombre_fichero)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'
    datastore mi_datasource_ficheros_txt
    sync(on commit) 
    lexer mi_lexer
    wordlist mi_wordlist
    stoplist palabras_vacias
'
); 
/* NOTA: sync(on commit) SOLO PARA EJEMPLOS DURANTE EL CURSO O DESARROLLO. NUNCA PRODUCCION*/

/*
Identificar errores en la indexación
*/
select * from ctx_user_index_errors;

select nombre_fichero
from ficheros_texto
where
    contains( nombre_fichero , 'programming' , 1) > 0;
    
select nombre_fichero
from ficheros_texto
where
    contains( nombre_fichero , 'bonito' , 1) > 0;