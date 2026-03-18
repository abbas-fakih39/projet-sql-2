-- =========================
-- PARAMETRES GLOBAUX
-- Modifie seulement ces valeurs
-- =========================
DROP TABLE IF EXISTS _params_reporting;
CREATE TEMP TABLE _params_reporting (
    seuil_alerte    NUMERIC,   -- moyenne min avant alerte formation
    seuil_risque    NUMERIC,   -- taux echec % avant alerte module
    seuil_excellent NUMERIC,   -- note >= excellent
    seuil_satisfait NUMERIC,   -- note >= satisfaisant
    seuil_passable  NUMERIC    -- note >= passable
);
INSERT INTO _params_reporting VALUES (12, 30, 16, 12, 10);

-- =========================
-- Q1 : Comptages globaux
-- =========================
SELECT
    (SELECT COUNT(*) FROM etudiant)    AS nb_etudiants,
    (SELECT COUNT(*) FROM formation)   AS nb_formations,
    (SELECT COUNT(*) FROM module_)     AS nb_modules,
    (SELECT COUNT(*) FROM intervenant) AS nb_intervenants,
    (SELECT COUNT(*) FROM inscription) AS nb_inscriptions,
    (SELECT COUNT(*) FROM evaluation)  AS nb_evaluations;

-- =========================
-- Q2 : Moyenne generale par formation
-- =========================
WITH stats AS (
    SELECT
        i.formation_id,
        COUNT(DISTINCT i.etudiant_id)                   AS nb_etudiants,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2)    AS moyenne,
        ROUND(MIN(ev.evaluation_valeur)::NUMERIC, 2)    AS note_min,
        ROUND(MAX(ev.evaluation_valeur)::NUMERIC, 2)    AS note_max
    FROM inscription i
    LEFT JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.formation_id
)
SELECT
    f.formation_intitule    AS formation,
    s.nb_etudiants,
    s.moyenne,
    s.note_min,
    s.note_max
FROM stats s
JOIN formation f ON f.formation_id = s.formation_id
ORDER BY s.moyenne DESC;

-- =========================
-- Q3 : Repartition des etudiants par statut
-- =========================
SELECT
    i.inscription_statut                                        AS statut,
    COUNT(*)                                                    AS nb,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)         AS pourcentage
FROM inscription i
GROUP BY i.inscription_statut
ORDER BY nb DESC;

-- =========================
-- Q4 : Moyenne par formation ET par module
-- =========================
WITH moyennes AS (
    SELECT
        i.formation_id,
        ev.module_id,
        COUNT(ev.evaluation_id)                         AS nb_notes,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2)    AS moyenne
    FROM inscription i
    JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.formation_id, ev.module_id
)
SELECT
    f.formation_intitule    AS formation,
    m.module_intitule       AS module,
    mo.nb_notes,
    mo.moyenne
FROM moyennes mo
JOIN formation f ON f.formation_id = mo.formation_id
JOIN module_   m ON m.module_id    = mo.module_id
ORDER BY f.formation_intitule, mo.moyenne ASC;

-- =========================
-- Q5 : Nombre d inscrits par formation et par annee
-- =========================
SELECT
    f.formation_annee,
    f.formation_intitule            AS formation,
    COUNT(i.inscription_id)         AS nb_inscrits
FROM formation f
LEFT JOIN inscription i ON i.formation_id = f.formation_id
GROUP BY f.formation_id, f.formation_annee, f.formation_intitule
ORDER BY f.formation_annee, nb_inscrits DESC;

-- =========================
-- Q6 : Evolution des inscriptions par mois avec cumul
-- =========================
WITH par_mois AS (
    SELECT
        TO_CHAR(inscription_date, 'YYYY-MM') AS mois,
        COUNT(*)                             AS nb_inscriptions
    FROM inscription
    GROUP BY TO_CHAR(inscription_date, 'YYYY-MM')
)
SELECT
    mois,
    nb_inscriptions,
    SUM(nb_inscriptions) OVER (ORDER BY mois) AS cumul
FROM par_mois
ORDER BY mois;

-- =========================
-- Q7 : Classement etudiants par categorie (CASE WHEN)
-- =========================
WITH moyennes AS (
    SELECT
        i.etudiant_id,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
    FROM inscription i
    JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.etudiant_id
)
SELECT
    e.etudiant_nom,
    e.etudiant_prenom,
    m.moyenne,
    CASE
        WHEN m.moyenne >= p.seuil_excellent THEN 'Excellent'
        WHEN m.moyenne >= p.seuil_satisfait THEN 'Satisfaisant'
        WHEN m.moyenne >= p.seuil_passable  THEN 'Passable'
        ELSE                                     'Insuffisant'
    END AS categorie
FROM moyennes m
JOIN etudiant e ON e.etudiant_id = m.etudiant_id
CROSS JOIN _params_reporting p
ORDER BY m.moyenne DESC;

-- =========================
-- Q8 : Formations avec moyenne inferieure au seuil d alerte
-- =========================
WITH moyennes_formation AS (
    SELECT
        i.formation_id,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
    FROM inscription i
    LEFT JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.formation_id
)
SELECT
    f.formation_intitule    AS formation,
    mf.moyenne
FROM moyennes_formation mf
JOIN formation f ON f.formation_id = mf.formation_id
CROSS JOIN _params_reporting p
WHERE mf.moyenne IS NULL
    OR mf.moyenne < p.seuil_alerte
ORDER BY mf.moyenne ASC;

-- =========================
-- Q9 : Modules a risque (taux echec >= seuil)
-- =========================
WITH stats_module AS (
    SELECT
        ev.module_id,
        COUNT(*)                                            AS nb_evaluations,
        COUNT(CASE WHEN ev.evaluation_valeur < 10 THEN 1 END) AS nb_echecs
    FROM evaluation ev
    GROUP BY ev.module_id
)
SELECT
    m.module_intitule                                   AS module,
    s.nb_evaluations,
    s.nb_echecs,
    ROUND(s.nb_echecs * 100.0 / s.nb_evaluations, 1)   AS taux_echec_pct
FROM stats_module s
JOIN module_ m ON m.module_id = s.module_id
CROSS JOIN _params_reporting p
WHERE s.nb_echecs * 100.0 / s.nb_evaluations >= p.seuil_risque
ORDER BY taux_echec_pct DESC;

-- =========================
-- Q10 : Classement par formation (RANK)
-- =========================
WITH moyennes AS (
    SELECT
        i.formation_id,
        i.etudiant_id,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
    FROM inscription i
    JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.formation_id, i.etudiant_id
)
SELECT
    f.formation_intitule                        AS formation,
    e.etudiant_nom || ' ' || e.etudiant_prenom  AS etudiant,
    m.moyenne,
    RANK() OVER (
        PARTITION BY m.formation_id
        ORDER BY m.moyenne DESC
    )                                           AS classement
FROM moyennes m
JOIN formation f ON f.formation_id = m.formation_id
JOIN etudiant  e ON e.etudiant_id  = m.etudiant_id
ORDER BY f.formation_intitule, classement;