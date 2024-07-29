CREATE USER 'hr'@'localhost' IDENTIFIED BY 'ZTWGNmYr3SsQzMCjlIFBJalWgxn9lu4';
GRANT INSERT, UPDATE ON Progetto_Blanco.Dipendente TO 'hr'@'localhost';
GRANT INSERT, UPDATE ON Progetto_Blanco.Luogo TO 'hr'@'localhost';
GRANT INSERT, UPDATE ON Progetto_Blanco.Rifornimento TO 'hr'@'localhost';

CREATE USER 'amministrazione'@'localhost' IDENTIFIED BY 'P8A2gl3i5hsJTlHiF8Obkxzv80mCpS7';
GRANT INSERT, UPDATE, DELETE ON Progetto_Blanco.Dipendente TO 'amministrazione'@'localhost';
GRANT INSERT, UPDATE, DELETE ON Progetto_Blanco.Veicolo TO 'amministrazione'@'localhost';

CREATE USER 'pianificazione'@'localhost' IDENTIFIED BY 'VUPFg3j0awunuD0d9EQPz83mHKzwmag';
GRANT INSERT, UPDATE, DELETE ON Progetto_Blanco.Trasferta TO 'pianificazione'@'localhost';
GRANT INSERT, UPDATE, DELETE ON Progetto_Blanco.Luogo TO 'pianificazione'@'localhost';
GRANT INSERT, UPDATE ON Progetto_Blanco.Manutenzione TO 'pianificazione'@'localhost';

FLUSH PRIVILEGES;
