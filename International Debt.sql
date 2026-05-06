SELECT DISTINCT "Country Name" FROM debt_data;

SELECT COUNT(DISTINCT "Country Name") FROM debt_data;

SELECT COUNT(DISTINCT "Series Code") FROM debt_data;

SELECT * FROM debt_data LIMIT 10;

SELECT SUM("Debt_Value") AS total_global_debt FROM debt_data;

SELECT DISTINCT "Series Name" FROM debt_data;

SELECT "Country Name", COUNT(*) 
FROM debt_data
GROUP BY "Country Name";


SELECT * 
FROM debt_data
WHERE "Debt_Value" > 1000000000;

SELECT 
    MIN("Debt_Value") AS min_debt,
    MAX("Debt_Value") AS max_debt,
    AVG("Debt_Value") AS avg_debt
FROM debt_data;


SELECT COUNT(*) FROM debt_data;



SELECT "Country Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name";


SELECT "Country Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name"
ORDER BY total_debt DESC
LIMIT 10;


SELECT "Country Name", AVG("Debt_Value") AS avg_debt
FROM debt_data
GROUP BY "Country Name";


SELECT "Series Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Series Name";


SELECT "Series Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Series Name"
ORDER BY total_debt DESC
LIMIT 1;


SELECT "Country Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name"
ORDER BY total_debt ASC
LIMIT 1;


SELECT 
    "Country Name",
    "Series Name",
    SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name", "Series Name";


SELECT "Country Name", COUNT(DISTINCT "Series Code") AS indicator_count
FROM debt_data
GROUP BY "Country Name";


SELECT "Country Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name"
HAVING SUM("Debt_Value") > (
    SELECT AVG(total_debt)
    FROM (
        SELECT SUM("Debt_Value") AS total_debt
        FROM debt_data
        GROUP BY "Country Name"
    ) t
);


SELECT 
    "Country Name",
    SUM("Debt_Value") AS total_debt,
    RANK() OVER (ORDER BY SUM("Debt_Value") DESC) AS rank
FROM debt_data
GROUP BY "Country Name";




SELECT "Series Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Series Name"
ORDER BY total_debt DESC
LIMIT 5;


SELECT 
    "Country Name",
    SUM("Debt_Value") AS total_debt,
    SUM("Debt_Value") * 100.0 / SUM(SUM("Debt_Value")) OVER () AS percentage_contribution
FROM debt_data
GROUP BY "Country Name"
ORDER BY percentage_contribution DESC;


SELECT *
FROM (
    SELECT 
        "Series Name",
        "Country Name",
        SUM("Debt_Value") AS total_debt,
        RANK() OVER (PARTITION BY "Series Name" ORDER BY SUM("Debt_Value") DESC) AS rnk
    FROM debt_data
    GROUP BY "Series Name", "Country Name"
) t
WHERE rnk <= 3;


SELECT 
    "Country Name",
    MAX("Debt_Value") - MIN("Debt_Value") AS debt_range
FROM debt_data
GROUP BY "Country Name";


CREATE VIEW top_10_countries AS
SELECT "Country Name", SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name"
ORDER BY total_debt DESC
LIMIT 10;

SELECT * FROM top_10_countries;


SELECT 
    "Country Name",
    SUM("Debt_Value") AS total_debt,
    CASE 
        WHEN SUM("Debt_Value") > 1000000000000 THEN 'High Debt'
        WHEN SUM("Debt_Value") > 100000000000 THEN 'Medium Debt'
        ELSE 'Low Debt'
    END AS debt_category
FROM debt_data
GROUP BY "Country Name";


SELECT 
    "Country Name",
    "Year",
    SUM("Debt_Value") AS yearly_debt,
    SUM(SUM("Debt_Value")) OVER (
        PARTITION BY "Country Name"
        ORDER BY "Year"
    ) AS cumulative_debt
FROM debt_data
GROUP BY "Country Name", "Year";


SELECT "Series Name", AVG("Debt_Value") AS avg_debt
FROM debt_data
GROUP BY "Series Name"
HAVING AVG("Debt_Value") > (
    SELECT AVG("Debt_Value") FROM debt_data
);


SELECT 
    "Country Name",
    SUM("Debt_Value") AS total_debt
FROM debt_data
GROUP BY "Country Name"
HAVING SUM("Debt_Value") * 100.0 / (
    SELECT SUM("Debt_Value") FROM debt_data
) > 5;


SELECT *
FROM (
    SELECT 
        "Country Name",
        "Series Name",
        SUM("Debt_Value") AS total_debt,
        RANK() OVER (
            PARTITION BY "Country Name"
            ORDER BY SUM("Debt_Value") DESC
        ) AS rnk
    FROM debt_data
    GROUP BY "Country Name", "Series Name"
) t
WHERE rnk = 1;
