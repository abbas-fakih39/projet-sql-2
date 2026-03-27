DROP TABLE IF EXISTS evaluation       CASCADE;
DROP TABLE IF EXISTS animer           CASCADE;
DROP TABLE IF EXISTS composer         CASCADE;
DROP TABLE IF EXISTS inscription      CASCADE;
DROP TABLE IF EXISTS intervenant      CASCADE;
DROP TABLE IF EXISTS module_          CASCADE;
DROP TABLE IF EXISTS formation        CASCADE;
DROP TABLE IF EXISTS etudiant         CASCADE;

--etudiant 
CREATE TABLE etudiant (
    etudiant_id             SERIAL          PRIMARY KEY,
    etudiant_nom            VARCHAR(100)    NOT NULL,
    etudiant_prenom         VARCHAR(100)    NOT NULL,
    etudiant_email          VARCHAR(150)    NOT NULL UNIQUE,
    etudiant_telephone      VARCHAR(10),
    etudiant_date_naissance DATE,
    etudiant_created        TIMESTAMP       DEFAULT NOW(),
    etudiant_updated        TIMESTAMP       DEFAULT NOW()
);

--formation
CREATE TABLE formation (
    formation_id        SERIAL          PRIMARY KEY,
    formation_intitule  VARCHAR(200)    NOT NULL,
    formation_duree     INTEGER         NOT NULL CHECK (formation_duree > 0),
    formation_debut     DATE            NOT NULL,
    formation_fin       DATE            NOT NULL,
    formation_annee     VARCHAR(9)      NOT NULL,
    formation_created   TIMESTAMP       DEFAULT NOW(),
    formation_updated   TIMESTAMP       DEFAULT NOW(),
    CONSTRAINT chk_formation_dates CHECK (formation_fin > formation_debut)
);

--module
CREATE TABLE module_ (
    module_id           SERIAL          PRIMARY KEY,
    module_intitule     VARCHAR(200)    NOT NULL,
    module_duree        INTEGER         NOT NULL CHECK (module_duree > 0),
    module_coefficient  NUMERIC(4,2)    NOT NULL DEFAULT 1.0 CHECK (module_coefficient > 0),
    module_created      TIMESTAMP       DEFAULT NOW(),
    module_updated      TIMESTAMP       DEFAULT NOW()
);

--intervenant
CREATE TABLE intervenant (
    intervenant_id          SERIAL          PRIMARY KEY,
    intervenant_nom         VARCHAR(100)    NOT NULL,
    intervenant_prenom      VARCHAR(100)    NOT NULL,
    intervenant_email       VARCHAR(150)    NOT NULL UNIQUE,
    intervenant_specialite  VARCHAR(150),
    intervenant_created      TIMESTAMP       DEFAULT NOW(),
    intervenant_updated      TIMESTAMP       DEFAULT NOW()
);

--inscription
CREATE TABLE inscription (
    inscription_id      SERIAL          PRIMARY KEY,
    inscription_date    DATE            NOT NULL DEFAULT CURRENT_DATE,
    inscription_statut  VARCHAR(20)     NOT NULL DEFAULT 'en_cours'
                        CHECK (inscription_statut IN ('en_cours', 'reussite', 'echec')),
    inscription_created TIMESTAMP       DEFAULT NOW(),
    inscription_updated TIMESTAMP       DEFAULT NOW(),
    formation_id        INTEGER         NOT NULL,
    etudiant_id         INTEGER         NOT NULL,
    FOREIGN KEY (formation_id) REFERENCES formation(formation_id) ON DELETE CASCADE,
    FOREIGN KEY (etudiant_id)  REFERENCES etudiant(etudiant_id)   ON DELETE CASCADE,
    CONSTRAINT uq_inscription UNIQUE (etudiant_id, formation_id)
);

--evaluation
CREATE TABLE evaluation (
    evaluation_id       SERIAL          PRIMARY KEY,
    evaluation_valeur   NUMERIC(5,2)    NOT NULL CHECK (evaluation_valeur >= 0 AND evaluation_valeur <= 20),
    evaluation_type     VARCHAR(30)     NOT NULL CHECK (evaluation_type IN ('examen', 'cc', 'rattrapage')),
    evaluation_date     DATE            NOT NULL,
    evaluation_created  TIMESTAMP       DEFAULT NOW(),
    evaluation_updated  TIMESTAMP       DEFAULT NOW(),
    module_id           INTEGER         NOT NULL,
    inscription_id      INTEGER         NOT NULL,
    FOREIGN KEY (module_id)      REFERENCES module_(module_id)          ON DELETE CASCADE,
    FOREIGN KEY (inscription_id) REFERENCES inscription(inscription_id) ON DELETE CASCADE
);

--composer
CREATE TABLE composer (
    formation_id        INTEGER         NOT NULL,
    module_id           INTEGER         NOT NULL,
    ordre               INTEGER         NOT NULL CHECK (ordre > 0),
    duree_effective     INTEGER         CHECK (duree_effective > 0),
    PRIMARY KEY (formation_id, module_id),
    FOREIGN KEY (formation_id) REFERENCES formation(formation_id) ON DELETE CASCADE,
    FOREIGN KEY (module_id)    REFERENCES module_(module_id)      ON DELETE CASCADE
);

--animer
CREATE TABLE animer (
    module_id           INTEGER         NOT NULL,
    intervenant_id      INTEGER         NOT NULL,
    PRIMARY KEY (module_id, intervenant_id),
    FOREIGN KEY (module_id)      REFERENCES module_(module_id)          ON DELETE CASCADE,
    FOREIGN KEY (intervenant_id) REFERENCES intervenant(intervenant_id) ON DELETE CASCADE
);

--index pour les performances
CREATE INDEX idx_inscription_etudiant   ON inscription(etudiant_id);
CREATE INDEX idx_inscription_formation  ON inscription(formation_id);
CREATE INDEX idx_evaluation_inscription ON evaluation(inscription_id);
CREATE INDEX idx_evaluation_module      ON evaluation(module_id);

--verification finale
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;