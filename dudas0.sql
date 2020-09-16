-----------------------------------------------------------------------------------
-- ÍNDICES ORACLE TEXT DE LA TABLA TBGBDJ_CONFLICTO (TEXTO LIBRE)
-----------------------------------------------------------------------------------
exec ctx_ddl.drop_preference ('datastore_conflicto_user');
exec ctx_ddl.drop_section_group ('section_conflicto_user');
DROP INDEX IOTTBGBDJ_CONFLICTO_01;

/*
UN DATASTORE CUSTOMIZADO
    Proceso almacenado Oracle ( FILA TABLA -> CLOB)
*/
EXEC CTX_DDL.CREATE_PREFERENCE ('datastore_conflicto_user', 'user_datastore');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_user', 'procedure', 'pkgbdj_conflicto.texto_libre');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_user', 'output_type', 'clob');

exec ctx_ddl.create_section_group ('section_conflicto_user', 'xml_section_group');
/*
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'titulo', 'title');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'MI ALIAS DE SECCION', 'ETIQUETA');
*/
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_CUESTIONDEBATIDA', 'DE_CUESTIONDEBATIDA');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_ACUMULACION', 'DE_ACUMULACION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'CL_OBSERVACION', 'CL_OBSERVACION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_TITULODISPOSICION', 'DE_TITULODISPOSICION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_ORGANOEMISOR', 'DE_ORGANOEMISOR');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_RELARTINCONSTOLITIG', 'DE_RELARTINCONSTOLITIG');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'DE_RELARTIMPUGNADO', 'DE_RELARTIMPUGNADO');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_user', 'CL_TEXTO', 'CL_TEXTO');
EXEC CTX_DDL.ADD_SPECIAL_SECTION ('section_conflicto_user', 'SENTENCE');
EXEC CTX_DDL.ADD_SPECIAL_SECTION ('section_conflicto_user', 'PARAGRAPH');

/*
NULL_FILTER -> texto plano (html, xml)
AUTO_FILTER -> binarios (pdfs, xls, doc) | xml, html, txt??? 
            -> NADA, pero TARDA MAS, porque teneía que ver que era un txt.. xml.. html...
*/
CREATE INDEX IOTTBGBDJ_CONFLICTO_01
ON TBGBDJ_CONFLICTO(CL_TEXTO)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS
('DATASTORE datastore_conflicto_user
  FILTER ctxsys.null_filter
  SECTION GROUP section_conflicto_user
  LEXER lexter_spanish
  STORAGE mystore
  SYNC (on commit)')
PARALLEL 8;
/*
PELIGROSO -> PARALLEL -> ALTER
PARAMETERS : Características funcionales<- intrinseca al indice, lo requiere para poder funcionar. Lo define

SYNC???

PARALLELS  : Comportamiento <- DEPENDE DEL ENTORNO Desarrollo, Integracion, Produccion
CARGA -> JMETER <- Pruebas de applicaciones WEB / JDBC
    YOUTUBE -> JMETER JDBC
    
SYNC         -> INDEXAR
OPTIMIZACION -> 1 hora ligera
OPTIMIZACION -> 1 dia pesada
REGENERACION -> 1 semana
*/
-----------------------------------------------------------------------------------
-- ÍNDICES ORACLE TEXT DE LA TABLA TBGBDJ_CONFLICTO (MARKUP)
-----------------------------------------------------------------------------------
exec ctx_ddl.drop_preference ('datastore_conflicto_markup');
exec ctx_ddl.drop_section_group ('section_conflicto_markup');
DROP INDEX IOTTBGBDJ_CONFLICTO_M_01;

EXEC CTX_DDL.CREATE_PREFERENCE ('datastore_conflicto_markup', 'user_datastore');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_markup', 'procedure', 'pkgbdj_conflicto.markup');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_markup', 'output_type', 'clob');

exec ctx_ddl.create_section_group ('section_conflicto_markup', 'xml_section_group');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_CUESTIONDEBATIDA', 'DE_CUESTIONDEBATIDA');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_ACUMULACION', 'DE_ACUMULACION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'CL_OBSERVACION', 'CL_OBSERVACION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_TITULODISPOSICION', 'DE_TITULODISPOSICION');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_ORGANOEMISOR', 'DE_ORGANOEMISOR');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_RELARTINCONSTOLITIG', 'DE_RELARTINCONSTOLITIG');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'DE_RELARTIMPUGNADO', 'DE_RELARTIMPUGNADO');
EXEC CTX_DDL.ADD_ZONE_SECTION ('section_conflicto_markup', 'CL_TEXTO', 'CL_TEXTOHTML');
EXEC CTX_DDL.ADD_SPECIAL_SECTION ('section_conflicto_markup', 'SENTENCE');
EXEC CTX_DDL.ADD_SPECIAL_SECTION ('section_conflicto_markup', 'PARAGRAPH');

