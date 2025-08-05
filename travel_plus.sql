-- 1. Tables de base

CREATE TABLE adresse (
    id_adresse SERIAL PRIMARY KEY,
    ligne1 VARCHAR NOT NULL,
    ligne2 VARCHAR,
    ville VARCHAR NOT NULL,
    code_postal VARCHAR NOT NULL,
    pays VARCHAR NOT NULL
);

CREATE TABLE client (
    id_client SERIAL PRIMARY KEY,
    type_client VARCHAR(3) NOT NULL CHECK (type_client IN ('B2C', 'B2B'))
);

CREATE TABLE client_b2c (
    id_client INT PRIMARY KEY REFERENCES client(id_client),
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    telephone VARCHAR NOT NULL,
    id_adresse INT REFERENCES adresse(id_adresse)
);

CREATE TABLE client_b2b (
    id_client INT PRIMARY KEY REFERENCES client(id_client),
    raison_sociale VARCHAR NOT NULL,
    siret VARCHAR UNIQUE NOT NULL,
    id_adresse INT REFERENCES adresse(id_adresse),
    email_contact VARCHAR NOT NULL,
    telephone_contact VARCHAR NOT NULL
);

CREATE TABLE agence (
    id_agence SERIAL PRIMARY KEY,
    nom VARCHAR NOT NULL,
    id_adresse INT REFERENCES adresse(id_adresse),
    email VARCHAR NOT NULL,
    telephone VARCHAR NOT NULL
);

CREATE TABLE agent (
    id_agent SERIAL PRIMARY KEY,
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    telephone VARCHAR,
    id_adresse INT REFERENCES adresse(id_adresse),
    id_agence INT REFERENCES agence(id_agence) NOT NULL
);

CREATE TABLE role (
    id_role SERIAL PRIMARY KEY,
    nom_role VARCHAR UNIQUE NOT NULL
);

CREATE TABLE utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,
    login VARCHAR UNIQUE NOT NULL,
    mot_de_passe_hash VARCHAR NOT NULL,
    id_role INT REFERENCES role(id_role),
    id_client INT REFERENCES client(id_client),
    id_agent INT REFERENCES agent(id_agent)
);

CREATE TABLE hotel (
    id_hotel SERIAL PRIMARY KEY,
    nom_hotel VARCHAR NOT NULL,
    id_adresse INT REFERENCES adresse(id_adresse),
    categorie_etoiles INT,
    telephone VARCHAR,
    email VARCHAR,
    description TEXT
);

CREATE TABLE vol (
    id_vol SERIAL PRIMARY KEY,
    compagnie_aerienne VARCHAR NOT NULL,
    numero_vol VARCHAR NOT NULL,
    aeroport_depart VARCHAR NOT NULL,
    aeroport_arrivee VARCHAR NOT NULL,
    heure_depart TIMESTAMP NOT NULL,
    heure_arrivee TIMESTAMP NOT NULL
);

CREATE TABLE etat_reservation (
    id_etat_reservation SERIAL PRIMARY KEY,
    nom_etat VARCHAR UNIQUE NOT NULL
);

-- 2. Tables spécifiques aux types de réservation

CREATE TABLE reservation_hotel (
    id_reservation_hotel SERIAL PRIMARY KEY,
    id_hotel INT REFERENCES hotel(id_hotel),
    date_debut_sejour DATE NOT NULL,
    date_fin_sejour DATE NOT NULL,
    nb_chambres INT NOT NULL,
    nb_personnes_hotel INT NOT NULL
);

CREATE TABLE reservation_vol (
    id_reservation_vol SERIAL PRIMARY KEY,
    id_vol INT REFERENCES vol(id_vol),
    date_depart_effective TIMESTAMP NOT NULL,
    date_arrivee_effective TIMESTAMP NOT NULL,
    nb_passagers INT NOT NULL,
    classe_vol VARCHAR
);

-- 3. Table générique des réservations (après Hotel/Vol)

CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_client INT REFERENCES client(id_client),
    id_agent_referent INT REFERENCES agent(id_agent),
    date_creation DATE NOT NULL,
    id_etat_reservation INT REFERENCES etat_reservation(id_etat_reservation),
    type_service VARCHAR NOT NULL,
    prix_total_reserve DECIMAL NOT NULL,
    id_reservation_hotel INT REFERENCES reservation_hotel(id_reservation_hotel),
    id_reservation_vol INT REFERENCES reservation_vol(id_reservation_vol)
);

-- 4. Ajout des FK inverses vers reservation

ALTER TABLE reservation_hotel
ADD COLUMN id_reservation_generique INT UNIQUE REFERENCES reservation(id_reservation);

ALTER TABLE reservation_vol
ADD COLUMN id_reservation_generique INT UNIQUE REFERENCES reservation(id_reservation);

-- 5. Table des voyages

CREATE TABLE voyage (
    id_voyage SERIAL PRIMARY KEY,
    nom_voyage VARCHAR NOT NULL,
    destination_principale VARCHAR NOT NULL,
    date_creation DATE NOT NULL,
    description_generale TEXT
);

CREATE TABLE voyage_reservation_hotel (
    id_voyage INT REFERENCES voyage(id_voyage),
    id_reservation_generique INT REFERENCES reservation(id_reservation),
    ordre INT NOT NULL,
    PRIMARY KEY (id_voyage, id_reservation_generique)
);

CREATE TABLE voyage_reservation_vol (
    id_voyage INT REFERENCES voyage(id_voyage),
    id_reservation_generique INT REFERENCES reservation(id_reservation),
    ordre INT NOT NULL,
    PRIMARY KEY (id_voyage, id_reservation_generique)
);

-- 6. Paiement

CREATE TABLE type_paiement (
    id_type_paiement SERIAL PRIMARY KEY,
    nom_type VARCHAR UNIQUE NOT NULL
);

CREATE TABLE paiement (
    id_paiement SERIAL PRIMARY KEY,
    date_paiement DATE NOT NULL,
    montant DECIMAL NOT NULL,
    id_type_paiement INT REFERENCES type_paiement(id_type_paiement),
    id_voyage INT REFERENCES voyage(id_voyage),
    statut_paiement VARCHAR NOT NULL
);
