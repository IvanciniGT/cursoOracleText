SELECT id,remitente FROM emails
WHERE
    CATSEARCH(remitente, 'Luis','order by id') > 0
;