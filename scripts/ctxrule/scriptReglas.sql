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
