-- ETUDIANTS (20)
INSERT INTO etudiant (etudiant_nom, etudiant_prenom, etudiant_email, etudiant_telephone, etudiant_date_naissance) VALUES
('Martin',    'Alice',     'alice.martin@mail.com',          '0611111111', '2000-03-15'),
('Dupont',    'Baptiste',  'baptiste.dupont@mail.com',       '0622222222', '1999-07-22'),
('Leroy',     'Clara',     'clara.leroy@mail.com',           '0633333333', '2001-01-10'),
('Bernard',   'David',     'david.bernard@mail.com',         '0644444444', '2000-11-05'),
('Petit',     'Emma',      'emma.petit@mail.com',            '0655555555', '1998-09-30'),
('Robert',    'Fabien',    'fabien.robert@mail.com',         '0666666666', '2001-06-18'),
('Richard',   'Gabrielle', 'gabrielle.richard@mail.com',     '0677777777', '1999-12-25'),
('Durand',    'Hugo',      'hugo.durand@mail.com',           '0688888888', '2000-04-02'),
('Moreau',    'Ines',      'ines.moreau@mail.com',           '0699999999', '2001-08-14'),
('Laurent',   'Julien',    'julien.laurent@mail.com',        '0610101010', '1998-02-28'),
('Simon',     'Kamel',     'kamel.simon@mail.com',           '0621212121', '2000-10-07'),
('Michel',    'Laura',     'laura.michel@mail.com',          '0632323232', '1999-05-19'),
('Lefebvre',  'Maxime',    'maxime.lefebvre@mail.com',       '0643434343', '2001-03-31'),
('Garcia',    'Nina',      'nina.garcia@mail.com',           '0654545454', '2000-07-16'),
('Thomas',    'Omar',      'omar.thomas@mail.com',           '0665656565', '1998-11-23'),
('Roux',      'Pauline',   'pauline.roux@mail.com',          '0676767676', '2001-09-08'),
('Vincent',   'Quentin',   'quentin.vincent@mail.com',       '0687878787', '1999-01-14'),
('Fontaine',  'Rania',     'rania.fontaine@mail.com',        '0698989898', '2000-06-27'),
('Chevalier', 'Sebastien', 'sebastien.chevalier@mail.com',   '0619191919', '2001-04-03'),
('Rousseau',  'Tiphaine',  'tiphaine.rousseau@mail.com',     '0620202020', '1998-08-11');

-- FORMATIONS (5)
INSERT INTO formation (formation_intitule, formation_duree, formation_debut, formation_fin, formation_annee) VALUES
('Developpement Web Full Stack',    420, '2024-09-02', '2025-06-30', '2024-2025'),
('Data Science & Machine Learning', 350, '2024-09-02', '2025-05-30', '2024-2025'),
('Cybersecurite Fondamentaux',      280, '2025-01-06', '2025-06-27', '2024-2025'),
('DevOps & Cloud',                  300, '2025-01-06', '2025-07-04', '2024-2025'),
('Administration Systemes Linux',   200, '2025-03-03', '2025-07-25', '2024-2025');

-- MODULES (15)
INSERT INTO module_ (module_intitule, module_duree, module_coefficient) VALUES
('HTML/CSS Fondamentaux',           40,  1.0),   -- 1
('JavaScript Avance',               60,  1.5),   -- 2
('Python pour la Data',             50,  1.5),   -- 3
('SQL & Bases de donnees',          45,  1.5),   -- 4
('React.js',                        55,  1.5),   -- 5
('Node.js & API REST',              50,  1.5),   -- 6
('Machine Learning avec Scikit',    60,  2.0),   -- 7
('Reseaux & Protocoles',            40,  1.0),   -- 8
('Securite des Applications Web',   45,  2.0),   -- 9
('Docker & Conteneurisation',       40,  1.5),   -- 10
('CI/CD & GitHub Actions',          35,  1.0),   -- 11
('Cloud AWS Fondamentaux',          50,  1.5),   -- 12
('Administration Linux',            45,  1.5),   -- 13
('Scripting Bash',                  35,  1.0),   -- 14
('Git & Versioning',                25,  1.0);   -- 15

-- INTERVENANTS (6)
INSERT INTO intervenant (intervenant_nom, intervenant_prenom, intervenant_email, intervenant_specialite) VALUES
('Marchand', 'Eric',    'eric.marchand@formateurs.fr',   'Developpement Web'),
('Leblanc',  'Sophie',  'sophie.leblanc@formateurs.fr',  'Data Science & IA'),
('Garnier',  'Thomas',  'thomas.garnier@formateurs.fr',  'Cybersecurite'),
('Faure',    'Amelie',  'amelie.faure@formateurs.fr',    'DevOps & Cloud'),
('Girard',   'Nicolas', 'nicolas.girard@formateurs.fr',  'Systemes Linux'),
('Morin',    'Claire',  'claire.morin@formateurs.fr',    'Bases de donnees');

