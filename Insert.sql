INSERT INTO Dipendente (Nome, Cognome, Indirizzo, RecapitoTelefonico, Patenti) VALUES
('Philip K.', 'Dick', 'Via dei Cavalli, 3', '0123456789', 'B'),
('Nobusuke', 'Tagomi', "Viale dell'Alto Castello, 5", '0987654321', 'A,B'),
('Elijah', 'Bailey', 'Piazza delle Galassie, 10', '0123498765', 'C'),
('Asimov', 'Isaac', 'Piazza dei Cicli, 3', '0987612345', 'A1,B'),
('Hari', 'Seldon', "Piazza Università di Striling", '0123487659', 'A2'),
('Douglas', 'Adams', 'Vicolo dei Dottori, 42', '0987632145', 'AM,B'),
('Gladia', 'Solaria', 'Via Aurora, 8', '0123458796', 'A'),
('Frank', 'Herbert', 'Via della Spezia, 8', '0987623451', 'B,C'),
('Paul', 'Atreides', "Via dell'abominio, 11", '0123476589', 'A2,B'),
('Daneel', 'Olivaw', "Corso dell'automazione, 13", '0987654321', 'B,C');

INSERT INTO Veicolo (Telaio, Marca, Modello, Targa, KMPercorsi, PotenzaMotore, TipologiaMotore, CategoriaVeicolo, ScadenzaBollo, ScadenzaRevisione, ScadenzaAssicurazione) VALUES
('TX1234ABCD', 'Citroen', 'C1', 'AB123CD', 5000.00, 53, 'Endotermico', 'Automobile', '2024-12-31', '2024-07-30', '2024-07-30'),
('TX5678EFGH', 'Tesla', 'Model S', 'EF456GH', 12000.50, 760, 'Elettrico', 'Automobile', '2024-11-30', '2025-07-31', '2024-09-01'),
('TX9101IJKL', 'Moto Guzzi', 'V9 Bobber', 'IJ789KL', 8000.00, 40, 'Endotermico', 'Motociclo', '2024-10-31', '2025-05-31', '2024-08-01'),
('TX1213MNOP', 'Vespa', 'GTS 300', 'MN012OP', 6000.75, 18, 'Endotermico', 'Motociclo', '2024-09-30', '2025-04-30', '2024-08-01'),
('TX1415QRST', 'Fiat', 'Panda', 'QR345ST', 3000.20, 52, 'Endotermico', 'Automobile', '2024-08-31', '2025-03-31', '2024-08-01'),
('TX1617UVWX', 'Iveco', 'S-Way', 'UV678WX', 20000.00, 251, 'Endotermico', 'Camion', '2024-07-31', '2025-02-28', '2024-08-01'),
('TX1819YZAB', 'Volkswagen', 'Golf GTI', 'YZ901AB', 10000.50, 198, 'Endotermico', 'Automobile', '2024-07-30', '2025-01-31', '2025-03-01'),
('TX2021CDEF', 'Citroen', 'C3', 'CD234EF', 15000.80, 61, 'Endotermico', 'Automobile', '2025-05-31', '2025-12-31', '2025-02-01'),
('TX2223GHIK', 'Audi', 'A4', 'GH567IK', 17000.90, 107, 'Endotermico', 'Automobile', '2025-04-30', '2025-11-30', '2025-01-01'),
('TX2425LMNO', 'Vespa', 'Primavera 50', 'LM890NO', 11000.40, 2, 'Endotermico', 'Ciclomotore', '2025-03-31', '2025-10-31', '2024-12-01');

INSERT INTO Luogo (Nome, Indirizzo, StimaKM) VALUES
('Trantor', 'Via del Palazzo, 1', 150.00),
('Terminus', 'Viale della Fondazioni, 1', 75.50),
('Gaia', "Via Utopia, 3", 120.75),
('Dreamland', 'Corso dei Castelli, 4', 260.80),
('VALIS', 'Largo dell’Universo, 5', 345.30),
('Lagash', 'Via del Notturno, 6', 190.25),
('Understair', 'Privet Drive, 4', 110.10),
('Distributore A', 'A20 km 42', 365.50),
('Distributore B', 'Via col vento 76', 280.40),
('Distributore C', "Corso d'opera, 10", 170.60);

