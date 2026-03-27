# Projet SQL — Organisme de Formation

**Dépôt :** https://github.com/abbas-fakih39/projet-sql-2  

---

## 1. Structure du projet

```
projet-sql-2/
├── ddn-ecole.xlsx           — Dictionnaire de données (Excel)
├── merise/
│   ├── mcdecole.jpg          — Modèle Conceptuel de Données (Looping)
│   ├── mldecole.jpg          — Modèle Logique de Données (Looping)
│   └── mpdecole.jpg          — Modèle Physique de Données (Looping)
├── sql/
│   ├── 1-create-tables.sql  — Création des 8 tables avec contraintes
│   ├── 2-insert-data.sql    — Données de test (20 étudiants, 5 formations...)
│   ├── 3-suivi-etudiants.sql— Requêtes suivi pédagogique individuel
│   ├── 4-suivi-formations.sql— Requêtes pilotage formations & modules
│   ├── 5-intervenants.sql   — Requêtes gestion des formateurs
│   ├── 6-reporting.sql      — Analyses avancées pour la direction
│   └── 7-securite.sql       — Rôles, droits, vues sécurisées
└── nosql/
    └── 8-nosql-mongodb.js   — Collections MongoDB (logs, commentaires, évaluations libres)
```

---

## 2. Choix de conception

### 2.1 Les 4 entités de base

Le modèle repose sur 4 entités principales identifiées à partir du contexte métier :

| Entité | Justification |
|---|---|
| `etudiant` | Acteur principal du système — il suit des formations et reçoit des notes |
| `formation` | Produit pédagogique proposé par l'organisme — a une durée, une période, une année |
| `module_` | Unité pédagogique indépendante — peut être mutualisée dans plusieurs formations |
| `intervenant` | Formateur qui anime des modules — indépendant des formations |

J'ai nommé la table `module_` avec un underscore final car la création échouait avec `module` seul, probablement à cause d'un mot réservé dans PostgreSQL.

### 2.2 Pourquoi INSCRIPTION est une entité et pas une simple association

L'inscription n’est pas une simple association car elle possède ses propres informations (date, statut : en cours/réussite/échec). Elle permet aussi de relier une évaluation à la fois à un étudiant et à la formation qu'il suit.

### 2.3 Pourquoi EVALUATION est une entité et pas un attribut

On l'a créée comme entité pour permettre à un étudiant d'avoir plusieurs notes (examen, rattrapage) pour un même module au sein d'une formation.

### 2.4 Pourquoi COMPOSER et ANIMER

Ce sont des tables de liaison nécessaires pour gérer les relations multiples (plusieurs modules dans une formation, plusieurs formateurs pour un module). `COMPOSER` contient aussi la durée effective et l'ordre des modules.

---

## 3. Logique des requêtes

### 3.1 — `1-create-tables.sql`

**Ordre de création :** les tables sont créées dans l'ordre des dépendances — d'abord les tables sans FK (`etudiant`, `formation`, `module_`, `intervenant`), ensuite celles qui en dépendent (`inscription`, puis `evaluation`, `composer`, `animer`).

**Ordre de suppression :** inverse de la création — `evaluation` en premier, `etudiant` en dernier. Sans cet ordre, PostgreSQL refuse de supprimer une table référencée par une FK.

**`ON DELETE CASCADE` :** si un étudiant est supprimé, toutes ses inscriptions et évaluations sont supprimées automatiquement. Cela évite les données orphelines.

**Contrainte `UNIQUE (etudiant_id, formation_id)` sur inscription :** empêche un étudiant de s'inscrire deux fois à la même formation.

**Index :** 4 index créés sur les colonnes les plus utilisées dans les JOIN (`etudiant_id`, `formation_id`, `inscription_id`, `module_id`) pour accélérer les requêtes.

### 3.2 — `2-insert-data.sql`

Les données ont été conçues pour couvrir tous les cas de test requis par le projet :

| Cas particulier | Pourquoi |
|---|---|
| Formation 5 sans inscrits | Tester Q3 de `4-suivi-formations.sql` |
| Module 15 (Git) sans intervenant | Tester Q3 de `5-intervenants.sql` |
| Inscriptions avec statut `echec` | Tester Q4 de `3-suivi-etudiants.sql` |
| Évaluations de type `rattrapage` | Montrer que plusieurs évals par module sont possibles |
| Notes partielles (certains modules sans note) | Tester Q3 de `03_suivi_etudiants.sql` |
| Module 4 (SQL) dans 2 formations | Montrer la mutualisation des modules |

