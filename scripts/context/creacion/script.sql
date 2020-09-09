/*
Tabla de juego
*/
drop Usuarios;
create table Usuarios (
    Id number primary key, 
    Pais varchar2(2), 
    Nombre varchar2(200)
);
insert into Usuarios values (1, 'ES', 'Ivan Osuna');
insert into Usuarios values (2, 'ES', 'Luis Osuna-Osuna');
insert into Usuarios values (3, 'ES', 'Ivan Ayuste');
insert into Usuarios values (4, 'UK', 'Ivan de Ayuste');

/*
Queries simples
*/

select 
    id, nombre 
from 
    usuarios 
where 
    pais='ES';

/*
Creación de índice sencillo de texto
*/
drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context;


select 
    id, nombre, score(27)
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'ivan',27)>0;

/*
    Busqueda de los usuario que empiezan por IVA
*/

select 
    id, nombre
from 
    usuarios 
where 
    upper(nombre) like 'IVA%';
    

desc dr$nombre_idx$i;
select token_text from dr$nombre_idx$i;

select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'%va%',27)>0;
/*
CHAPU !!!!!!   
 Porque nos falta por decirle al indice que vamos a utilizar WILDCARDS
 Si no se lo aviso al indice, el performance va a ser desastroso!
*/

select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'fuzzy(( osoona ))',27)>0;
    
select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'fuzzy(( alluste ))',27)>0;
    
    
insert into Usuarios values (5, 'UK', 'Iv'||unistr('\00C1')||'n de Ayuste');
/*
Actualizar el indice
*/
exec ctx_ddl.sync_index('nombre_idx');
select token_text from dr$nombre_idx$i;

select 
    id
from 
    usuarios 
where 
    contains(nombre,'ayuste',27)>0;
    

/*
Configurar syncronizidad del indice
POR DEFECTO: Un indice de tipo CONTEXT se sincroniza cuando se solicita formalmente
    exec ctx_ddl.sync_index(<nombre índice>);
CONFIGURACIONES:
    - sync (on commit) -> Sincronización del indice al hacer commit;
    - sync (every PERIODO) -> Sincronización del indice cada cierto tiempo;
    
*/
drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
    ');
insert into Usuarios values (6, 'ES', 'Osuna Ayuste');

select 
    id
from 
    usuarios 
where 
    contains(nombre,'ayuste',27)>0;
    

/*
    Actualiza el indice cada minuto
*/
drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (every SYSDATE+1/24/60)
    ');
insert into Usuarios values (7, 'ES', 'Ayuste Ivan');

select 
    id
from 
    usuarios 
where 
    contains(nombre,'ayuste',27)>0;

/*
Configuraciones en Oracle TEXT:
1- Crearnos un Objeto (Preferencias) de un determinado tipo (LEXER, FILTER, SECTIONER)
2- Asignarle configuraciones (Atributos)
3- Usar el objeto dentro de un indice

Tenemos en Oracle Text una serie de procedimientos:
    ctx_ddl.create_preference( nombre_nuestro , tipo )
    ctx_ddl.drop_preference( nombre_nuestro )
    ctx_ddl.set_attribute( nombre_preferencia , nombre_atributo , valor_attributo )
*/

/*
Proceso de Indexación de textos:
    FILTRADO (quitar estilos) > SECTIONER (separar marcas HTML / XML) > LEXER (partia las palabras de los textos y ...)
CONFIGURACIONES DEL LEXER
    - INDEX_STEMS
    - BASE_LETTER
    */
/*
1- CREAR NUESTRO PROPIO LEXER
                                     Tipos de Objetos que existen en Oracle Text
                                                         v 
*/
exec ctx_ddl.create_preference( 'mi_lexer_de_nombres' , 'BASIC_LEXER' );
/*
2 - ASIGNARLE CONFIGURACIONES
                         Atributos que existen para el tipo de objeto que estoy creando
                                                         v 
*/
exec ctx_ddl.set_attribute(     'mi_lexer_de_nombres' , 'BASE_LETTER' , 'TRUE' );
/*
    BASE_LETTER: Propiedad que indica si hay que convertir los caracteres 
                 especiales en sus correspondientes básicos
    Ejemplo:
            Iván  -> Ivan
            Nuñez -> Nunez
*/
/*
3- Creamos el índice utilizando el lexer que hemos definido
*/
drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
    ');
    
