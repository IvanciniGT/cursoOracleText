/*
Crear una tabla
*/
CREATE TABLE emails (
    id NUMBER PRIMARY KEY,
    destinatario VARCHAR2(200),
    remitente VARCHAR2(200),
    asunto VARCHAR2(200),
    contenido VARCHAR2(4000)
);
/*
Crear un indice de texto
*/
CREATE INDEX destinatario_idx ON emails(destinatario)
INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
(
'FILTER CTXSYS.NULL_FILTER'
);
/*
Insertar unas cuantas filas
*/
INSERT INTO emails VALUES (1, 'Iván Osuna Ayuste', 'Cristian Blanco Isidoro', 'Feedbask del curso', '........');
INSERT INTO emails VALUES (2, 'Luis Adeva Paredes', 'Cristian Blanco Isidoro', 'El profe no se explica', '........');
INSERT INTO emails VALUES (3, 'Cristian Blanco Isidoro', 'Luis Adeva Paredes', 'Ya, es un poco capullo', '........');
INSERT INTO emails VALUES (4, 'Lorena Peciña', 'Cristian Blanco Isidoro', 'El profe si se explica bien', '........');
INSERT INTO emails VALUES (5, 'Isidoro Blanco García', 'Cristian Blanco Isidoro', 'Ya, es un poco capullo', '........');
INSERT INTO emails VALUES (6, 'Luis Adeva García de Miguel Sanchez Paredes', 'Cristian Blanco Isidoro', 'El profe no se explica', '........');

/*
REGENERAR EL INDICE DESPUES DE INSERCIONES
*/
EXEC CTX_DDL.SYNC_INDEX('destinatario_idx','2M');