Les `inscription_id` sont séquentiels (1 à 23) et les `evaluation` les référencent directement — c'est pourquoi l'ordre d'insertion est critique.

### 3.3 — `3-suivi-etudiants.sql`

**Table `_params` :** technique du "paramètre global" — au lieu de modifier chaque requête, on change les valeurs une seule fois en haut du fichier. Propre et maintenable.

**`NOT EXISTS` vs `NOT IN` (Q3) :** `NOT IN` a un comportement inattendu si la sous-requête retourne un `NULL` — elle renvoie `UNKNOWN` au lieu de `TRUE`, ce qui peut faire disparaître des lignes du résultat. `NOT EXISTS` est immunisé contre ce problème.

**CTEs `WITH moyennes AS (...)` (Q4 et Q5) :** la moyenne est calculée une seule fois dans le CTE et réutilisée dans le SELECT principal.

**`LEFT JOIN` sur evaluation (Q4) :** utilisation d'un LEFT JOIN pour inclure les étudiants qui n'ont aucune évaluation (leur moyenne serait NULL). Sans LEFT JOIN, ces étudiants disparaissent du résultat même s'ils sont en `echec`.

### 3.4 — `4-suivi-formations.sql`

**CTE `durees` (Q4) :** calcule la somme des durées effectives par formation en une seule passe, puis la joint aux formations.

**`NOT EXISTS` (Q3) :** même raisonnement que dans le script 03 — plus robuste que `NOT IN`.

**`COUNT(DISTINCT etudiant_id)` (Q2) :** le `DISTINCT` est essentiel ici. Sans lui, un étudiant inscrit dans deux formations qui partagent le même module serait compté deux fois. Le DISTINCT garantit qu'on compte des personnes uniques.

### 3.5 — `5-intervenants.sql`

**`COALESCE(c.nb_modules, 0)` (Q2) :** le LEFT JOIN inclut les intervenants sans aucun module. Sans COALESCE, leur colonne `nb_modules` serait NULL — COALESCE la remplace par 0.

**`NOT EXISTS` (Q3) :** trouve les modules qui n'ont aucune ligne dans la table `animer`. Le module 15 (Git & Versioning) est le seul dans ce cas — intentionnellement laissé sans affectation pour valider cette requête.

### 3.6 — `6-reporting.sql`

**Table `_params_reporting` :** contient tous les seuils paramétrables — seuil d'alerte formation (12), seuil de risque module (30%), catégories de résultats (16/12/10). Changer une seule valeur dans `_params_reporting` modifie le comportement de toutes les requêtes qui l'utilisent.

**Window function `SUM(COUNT(*)) OVER ()` (Q3) :** calcule le total de toutes les lignes sans GROUP BY supplémentaire. Permet de calculer le pourcentage de chaque statut en une seule requête sans sous-requête.

**`RANK() OVER (PARTITION BY formation_id ORDER BY moyenne DESC)` (Q10) :** la fonction de fenêtre la plus avancée du projet. `PARTITION BY` remet le compteur de rang à 1 pour chaque formation. Sans `PARTITION BY`, le rang serait global sur tous les étudiants de toutes les formations.

**Filtre sur valeur brute (Q9) :** le taux d'échec est filtré sur la valeur non arrondie (`s.nb_echecs * 100.0 / s.nb_evaluations >= p.seuil_risque`) et l'arrondi n'est utilisé qu'à l'affichage. Cela évite qu'un module avec 29.6% de taux réel soit exclu ou inclus à tort à cause de l'arrondi.

**`LEFT JOIN` vers evaluation (Q2 et Q8) :** pour inclure les formations qui ont des inscrits mais aucune évaluation encore saisie. Sans LEFT JOIN, ces formations disparaissent du reporting.

### 3.7 — `7-securite.sql`

**3 niveaux de rôles :**

`formation_lecteur` → lecture restreinte via les vues sécurisées (`v_etudiants_public`, `v_resultats`) pour limiter l'accès aux données sensibles.

`formation_gestionnaire` → SELECT + INSERT + UPDATE + DELETE. Destiné aux responsables pédagogiques. Ils gèrent les inscriptions, les notes, les modules. Ils ne peuvent pas modifier la structure des tables (pas de DROP, pas de CREATE).

`formation_admin` → ALL PRIVILEGES. Destiné au DBA. Accès complet.

**Pourquoi des rôles et pas des droits directs sur les utilisateurs :** les rôles sont réutilisables. Si on crée un nouvel utilisateur `assistant_pedago`, on lui affecte juste le rôle `formation_gestionnaire` — pas besoin de redéfinir tous les droits.

**Vues sécurisées :**