select 
    id
from 
    usuarios 
where 
    contains(nombre,'ivan',27)>0;
    
/*
RAICES DE PALABRAS
*/    
insert into Usuarios values (8, 'ES', 'Ivan Casas');
insert into Usuarios values (9, 'ES', 'Ivan Casa');
insert into Usuarios values (10, 'ES', 'Ivan Casitas');
commit;


select 
    id
from 
    usuarios 
where 
    contains(nombre,'$casa',27)>0;

/*
    INDEX_STEMS: Indica a Oracle text, que idioma se debe utilizar para extraer las raices de las palabras

    PALABRA           RAIZ
    casa         ->   cas
    casas        ->   cas
    casita       ->   cas
    
*/
exec ctx_ddl.set_attribute(     'mi_lexer_de_nombres' , 'INDEX_STEMS' , 'SPANISH' );

drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
    ');
    
select 
    id
from 
    usuarios 
where 
    contains(nombre,'casa',27)>0;

/*
WORDLIST: Contien las preferencias para búsquedas no exactas:
    Difusas: Fuzzy
    Con patrones %
    Con strems
*/
exec ctx_ddl.create_preference( 'mi_wordlist_de_nombres' , 'BASIC_WORDLIST' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'STEMMER' , 'SPANISH' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_MATCH' , 'SPANISH' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_SCORE' , '1' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_NUMRESULTS' , '5000' );

drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
    ');

    
select 
    id
from 
    usuarios 
where 
    contains(nombre,'$casa not $blanca',27)>0;
/*    contains(nombre,'$casa and $blanca',27)>0;*/
/*    contains(nombre,'$casa or $blanca',27)>0;*/

select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'fuzzy(( osoona ))',27)>0;

select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'fuzzy(( hosuna ))',27)>0;


select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'fuzzy(( ozuna ))',27)>0;
    
select token_text from dr$nombre_idx$i;
/*
INDICES IDEALES PARA AUTOCOMPLETAR
*/
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_INDEX' , 'TRUE' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_MIN_LENGTH' , '3' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_MAX_LENGTH' , '20' );
/*
El índice se prepara para hacer busquedas de tipo: iv%
No me vale para busquedas de tipo %iv o de tipo %iv%
*/
drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
    ');


select 
    id
from 
    usuarios 
where 
    pais='ES'
    and contains(nombre,'iv%',27)>0;

/*
    BUSQUEDAS DE TIPO SUBSTRING %va%
    Avisarle que vamos a tener busqiedas con caracteres comodin por delante y quizás también por detras
*/
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'SUBSTRING_INDEX' , 'TRUE' );


/*
STOP WORDS: Palabras que no aportan y que no queremos indexar
ctx_ddl.create_stoplist(<NOMBRE DE LA  LISTA DE PALABRAS INSIGNIFICANTES>)
ctx_ddl.add_stopword(<NOMBRE DE LA  LISTA DE PALABRAS INSIGNIFICANTES>, <palabra a ignorar>)
*/

exec ctx_ddl.create_stoplist('palabras_vacias_en_nombres');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'de');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'la');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'las');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'los');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'el');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'y');