CREATE INDEX IOTTBGBDJ_CONFLICTO_M_01
ON TBGBDJ_CONFLICTO(CL_TEXTOHTML)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS
('DATASTORE datastore_conflicto_markup
  FILTER ctxsys.null_filter
  SECTION GROUP section_conflicto_markup
  LEXER lexter_spanish
  STORAGE mystore
  SYNC (on commit)')
PARALLEL 8;

-----------------------------------------------------------------------------------
-- ÍNDICES ORACLE TEXT DE LA TABLA TBGBDJ_DOCUMENTOCONFLICTO
-----------------------------------------------------------------------------------
DROP INDEX IOTTBGBDJ_DOCCONFLICTO_01;

CREATE INDEX IOTTBGBDJ_DOCCONFLICTO_01
ON TBGBDJ_DOCUMENTOCONFLICTO(CL_TEXTO)
INDEXTYPE IS ctxsys.CONTEXT
PARAMETERS
('DATASTORE ctxsys.default_datastore
  FILTER ctxsys.auto_filter
  LEXER lexter_spanish
  STORAGE mystore
  SYNC (on commit)')
PARALLEL 8;

/*
<CONFLICTO>
    <DE_CUESTIONDEBATIDA><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_CUESTIONDEBATIDA>
    <DE_ACUMULACION><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_ACUMULACION>
    <CL_OBSERVACION><![CDATA[ contenido & que "no" se <procesa> como XML ]]></CL_OBSERVACION>
    <DISPOSICIONES>
        <DISPOSICION id="01927">
            <DE_CUESTIONDEBATIDA><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_CUESTIONDEBATIDA>
            <DE_ACUMULACION><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_ACUMULACION>
            <CL_OBSERVACION><![CDATA[ contenido & que "no" se <procesa> como XML ]]></CL_OBSERVACION>
        </DISPOSICION>
        <DISPOSICION id="12314">
            <DE_TITULODISPOSICION><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_TITULODISPOSICION>
            <DE_ORGANOEMISOR><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_ORGANOEMISOR>
            <DE_RELARTINCONSTOLITIG><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_RELARTINCONSTOLITIG>
            <DE_RELARTIMPUGNADO><![CDATA[ contenido & que "no" se <procesa> como XML ]]></DE_RELARTIMPUGNADO>
        </DISPOSICION>
        ...
    </DISPOSICIONES>
    <CL_TEXTO><![CDATA[ contenido & que "no" se <procesa> como XML ]]></CL_TEXTO>
</CONFLICTO>

*/

PROCEDURE TEXTO_LIBRE(P_ROWID IN ROWID, P_CLOB IN OUT CLOB) AS
BEGIN
SELECT
    PKGBDJ_XML.TOXMLCDATA(XML) INTO P_CLOB
FROM
    (
    SELECT
        XMLELEMENT(CONFLICTO,
        XMLELEMENT(DE_CUESTIONDEBATIDA, PKGBDJ_XML.XMLCDATA(CONFLICTO.DE_CUESTIONDEBATIDA)),
        XMLELEMENT(DE_ACUMULACION, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.DE_ACUMULACION)),
        XMLELEMENT(CL_OBSERVACION, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.CL_OBSERVACION)),
        XMLELEMENT(DISPOSICIONES,
            (SELECT
                XMLAGG(
                    XMLELEMENT(DISPOSICION, 
                        XMLATTRIBUTES(DISPOSICIONCONFLICTO.ID_DISPOSICIONCONFLICTO AS ID),
                        XMLELEMENT(DE_TITULODISPOSICION, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_TITULODISPOSICION)),
                        XMLELEMENT(DE_ORGANOEMISOR, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_ORGANOEMISOR)),
                        XMLELEMENT(DE_RELARTINCONSTOLITIG, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTINCONSTOLITIG)),
                        XMLELEMENT(DE_RELARTIMPUGNADO, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTIMPUGNADO))
                    )
                )
            FROM 
                TBRBDJ_DISPOSICIONCONFLICTO DISPOSICIONCONFLICTO
                    INNER JOIN 
                    TBGBDJ_DISPOSICION DISPOSICION 
                ON 
                    DISPOSICIONCONFLICTO.ID_DISPOSICION = DISPOSICION.ID_DISPOSICION
            WHERE 
                CONFLICTO.ID_CONFLICTO = DISPOSICIONCONFLICTO.ID_CONFLICTO
            )
        ),
        XMLELEMENT(CL_TEXTO, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.CL_TEXTO))
        ).GETCLOBVAL() AS XML
    FROM 
        TBGBDJ_CONFLICTO CONFLICTO
    WHERE
        CONFLICTO.ROWID = P_ROWID
    );
