-----------------------------------------------------------------------------------
-- ÍNDICES ORACLE TEXT DE LA TABLA TBGBDJ_CONFLICTO (TEXTO LIBRE)
-----------------------------------------------------------------------------------
exec ctx_ddl.drop_preference ('datastore_conflicto_user');
exec ctx_ddl.drop_section_group ('section_conflicto_user');
DROP INDEX IOTTBGBDJ_CONFLICTO_01;

EXEC CTX_DDL.CREATE_PREFERENCE ('datastore_conflicto_user', 'user_datastore');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_user', 'procedure', 'pkgbdj_conflicto.texto_libre');
EXEC CTX_DDL.SET_ATTRIBUTE ('datastore_conflicto_user', 'output_type', 'clob');

exec ctx_ddl.create_section_group ('section_conflicto_user', 'xml_section_group');
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
XMLELEMENT(DISPOSICION, XMLATTRIBUTES(DISPOSICIONCONFLICTO.ID_DISPOSICIONCONFLICTO AS ID),
XMLELEMENT(DE_TITULODISPOSICION, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_TITULODISPOSICION)),
XMLELEMENT(DE_ORGANOEMISOR, PKGBDJ_XML.XMLCDATA(DISPOSICION.DE_ORGANOEMISOR)),
XMLELEMENT(DE_RELARTINCONSTOLITIG, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTINCONSTOLITIG)),
XMLELEMENT(DE_RELARTIMPUGNADO, PKGBDJ_XML.XMLCDATA(DISPOSICIONCONFLICTO.DE_RELARTIMPUGNADO))
)
)
FROM TBRBDJ_DISPOSICIONCONFLICTO DISPOSICIONCONFLICTO
INNER JOIN TBGBDJ_DISPOSICION DISPOSICION ON DISPOSICIONCONFLICTO.ID_DISPOSICION = DISPOSICION.ID_DISPOSICION
WHERE CONFLICTO.ID_CONFLICTO = DISPOSICIONCONFLICTO.ID_CONFLICTO)
),
XMLELEMENT(CL_TEXTO, PKGBDJ_XML.XMLCDATA_PLAINTEXT(CONFLICTO.CL_TEXTO))
).GETCLOBVAL() AS XML
FROM TBGBDJ_CONFLICTO CONFLICTO
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
FROM TBRBDJ_DISPOSICIONCONFLICTO DISPOSICIONCONFLICTO
INNER JOIN TBGBDJ_DISPOSICION DISPOSICION ON DISPOSICIONCONFLICTO.ID_DISPOSICION = DISPOSICION.ID_DISPOSICION
WHERE CONFLICTO.ID_CONFLICTO = DISPOSICIONCONFLICTO.ID_CONFLICTO)
),            
XMLELEMENT(CL_TEXTOHTML, PKGBDJ_XML.XMLCDATA_HTMLTEXT(CONFLICTO.CL_TEXTOHTML))
).GETCLOBVAL() AS XML
FROM TBGBDJ_CONFLICTO CONFLICTO
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
exec ctx_ddl.set_attribute('lexter_spanish', 'base_letter_type', 'generic');
exec ctx_ddl.set_attribute('lexter_spanish', 'index_text', 'yes');
exec ctx_ddl.set_attribute('lexter_spanish', 'punctuations', '.!?):');
--exec ctx_ddl.set_attribute('lexter_spanish', 'index_stems', 'spanish');
exec ctx_ddl.set_attribute('lexter_spanish', 'index_themes', 'no');
--exec ctx_ddl.set_attribute('lexter_spanish', 'theme_language', 'spanish');

--exec ctx_ddl.create_preference('wordlist_spanish', 'BASIC_WORDLIST');
--exec ctx_ddl.set_attribute('wordlist_spanish', 'stemmer', 'spanish');
--exec ctx_ddl.set_attribute('wordlist_spanish', 'fuzzy_match', 'spanish');

exec ctx_ddl.create_preference('mystore', 'BASIC_STORAGE');
exec ctx_ddl.set_attribute('mystore', 'I_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'K_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'R_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K) lob (data) store as (disable storage in row cache)');
exec ctx_ddl.set_attribute('mystore', 'N_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');
exec ctx_ddl.set_attribute('mystore', 'I_INDEX_CLAUSE','tablespace IDMPTBDJ storage (initial 1K) compress 2');
exec ctx_ddl.set_attribute('mystore', 'P_TABLE_CLAUSE','tablespace IDMPTBDJ storage (initial 1K)');