drop index nombre_idx;
create index nombre_idx on usuarios(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');

select 
    id
from 
    usuarios 
where 
    contains(nombre,'ivan de ayuste',27)>0;
/*
Ivan Ayuste
Ayuste Ivan
Ivan de Ayuste
*/

select 
    id
from 
    usuarios 
where 
    contains(nombre,'ivan de ayuste',27)>0;
    
/*    
BUSQUEDA:
    ivan
        -> tanto en nombre como en apellidos
    -> Quiero premiar los resultados en los que ivan esté contenido en el nombre
    
    
| Usuarios                      |
| Nombre      | Apellidos       |
| Ivan.       | Osuna.          |. 1
| Ivan.       | Garcia.         |. 2
| Lucas.      | de Ivan.        |. 3

QUERY: ivan (Nombre*2 + Apellidos)

ID.  SCORE
1.   10
2.   10
3.   5


INDICES: 
--------
 2 Indices: NOMBRE_IDX
            APELLIDOS_IDX
 Solucion IDEAL:
    1 INDICE multicolumna -> NOMBRE_COMPLETO_IDX
        SECTIONER -> Separaba bloques de contenido dentro de un indice (habitualmente se usa para marcas HTML, XML)

QUERY
------
SELECT ID, SCORE(1) * 2 + SCORE(2)
FROM USUARIOS
WHERE 
       CONTAINS (nombre   , 'ivan', 1) > 0   ---> Nombre_idx
    OR CONTAINS (apellidos, 'ivan', 2) > 0   ---> Apellidos_idx


      CHAPUZA !!!!!!!
      El performance es malo!
*/
SELECT ID, SCORE(1)
FROM USUARIOS
WHERE 
       CONTAINS (nombre_completo   , 'ivan', 1) > 0   ---> Nombre_idx

/*
    GUAY en cuanto a RENDIMIENTO !!!!
    Problema: Como controlo que una columna tenga más score que otra?¿?¿?¿? 
    Asi no lo estoy controlando
*/


drop UsuariosSeparados;
create table UsuariosSeparados (
    Id number primary key, 
    Pais varchar2(2), 
    Nombre varchar2(200),
    Apellidos varchar2(200)
);
insert into UsuariosSeparados values (1, 'ES', 'Ivan', 'Osuna');
insert into UsuariosSeparados values (2, 'ES', 'Luis', 'Osuna-Osuna');
insert into UsuariosSeparados values (3, 'ES', 'Ivan', 'Ayuste');
insert into UsuariosSeparados values (4, 'UK', 'Ivan', 'de Ayuste');
insert into UsuariosSeparados values (5, 'UK', 'Iv'||unistr('\00C1')||'n', 'de Ayuste');
insert into UsuariosSeparados values (6, 'ES', 'Osuna', 'Ayuste');
insert into UsuariosSeparados values (7, 'ES', 'Ayuste', 'Ivan');
insert into UsuariosSeparados values (8, 'ES', 'Ivan', 'Casas');
insert into UsuariosSeparados values (9, 'ES', 'Ivan', 'Casa');
insert into UsuariosSeparados values (10, 'ES', 'Ivan', 'Casitas');



exec ctx_ddl.create_preference( 'mi_lexer_de_nombres' , 'BASIC_LEXER' );
exec ctx_ddl.set_attribute(     'mi_lexer_de_nombres' , 'BASE_LETTER' , 'TRUE' );
exec ctx_ddl.set_attribute(     'mi_lexer_de_nombres' , 'INDEX_STEMS' , 'SPANISH' );

exec ctx_ddl.create_preference( 'mi_wordlist_de_nombres' , 'BASIC_WORDLIST' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'STEMMER' , 'SPANISH' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_MATCH' , 'SPANISH' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_SCORE' , '1' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'FUZZY_NUMRESULTS' , '5000' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_INDEX' , 'TRUE' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_MIN_LENGTH' , '3' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'PREFIX_MAX_LENGTH' , '20' );
exec ctx_ddl.set_attribute(     'mi_wordlist_de_nombres' , 'SUBSTRING_INDEX' , 'TRUE' );

exec ctx_ddl.create_stoplist('palabras_vacias_en_nombres');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'de');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'la');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'las');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'los');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'el');
exec ctx_ddl.add_stopword('palabras_vacias_en_nombres', 'y');

/*
    DATASTORES:
        ctxsys.default_datastore:        Trabaja con 1 columna
        ctxsys.multi_column_datastore:   Trabaja con varias columnas
*/

exec ctx_ddl.create_preference( 'datastore_nombre_completo' , 'MULTI_COLUMN_DATASTORE' );
exec ctx_ddl.set_attribute(     'datastore_nombre_completo' , 'COLUMNS' , 'nombre,apellidos' );

/*Columna dummy para su uso en busquedas*/
ALTER TABLE usuariosseparados ADD nombre_completo VARCHAR2(1);

