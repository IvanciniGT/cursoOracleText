
/*
Paso 1 crear Tabla: ficheros_pdf
    2 columnas: 
        - Id
        - Nombre_fichero
        
    Cargar en la tabla los nombres de los ficheros
*/
DROP TABLE ficheros_pdf;
CREATE TABLE ficheros_pdf (
    id INTEGER PRIMARY KEY,
    nombre_fichero VARCHAR2(50)
);

INSERT INTO ficheros_pdf VALUES ( 1 , 'java.pdf' );
INSERT INTO ficheros_pdf VALUES ( 2 , 'jenkins.pdf' );
INSERT INTO ficheros_pdf VALUES ( 3 , 'Python Quick Guide - Tutorialspoint.pdf' );

COMMIT;

/*
Paso 2- Crear el indicide más completo que podais sobre la columna nombre_fichero
*/
exec ctx_ddl.create_preference('mi_pdf_pdf_lexer', 'BASIC_LEXER');
exec ctx_ddl.set_attribute(    'mi_pdf_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'mi_pdf_lexer', 'INDEX_STEMS', 'ENGLISH');        
exec ctx_ddl.set_attribute(    'mi_pdf_lexer', 'MIXED_CASE', 'TRUE');        
/* Me permite hacer búsquedas con el signo $ */

exec ctx_ddl.create_preference('mi_pdf_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'STEMMER', 'ENGLISH');        
/* Me permite hacer búsquedas con el signo $ */
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'FUZZY_MATCH', 'ENGLISH');    
/* Si quiero busquedas para usuarios que escriben de aquella manera */
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'FUZZY_SCORE', '1');
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'FUZZY_NUMRESULTS', '5000');
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
/* Búsquedas con el % por DETRAS -> AUTOCOMPLETAR */
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
/* Dependerá de cómo monte los formularios de búsqueda */ 
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
/* Dependerá de los CONTENIDOS que indexe*/
exec ctx_ddl.set_attribute(    'mi_pdf_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_stoplist('pdf_palabras_vacias');
exec ctx_ddl.add_stopword(   'pdf_palabras_vacias', 'the');
exec ctx_ddl.add_stopword(   'pdf_palabras_vacias', 'a');
exec ctx_ddl.add_stopword(   'pdf_palabras_vacias', 'an');
exec ctx_ddl.add_stopword(   'pdf_palabras_vacias', 'these');

exec ctx_ddl.create_preference('mi_pdf_datasource_ficheros' , 'FILE_DATASTORE');
exec ctx_ddl.set_attribute(    'mi_pdf_datasource_ficheros' , 'PATH', '/home/oracle/documents');

/*
    Como superusuario de la base de datos
connect sys as sysdba;
alter session set "_ORACLE_SCRIPT"=true;

Creamos un role, llamo como nos de la gana, que vamos a:
- asignar a nuestro usuario
- dar de alta en oracle text, como role requerido para usar datastores de tipo FILE_DATASTORE
create role FILE_ACCESS;
exec ctxsys.ctx_adm.set_parameter('FILE_ACCESS_ROLE','FILE_ACCESS');
grant FILE_ACCESS TO usuario;

connect usuario;
*/


/*
SECCIONADOR:
    pdf y XML son lenguajes de marcado y significa que tienen marcas: 
        - <marca>  -> marca de apertura
        - </marca> -> marca de cierre            
        - <marca/> -> marca de apertura y cierre 
    En XML SIEMPRE se requierren marcas de cierre
    En pdf no se requiere que toda marca de apertura tenga marca de cierre
        <meta>
        <br>
        <img>
        
    pdf viene de un lenguae que se llama SGML, donde sNO SE REQUIEREN siempre marcas de cierre
    
    
    En XML trabajo con el AUTO_SECTION_GROUP
    En pdf trabajo con el pdf_SECTION_GROUP y tengo que definir las secciones que me interesan

*/

exec ctx_ddl.create_section_group('mi_seccionador_pdf' , 'NULL_SECTION_GROUP'); 
/*Estos 2 los puedo añadir a cualquier SECCIONADOR*/
exec ctx_ddl.add_special_section( 'mi_seccionador_pdf' , 'SENTENCE'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_pdf' , 'PARAGRAPH'); 

/*
FILTERS:
    ELIMINAN BASURILLA (cosas de formatos y estilos)
    Cuando tenemos documentos HTML, XML, textos planos:
        Aplicamos es el NULL_FILTER
    Cuando tenemos documentos binarios: WORD, PDF, PPT, XLS
        Aplicamos el AUTO_FILTER: Discrimina los HTML, XML, TEXTOS PLANOS
*/

DROP INDEX fichero_pdf_idx;
CREATE INDEX fichero_pdf_idx ON ficheros_pdf (nombre_fichero)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'
    filter ctxsys.AUTO_FILTER
    datastore mi_pdf_datasource_ficheros
    section group mi_seccionador_pdf
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
delete from ctx_user_index_errors;
select * from ctx_user_index_errors;

select nombre_fichero
from ficheros_pdf
where
    contains( nombre_fichero , 'Python' , 1) > 0;
    
select nombre_fichero
from ficheros_pdf
where
    contains( nombre_fichero , 'aderezo' , 1) > 0;