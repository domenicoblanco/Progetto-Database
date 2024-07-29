CREATE TABLE Dipendente (
	Matricola          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Nome               VARCHAR(30) NOT NULL,
    Cognome            VARCHAR(30) NOT NULL,
    Indirizzo          VARCHAR(50),
    RecapitoTelefonico VARCHAR(10),
    Patenti            SET('AM', 'A1', 'A2', 'A', 'B', 'C') DEFAULT NULL,
    
    PRIMARY KEY(Matricola)
);

CREATE TABLE Veicolo (
	Telaio                VARCHAR(30) NOT NULL,
    Marca                 VARCHAR(15) NOT NULL,
    Modello               VARCHAR(20) NOT NULL,
    Targa                 VARCHAR(7)  NOT NULL,
    KMPercorsi            DECIMAL(10, 2) UNSIGNED NOT NULL DEFAULT 0,
    PotenzaMotore         INT UNSIGNED NOT NULL DEFAULT 1000,
    TipologiaMotore       ENUM('Endotermico', 'Elettrico') NOT NULL DEFAULT 'Endotermico',
    CategoriaVeicolo      ENUM('Ciclomotore', 'Motociclo', 'Automobile', 'Camion') NOT NULL,
    ScadenzaBollo         DATE,
    ScadenzaRevisione     DATE,
    ScadenzaAssicurazione DATE NOT NULL,
    
    PRIMARY KEY(Telaio)
);

CREATE TABLE Luogo (
	IDLuogo   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Nome      VARCHAR(20),
    Indirizzo VARCHAR(50),
    StimaKM   DECIMAL(10, 2) UNSIGNED NOT NULL,
    
    PRIMARY KEY(IDLuogo)
);

CREATE TABLE Trasferta (
	IDTrasferta  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Veicolo      VARCHAR(30) NOT NULL,
    Autista      INT UNSIGNED NOT NULL,
    KMPercorsi   DECIMAL(10, 2) UNSIGNED,
    Stato        ENUM('Conclusa', 'Non conclusa') DEFAULT 'Non conclusa',
    Destinazione INT UNSIGNED NOT NULL, 
    Inizio       DATETIME NOT NULL,
    Fine         DATETIME,
    
    PRIMARY KEY(IDTrasferta),
    FOREIGN KEY(Veicolo)      REFERENCES Veicolo(Telaio),
    FOREIGN KEY(Autista)      REFERENCES Dipendente(Matricola),
    FOREIGN KEY(Destinazione) REFERENCES Luogo(IDLuogo),

    CONSTRAINT controllo_date_trasferta CHECK (Fine IS NULL OR Fine > Inizio),
    CONSTRAINT controllo_conclusa       CHECK ((Stato = 'Non conclusa' AND Fine IS NULL) OR (Stato = 'Conclusa' AND Fine IS NOT NULL))
);

CREATE TABLE Manutenzione (
	Veicolo          VARCHAR(30) NOT NULL,
    TipoManutenzione ENUM('Guasto', 'Tagliando', 'Revisione', 'Sinistro') NOT NULL,
    Descrizione      VARCHAR(200),
    Inizio           DATETIME NOT NULL,
    Fine             DATETIME,
    KM               DECIMAL(10, 2) UNSIGNED NOT NULL,
    Autista          INT UNSIGNED DEFAULT NULL,
    Costo            DECIMAL(10, 2) NOT NULL,
    
    PRIMARY KEY(Veicolo, Inizio),
    FOREIGN KEY(Autista) REFERENCES Dipendente(Matricola),
    FOREIGN KEY(Veicolo) REFERENCES Veicolo(Telaio),

    CONSTRAINT controllo_date_manutenzione CHECK (Fine IS NULL OR Fine > Inizio),
    CONSTRAINT controllo_inserimento       CHECK ((TipoManutenzione <> 'Sinistro' AND Autista IS NULL) OR (TipoManutenzione = 'Sinistro' AND Autista IS NOT NULL))
);

CREATE TABLE Rifornimento (
	IDTransazione   INT UNSIGNED NOT NULL,
    Veicolo         VARCHAR(30) NOT NULL,
    Autista         INT UNSIGNED NOT NULL,
    DataOra         DATETIME NOT NULL,
    Localita        INT UNSIGNED NOT NULL,
    Importo         DECIMAL(6, 3) UNSIGNED NOT NULL,
    LitriCarburante DECIMAL(5, 2) UNSIGNED NOT NULL,
    
    PRIMARY KEY(IDTransazione),

    FOREIGN KEY(Veicolo)  REFERENCES Veicolo(Telaio),
    FOREIGN KEY(Autista)  REFERENCES Dipendente(Matricola),
    FOREIGN KEY(Localita) REFERENCES Luogo(IDLuogo)
);