drop index nombrecompleto_sep_idx;
create index nombrecompleto_sep_idx on usuariosseparados(nombre_completo)
    indextype is ctxsys.context parameters('
        datastore datastore_nombre_completo
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');


drop index nombre_sep_idx;
create index nombre_sep_idx on usuariosseparados(nombre)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');

drop index apellidos_sep_idx;
create index apellidos_sep_idx on usuariosseparados(apellidos)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');



SELECT ID, SCORE(1)
FROM USUARIOSSEPARADOS
WHERE 
       CONTAINS (nombre_completo   , 'ivan', 1) > 0;   ---> Nombre_idx
       
       

SELECT ID, SCORE(1)*10 + SCORE(2) as relevancia 
FROM USUARIOSSEPARADOS
WHERE 
          CONTAINS (nombre      , 'ivan', 1) > 0        
       OR CONTAINS (apellidos   , 'ivan', 2) > 0
ORDER BY relevancia DESC;
/* 
    UNA CHAPU -> Rendimiento es muy mejorable

Juntar las 2 tablas OR  -> Union           -> Poner unos cuantos delante y otros detras
                           select DISTINCT -> Eliminar los duplicados
                                  sort ID  -> Peor operación que puedo pedir a una base de datos

Combinar 2 tablas   AND -> JOIN

En ordenar 10 datos tarda 10 seg
En ordenar 20 datos tarda 30 seg

*/
/*
PARA RESOLVER ESTO VAMOS A TRABAJAR CON SECTIONERS
*/
drop textos_marcados;
CREATE TABLE textos_marcados(
    Id number primary key, 
    Texto varchar2(4000)
);
insert into textos_marcados values (1, '<documento><titulo>Frutas</titulo><contenido>Algunas frutas son: Fresas, melón, manzanas platanos, peras.</contenido></documento>');
insert into textos_marcados values (2, '<documento><titulo>Receta de tarta de manzana</titulo><contenido>Ingredientes: manzanas, harina, huevos, leche...</contenido></documento>');

drop   index contenido_textos_marcados_idx;
create index contenido_textos_marcados_idx on textos_marcados(Texto)
    indextype is ctxsys.context parameters('
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');


SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , 'manzana', 1) > 0; 
       
SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , 'titulo', 1) > 0; 
/*
<documento>
    <titulo>Frutas</titulo>
    <contenido>
        Algunas frutas son: 
            Fresas, 
            melón, 
            manzanas 
            platanos, 
            peras
    </contenido>
</documento>

<documento>
    <titulo>Receta de tarta de manzana</titulo>
    <contenido>
        Ingredientes: 
            manzanas, 
            harina, 
            huevos, 
            leche
    </contenido>
</documento>
*/
exec ctx_ddl.create_section_group('seccionador_documentos' , 'AUTO_SECTION_GROUP');

drop   index contenido_textos_marcados_idx;
create index contenido_textos_marcados_idx on textos_marcados(Texto)
    indextype is ctxsys.context parameters('
        section group seccionador_documentos
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
    ');
    

SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , '$manzana', 1) > 0; 
SELECT ID, SCORE(1)

FROM textos_marcados
WHERE 
       CONTAINS (texto   , '$manzana WITHIN titulo', 1) > 0; 


SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , 'harina WITHIN contenido', 1) > 0; 
       

SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , '($manzana within titulo) * 2', 1) > 0; 


SELECT ID, SCORE(1)
FROM textos_marcados
WHERE 
       CONTAINS (texto   , '($manzana within titulo) * 10 or ($manzana within contenido)', 1) > 0; 
       
/*
    SUPER GUAY !!!!!!  MUY RAPIDITO 
*/


/*
    Vamos a aplicar esto al ejeplo de la multicolumna del nombre y apellidos
*/
exec ctx_ddl.create_section_group('seccionador_nombres_completos' , 'AUTO_SECTION_GROUP');

drop index nombrecompleto_sep_idx;
create index nombrecompleto_sep_idx on usuariosseparados(nombre_completo)
    indextype is ctxsys.context parameters('
        datastore datastore_nombre_completo
        sync (on commit)
        lexer mi_lexer_de_nombres
        wordlist mi_wordlist_de_nombres
        stoplist palabras_vacias_en_nombres
        section group seccionador_nombres_completos
    ');

SELECT ID, SCORE(1)
FROM USUARIOSSEPARADOS
WHERE 
       CONTAINS (nombre_completo   , 'ivan within apellidos', 1) > 0;  


SELECT ID, SCORE(1)
FROM USUARIOSSEPARADOS
WHERE 
       CONTAINS (nombre_completo   , '(ivan within apellidos) * 10 or (ivan within nombre)', 1) > 0;  
              