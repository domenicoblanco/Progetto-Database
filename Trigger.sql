/* E1 - Aggiornamento data bollo ogni giorno della scadenza */
CREATE EVENT AggiornamentoScadenzaBollo
ON SCHEDULE EVERY 1 DAY DO
UPDATE Veicolo
SET ScadenzaBollo = DATE_ADD(CURRENT_DATE, INTERVAL 12 MONTH)
WHERE ScadenzaBollo = CURRENT_DATE;


/* E2 - Aggiornamento scadenza assicurazione */
CREATE EVENT AggiornamentoScadenzaAssicurazione
ON SCHEDULE EVERY 1 DAY DO
UPDATE Veicolo
SET ScadenzaAssicurazione = DATE_ADD(CURRENT_DATE, INTERVAL 12 MONTH)
WHERE ScadenzaAssicurazione = CURRENT_DATE;


/* E3 - Prenotazione revisione una settimana prima della scadenza */
DELIMITER $$

CREATE PROCEDURE PrenotazioneRevisione()
BEGIN
    DECLARE fine_veicoli BOOLEAN DEFAULT FALSE;
    DECLARE tel VARCHAR(30);
    DECLARE km_percorsi DECIMAL(10, 2) UNSIGNED;
    DECLARE domani DATE DEFAULT DATE_ADD(NOW(), INTERVAL 1 DAY);
    DECLARE settimana_prossima DATE DEFAULT DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    DECLARE revisione_in_scadenza CURSOR FOR
        SELECT Telaio
        FROM Veicolo LEFT JOIN Manutenzione ON Telaio = Veicolo
        WHERE ScadenzaRevisione = settimana_prossima AND
        (TipoManutenzione IS NULL OR NOT (TipoManutenzione = 'Revisione' AND Inizio NOT BETWEEN CURRENT_DATE AND settimana_prossima));
    DECLARE km_revisione_in_scadenza CURSOR FOR
        SELECT KMPercorsi
        FROM Veicolo LEFT JOIN Manutenzione ON Telaio = Veicolo
        WHERE ScadenzaRevisione = settimana_prossima AND
        (TipoManutenzione IS NULL OR NOT (TipoManutenzione = 'Revisione' AND Inizio NOT BETWEEN CURRENT_DATE AND settimana_prossima));
    DECLARE CONTINUE HANDLER FOR
        NOT FOUND SET fine_veicoli = TRUE;

    OPEN revisione_in_scadenza;
    OPEN km_revisione_in_scadenza;

    read_loop: LOOP
        FETCH revisione_in_scadenza    INTO tel;
        FETCH km_revisione_in_scadenza INTO km_percorsi;

        IF fine_veicoli THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO Manutenzione (Veicolo, TipoManutenzione, Descrizione, Inizio, KM, Costo) 
        VALUES (tel, 'Revisione', 'Revisione periodica', domani, km_percorsi, 80);
    END LOOP;

    CLOSE revisione_in_scadenza;
    CLOSE km_revisione_in_scadenza;
END$$


DELIMITER ;

CREATE EVENT PrenotazioneRevisione
ON SCHEDULE EVERY 1 DAY DO
CALL PrenotazioneRevisione;


/* Attivazione Event Scheduler */
SET GLOBAL event_scheduler="ON"


/* T1 - Inizializzazione scadenza revisione e bollo */
DELIMITER $$

CREATE TRIGGER AggiuntaNuovoVeicolo
BEFORE INSERT ON Veicolo 
FOR EACH ROW
BEGIN
	IF NEW.ScadenzaBollo IS NULL THEN
    	SET NEW.ScadenzaBollo = DATE_ADD(CURRENT_DATE, INTERVAL 12 MONTH);
    ELSEIF NEW.ScadenzaBollo < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il bollo non può essere già scaduto!';
    END IF;
    
    IF NEW.ScadenzaRevisione IS NULL THEN
    	SET NEW.ScadenzaRevisione = DATE_ADD(CURRENT_DATE, INTERVAL 4 YEAR);
    ELSEIF NEW.ScadenzaRevisione < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La revisione non può essere già scaduta!';
    END IF;

    IF NEW.ScadenzaAssicurazione < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'assicurazione non può essere già scaduta!";
    END IF;
END$$