-- COMPOSER (formation_module)

-- Formation 1 : Web Full Stack
INSERT INTO composer (formation_id, module_id, ordre, duree_effective) VALUES
(1, 1,  1, 38), (1, 2,  2, 58), (1, 15, 3, 24),
(1, 4,  4, 44), (1, 5,  5, 52), (1, 6,  6, 50);

-- Formation 2 : Data Science
INSERT INTO composer (formation_id, module_id, ordre, duree_effective) VALUES
(2, 3, 1, 50), (2, 4, 2, 42), (2, 15, 3, 22), (2, 7, 4, 58);

-- Formation 3 : Cybersécurité
INSERT INTO composer (formation_id, module_id, ordre, duree_effective) VALUES
(3, 8, 1, 40), (3, 9, 2, 45), (3, 15, 3, 20);

-- Formation 4 : DevOps
INSERT INTO composer (formation_id, module_id, ordre, duree_effective) VALUES
(4, 15, 1, 24), (4, 10, 2, 38), (4, 11, 3, 34), (4, 12, 4, 48);

-- Formation 5 : Linux
INSERT INTO composer (formation_id, module_id, ordre, duree_effective) VALUES
(5, 8, 1, 38), (5, 13, 2, 44), (5, 14, 3, 32);

-- ANIMER (affectation intervenants -> modules)
INSERT INTO animer (module_id, intervenant_id) VALUES
(1, 1), (2, 1), (5, 1), (6, 1),             -- Eric : web 
(3, 2), (7, 2),                             -- Sophie : data
(4, 6),                                     -- Claire : SQL
(8, 3), (9, 3),                             -- Thomas : sécu
(10, 4), (11, 4), (12, 4),                  -- Amelie : devops
(13, 5), (14, 5);                           -- Nicolas : linux
-- module_id 15 (Git) non affecté

-- INSCRIPTIONS (23)

-- Formation 1 — étudiants 1 à 8
INSERT INTO inscription (etudiant_id, formation_id, inscription_date, inscription_statut) VALUES
(1, 1, '2024-07-10', 'reussite'),
(2, 1, '2024-07-12', 'reussite'),
(3, 1, '2024-07-15', 'en_cours'),
(4, 1, '2024-07-15', 'echec'),
(5, 1, '2024-08-01', 'en_cours'),
(6, 1, '2024-08-05', 'reussite'),
(7, 1, '2024-08-10', 'en_cours'),
(8, 1, '2024-08-10', 'echec');

-- Formation 2 — étudiants 5, 9 à 14
INSERT INTO inscription (etudiant_id, formation_id, inscription_date, inscription_statut) VALUES
(5,  2, '2024-07-20', 'reussite'),
(9,  2, '2024-07-22', 'en_cours'),
(10, 2, '2024-07-25', 'echec'),
(11, 2, '2024-08-01', 'reussite'),
(12, 2, '2024-08-03', 'en_cours'),
(13, 2, '2024-08-05', 'echec'),
(14, 2, '2024-08-08', 'en_cours');

-- Formation 3 — étudiants 10, 15, 16, 17
INSERT INTO inscription (etudiant_id, formation_id, inscription_date, inscription_statut) VALUES
(10, 3, '2024-11-01', 'en_cours'),
(15, 3, '2024-11-03', 'en_cours'),
(16, 3, '2024-11-05', 'reussite'),
(17, 3, '2024-11-08', 'en_cours');

-- Formation 4 — étudiants 13, 18, 19, 20
INSERT INTO inscription (etudiant_id, formation_id, inscription_date, inscription_statut) VALUES
(13, 4, '2024-11-10', 'en_cours'),
(18, 4, '2024-11-12', 'en_cours'),
(19, 4, '2024-11-15', 'echec'),
(20, 4, '2024-11-15', 'en_cours');

-- Formation 5 — aucun inscrit (formation vide pour les tests)