INSERT INTO Trasferta (Veicolo, Autista, KMPercorsi, Stato, Destinazione, Inizio, Fine) VALUES
('TX1234ABCD', 2, 450.53, 'Conclusa', 1, '2024-07-10 08:00:00', '2024-07-10 18:00:00'),
('TX5678EFGH', 1, 450.75, 'Non conclusa', 2, '2024-07-11 09:00:00', NULL),
('TX9101IJKL', 7, 200.00, 'Conclusa', 3, '2024-07-12 10:00:00', '2024-07-12 16:00:00'),
('TX1213MNOP', 5, 150.50, 'Non conclusa', 4, '2024-07-13 11:00:00', NULL),
('TX1415QRST', 2, 250.75, 'Conclusa', 5, '2024-07-14 12:00:00', '2024-07-14 20:00:00'),
('TX1617UVWX', 3, 300.60, 'Non conclusa', 6, '2024-07-15 13:00:00', NULL),
('TX1819YZAB', 6, 200.40, 'Conclusa', 7, '2024-07-16 14:00:00', '2024-07-16 22:00:00'),
('TX2021CDEF', 8, 350.30, 'Non conclusa', 8, '2024-07-17 15:00:00', NULL),
('TX2223GHIK', 9, 400.50, 'Conclusa', 9, '2024-07-18 16:00:00', '2024-07-18 23:00:00'),
('TX2425LMNO', 10, 500.70, 'Non conclusa', 10, '2024-07-19 17:00:00', NULL);

INSERT INTO Manutenzione (Veicolo, TipoManutenzione, Descrizione, Inizio, Fine, KM, Autista, Costo) VALUES
('TX1234ABCD', 'Guasto', 'Sostituzione batteria', '2024-06-01 08:00:00', '2024-06-01 12:00:00', 5300.53, NULL, 250.00),
('TX5678EFGH', 'Tagliando', 'Tagliando completo', '2024-06-02 09:00:00', '2024-06-02 14:00:00', 12450.75, NULL, 150.00),
('TX9101IJKL', 'Revisione', 'Revisione annuale', '2024-06-03 10:00:00', '2024-06-03 13:00:00', 1000.00, NULL, 100.00),
('TX1213MNOP', 'Sinistro', 'Incidente lieve', '2024-06-04 11:00:00', '2024-06-04 18:00:00', 6150.50, 4, 300.00),
('TX1415QRST', 'Guasto', 'Problemi al motore', '2024-06-05 12:00:00', '2024-06-05 16:00:00', 3250.75, NULL, 200.00),
('TX1617UVWX', 'Tagliando', 'Tagliando completo', '2024-06-06 13:00:00', '2024-06-06 17:00:00', 20300.60, NULL, 150.00),
('TX1819YZAB', 'Revisione', 'Revisione annuale', '2024-06-07 14:00:00', '2024-06-07 18:00:00', 10200.40, NULL, 100.00),
('TX2021CDEF', 'Sinistro', 'Incidente grave', '2024-06-08 15:00:00', '2024-06-08 23:00:00', 15350.30, 8, 500.00),
('TX2223GHIK', 'Guasto', 'Problemi al cambio', '2024-06-09 16:00:00', '2024-06-09 17:00:00', 17400.50, NULL, 250.00),
('TX2223GHIK', 'Guasto', 'Problemi al cambio', '2024-06-09 17:30:00', '2024-06-09 19:00:00', 17400.50, NULL, 250.00),
('TX2223GHIK', 'Guasto', 'Problemi al cambio', '2024-06-09 19:10:00', '2024-06-09 20:00:00', 17400.50, NULL, 250.00),
('TX2223GHIK', 'Guasto', 'Problemi al cambio', '2024-06-09 20:05:00', '2024-06-09 22:00:00', 17400.50, NULL, 250.00),
('TX2425LMNO', 'Tagliando', 'Tagliando completo', '2024-06-10 17:00:00', '2024-06-10 21:00:00', 11500.70, NULL, 150.00);

INSERT INTO Rifornimento (IDTransazione, Veicolo, Autista, DataOra, Localita, Importo, LitriCarburante) VALUES
(1, 'TX1234ABCD', 1, '2024-07-01 08:00:00', 10, 50.000, 40.50),
(2, 'TX1819YZAB', 2, '2024-07-02 09:00:00', 8, 60.000, 45.75),
(3, 'TX9101IJKL', 3, '2024-07-03 10:00:00', 9, 70.000, 50.00),
(4, 'TX1213MNOP', 4, '2024-07-04 11:00:00', 10, 80.000, 55.25),
(5, 'TX1415QRST', 5, '2024-07-05 12:00:00', 10, 90.000, 60.50),
(6, 'TX1617UVWX', 6, '2024-07-06 13:00:00', 8, 100.000, 65.75),
(7, 'TX1819YZAB', 7, '2024-07-07 14:00:00', 9, 110.000, 70.00),
(8, 'TX2021CDEF', 8, '2024-06-08 15:00:00', 8, 120.000, 75.25),
(9, 'TX2223GHIK', 9, '2024-05-09 16:00:00', 9, 130.000, 80.50),
(10, 'TX2425LMNO', 10, '2024-04-10 17:00:00', 9, 140.000, 85.75);
