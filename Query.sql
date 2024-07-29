/* O7 - Ricerca dei veicoli che hanno subito più di 3 guasti */
SELECT Telaio, Marca, Modello, COUNT(*) 'Numero guasti'
FROM Veicolo v, Manutenzione m
WHERE v.Telaio = m.Veicolo AND m.TipoManutenzione = 'Guasto'
GROUP BY Telaio
HAVING `Numero guasti` > 3;


/* O8 - Ricerca dei dipendenti che hanno causato più sinistri */
SELECT Matricola, Nome, Cognome, Sin 'Numero sinistri'
FROM (
    SELECT d.Matricola, d.Nome, d.Cognome, COUNT(*) 'Sin'
    FROM Dipendente d, Manutenzione m
    WHERE d.Matricola = m.Autista AND m.TipoManutenzione = 'Sinistro' AND m.Inizio BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
    GROUP BY d.Matricola, d.Nome, d.Cognome
) Sinistri, (
    SELECT COUNT(*) 'Si'
 	FROM Dipendente d, Manutenzione m
    WHERE d.Matricola = m.Autista AND m.TipoManutenzione = 'Sinistro' AND m.Inizio BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) AND CURRENT_DATE
    GROUP BY d.Matricola
 	ORDER BY Si DESC
 	LIMIT 1
) Si
WHERE Sinistri.Sin = Si.Si;


/* O9 - Aggiornamento anagrafica dipendente */
UPDATE Dipendente SET 
Indirizzo = 'Viale Andrea Doria, 6', 
RecapitoTelefonico = '1123456789', 
Patenti = 'A,B'
WHERE Matricola = 1;


/* O10 - Ricerca dei veicoli a cui scadrà il bollo durante il mese corrente */
SELECT Telaio, Marca, Modello
FROM Veicolo
WHERE YEAR(ScadenzaBollo) = YEAR(CURRENT_DATE) AND MONTH(ScadenzaBollo) = MONTH(CURRENT_DATE);


/* O11 - Ricerca dei veicoli a cui scadrà la revisione durante il mese corrente */
SELECT Telaio, Marca, Modello
FROM Veicolo
WHERE YEAR(ScadenzaRevisione) = YEAR(CURRENT_DATE) AND MONTH(ScadenzaRevisione) = MONTH(CURRENT_DATE);


/* O12 - Ricerca dei veicoli a cui scadrà l'assicurazione durante il mese corrente */
SELECT Telaio, Marca, Modello
FROM Veicolo
WHERE YEAR(ScadenzaAssicurazione) = YEAR(CURRENT_DATE) AND MONTH(ScadenzaAssicurazione) = MONTH(CURRENT_DATE);


/* O13 - Calcolo dei consumi di carburante per ciascun veicolo durante i 30 giorni precedenti */
SELECT *, `Litri riforniti` / `KM percorsi` 'Stima KM/L'
FROM (
    SELECT v.Telaio, v.Marca, v.Modello, IFNULL(SUM(r.Importo), 0) 'Costo carburante', 
           IFNULL(SUM(r.LitriCarburante), 0) 'Litri riforniti', COUNT(DISTINCT t.IDTrasferta) 'Trasferte effettuate', 
           SUM(t.KMPercorsi) 'KM percorsi'
    FROM Veicolo v 
         LEFT JOIN Rifornimento r ON v.Telaio = r.Veicolo AND
         r.DataOra BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 31 DAY) AND CURRENT_DATE
         LEFT JOIN Trasferta t ON v.Telaio = t.Veicolo AND t.Inizio >= DATE_SUB(CURRENT_DATE, INTERVAL 31 DAY)
         AND t.Fine <= CURRENT_DATE
    WHERE v.TipologiaMotore = 'Endotermico'
    GROUP BY v.Telaio
) AnalisiConsumi
WHERE `KM percorsi` IS NOT NULL;


/* O14 - Ricerca dei dipendenti che hanno impiegato oltre il 20% della stima dei KM in una trasferta durante i 30 giorni precedenti */
SELECT Matricola, d.Nome, d.Cognome, t.IDTrasferta 'Trasferta', l.StimaKM*2 'Stima KM trasferta A/R', KMPercorsi 'KM effettivi trasferta A/R'
FROM Dipendente d, Trasferta t, Luogo l
WHERE d.Matricola = t.Autista AND t.Stato = 'Conclusa' 
	  AND l.IDLuogo = t.Destinazione AND l.StimaKM*2 + l.StimaKM*2*0.2 < KMPercorsi
	  AND t.Inizio >= DATE_SUB(CURRENT_DATE, INTERVAL 31 DAY) AND t.Fine <= DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
GROUP BY Matricola, StimaKM, KMPercorsi, t.IDTrasferta;