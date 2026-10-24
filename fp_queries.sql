-- =====================================================================
-- Завдання 1.
-- Скриншот: p1_create_schema_import.png
-- =====================================================================
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

SELECT * FROM infectious_cases;

-- =====================================================================
-- Завдання 2.
-- Скриншоти: p2_1_count_infectious_cases.png, p2_2_normalized_tables.png
-- =====================================================================
SELECT COUNT(*) FROM infectious_cases;

CREATE TABLE entities (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL UNIQUE,
    code   VARCHAR(10) NULL
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, NULLIF(Code, '')
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    entity_id            INT NOT NULL,
    year                 INT NOT NULL,
    number_yaws          DOUBLE NULL,
    polio_cases          DOUBLE NULL,
    cases_guinea_worm    DOUBLE NULL,
    number_rabies        DOUBLE NULL,
    number_malaria       DOUBLE NULL,
    number_hiv           DOUBLE NULL,
    number_tuberculosis  DOUBLE NULL,
    number_smallpox      DOUBLE NULL,
    number_cholera_cases DOUBLE NULL,
    UNIQUE (entity_id, year),
    FOREIGN KEY (entity_id) REFERENCES entities (id)
);

INSERT INTO infectious_cases_normalized (
    entity_id, year, number_yaws, polio_cases, cases_guinea_worm,
    number_rabies, number_malaria, number_hiv, number_tuberculosis,
    number_smallpox, number_cholera_cases
)
SELECT e.id, ic.Year,
       NULLIF(ic.Number_yaws, ''),
       NULLIF(ic.polio_cases, ''),
       NULLIF(ic.cases_guinea_worm, ''),
       NULLIF(ic.Number_rabies, ''),
       NULLIF(ic.Number_malaria, ''),
       NULLIF(ic.Number_hiv, ''),
       NULLIF(ic.Number_tuberculosis, ''),
       NULLIF(ic.Number_smallpox, ''),
       NULLIF(ic.Number_cholera_cases, '')
FROM infectious_cases ic
JOIN entities e ON e.entity = ic.Entity;

SELECT COUNT(*) FROM infectious_cases;
SELECT COUNT(*) FROM entities;
SELECT COUNT(*) FROM infectious_cases_normalized;

-- =====================================================================
-- Завдання 3.
-- Скриншот: p3_rabies_stats.png
-- =====================================================================
SELECT e.id,
       e.entity,
       e.code,
       AVG(n.number_rabies) AS avg_rabies,
       MIN(n.number_rabies) AS min_rabies,
       MAX(n.number_rabies) AS max_rabies,
       SUM(n.number_rabies) AS sum_rabies
FROM infectious_cases_normalized n
JOIN entities e ON e.id = n.entity_id
WHERE n.number_rabies IS NOT NULL
GROUP BY e.id, e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- =====================================================================
-- Завдання 4.
-- Скриншот: p4_year_diff.png
-- =====================================================================
SELECT id,
       entity_id,
       year,
       MAKEDATE(year, 1)                                  AS start_of_year,
       CURDATE()                                          AS today,
       TIMESTAMPDIFF(YEAR, MAKEDATE(year, 1), CURDATE())  AS years_diff
FROM infectious_cases_normalized;

-- =====================================================================
-- Завдання 5.
-- Скриншот: p5_years_since_function.png
-- =====================================================================
DROP FUNCTION IF EXISTS years_since;

DELIMITER //

CREATE FUNCTION years_since(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
END //

DELIMITER ;

SELECT id,
       entity_id,
       year,
       years_since(year) AS years_diff
FROM infectious_cases_normalized;
