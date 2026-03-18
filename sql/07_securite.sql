-- ============================================================
-- 07_securite.sql
-- Partie 5 - Sécurité & Sauvegarde
-- ============================================================

-- ============================================================
-- GESTION DES RÔLES
-- 3 rôles : lecteur / gestionnaire / admin
-- ============================================================

-- Supprimer si déjà existants (pour reset)
DROP ROLE IF EXISTS formation_lecteur;
DROP ROLE IF EXISTS formation_gestionnaire;
DROP ROLE IF EXISTS formation_admin;

-- Rôle 1 : LECTEUR (consultation uniquement - ex: direction, auditeurs)
CREATE ROLE formation_lecteur;
GRANT CONNECT ON DATABASE formation_db TO formation_lecteur;
GRANT USAGE   ON SCHEMA public          TO formation_lecteur;
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM formation_lecteur;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM formation_lecteur;
-- Les futures tables aussi
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    REVOKE SELECT ON TABLES FROM formation_lecteur;

-- Rôle 2 : GESTIONNAIRE (lecture + écriture des données pédagogiques)
--           mais PAS de modification de structure
CREATE ROLE formation_gestionnaire;
GRANT CONNECT ON DATABASE formation_db TO formation_gestionnaire;
GRANT USAGE   ON SCHEMA public          TO formation_gestionnaire;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA public      TO formation_gestionnaire;
GRANT USAGE, SELECT
    ON ALL SEQUENCES IN SCHEMA public   TO formation_gestionnaire;
-- Pas de DROP TABLE, pas de CREATE TABLE

-- Rôle 3 : ADMIN (tous les droits)
CREATE ROLE formation_admin;
GRANT ALL PRIVILEGES ON DATABASE formation_db TO formation_admin;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO formation_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO formation_admin;

-- ============================================================
-- CRÉATION D'UTILISATEURS ET ASSIGNATION DE RÔLES
-- ============================================================

-- Utilisateur : directeur (lecture seule)
CREATE USER directeur WITH PASSWORD 'directeur_pass_2024!';
GRANT formation_lecteur TO directeur;

-- Utilisateur : responsable_pedago (gestion)
CREATE USER responsable_pedago WITH PASSWORD 'resp_pass_2024!';
GRANT formation_gestionnaire TO responsable_pedago;

-- Utilisateur : dba_formation (admin complet)
CREATE USER dba_formation WITH PASSWORD 'dba_pass_2024!';
GRANT formation_admin TO dba_formation;

-- ============================================================
-- VUES SÉCURISÉES (limiter l'exposition des données sensibles)
-- ============================================================

-- Vue publique étudiants (sans email ni téléphone)
CREATE OR REPLACE VIEW v_etudiants_public AS
SELECT
    etudiant_id,
    etudiant_nom,
    etudiant_prenom,
    etudiant_date_naissance
FROM etudiant;

-- Vue résultats (sans données personnelles)
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

-- ============================================================
-- STRATÉGIE DE SAUVEGARDE
-- (commandes à exécuter depuis le terminal, pas dans psql)
-- ============================================================

-- ---- SAUVEGARDE COMPLÈTE ----
-- pg_dump -U postgres -F c -b -v -f "backup_formation_$(date +%Y%m%d).dump" formation_db

-- ---- SAUVEGARDE SQL LISIBLE ----
-- pg_dump -U postgres --clean --if-exists formation_db > backup_formation_$(date +%Y%m%d).sql

-- ---- RESTAURATION ----
-- pg_restore -U postgres -d formation_db -v "backup_formation_20250317.dump"
-- ou pour le SQL :
-- psql -U postgres -d formation_db < backup_formation_20250317.sql

-- ---- SAUVEGARDE AUTOMATIQUE (cron Linux) ----
-- Ajouter dans crontab (crontab -e) :
-- 0 2 * * * pg_dump -U postgres -F c formation_db > /backups/formation_$(date +\%Y\%m\%d).dump
-- (sauvegarde tous les jours à 2h du matin)

-- ============================================================
-- VÉRIFICATION DES DROITS
-- ============================================================
-- Lister les rôles et leurs membres :
-- \du

-- Lister les droits sur les tables :
-- \dp

SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('formation_lecteur','formation_gestionnaire','formation_admin')
ORDER BY grantee, table_name;
