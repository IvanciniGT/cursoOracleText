SELECT id FROM emails
WHERE
    CATSEARCH(remitente, 'Luis','order by remitente') > 0
;