EXCEPTION WHEN OTHERS THEN
    PKGBDJ_LOG.ERRORE('PKGBDJ_CONFLICTO.texto_libre -> rowId = '|| P_ROWID ||' : '||SQLERRM);
    P_CLOB := '';
END TEXTO_LIBRE;

/**********************************************************
*
**********************************************************/
PROCEDURE MARKUP(P_ROWID IN ROWID, P_CLOB IN OUT CLOB) AS
BEGIN
SELECT
    PKGBDJ_XML.TOXMLCDATA(XML) INTO P_CLOB
FROM
    (
    SELECT
        XMLELEMENT(CONFLICTO,
        XMLELEMENT(DE_CUESTIONDEBATIDA, PKGBDJ_XML.XMLCDATA(CONFLICTO.DE_CUESTIONDEBATIDA)),
        XMLELEMENT(DE_ACUMULACION, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.DE_ACUMULACION)),
        XMLELEMENT(CL_OBSERVACION, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.CL_OBSERVACION)),
        XMLELEMENT(DISPOSICIONES,
            (SELECT
                XMLAGG(
                XMLELEMENT(DISPOSICION, XMLATTRIBUTES(DISPOSICIONCONFLICTO.ID_DISPOSICIONCONFLICTO AS ID),
                XMLELEMENT(DE_TITULODISPOSICION, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_TITULODISPOSICION)),
                XMLELEMENT(DE_ORGANOEMISOR, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_ORGANOEMISOR)),
                XMLELEMENT(DE_RELARTINCONSTOLITIG, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTINCONSTOLITIG)),
                XMLELEMENT(DE_RELARTIMPUGNADO, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTIMPUGNADO))
                )
            )
            FROM 
                TBRBDJ_DISPOSICIONCONFLICTO DISPOSICIONCONFLICTO
                    INNER JOIN 
                    TBGBDJ_DISPOSICION DISPOSICION 
                ON 
                    DISPOSICIONCONFLICTO.ID_DISPOSICION = DISPOSICION.ID_DISPOSICION
            WHERE 
                CONFLICTO.ID_CONFLICTO = DISPOSICIONCONFLICTO.ID_CONFLICTO)
            ),            
        XMLELEMENT(CL_TEXTOHTML, PKGBDJ_XML.XMLCDATA_HTMLTEXT(CONFLICTO.CL_TEXTOHTML))
        ).GETCLOBVAL() AS XML
    FROM 
        TBGBDJ_CONFLICTO CONFLICTO
    WHERE
        CONFLICTO.ROWID = P_ROWID
    );
EXCEPTION WHEN OTHERS THEN
    PKGBDJ_LOG.ERRORE('PKGBDJ_CONFLICTO.markup -> rowId = '|| P_ROWID ||' : '||SQLERRM);
    P_CLOB := '';
END MARKUP;




-----------------------------------------------------------------------------------
-- DEFINE EL LEXICO POR DEFECTO PARA TODOS LOS ÍNDICES
-----------------------------------------------------------------------------------
exec ctx_ddl.drop_preference('lexter_spanish');
--exec ctx_ddl.drop_preference('wordlist_spanish');
exec ctx_ddl.drop_preference('mystore');

exec ctx_ddl.create_preference('lexter_spanish', 'BASIC_LEXER');
exec ctx_ddl.set_attribute('lexter_spanish', 'base_letter', 'yes');
/*
jamón -> jamon
*/
exec ctx_ddl.set_attribute('lexter_spanish', 'base_letter_type', 'generic');

