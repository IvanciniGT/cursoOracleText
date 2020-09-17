
/*
Paso 1 crear Tabla: ficheros_todos
    2 columnas: 
        - Id
        - Nombre_fichero
        
    Cargar en la tabla los nombres de los ficheros
*/
DROP TABLE ficheros_todos;
CREATE TABLE ficheros_todos (
    id INTEGER PRIMARY KEY,
    nombre_fichero VARCHAR2(500)
);

INSERT INTO ficheros_todos VALUES ( 1 , '/home/oracle/documents/pdf/java.pdf' );
INSERT INTO ficheros_todos VALUES ( 2 , '/home/oracle/documents/pdf/jenkins.pdf' );
INSERT INTO ficheros_todos VALUES ( 4 , '/home/oracle/documents/text/bonito_con_pisto.txt' );
INSERT INTO ficheros_todos VALUES ( 5 , '/home/oracle/documents/text/carrilleras.txt' );
INSERT INTO ficheros_todos VALUES ( 6 , '/home/oracle/documents/text/java.txt' );
INSERT INTO ficheros_todos VALUES ( 7 , '/home/oracle/documents/text/jenkins.txt' );
INSERT INTO ficheros_todos VALUES ( 8 , '/home/oracle/documents/text/pisto.txt' );
INSERT INTO ficheros_todos VALUES ( 9 , '/home/oracle/documents/text/python.txt' );
INSERT INTO ficheros_todos VALUES ( 10 , '/home/oracle/documents/html/bonito_con_pisto.html' );
INSERT INTO ficheros_todos VALUES ( 11 , '/home/oracle/documents/html/carrilleras.html' );
INSERT INTO ficheros_todos VALUES ( 12 , '/home/oracle/documents/html/pisto.html' );
COMMIT;

/*
Paso 2- Crear el indicide más completo que podais sobre la columna nombre_fichero
*/
exec ctx_ddl.create_preference('mi_todos_lexer', 'AUTO_LEXER');
exec ctx_ddl.set_attribute(    'mi_todos_lexer', 'BASE_LETTER', 'TRUE');
exec ctx_ddl.set_attribute(    'mi_todos_lexer', 'INDEX_STEMS', 'TRUE');        
/* Me permite hacer búsquedas con el signo $ */

exec ctx_ddl.create_preference('mi_todos_wordlist' , 'BASIC_WORDLIST');
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'STEMMER', 'AUTO');        
/* Me permite hacer búsquedas con el signo $ */
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'FUZZY_MATCH', 'AUTO');    
/* Si quiero busquedas para usuarios que escriben de aquella manera */
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'FUZZY_SCORE', '1');
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'FUZZY_NUMRESULTS', '5000');
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'PREFIX_INDEX' , 'TRUE' );    
/* Búsquedas con el % por DETRAS -> AUTOCOMPLETAR */
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'PREFIX_MIN_LENGTH' , '3' );  
/* Dependerá de cómo monte los formularios de búsqueda */ 
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'PREFIX_MAX_LENGTH' , '8' );  
/* Dependerá de los CONTENIDOS que indexe*/
exec ctx_ddl.set_attribute(    'mi_todos_wordlist' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_stoplist('todos_palabras_vacias');
exec ctx_ddl.add_stopword(   'todos_palabras_vacias', 'the');
exec ctx_ddl.add_stopword(   'todos_palabras_vacias', 'a');
exec ctx_ddl.add_stopword(   'todos_palabras_vacias', 'an');
exec ctx_ddl.add_stopword(   'todos_palabras_vacias', 'these');

exec ctx_ddl.create_preference('mi_todos_datasource_ficheros' , 'FILE_DATASTORE');
/*
En este caso no vale, porque hay documentos en varias carpetas
exec ctx_ddl.set_attribute(    'mi_todos_datasource_ficheros' , 'PATH', '/home/oracle/documents/todos');
*/
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
    todos y XML son lenguajes de marcado y significa que tienen marcas: 
        - <marca>  -> marca de apertura
        - </marca> -> marca de cierre            
        - <marca/> -> marca de apertura y cierre 
    En XML SIEMPRE se requierren marcas de cierre
    En todos no se requiere que toda marca de apertura tenga marca de cierre
        <meta>
        <br>
        <img>
        
    todos viene de un lenguae que se llama SGML, donde sNO SE REQUIEREN siempre marcas de cierre
    
    
    En XML trabajo con el AUTO_SECTION_GROUP
    En todos trabajo con el todos_SECTION_GROUP y tengo que definir las secciones que me interesan

*/

exec ctx_ddl.create_section_group('mi_seccionador_todos' , 'NULL_SECTION_GROUP'); 
/*Estos 2 los puedo añadir a cualquier SECCIONADOR*/
exec ctx_ddl.add_special_section( 'mi_seccionador_todos' , 'SENTENCE'); 
exec ctx_ddl.add_special_section( 'mi_seccionador_todos' , 'PARAGRAPH'); 

/*
FILTERS:
    ELIMINAN BASURILLA (cosas de formatos y estilos)
    Cuando tenemos documentos HTML, XML, textos planos:
        Aplicamos es el NULL_FILTER
    Cuando tenemos documentos binarios: WORD, todos, PPT, XLS
        Aplicamos el AUTO_FILTER: Discrimina los HTML, XML, TEXTOS PLANOS
*/

DROP INDEX fichero_todos_idx;
CREATE INDEX fichero_todos_idx ON ficheros_todos (nombre_fichero)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'
    filter ctxsys.AUTO_FILTER
    datastore mi_todos_datasource_ficheros
    section group mi_seccionador_todos
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
from ficheros_todos
where
    contains( nombre_fichero , 'pisto' , 1) > 0;
    
explain plan for select nombre_fichero
from ficheros_todos
where
    contains( nombre_fichero , '(curly and braces) within sentence' , 1) > 0;
    
    
 /*   
    
EVITAR EL USO DE PROCEDIMIENTOS ALMACENADOS EN BD:
    Logica de la APLICACION/NEGOCIO debe estar en la aplicación <- VERDAD COMO UN TEMPLO !

LOGICA DE LOS DATOS ??? -> PROCEDIMIENTOS ALMACENADOS

JAVA !

Aplicacion -> Carga de un documento en la BD
    3 tablas 
    
    PROCEDIMIENTO ALMACENADO
    
    INSERT desde JAVA <- RUINA!!!!!
        decenas bajas de ms -> 15-20 ms
    JAVA -> ORACLE insert:
        latencia red!: 100ms +- 20 IDA : 70 ms
        insert -> 20ms
        latencia red!: 100ms +- 20 VUELTA 70 ms
        
        60ms 
        3* (70+70 ms) + 3* 20=
        BD: 60ms
        RED: 360ms 
    
    APLICACION 1:
        comunicar con APP 2:
            PROGRAMACION: DISEÑO: Interfaz  de comunicación API-> 
                Funciones de bajo nivel o funciones de ALTO nivel???
        comunicar con la BD
            altaDeDocumento(Fichero, nombre) -> ID
                LOGICA DE DATOS
        
        HIBERNATE <- Evita tirar SQL: A costa de rendimiento
        
            

    DNIs
        Validación de los DNI ?
            BD
            Java también ponga la validación
            JS   ni siquiera mandarlo a la BD -> Interactividad
            
        BD <- Responsable de los datos.

        JAVA <- Mierda lenguaje . GUAY JS
                OO castaña -> GUAY Programacion funcional
*/

