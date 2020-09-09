# Instalar Oracle como contenedor

## Paso 1: Crear y arrancar contenedor:
> docker run -d -it -p 1521:1521 -v /home/ubuntu/environment/ivan/scripts/context/documents:/home/oracle/documents --name mi_oracle store/oracle/database-enterprise:12.2.0.1

### Paso 1: Verificación:
> docker container list --all
    CONTAINER ID        IMAGE                                       COMMAND                  CREATED             STATUS                 PORTS                NAMES
    a27944d4f70b        store/oracle/database-enterprise:12.2.0.1   "/bin/sh -c '/bin/ba…"   2 hours ago         Up 2 hours (healthy)   1521/tcp, 5500/tcp   mi_oracle

## Paso 2: Cambiar la contraseña del usuario sys
> docker exec -it mi_oracle bash
>> sqlplus sys as sysdba
>>> alter user sys identified by password;

## Comandos adicionales
### Parar oracle
> docker stop mi_oracle

### Parar arrancar oracle
> docker start mi_oracle

# Reinstalar Oracle
> docker rm mi_oracle -f -v
    -f: Aunque oracle esté corriendo, que lo borre
    -v: Borar todos los archivos del disco (Volumen del contenedor)
Repetir el paso 1

# Abrir el sqlplus en el contenedor de oracle
> docker exec -it mi_oracle bash -c "source /home/oracle/.bashrc; sqlplus"
> docker exec -it mi_oracle bash -c "source /home/oracle/.bashrc; sqlplus sys as sysdba"