-- EVALUATIONS (~60 lignes)
-- Formation 1 (inscription_id 1 à 8)
INSERT INTO evaluation (inscription_id, module_id, evaluation_valeur, evaluation_type, evaluation_date) VALUES
-- insc 1 (étudiant 1 - réussite)
(1, 1, 17.5, 'examen', '2024-11-15'), (1, 2, 16.0, 'examen', '2024-12-10'),
(1, 4, 18.0, 'examen', '2025-01-20'), (1, 5, 15.5, 'cc',     '2025-03-05'),
(1, 6, 16.5, 'examen', '2025-05-10'),
-- insc 2 (étudiant 2 - réussite)
(2, 1, 14.0, 'examen', '2024-11-15'), (2, 2, 13.5, 'examen', '2024-12-10'),
(2, 4, 15.0, 'examen', '2025-01-20'), (2, 5, 14.5, 'cc',     '2025-03-05'),
(2, 6, 13.0, 'examen', '2025-05-10'),
-- insc 3 (étudiant 3 - en_cours, notes partielles)
(3, 1, 12.0, 'examen', '2024-11-15'), (3, 2, 11.5, 'examen', '2024-12-10'),
(3, 4, 13.0, 'examen', '2025-01-20'),
-- insc 4 (étudiant 4 - echec)
(4, 1,  6.0, 'examen', '2024-11-15'), (4, 2,  5.5, 'examen', '2024-12-10'),
(4, 4,  7.0, 'examen', '2025-01-20'), (4, 5,  4.0, 'cc',     '2025-03-05'),
(4, 6,  6.5, 'examen', '2025-05-10'), (4, 2,  8.0, 'rattrapage', '2025-01-15'),
-- insc 5 (étudiant 5 - en_cours)
(5, 1, 15.0, 'examen', '2024-11-15'), (5, 2, 14.0, 'examen', '2024-12-10'),
-- insc 6 (étudiant 6 - réussite excellente)
(6, 1, 19.0, 'examen', '2024-11-15'), (6, 2, 18.5, 'examen', '2024-12-10'),
(6, 4, 17.0, 'examen', '2025-01-20'), (6, 5, 19.5, 'cc',     '2025-03-05'),
(6, 6, 18.0, 'examen', '2025-05-10'),
-- insc 7 (étudiant 7 - en_cours)
(7, 1, 11.0, 'examen', '2024-11-15'), (7, 2, 10.5, 'cc', '2024-12-10'),
-- insc 8 (étudiant 8 - echec)
(8, 1,  3.5, 'examen', '2024-11-15'), (8, 2,  4.0, 'examen', '2024-12-10'),
(8, 4,  5.0, 'examen', '2025-01-20'), (8, 5,  3.0, 'cc',     '2025-03-05');

-- Formation 2 (inscription_id 9 à 15)
INSERT INTO evaluation (inscription_id, module_id, evaluation_valeur, evaluation_type, evaluation_date) VALUES
(9,  3, 16.0, 'examen', '2024-12-05'), (9,  4, 15.5, 'examen', '2025-01-10'), (9,  7, 17.0, 'examen', '2025-03-20'),
(10, 3, 14.0, 'examen', '2024-12-05'), (10, 4, 13.0, 'examen', '2025-01-10'), (10, 7, 15.5, 'examen', '2025-03-20'),
(11, 3,  5.0, 'examen', '2024-12-05'), (11, 4,  6.5, 'examen', '2025-01-10'), (11, 7,  4.0, 'examen', '2025-03-20'),
(12, 3, 18.0, 'examen', '2024-12-05'), (12, 4, 17.5, 'examen', '2025-01-10'),
(13, 3, 12.0, 'examen', '2024-12-05'),
(14, 3,  7.0, 'examen', '2024-12-05'), (14, 4,  6.0, 'examen', '2025-01-10'), (14, 7,  5.5, 'examen', '2025-03-20');

-- Formation 3 (inscription_id 16 à 19)
-- insc 16 = étudiant 10 : aucune note (étudiant sans note)
INSERT INTO evaluation (inscription_id, module_id, evaluation_valeur, evaluation_type, evaluation_date) VALUES
(17, 8, 13.0, 'examen', '2025-02-20'), (17, 9, 14.5, 'examen', '2025-04-10'),
(18, 8, 17.0, 'examen', '2025-02-20'), (18, 9, 18.0, 'examen', '2025-04-10'),
(19, 8, 11.0, 'examen', '2025-02-20');

-- Formation 4 (inscription_id 20 à 23)
INSERT INTO evaluation (inscription_id, module_id, evaluation_valeur, evaluation_type, evaluation_date) VALUES
(20, 10, 15.0, 'examen', '2025-02-28'), (20, 11, 14.0, 'cc',     '2025-03-28'),
(21, 10, 16.5, 'examen', '2025-02-28'),
(22, 10,  4.0, 'examen', '2025-02-28'), (22, 11,  3.5, 'cc',     '2025-03-28'),
(22, 12,  5.0, 'examen', '2025-05-02');

-- Vérification
SELECT
    (SELECT COUNT(*) FROM etudiant)    AS nb_etudiants,
    (SELECT COUNT(*) FROM formation)   AS nb_formations,
    (SELECT COUNT(*) FROM module_)     AS nb_modules,
    (SELECT COUNT(*) FROM intervenant) AS nb_intervenants,
    (SELECT COUNT(*) FROM inscription) AS nb_inscriptions,
    (SELECT COUNT(*) FROM evaluation)  AS nb_evaluations;
