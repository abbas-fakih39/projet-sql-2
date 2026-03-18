-- =========================
-- PARAMETRES GLOBAUX
-- Modifie seulement cette valeur
-- =========================
DROP TABLE IF EXISTS _params_intervenant;
CREATE TEMP TABLE _params_intervenant (
    intervenant_id INT
);
INSERT INTO _params_intervenant VALUES (1);

-- =========================
-- Q1 : Modules animes par un intervenant
-- =========================
SELECT
    iv.intervenant_nom || ' ' || iv.intervenant_prenom  AS intervenant,
    m.module_intitule                                    AS module,
    m.module_duree
FROM animer a
JOIN intervenant iv ON iv.intervenant_id = a.intervenant_id
JOIN module_     m  ON m.module_id       = a.module_id
CROSS JOIN _params_intervenant p
WHERE a.intervenant_id = p.intervenant_id
ORDER BY m.module_intitule;

-- =========================
-- Q2 : Intervenants avec le plus de modules
-- =========================
WITH charge AS (
    SELECT
        a.intervenant_id,
        COUNT(a.module_id) AS nb_modules
    FROM animer a
    GROUP BY a.intervenant_id
)
SELECT
    iv.intervenant_nom || ' ' || iv.intervenant_prenom  AS intervenant,
    iv.intervenant_specialite,
    COALESCE(c.nb_modules, 0)                           AS nb_modules
FROM intervenant iv
LEFT JOIN charge c ON c.intervenant_id = iv.intervenant_id
ORDER BY nb_modules DESC;

-- =========================
-- Q3 : Modules sans intervenant affecte
-- =========================
SELECT
    m.module_id,
    m.module_intitule   AS module,
    m.module_duree
FROM module_ m
WHERE NOT EXISTS (
    SELECT 1
    FROM animer a
    WHERE a.module_id = m.module_id
)
ORDER BY m.module_intitule;