CREATE TRIGGER AggiuntaNuovoVeicoloUpd
BEFORE UPDATE ON Veicolo 
FOR EACH ROW
BEGIN
	IF NEW.ScadenzaBollo IS NULL THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il bollo deve essere valorizzato!';
    ELSEIF NEW.ScadenzaBollo < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il bollo non può essere già scaduto!';
    END IF;
    
    IF NEW.ScadenzaRevisione IS NULL THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La revisione deve essere valorizzata!';
    ELSEIF NEW.ScadenzaRevisione < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La revisione non può essere già scaduta!';
    END IF;

    IF NEW.ScadenzaAssicurazione < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'assicurazione non può essere già scaduta!";
    END IF;
END$$


/* T2 - Aggiornamento KM totali veicolo dopo ogni trasferta */
DELIMITER $$

CREATE TRIGGER AggiornamentoKMPostTrasferta
AFTER UPDATE ON Trasferta 
FOR EACH ROW
BEGIN
    IF NEW.Stato = 'Conclusa' THEN
    	UPDATE Veicolo
        SET Veicolo.KMPercorsi = Veicolo.KMPercorsi + NEW.KMPercorsi
        WHERE Telaio = NEW.Veicolo;
    END IF;
END$$

CREATE TRIGGER AggiornamentoKMTrasfertaPassata
AFTER INSERT ON Trasferta 
FOR EACH ROW
BEGIN
	IF NEW.Stato = 'Conclusa' THEN
    	UPDATE Veicolo
        SET Veicolo.KMPercorsi = Veicolo.KMPercorsi + NEW.KMPercorsi
        WHERE Telaio = NEW.Veicolo;
    END IF;
END$$


/* T3 - Aggiornamento KM totali veicolo dopo ogni manutenzione */
DELIMITER $$

CREATE TRIGGER AggiornamentoKMPostManutenzione
AFTER INSERT ON Manutenzione 
FOR EACH ROW
BEGIN
    DECLARE km_veicolo DECIMAL(10, 2) UNSIGNED;
    DECLARE trasferta_recente DATETIME;

    SELECT KMPercorsi INTO km_veicolo
    FROM Veicolo 
    WHERE Telaio = NEW.Veicolo;

    SELECT Fine INTO trasferta_recente
    FROM Trasferta
    WHERE Veicolo = NEW.Veicolo
    ORDER BY Fine DESC
    LIMIT 1;

	IF NEW.Fine IS NOT NULL THEN
        IF NEW.KM >= km_veicolo THEN
            UPDATE Veicolo
            SET Veicolo.KMPercorsi = NEW.KM
            WHERE Telaio = NEW.Veicolo;
        ELSEIF NEW.Fine > IFNULL(trasferta_recente, '1970-01-01 08:00:00') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Il veicolo non può avere meno km!';
        END IF;
    END IF;
END$$

/* T4 - Aggiornamento scadenza revisione */
DELIMITER $$

CREATE TRIGGER AggiornamentoScadenzaRevisione
AFTER INSERT ON Manutenzione 
FOR EACH ROW
BEGIN
	IF NEW.TipoManutenzione = 'Revisione' AND NEW.Fine IS NOT NULL THEN
        UPDATE Veicolo
        SET Veicolo.ScadenzaRevisione = DATE_ADD(NEW.Fine, INTERVAL 2 YEAR)
        WHERE Telaio = NEW.Veicolo;
    END IF;
END$$

CREATE TRIGGER AggiornamentoScadenzaRevisioneUpd
AFTER UPDATE ON Manutenzione 
FOR EACH ROW
BEGIN
	IF NEW.TipoManutenzione = 'Revisione' AND NEW.Fine IS NOT NULL THEN
        UPDATE Veicolo
        SET Veicolo.ScadenzaRevisione = DATE_ADD(NEW.Fine, INTERVAL 2 YEAR)
        WHERE Telaio = NEW.Veicolo;
    END IF;
END$$


/* T5 - Prenotazione tagliando il giorno successivo al superamento dei km */
DELIMITER $$

CREATE TRIGGER ProgrammazioneTagliando
AFTER UPDATE ON Veicolo
FOR EACH ROW
BEGIN
    DECLARE km_veicolo DECIMAL(10, 2) UNSIGNED;
    DECLARE is_scheduled BOOLEAN;

    SELECT IFNULL(MAX(KM), 0) INTO km_veicolo
    FROM Manutenzione m 
    WHERE m.Veicolo = NEW.Telaio;

    SELECT CASE WHEN COUNT(Veicolo) > 0 THEN 1 ELSE 0 END INTO is_scheduled
    FROM Manutenzione
    WHERE Veicolo = NEW.Telaio AND TipoManutenzione = 'Tagliando' AND Fine IS NULL;

	IF NEW.KMPercorsi > km_veicolo + 10000 AND NOT is_scheduled THEN
    	INSERT INTO Manutenzione (Veicolo, TipoManutenzione, Descrizione, Inizio, KM, Costo) VALUES
        (NEW.Telaio, 'Tagliando', 'Prenotazione tagliando temporanea', DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), NEW.KMPercorsi, 0);
    END IF;