/* Quiero que generes un indice con los tokens del texto */
exec ctx_ddl.set_attribute('lexter_spanish', 'index_text', 'yes');
/* Quiero que generes un indice con los temas del texto 
    Si le pongo que si me permite usar la palabrita.... ABOUT()
    En este caso, no es que no se vayan a hacer busquedas con ABOUT....
    es que no podriamos hacerlas en ningun caso:
        ¿?¿?¿?¿? IDIOMAS: ingles, frances
*/
exec ctx_ddl.set_attribute('lexter_spanish', 'index_themes', 'no');

/*
Final de frase: .!? 
    )-> esto es una (gran) frase
    :. He comprado: manzanas, peras y melocotones
*/
exec ctx_ddl.set_attribute('lexter_spanish', 'punctuations', '.!?):');
/*
Si activo la linea de abajo, puedo...
hacer busquedas por raices: $palabra
*/
--exec ctx_ddl.set_attribute('lexter_spanish', 'index_stems', 'spanish');
--exec ctx_ddl.set_attribute('lexter_spanish', 'theme_language', 'spanish');

/*
Al desactivar el wordlist he perdido:
    - raiz
    - fuzzy
    - prefijos
    - sufijos
*/
--exec ctx_ddl.create_preference('wordlist_spanish', 'BASIC_WORDLIST');
--exec ctx_ddl.set_attribute('wordlist_spanish', 'stemmer', 'spanish');
--exec ctx_ddl.set_attribute('wordlist_spanish', 'fuzzy_match', 'spanish');

/*
Indices en tablespace separado:
    MEJORA RENDIMIENTO -> Siempre y cuando los tablespaces estén en dispositivos de almacenamiento diferentes
    BACKUPS -> Puedo hacer backup de un tablespace
*/

exec ctx_ddl.create_preference('mystore', 'BASIC_STORAGE');
--exec ctx_ddl.set_attribute('mystore', 'I_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'K_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'R_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K) lob (data) store as (disable storage in row cache)');
exec ctx_ddl.set_attribute('mystore', 'N_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'I_INDEX_CLAUSE','tablespace IDMPTBDJ storage (initial 1K) compress 2');
/* SUBSTRING_INDEX */
--exec ctx_ddl.set_attribute('mystore', 'P_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)'); 





TABLA A - Conflicto <- INDICE
    id
    textos

TABLA B - Disposiciones
    id
    a.id
    sus_textos
    
INDICE A
    - textos + n · sus_textos   ->   VELOCIDAD ACCESO A DATOS
    - ¿Que pasa con la actualización del indice?
        Cuando cambio una disposicion? -> QUE SE TIENE QUE indexar también el conflicto
            ->  QUE LE OCURRE A MI INDICE: NADA <- dejando a la programación
                RUINA !!!!!! La logica de datos: EN LA BASE DE DATOS
                2 TRIGGER -> A y B
        Cuando cambio el conflicto?    -> Se regenera TODO el indice que tiene que ver con:
                                                El conflicto
                                                Sus N disposiciones-> CUANTO VALE N? 2-4
                                                    Como de grandes son?
                                                        Tamaño disposicion?    DETERMINAR
                                                        Tamaño del conflicto?  DETERMINAR
                                                    Con que frecuencia se actualizan disposiciones
                                                    y conflictos
-------
ALTERNATIVA

TABLA A - Conflicto <- INDICE
    id
    textos

TABLA B - Disposiciones <- INDICE
    id
    a.id
    sus_textos

¿Que tipo de store? -> MULTI_COLUMN_STORE -> TRIGGER
    
FORMULARIO:
    Caja texto -> busque en conflicto y en las disposiciones

/*AHORA*/
SELECT 
    * 
FROM 
    CONFLICTO
WHERE 
    CONTAINS( cl_texto , 'TOKENS DE BUSQUEDA' , 1 ) >0
ORDER BY  
    SCORE(1) DESC;

/*ALTERNATIVA*/
SELECT 
    * 
FROM 
    CONFLICTO, DISPOSICION (JOIN)
WHERE 
    CONTAINS( conflicto.cl_texto , 'TOKENS DE BUSQUEDA' , 1 ) >0
    OR
    CONTAINS( disposicion.cl_texto , 'TOKENS DE BUSQUEDA' , 2 ) >0
ORDER BY  
    SCORE(2)+SCORE(1) DESC;

->INFRAESTRUCTURA<-
CABINA DE ALMACENAMIENTO: 10-100 ssd + RAID 
1 SDD -> tablas
1 SDD -> Indice conflictos y Indice disposicion
