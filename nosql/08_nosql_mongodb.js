// ============================================================
// 08_nosql_mongodb.js
// Partie 6 - Ouverture NoSQL - MongoDB
// Base : formation_nosql
// Lancer avec : mongosh formation_nosql 08_nosql_mongodb.js
// ============================================================

// ============================================================
// 1. LOGS - Traçabilité des actions utilisateurs
// Stocke chaque action effectuée sur le système
// ============================================================
db.logs.insertMany([
  {
    timestamp: new Date("2025-01-15T08:32:00Z"),
    action: "connexion",
    utilisateur: "responsable_pedago",
    details: { ip: "192.168.1.10", navigateur: "Chrome" },
    statut: "succes"
  },
  {
    timestamp: new Date("2025-01-15T09:10:00Z"),
    action: "insertion_note",
    utilisateur: "responsable_pedago",
    details: {
      etudiant_id: 4,
      module_id: 2,
      valeur: 8.0,
      type: "rattrapage"
    },
    statut: "succes"
  },
  {
    timestamp: new Date("2025-01-15T10:45:00Z"),
    action: "suppression_inscription",
    utilisateur: "dba_formation",
    details: { inscription_id: 12, raison: "erreur saisie" },
    statut: "succes"
  },
  {
    timestamp: new Date("2025-01-16T14:20:00Z"),
    action: "connexion",
    utilisateur: "directeur",
    details: { ip: "192.168.1.25", navigateur: "Firefox" },
    statut: "succes"
  },
  {
    timestamp: new Date("2025-01-16T14:22:00Z"),
    action: "export_rapport",
    utilisateur: "directeur",
    details: { rapport: "moyennes_par_formation", format: "PDF" },
    statut: "succes"
  },
  {
    timestamp: new Date("2025-01-17T08:05:00Z"),
    action: "connexion",
    utilisateur: "inconnu",
    details: { ip: "45.33.32.156", navigateur: "curl" },
    statut: "echec"
  },
  {
    timestamp: new Date("2025-01-17T11:30:00Z"),
    action: "modification_etudiant",
    utilisateur: "responsable_pedago",
    details: { etudiant_id: 7, champ: "etudiant_email", ancienne_valeur: "old@mail.com" },
    statut: "succes"
  }
]);

// ============================================================
// 2. COMMENTAIRES - Retours pédagogiques libres
// Rattachés à un étudiant + module + inscription (via IDs SQL)
// ============================================================
db.commentaires.insertMany([
  {
    inscription_id: 1,
    etudiant_id: 1,
    module_id: 2,
    auteur: "Marchand Eric",
    date: new Date("2024-12-10"),
    contenu: "Alice progresse très bien en JavaScript. Autonome et rigoureuse.",
    tags: ["positif", "autonomie"]
  },
  {
    inscription_id: 4,
    etudiant_id: 4,
    module_id: 2,
    auteur: "Marchand Eric",
    date: new Date("2024-12-10"),
    contenu: "David en difficulté sur les concepts asynchrones. Prévoir un accompagnement.",
    tags: ["difficulte", "suivi-requis", "async"]
  },
  {
    inscription_id: 8,
    etudiant_id: 8,
    module_id: 1,
    auteur: "Marchand Eric",
    date: new Date("2024-11-20"),
    contenu: "Hugo absent plusieurs séances. Résultats très faibles.",
    tags: ["absenteisme", "echec", "suivi-requis"]
  },
  {
    inscription_id: 6,
    etudiant_id: 6,
    module_id: 5,
    auteur: "Marchand Eric",
    date: new Date("2025-03-10"),
    contenu: "Fabien excellent sur React. Maîtrise parfaite des hooks et du state management.",
    tags: ["positif", "excellent"]
  },
  {
    inscription_id: 11,
    etudiant_id: 11,
    module_id: 7,
    auteur: "Leblanc Sophie",
    date: new Date("2025-03-25"),
    contenu: "Maxime en grande difficulté sur le ML. Les bases mathématiques sont insuffisantes.",
    tags: ["difficulte", "suivi-requis", "mathematiques"]
  },
  {
    inscription_id: 9,
    etudiant_id: 9,
    module_id: 3,
    auteur: "Leblanc Sophie",
    date: new Date("2024-12-08"),
    contenu: "Ines montre un excellent esprit analytique en Python.",
    tags: ["positif", "analytique"]
  }
]);

