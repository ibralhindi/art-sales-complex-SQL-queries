
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon*/
/* (;) at the end of this answer*/
SELECT
    artist_code,
    TRIM(artist_gname
         || ' '
         || artist_fname)    AS artist_fullname,
    artist_street
    || ', '
    || artist_town
    || ', '
    || artist_state     AS artist_address
FROM
    acl.artist
WHERE
    artist_code NOT IN (
        SELECT
            artist_code
        FROM
            acl.artwork
    )
    AND artist_phone IS NULL
ORDER BY
    artist_code;

/*
    Q2
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    artist_code,
    TRIM(artist_gname
         || ' '
         || artist_fname)    AS artist_fullname,
    CASE
        WHEN artist_state = 'SA'   THEN
            'South Australia'
        WHEN artist_state = 'QLD'  THEN
            'Queensland'
        WHEN artist_state = 'NSW'  THEN
            'New South Wales'
    END                 AS artist_state
FROM
    acl.artist
WHERE
    artist_state IN ( 'NSW', 'SA', 'QLD' )
ORDER BY
    artist_fullname,
    artist_code;

/*
    Q3
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    a.artist_code,
    a.artwork_no,
    artwork_title,
    to_char(sale_date, 'dd/MON/yyyy')      AS sale_date,
    to_char(sale_price, '$99,999.99')      AS "Sale Price"
FROM
         acl.sale s
    JOIN acl.artwork_display    a
    ON s.awdisplay_id = a.awdisplay_id
    JOIN acl.artwork            ar
    ON ( a.artist_code = ar.artist_code
         AND a.artwork_no = ar.artwork_no )
WHERE
        customer_id = (
            SELECT
                customer_id
            FROM
                acl.customer
            WHERE
                    upper(customer_gname) = upper('Jobie')
                AND upper(customer_fname) = upper('Pheazey')
        )
    AND gallery_id = (
        SELECT
            gallery_id
        FROM
            acl.gallery
        WHERE
            gallery_phone = '0490556646'
    )
ORDER BY
    sale_price DESC,
    artist_code,
    artwork_no;

/*
    Q4
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    a.artist_code,
    a.artwork_no,
    artwork_title,
    to_char(awdisplay_start_date, 'dd/MON/yyyy')      AS display_start_date,
    ( awdisplay_end_date - awdisplay_start_date )     AS display_total_days
FROM
         acl.artwork_display ad
    JOIN acl.artwork a
    ON ( ad.artist_code = a.artist_code
         AND ad.artwork_no = a.artwork_no )
WHERE
    awdisplay_end_date IS NOT NULL
    AND gallery_id = (
        SELECT
            gallery_id
        FROM
            acl.gallery
        WHERE
            gallery_phone = '0438093219'
    )
    AND ( awdisplay_end_date - awdisplay_start_date ) < (
        SELECT
            AVG(awdisplay_end_date - awdisplay_start_date)
        FROM
            acl.artwork_display
        WHERE
            gallery_id = (
                SELECT
                    gallery_id
                FROM
                    acl.gallery
                WHERE
                    gallery_phone = '0438093219'
            )
    )
ORDER BY
    display_total_days,
    awdisplay_start_date,
    artist_code,
    artwork_no;        

/*
    Q5
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    a.artist_code,
    a.artwork_no,
    artwork_title,
    COUNT(*) AS artwork_movements
FROM
         acl.artwork a
    JOIN acl.artwork_status ar
    ON ( a.artist_code = ar.artist_code
         AND a.artwork_no = ar.artwork_no )
WHERE
        aws_action = 'T'
    AND gallery_id IS NOT NULL
GROUP BY
    a.artist_code,
    a.artwork_no,
    artwork_title
HAVING
    COUNT(*) > (
        SELECT
            AVG(COUNT(*))
        FROM
            acl.artwork_status
        WHERE
                aws_action = 'T'
            AND gallery_id IS NOT NULL
        GROUP BY
            artist_code,
            artwork_no
    )
ORDER BY
    artwork_movements DESC,
    artist_code,
    artwork_no; 

/*
    Q6
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    a.artist_code,
    TRIM(artist_gname
         || ' '
         || artist_fname)                                                   AS artist_fullname,
    ar.artwork_no,
    artwork_title,
    lpad(to_char(artwork_minpayment, '$99,999.99'), 15, ' ')           AS "Artist Min. Payment",
    floor((aws_date_time - artwork_submitdate))                        AS days_held_by_acl
FROM
         acl.artist a
    JOIN acl.artwork           ar
    ON a.artist_code = ar.artist_code
    JOIN acl.artwork_status    aw
    ON ( ar.artist_code = aw.artist_code
         AND ar.artwork_no = aw.artwork_no )
WHERE
        aws_action = 'R'
    AND ( aws_date_time - artwork_submitdate ) <= 60
    AND ( ar.artist_code, ar.artwork_no ) NOT IN (
        SELECT
            artist_code,
            artwork_no
        FROM
            acl.artwork_display
    )
ORDER BY
    artist_code,
    days_held_by_acl DESC;

/*
    Q7
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    g.gallery_id,
    gallery_name,
    gallery_manager,
    gallery_street
    || ', '
    || gallery_town
    || ', '
    || gallery_state                                                                AS gallery_address,
    lpad(to_char(nvl(SUM(sale_price), 0), '$999,990.99'), 15, ' ')                  AS "Total Sales",
    lpad(to_char((gallery_sale_percent / 100) * nvl(SUM(sale_price), 0), '$99,990.99'),
         15,
         ' ')                                                                       AS "Total Commision"
FROM
    acl.gallery            g
    LEFT JOIN acl.artwork_display    a
    ON g.gallery_id = a.gallery_id
    LEFT JOIN acl.sale               s
    ON a.awdisplay_id = s.awdisplay_id
WHERE
    gallery_state = 'VIC'
GROUP BY
    g.gallery_id,
    gallery_name,
    gallery_manager,
    gallery_street,
    gallery_town,
    gallery_state,
    gallery_sale_percent
ORDER BY
    ( ( gallery_sale_percent / 100 ) * nvl(SUM(sale_price), 0) ) DESC,
    gallery_id;

/*
    Q8
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    a.artist_code,
    TRIM(artist_gname
         || ' '
         || artist_fname)                       AS artist_fullname,
    artwork_title,
    gallery_name,
    to_char(artwork_minpayment /(1 -(0.2 +(gallery_sale_percent / 100))),
            '$99,999.99')                  AS est_min_sale_price,
    to_char(sale_price, '$99,999.99')      AS sale_price,
    to_char(((sale_price /(artwork_minpayment /(1 -(0.2 +(gallery_sale_percent / 100))))) -
    1) * 100,
            '990.9')
    || '%'                                 AS perc_abve_min_sale_price
FROM
         acl.sale s
    JOIN acl.artwork_display    ad
    ON s.awdisplay_id = ad.awdisplay_id
    JOIN acl.artist             a
    ON ad.artist_code = a.artist_code
    JOIN acl.artwork            ar
    ON ( ad.artist_code = ar.artist_code
         AND ad.artwork_no = ar.artwork_no )
    JOIN acl.gallery            g
    ON ad.gallery_id = g.gallery_id
ORDER BY
    ( ( ( s.sale_price / ( artwork_minpayment / ( 1 - ( 0.2 + ( gallery_sale_percent /
    100 ) ) ) ) ) - 1 ) * 100 );

/*
    Q9
*/
/* PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE*/
/* ENSURE that your query is formatted and has a semicolon (;)*/
/* at the end of this answer*/
SELECT
    g.gallery_id,
    gallery_name,
    lpad(to_char((0.2 * SUM(sale_price)), '$99,999.99'), 15, ' ')                  AS total_acl_commision,
    TRIM(
        CASE
            WHEN SUM(sale_price) =(
                SELECT
                    MAX(SUM(sale_price))
                FROM
                         acl.sale s
                    JOIN acl.artwork_display a
                    ON s.awdisplay_id = a.awdisplay_id
                GROUP BY
                    gallery_id
            ) THEN
                to_char((0.2 * SUM(sale_price)) /(
                    SELECT
                        0.2 * SUM(sale_price)
                    FROM
                        acl.sale
                ) * 100,
                        '990')
                || '% - Most profitable'
            ELSE
                to_char((0.2 * SUM(sale_price)) /(
                    SELECT
                        0.2 * SUM(sale_price)
                    FROM
                        acl.sale
                ) * 100,
                        '990')
                || '% - Least profitable'
        END
    )                                                                              AS percentage_of_revenue
FROM
         acl.sale s
    JOIN acl.artwork_display    a
    ON s.awdisplay_id = a.awdisplay_id
    JOIN acl.gallery            g
    ON a.gallery_id = g.gallery_id
GROUP BY
    g.gallery_id,
    gallery_name
HAVING
    SUM(sale_price) IN ( (
        SELECT
            MIN(SUM(sale_price))
        FROM
                 acl.sale s
            JOIN acl.artwork_display a
            ON s.awdisplay_id = a.awdisplay_id
        GROUP BY
            gallery_id
    ),
                         (
                         SELECT
                             MAX(SUM(sale_price))
                         FROM
                                  acl.sale s
                             JOIN acl.artwork_display a
                             ON s.awdisplay_id = a.awdisplay_id
                         GROUP BY
                             gallery_id
                     ) )
ORDER BY
    SUM(sale_price) DESC,
    gallery_id;