`v_etudiants_public` : expose les étudiants sans `etudiant_email` ni `etudiant_telephone`. Utilisée pour partager des listes sans exposer les données personnelles (RGPD).

`v_resultats` : expose les résultats agrégés par inscription sans aucune donnée personnelle. Utile pour les rapports anonymisés.

### 3.8 — `8-nosql-mongodb.js`

**Collection `logs` :** chaque document représente une action utilisateur. Le champ `details` est un sous-document dont la structure varie selon le type d'action.

**Collection `commentaires` :** les formateurs laissent des retours qualitatifs avec un tableau de `tags` (ex: `["difficulte", "suivi-requis"]`). La requête `db.commentaires.find({ tags: "suivi-requis" })` cherche dans le tableau.

**Collection `evaluations_libres` :** feedback qualitatif des étudiants sur les modules. Structure mixte : `note_satisfaction` (numérique), `points_positifs`, `points_negatifs`, `suggestion` (texte libre).

**Agrégation `$unwind` + `$group` (stats tags) :** `$unwind` déplie le tableau `tags` pour que chaque tag devienne un document séparé. Ensuite, `$group` compte les occurrences par tag, ce qui serait difficile à faire en SQL sans table de liaison.

---

## 4. Instructions d'exécution

### 4.1 PostgreSQL

#### Créer la base
```powershell
psql -U postgres
```
```sql
CREATE DATABASE formation_db;
\c formation_db
```

#### Exécuter les scripts dans l'ordre
```sql
\i 'C:/chemin/vers/projet-sql-2/sql/1-create-tables.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/2-insert-data.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/3-suivi-etudiants.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/4-suivi-formations.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/5-intervenants.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/6-reporting.sql'
\i 'C:/chemin/vers/projet-sql-2/sql/7-securite.sql'
```

#### Modifier les paramètres des requêtes

Chaque fichier de requêtes (03 à 06) contient une table de paramètres en haut (`_params`, `_params_formation`, `_params_intervenant`, `_params_reporting`). Pour tester une autre formation ou un autre étudiant, modifiez uniquement :

```sql
-- Dans 3-suivi-etudiants.sql
INSERT INTO _params (formation_id, etudiant_id, module_id) VALUES (2, 5, 3);

-- Dans 4-suivi-formations.sql
INSERT INTO _params_formation VALUES (2);

-- Dans 5-intervenants.sql
INSERT INTO _params_intervenant VALUES (2);

-- Dans 6-reporting.sql
-- seuil_alerte, seuil_risque, seuil_excellent, seuil_satisfait, seuil_passable
INSERT INTO _params_reporting VALUES (12, 30, 16, 12, 10);
```

### 4.2 MongoDB

#### Lancer le script
```powershell
mongosh formation_nosql "C:/chemin/vers/projet-sql-2/nosql/8-nosql-mongodb.js"
```

#### Explorer les données dans mongosh
```javascript
use formation_nosql

// Voir toutes les collections
show collections

// Logs d'échec de connexion
db.logs.find({ statut: "echec" })

// Étudiants nécessitant un suivi
db.commentaires.find({ tags: "suivi-requis" })

// Modules avec faible satisfaction
db.evaluations_libres.aggregate([
  { $group: { _id: "$module_id", moy: { $avg: "$note_satisfaction" } } },
  { $sort: { moy: 1 } }
])
```

---

## 5. Résultats attendus

Après exécution de `01` et `02`, la base contient :

| Table | Lignes |
|---|---|
| etudiant | 20 |
| formation | 5 |
| module_ | 15 |
| intervenant | 6 |
| inscription | 23 |
| evaluation | 58 |
| composer | 20 |
| animer | 14 |

Cas particuliers vérifiables :

```sql
-- Formation sans inscrits → Administration Systèmes Linux
SELECT formation_intitule FROM formation
WHERE formation_id NOT IN (SELECT DISTINCT formation_id FROM inscription);

-- Module sans intervenant → Git & Versioning
SELECT module_intitule FROM module_
WHERE module_id NOT IN (SELECT DISTINCT module_id FROM animer);

-- Étudiant avec la meilleure moyenne → Robert Fabien (18.40)
SELECT etudiant_nom, etudiant_prenom, ROUND(AVG(ev.evaluation_valeur)::NUMERIC,2) AS moyenne
FROM etudiant e
JOIN inscription i ON i.etudiant_id = e.etudiant_id
JOIN evaluation ev ON ev.inscription_id = i.inscription_id
GROUP BY e.etudiant_id, e.etudiant_nom, e.etudiant_prenom
ORDER BY moyenne DESC LIMIT 1;
```