// ============================================================
// 3. EVALUATIONS LIBRES - Feedbacks qualitatifs des étudiants
// Les étudiants évaluent les modules (pas de note, texte libre)
// ============================================================
db.evaluations_libres.insertMany([
  {
    etudiant_id: 1,
    module_id: 2,
    formation_id: 1,
    date: new Date("2025-01-05"),
    note_satisfaction: 4,
    points_positifs: "Cours très bien structuré, exemples concrets.",
    points_negatifs: "Rythme parfois trop rapide sur les Promises.",
    suggestion: "Ajouter plus d'exercices sur async/await."
  },
  {
    etudiant_id: 4,
    module_id: 2,
    formation_id: 1,
    date: new Date("2025-01-05"),
    note_satisfaction: 2,
    points_positifs: "Le formateur est disponible.",
    points_negatifs: "Trop de contenu en trop peu de temps.",
    suggestion: "Revoir le découpage du cours en 2 modules."
  },
  {
    etudiant_id: 6,
    module_id: 5,
    formation_id: 1,
    date: new Date("2025-04-01"),
    note_satisfaction: 5,
    points_positifs: "Module passionnant, projet final très formateur.",
    points_negatifs: "Rien à signaler.",
    suggestion: "Pourquoi pas ajouter Next.js ?"
  },
  {
    etudiant_id: 9,
    module_id: 3,
    formation_id: 2,
    date: new Date("2024-12-20"),
    note_satisfaction: 5,
    points_positifs: "Python bien enseigné, progression logique.",
    points_negatifs: "Les TPs pourraient être plus challengeants.",
    suggestion: "Ajouter des projets réels avec des datasets publics."
  },
  {
    etudiant_id: 11,
    module_id: 7,
    formation_id: 2,
    date: new Date("2025-04-01"),
    note_satisfaction: 1,
    points_positifs: "Sujet intéressant.",
    points_negatifs: "Cours trop théorique, pas assez de pratique.",
    suggestion: "Commencer par les bases des maths avant le ML."
  }
]);

// ============================================================
// REQUETES DE TEST
// ============================================================

print("\n--- LOGS : toutes les actions ---");
db.logs.find().forEach(printjson);

print("\n--- LOGS : echecs de connexion ---");
db.logs.find({ statut: "echec" }).forEach(printjson);

print("\n--- LOGS : actions du responsable_pedago ---");
db.logs.find({ utilisateur: "responsable_pedago" }).forEach(printjson);

print("\n--- COMMENTAIRES : etudiants avec tag suivi-requis ---");
db.commentaires.find({ tags: "suivi-requis" }).forEach(printjson);

print("\n--- EVALUATIONS LIBRES : satisfaction <= 2 (insatisfaits) ---");
db.evaluations_libres.find({ note_satisfaction: { $lte: 2 } }).forEach(printjson);

print("\n--- STATS : moyenne satisfaction par module ---");
db.evaluations_libres.aggregate([
  {
    $group: {
      _id: "$module_id",
      moyenne_satisfaction: { $avg: "$note_satisfaction" },
      nb_reponses: { $sum: 1 }
    }
  },
  { $sort: { moyenne_satisfaction: 1 } }
]).forEach(printjson);

print("\n--- STATS : nb commentaires par tag ---");
db.commentaires.aggregate([
  { $unwind: "$tags" },
  { $group: { _id: "$tags", nb: { $sum: 1 } } },
  { $sort: { nb: -1 } }
]).forEach(printjson);