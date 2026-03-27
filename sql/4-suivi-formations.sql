-- parametres pour les requetes
DROP TABLE IF EXISTS _params_formation;
CREATE TEMP TABLE _params_formation (
    formation_id INT
);
INSERT INTO _params_formation VALUES (1);

--q1
SELECT
    f.formation_intitule    AS formation,
    c.ordre,
    m.module_intitule       AS module,
    m.module_duree          AS duree_prevue,
    c.duree_effective,
    m.module_coefficient
FROM composer c
JOIN formation f ON f.formation_id = c.formation_id
JOIN module_   m ON m.module_id    = c.module_id
CROSS JOIN _params_formation p
WHERE c.formation_id = p.formation_id
ORDER BY c.ordre;

--q2
SELECT
    m.module_intitule                   AS module,
    COUNT(DISTINCT i.etudiant_id)       AS nb_inscrits
FROM module_ m
JOIN composer    c ON c.module_id    = m.module_id
JOIN inscription i ON i.formation_id = c.formation_id
GROUP BY m.module_id, m.module_intitule
ORDER BY nb_inscrits DESC;

--q3
SELECT
    f.formation_id,
    f.formation_intitule,
    f.formation_annee
FROM formation f
WHERE NOT EXISTS (
    SELECT 1
    FROM inscription i
    WHERE i.formation_id = f.formation_id
)
ORDER BY f.formation_intitule;

--q4
WITH durees AS (
    SELECT
        c.formation_id,
        SUM(c.duree_effective)  AS total_effectif,
        COUNT(c.module_id)      AS nb_modules
    FROM composer c
    GROUP BY c.formation_id
)
SELECT
    f.formation_intitule                        AS formation,
    f.formation_duree                           AS total_prevu_h,
    d.total_effectif                            AS total_effectif_h,
    f.formation_duree - d.total_effectif        AS ecart_h,
    ROUND(
        d.total_effectif::NUMERIC
        / f.formation_duree * 100, 1
    )                                           AS taux_realisation_pct
FROM formation f
JOIN durees d ON d.formation_id = f.formation_id
ORDER BY taux_realisation_pct ASC;