END$$


/* T6 - Selezione veicolo adeguato */
DELIMITER $$

CREATE TRIGGER PrediligiVeicoloAdeguato
BEFORE INSERT ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE stima_km INT;
    DECLARE tipologia_motore VARCHAR(11);
    DECLARE veicolo_alternativo VARCHAR(30);

    SELECT StimaKM INTO stima_km
    FROM Luogo
    WHERE IDLuogo = NEW.Destinazione;

    SELECT TipologiaMotore INTO tipologia_motore
    FROM Veicolo
    WHERE Telaio = NEW.Veicolo;

    IF stima_km <= 100 AND tipologia_motore = 'Endotermico' THEN        
        SELECT Telaio INTO veicolo_alternativo
        FROM Veicolo
        WHERE TipologiaMotore = 'Elettrico' AND Telaio NOT IN (
            SELECT Veicolo
            FROM Trasferta t LEFT JOIN Manutenzione m ON t.Veicolo = m.Veicolo
            WHERE (NEW.Inizio BETWEEN t.Inizio AND IFNULL(t.Fine, NOW()))
            OR (NEW.Fine BETWEEN t.Inizio AND IFNULL(t.Fine, NOW()))
            OR (t.Inizio BETWEEN NEW.Inizio AND NEW.Fine)
            OR (NEW.Inizio BETWEEN m.Inizio AND IFNULL(m.Fine, NOW()))
            OR (NEW.Fine BETWEEN m.Inizio AND IFNULL(m.Fine, NOW()))
            OR (m.Inizio BETWEEN NEW.Inizio AND NEW.Fine)
        ) LIMIT 1;

        IF veicolo_alternativo IS NOT NULL THEN
            SET NEW.Veicolo = veicolo_alternativo;
        END IF;

    ELSEIF stima_km > 100 AND tipologia_motore = 'Elettrico' THEN
        SELECT Telaio INTO veicolo_alternativo
        FROM Veicolo
        WHERE TipologiaMotore = 'Endotermico' AND Telaio NOT IN (
            SELECT Veicolo
            FROM Trasferta t LEFT JOIN Manutenzione m ON t.Veicolo = m.Veicolo
            WHERE (NEW.Inizio BETWEEN t.Inizio AND IFNULL(t.Fine, NOW()))
            OR (NEW.Fine BETWEEN t.Inizio AND IFNULL(t.Fine, NOW()))
            OR (t.Inizio BETWEEN NEW.Inizio AND NEW.Fine)
            OR (NEW.Inizio BETWEEN m.Inizio AND IFNULL(m.Fine, NOW()))
            OR (NEW.Fine BETWEEN m.Inizio AND IFNULL(m.Fine, NOW()))
            OR (m.Inizio BETWEEN NEW.Inizio AND NEW.Fine)
        ) LIMIT 1;

        IF veicolo_alternativo IS NOT NULL THEN
            SET NEW.Veicolo = veicolo_alternativo;
        END IF;
    END IF;
END$$


/* T7 - Controllo che il veicolo aggiunto in trasferta sia disponibile */
DELIMITER $$

