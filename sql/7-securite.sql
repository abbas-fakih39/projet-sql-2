-- 3 rôles : lecteur / gestionnaire / admin

-- Supprimer si existent
DROP ROLE IF EXISTS formation_lecteur;
DROP ROLE IF EXISTS formation_gestionnaire;
DROP ROLE IF EXISTS formation_admin;

-- Rôle 1 : LECTEUR 
CREATE ROLE formation_lecteur;
GRANT CONNECT ON DATABASE formation_db TO formation_lecteur;
GRANT USAGE   ON SCHEMA public          TO formation_lecteur;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM formation_lecteur;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM formation_lecteur;
-- Les futures tables aussi
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    REVOKE SELECT ON TABLES FROM formation_lecteur;

-- Rôle 2 : GESTIONNAIRE 
CREATE ROLE formation_gestionnaire;
GRANT CONNECT ON DATABASE formation_db TO formation_gestionnaire;
GRANT USAGE   ON SCHEMA public          TO formation_gestionnaire;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA public      TO formation_gestionnaire;
GRANT USAGE, SELECT
    ON ALL SEQUENCES IN SCHEMA public   TO formation_gestionnaire;
-- Pas de DROP TABLE, pas de CREATE TABLE

-- Rôle 3 : ADMIN 
CREATE ROLE formation_admin;
GRANT ALL PRIVILEGES ON DATABASE formation_db TO formation_admin;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO formation_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO formation_admin;

--creation d'utilisateurs et attribution de rôles

CREATE USER directeur WITH PASSWORD 'directeur_pass_2024!';
GRANT formation_lecteur TO directeur;


CREATE USER responsable_pedago WITH PASSWORD 'resp_pass_2024!';
GRANT formation_gestionnaire TO responsable_pedago;

CREATE USER dba_formation WITH PASSWORD 'dba_pass_2024!';
GRANT formation_admin TO dba_formation;


-- Vue publique etudiants (sans email ni telephone)
CREATE OR REPLACE VIEW v_etudiants_public AS
SELECT
    etudiant_id,
    etudiant_nom,
    etudiant_prenom,
    etudiant_date_naissance
FROM etudiant;


CREATE OR REPLACE VIEW v_resultats AS
SELECT
    i.inscription_id,
    i.formation_id,
    i.inscription_statut,
    ROUND(AVG(ev.evaluation_valeur)::NUMERIC, 2) AS moyenne
FROM inscription i
LEFT JOIN evaluation ev ON ev.inscription_id = i.inscription_id
GROUP BY i.inscription_id, i.formation_id, i.inscription_statut;

GRANT SELECT ON v_etudiants_public TO formation_lecteur;
GRANT SELECT ON v_resultats        TO formation_lecteur;

-- VÉRIFICATION DES DROITS

SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('formation_lecteur','formation_gestionnaire','formation_admin')
ORDER BY grantee, table_name;
