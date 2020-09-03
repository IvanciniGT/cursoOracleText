select * from emails;

select id from emails
where
    remitente='Cristian Blanco Isidoro';


/*
2ª RUINA MAS GRANDE QUE PUEDO HACER EN ORACLE!!!!! PROHIBIDIISIIIIIISIMO
*/
select id from emails
where
    remitente LIKE 'Cristian%';


/*
1,5ª RUINA MAS GRANDE QUE PUEDO HACER EN ORACLE!!!!! PROHIBIDIISIIIIIISIMO
*/
select id from emails
where
    UPPER(remitente) LIKE UPPER('cristian%');


/*
1ª RUINA MAS GRANDE QUE PUEDO HACER EN ORACLE!!!!! PROHIBIDIISIIIIIISIMO
*/
select id from emails
where
    REGEXP_LIKE(destinatario, '[A-Za-z]+ [A-Za-z]{2,10}( [A-Za-z]+)?');

/*
METODO GUAY !!!!!!
*/
select id, SCORE(1) from emails
where
    CONTAINS(destinatario, 'Luis and Paredes', 1) > 0;
    
select id, SCORE(1) from emails
where
    CONTAINS(destinatario, 'Luis or iván', 1) > 0;
    
select id, SCORE(1) from emails
where
    CONTAINS(destinatario, 'near((Luis,Paredes),10)', 1) > 0;

/*
Este no funciona porque no tiene índice creado
*/
select id, SCORE(1) from emails
where
    CONTAINS(remitente, 'Cristian', 1) > 0;