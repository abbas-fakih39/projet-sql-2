
-- parametres pour les requetes
-- Modifie seulement ces 3 valeurs
-- =========================
DROP TABLE IF EXISTS _params;
CREATE TEMP TABLE _params (
    formation_id INT,
    etudiant_id INT,
    module_id INT
);

INSERT INTO _params (formation_id, etudiant_id, module_id)
VALUES (1, 1, 2);

--q1
SELECT
    e.etudiant_id,
    e.etudiant_nom,
    e.etudiant_prenom,
    e.etudiant_email,
    i.inscription_date,
    i.inscription_statut
FROM inscription i
JOIN etudiant e ON e.etudiant_id = i.etudiant_id
CROSS JOIN _params p
WHERE i.formation_id = p.formation_id
ORDER BY e.etudiant_nom, e.etudiant_prenom;

--q2
SELECT
    e.etudiant_nom || ' ' || e.etudiant_prenom AS etudiant,
    f.formation_intitule                        AS formation,
    m.module_intitule                           AS module,
    ev.evaluation_type,
    ev.evaluation_valeur                        AS note,
    ev.evaluation_date
FROM etudiant e
JOIN inscription i  ON i.etudiant_id     = e.etudiant_id
JOIN formation   f  ON f.formation_id    = i.formation_id
JOIN evaluation  ev ON ev.inscription_id = i.inscription_id
JOIN module_     m  ON m.module_id       = ev.module_id
CROSS JOIN _params p
WHERE e.etudiant_id = p.etudiant_id
ORDER BY f.formation_intitule, m.module_intitule, ev.evaluation_date;

--q3
SELECT
    e.etudiant_id,
    e.etudiant_nom,
    e.etudiant_prenom,
    f.formation_intitule AS formation
FROM inscription i
JOIN etudiant  e ON e.etudiant_id  = i.etudiant_id
JOIN formation f ON f.formation_id = i.formation_id
CROSS JOIN _params p
WHERE i.formation_id = p.formation_id
  AND NOT EXISTS (
      SELECT 1
      FROM evaluation ev
      WHERE ev.inscription_id = i.inscription_id
        AND ev.module_id = p.module_id
  )
ORDER BY e.etudiant_nom, e.etudiant_prenom;

--q4
WITH moyennes AS (
    SELECT
        i.inscription_id,
        i.etudiant_id,
        i.formation_id,
        i.inscription_statut,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
    FROM inscription i
    LEFT JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.inscription_id, i.etudiant_id, i.formation_id, i.inscription_statut
)
SELECT
    e.etudiant_nom,
    e.etudiant_prenom,
    f.formation_intitule AS formation,
    m.inscription_statut,
    m.moyenne
FROM moyennes m
JOIN etudiant  e ON e.etudiant_id  = m.etudiant_id
JOIN formation f ON f.formation_id = m.formation_id
WHERE m.inscription_statut = 'echec'
   OR m.moyenne < 10
ORDER BY m.moyenne ASC NULLS LAST;

-q5
WITH moyennes AS (
    SELECT
        i.inscription_id,
        i.etudiant_id,
        i.formation_id,
        i.inscription_statut,
        ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
    FROM inscription i
    JOIN evaluation ev ON ev.inscription_id = i.inscription_id
    GROUP BY i.inscription_id, i.etudiant_id, i.formation_id, i.inscription_statut
)
SELECT
    e.etudiant_nom,
    e.etudiant_prenom,
    f.formation_intitule AS formation,
    m.moyenne
FROM moyennes m
JOIN etudiant  e ON e.etudiant_id  = m.etudiant_id
JOIN formation f ON f.formation_id = m.formation_id
WHERE m.inscription_statut = 'reussite'
  AND m.moyenne >= 10
ORDER BY m.moyenne DESC;