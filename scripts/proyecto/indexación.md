generatedata.com

LUIS                    CRISTIAN                 LORENA
--------------------------------------------------------------
DNI                     TELEFONO                 CP                        
Nombre_Apellidos        email                    cv
pais                    ciudad                   empresa
                        genero                   altura
fecha_ultima_operacion  fecha_nacimiento         fecha_nacimiento


Usuarios:
---------
Id                              PK
Nombre                          nombre_apellidos -> Indice Texto Multicolumna (seccionador)
Primer Apellido                 nombre_apellidos -> Indice Texto Multicolumna (seccionador)
Segundo Apellido                nombre_apellidos -> Indice Texto Multicolumna (seccionador)
                                    EXACTA ? SI
                                    RANGOS ? NO
                                    PREFIJO ? SI ( PREFIJO% )
                                    INFIJO ?  SI ( %INFIJO% )
                                    RAICES ? NO  ( $RAIZ )
                                    FUZZY ?  SI
DNI                             -> NUMERO (Busquedas???)  
                                    Rangos ? NO tiene sentido -> Tiene sentido cuando trabajamos con NUMEROS
                                    EXACTA ? SI
                                    PREFIJO ? SI (autocompletar)
                                    INFIJO ? NO 
                                    RAICES ? NO
                                    FUZZY  ? NO
email                           INDICE ORACLE TEXT ? SI
                                    EXACTA ?  SI
                                    PREFIJO ? SI
                                    INFIJO ?  SI  %osuna%
                                    RAICES ? NO
                                    FUZZY ?  SI
                                    Termino búsqueda?  
                                        ivan.osuna.ayuste@gmail.com ? SI
                                        @gmail.com ? SI
                                        gmail.com  ? SI
                                        ivan osuna ? SI
                                        ozuna ?      SI
                                        ayuste ?     
                                        
                                    ivan.osuna.ayuste@gmail.com
                                        -> ORACLE TEXT INDEXANDO:
                                            Separar tokens por . - _ @ -> VELOCIDAD
                                                ivan
                                                osuna
                                                ayuste
                                                gmail
                                                com
                
telefono                            00 00 00 00 00 00 -> 000000000 -> TEXTO o NUMERO ???
                                    EXACTA ?  SI
                                    FUZZY ?   NO
                                    PREFIJO ? SI   LIKE '1836498%'
                                    INFIJO  ? NO
                                    RAICES ?  NO
                                    RANGOS ?  NO
pais                            NO INDICE ORACLE TEXT -> INDICE NORMALITO
                                    EXACTA ? SI
                                    LISTA DESPLEGABLE
                                    PREFIJO ? NO
                                    INFIJO ?  NO
                                    FUZZY ?   NO
                                Tabla normalizada paises FK
                                    Personas (pais_id)
                                    Paises   (id, nombre_pais) -> nombre_pais (Unique)
                # Numero de paises? 194
ciudad          SI USO ORACLE TEXT
                # Numero de paises? Cientos de miles
                Normalizar las ciudades? -> Si se repiten
                    SI NORMALIZAMOS
                    Ciudades (id, nombre)
                    nombre ciudad -> BUSQUEDAS?
                        EXACTAS ? SI
                        PREFIJO ? SI
                        INFIJO ? SI ¿?
                        FUZZY ? SI

cp                  -> DNI o TELEFONO
empresa             -> NORMALIZAR???? Depende¿?  Cuantos diferentes hay?
                    SI USO OT
tarjeta             -> DNI
pin                 -> No indexo
ccv                 -> No indexo
cv                  ->  ORACLE TEXT
                        EXACTAS ? NO
                        PREFIJO ? NO
                        INFIJO  ? NO
                        FUZZY ?   SI
                        RAICES ?  SI
genero              -> INDICE TRADICIONAL BUSQUEDA EXACTA
altura              -> INDICE TRADICIONAL BUSQUEDA EXACTA
                        EXACTA? SI ¿?
                        RANGOS? SI
                        
fecha ultima operacion sistema -> EXACTA, RANGO = IGUAL QUE ALTURA
fecha nacimiento

99999999-T -> 
    VARCHAR2(9)
99999999 
    INTEGER

1º Ventaja:
    - Espacio: 18 bytes -> (4 bytes + 2 bytes)
    
    1 byte: 2^8 = 256
    2 bytes: 256*256 = 65k
    3 bytes: 256^3 = 16 M
    4 bytes: 256^4 = 4kM

    INSERT -> LETRA uso para validar:Si es ok hago insert sin letra. Si no cuela, error
                Procedimiento almacenado
    
Inconvenientes:
    - Quiero generar un listado que incluya las letras
        Tener las letras precalculadas -> Almacenar las letras
            2 campos  -> numero
                      -> letra
    
    Pc -> Comodore PC 10 -> Micro 4Mhz  - Hoy en día 4Ghz x 8 cores
                            640 kbs RAM
                            No HD (50.000 pts -> 300 € -> 10Mb )
                
                BIGDATA
                            
            250.000 pts ->  1500 €