CREATE TRIGGER VerificaVeicoloDisponibile
BEFORE INSERT ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE veicolo_occupato BOOLEAN;

    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO veicolo_occupato
    FROM Trasferta t LEFT JOIN Manutenzione m ON t.Veicolo = NEW.Veicolo AND m.Veicolo = t.Veicolo
    WHERE NEW.Inizio < IFNULL(t.Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > t.Inizio
          AND NEW.Inizio < IFNULL(m.Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > m.Inizio
          AND t.IDTrasferta <> NEW.IDTrasferta;

    IF veicolo_occupato THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il veicolo è già occupato in questo periodo.';
    END IF;
END$$

CREATE TRIGGER VerificaVeicoloDisponibileUpd
BEFORE UPDATE ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE veicolo_occupato BOOLEAN;

    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO veicolo_occupato
    FROM Trasferta t LEFT JOIN Manutenzione m ON t.Veicolo = NEW.Veicolo AND m.Veicolo = t.Veicolo
    WHERE NEW.Inizio < IFNULL(t.Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > t.Inizio
          AND NEW.Inizio < IFNULL(m.Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > m.Inizio
          AND t.IDTrasferta <> NEW.IDTrasferta;

    IF veicolo_occupato THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il veicolo è già occupato in questo periodo.';
    END IF;
END$$


/* T8 - Controllo che l’autista aggiunto in trasferta sia disponibile */
DELIMITER $$

CREATE TRIGGER VerificaAutistaDisponibile
BEFORE INSERT ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE autista_occupato BOOLEAN;

    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO autista_occupato
    FROM Trasferta
    WHERE Autista = NEW.Autista AND NEW.Inizio < IFNULL(Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > Inizio
          AND IDTrasferta <> NEW.IDTrasferta;

    IF autista_occupato THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'autista è già occupato in questo periodo.";
    END IF;
END$$

CREATE TRIGGER VerificaAutistaDisponibileUpd
BEFORE UPDATE ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE autista_occupato BOOLEAN;

    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO autista_occupato
    FROM Trasferta
    WHERE Autista = NEW.Autista AND NEW.Inizio < IFNULL(Fine, NOW()) AND IFNULL(NEW.Fine, NOW()) > Inizio
          AND IDTrasferta <> NEW.IDTrasferta;

    IF autista_occupato THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "L'autista è già occupato in questo periodo.";
    END IF;
END$$


/* T9 - Controllo che venga effettuato il rifornimento su un veicolo endotermico */
DELIMITER $$

CREATE TRIGGER VerificaRifornimento
BEFORE INSERT ON Rifornimento
FOR EACH ROW
BEGIN
    DECLARE tipologia_motore VARCHAR(30);

    SELECT TipologiaMotore INTO tipologia_motore
    FROM Veicolo
    WHERE Telaio = NEW.Veicolo;

    IF tipologia_motore = 'Elettrico' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non si può effettuare un'operazione di rifornimento su un veicolo elettrico!";
    END IF;
END$$

CREATE TRIGGER VerificaRifornimentoUpd
BEFORE UPDATE ON Rifornimento
FOR EACH ROW
BEGIN
    DECLARE tipologia_motore VARCHAR(30);

    SELECT TipologiaMotore INTO tipologia_motore
    FROM Veicolo
    WHERE Telaio = NEW.Veicolo;

    IF tipologia_motore = 'Elettrico' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Non si può effettuare un'operazione di rifornimento su un veicolo elettrico!";
    END IF;
END$$


/* T10 - Controllo che l'autista possa guidare quel determinato veicolo */
DELIMITER $$

CREATE TRIGGER VerificaPatente
BEFORE INSERT ON Trasferta
FOR EACH ROW
BEGIN
    DECLARE pat VARCHAR(30);
    DECLARE categoria_veicolo VARCHAR(20);
    DECLARE potenza INT UNSIGNED;

    SELECT Patenti INTO pat
    FROM Dipendente
    WHERE Matricola = NEW.Autista;
    
    SELECT CategoriaVeicolo, PotenzaMotore 
    INTO categoria_veicolo, potenza
    FROM Veicolo
    WHERE Telaio = NEW.Veicolo;

    IF pat IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Il dipendente non è in possesso di patenti.';
	ELSEIF (FIND_IN_SET('Ciclomotore', categoria_veicolo)      AND NOT (
            FIND_IN_SET('AM', pat) OR 
            FIND_IN_SET('A1', pat)  OR
            FIND_IN_SET('A2', pat) OR
            FIND_IN_SET('A', pat)  OR
            FIND_IN_SET('B', pat))
        ) OR (FIND_IN_SET('Motociclo', categoria_veicolo)  AND potenza <= 11 AND NOT (
            FIND_IN_SET('A1', pat) OR 
            FIND_IN_SET('A2', pat) OR
            FIND_IN_SET('A', pat)  OR
            FIND_IN_SET('B', pat))
        ) OR (FIND_IN_SET('Motociclo', categoria_veicolo)  AND potenza <= 35 AND NOT (
            FIND_IN_SET('A2', pat) OR
            FIND_IN_SET('A', pat))
        ) OR (FIND_IN_SET('Motociclo', categoria_veicolo)  AND potenza > 35 AND NOT FIND_IN_SET('A', pat))
        OR (FIND_IN_SET('Automobile', categoria_veicolo)   AND NOT FIND_IN_SET('B', pat)) 
        OR (FIND_IN_SET('Camion', categoria_veicolo)       AND NOT FIND_IN_SET('C', pat))
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = "L'autista non ha la patente idonea a guidare il veicolo selezionato!";
    END IF;
END$$