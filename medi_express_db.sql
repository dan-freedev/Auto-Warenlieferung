-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 21. Mrz 2025 um 21:25
-- Server-Version: 10.4.32-MariaDB
-- PHP-Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `medi_express_db`
--
CREATE DATABASE IF NOT EXISTS `medi_express_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `medi_express_db`;

DELIMITER $$
--
-- Prozeduren
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ErstelleAuftrag` (IN `ProzBestNr` INT, IN `ProzMtNr` INT, IN `ProzRezeptNr` INT)   BEGIN
  INSERT INTO auftrag (AufBestNr, AufMtNr, AufStatus, AufRezeptNr)
  VALUES(ProzBestNr, ProzMtNr, 'Eingereicht', ProzRezeptNr);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `artikel`
--

CREATE TABLE `artikel` (
  `ArtNr` int(11) NOT NULL,
  `ArtName` varchar(50) NOT NULL,
  `ArtAlias` varchar(50) NOT NULL,
  `ArtGenetik` varchar(50) NOT NULL,
  `ArtTHC` decimal(10,1) NOT NULL,
  `ArtCBD` decimal(10,1) NOT NULL,
  `ArtBestrahlt` varchar(50) NOT NULL,
  `ArtPreis` decimal(10,2) NOT NULL,
  `ArtBild` text NOT NULL,
  `ArtStatus` tinyint(1) NOT NULL,
  `ArtVerfuegbarkeit` tinyint(1) NOT NULL,
  `ArtHerstellungsdatum` date NOT NULL,
  `ArtHaltbarkeitsdatum` date NOT NULL,
  `ArtMenge` decimal(30,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `artikel`:
--

--
-- Daten für Tabelle `artikel`
--

INSERT INTO `artikel` (`ArtNr`, `ArtName`, `ArtAlias`, `ArtGenetik`, `ArtTHC`, `ArtCBD`, `ArtBestrahlt`, `ArtPreis`, `ArtBild`, `ArtStatus`, `ArtVerfuegbarkeit`, `ArtHerstellungsdatum`, `ArtHaltbarkeitsdatum`, `ArtMenge`) VALUES
(1, 'Avaaz Signature 28/1 WB', 'Waffle Bites', 'Hybrid', 28.1, 0.1, 'nein', 10.99, 'wl_bilder/AVAAYSign231WB.webp', 1, 1, '2024-04-18', '2024-10-31', 7530.300),
(2, 'Cannamedical Indica Ultra SF', 'Rainmaker', 'Indica', 27.1, 0.1, 'nein', 9.00, 'wl_bilder/rainmaker.webp', 0, 1, '2024-01-23', '2024-11-22', 269.300);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `artikelbenachrichtigung`
--

CREATE TABLE `artikelbenachrichtigung` (
  `BenachrichtigungNr` int(11) NOT NULL,
  `BenArtNr` int(11) DEFAULT NULL,
  `BenachrichtigungDatum` timestamp NOT NULL DEFAULT current_timestamp(),
  `Nachricht` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONEN DER TABELLE `artikelbenachrichtigung`:
--   `BenArtNr`
--       `artikel` -> `ArtNr`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `auftrag`
--

CREATE TABLE `auftrag` (
  `AufNr` int(11) NOT NULL,
  `AufBestNr` int(11) DEFAULT NULL,
  `AufMtNr` int(11) DEFAULT NULL,
  `AufStatus` varchar(50) NOT NULL,
  `Auferstellt` timestamp NOT NULL DEFAULT current_timestamp(),
  `Aufupdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `AufRezeptNr` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `auftrag`:
--   `AufBestNr`
--       `bestellung` -> `BestNr`
--   `AufMtNr`
--       `mitarbeiter` -> `MtNr`
--   `AufRezeptNr`
--       `rezept` -> `RezeptNr`
--

--
-- Daten für Tabelle `auftrag`
--

INSERT INTO `auftrag` (`AufNr`, `AufBestNr`, `AufMtNr`, `AufStatus`, `Auferstellt`, `Aufupdate`, `AufRezeptNr`) VALUES
(1, NULL, NULL, '', '2024-05-20 16:31:27', '2024-05-20 16:31:27', NULL);

--
-- Trigger `auftrag`
--
DELIMITER $$
CREATE TRIGGER `UpdateArtikelNachBestellung` AFTER INSERT ON `auftrag` FOR EACH ROW BEGIN
  DECLARE UpdArtNr INT;
  DECLARE UpdArtMenge DECIMAL(30,3);

  SELECT BestArtNr, BestMenge INTO UpdArtNr, UpdArtMenge 
  FROM bestellung 
  WHERE BestNr = NEW.AufBestNr;

  UPDATE artikel    
  SET ArtMenge = ArtMenge - UpdArtMenge    
  WHERE ArtNr = UpdArtNr;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `bestellung`
--

CREATE TABLE `bestellung` (
  `BestNr` int(11) NOT NULL,
  `BestKdNr` int(11) DEFAULT NULL,
  `BestArtNr` int(11) DEFAULT NULL,
  `BestMenge` double DEFAULT NULL,
  `BestDatum` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `bestellung`:
--   `BestKdNr`
--       `kunde` -> `KdNr`
--   `BestArtNr`
--       `artikel` -> `ArtNr`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `kunde`
--

CREATE TABLE `kunde` (
  `KdNr` int(11) NOT NULL,
  `KdVorname` varchar(50) NOT NULL,
  `KdNachname` varchar(50) NOT NULL,
  `KdTelefonnummer` int(50) DEFAULT NULL,
  `KdPLZ` varchar(10) NOT NULL,
  `KdOrt` varchar(50) NOT NULL,
  `KdStrasse` varchar(50) NOT NULL,
  `KdEmail` varchar(50) NOT NULL,
  `KdPasswort` varchar(35) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `kunde`:
--

--
-- Daten für Tabelle `kunde`
--

INSERT INTO `kunde` (`KdNr`, `KdVorname`, `KdNachname`, `KdTelefonnummer`, `KdPLZ`, `KdOrt`, `KdStrasse`, `KdEmail`, `KdPasswort`) VALUES
(1, 'Josef', 'Maier', 1518743501, '84032', 'Landshut', 'Ludwigstr.10', '1@gmail', 'wert123!'),
(2, 'Franz', 'Huber', 1518743502, '84051', 'Essenbach', 'Hauptstr.2', '2@gmail', ''),
(3, 'Max', 'Mustermann', 1518743503, '12345', 'Musterstadt', 'Musterstr.1', '3@gmail', ''),
(4, 'Christian', 'Mayer', 1518743504, '84034', 'Landshut', 'Landshuter Str.1', '4@gmail', ''),
(5, 'Christian', 'Huber', 1518743505, '84034', 'Landshut', 'Hauptstr.10', '5@gmail', ''),
(6, 'Andreas', 'Berger', 1518743506, '84034', 'Landshut', 'Dresdener Str.5', '6@gmail', ''),
(7, 'Anton', 'Weinberger', 1518743507, '84032', 'Landshut', 'Lübecker Str.3', '7@gmail', ''),
(8, 'Helmut', 'Schmidt', 1518743508, '80331', 'München', 'Ludwigstr.15', '8@gmail', ''),
(9, 'Franz', 'Schmidt', 1518743509, '12345', 'Musterstadt', 'Musterstr.3', '9@gmail', ''),
(10, 'Helmut', 'Huber', 1518743510, '12345', 'Musterstadt', 'Musterstr.5', '10@gmail', '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mitarbeiter`
--

CREATE TABLE `mitarbeiter` (
  `MtNr` int(11) NOT NULL,
  `MtVorname` varchar(50) NOT NULL,
  `MtNachname` varchar(50) NOT NULL,
  `MtTele` int(50) NOT NULL,
  `MtPLZ` varchar(10) NOT NULL,
  `MtOrt` varchar(50) NOT NULL,
  `MtStrasse` varchar(50) NOT NULL,
  `MtEmail` varchar(50) NOT NULL,
  `MtPasswort` varchar(35) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `mitarbeiter`:
--

--
-- Daten für Tabelle `mitarbeiter`
--

INSERT INTO `mitarbeiter` (`MtNr`, `MtVorname`, `MtNachname`, `MtTele`, `MtPLZ`, `MtOrt`, `MtStrasse`, `MtEmail`, `MtPasswort`) VALUES
(1, 'Max', 'Musterman', 1743215763, '93128', 'Regenstauf', 'Dr.Strasse', 'bot@gmx.de', 'personal');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `rezept`
--

CREATE TABLE `rezept` (
  `RezeptNr` int(11) NOT NULL,
  `KdNr` int(11) NOT NULL,
  `RezeptBild` text NOT NULL,
  `RezeptDatum` timestamp NOT NULL DEFAULT current_timestamp(),
  `RezeptStatus` varchar(50) NOT NULL DEFAULT 'Eingereicht'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_german1_ci;

--
-- RELATIONEN DER TABELLE `rezept`:
--   `KdNr`
--       `kunde` -> `KdNr`
--

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `artikel`
--
ALTER TABLE `artikel`
  ADD PRIMARY KEY (`ArtNr`);

--
-- Indizes für die Tabelle `artikelbenachrichtigung`
--
ALTER TABLE `artikelbenachrichtigung`
  ADD PRIMARY KEY (`BenachrichtigungNr`),
  ADD KEY `BenArtNr` (`BenArtNr`);

--
-- Indizes für die Tabelle `auftrag`
--
ALTER TABLE `auftrag`
  ADD PRIMARY KEY (`AufNr`),
  ADD KEY `AufBestNr` (`AufBestNr`),
  ADD KEY `AufMtNr` (`AufMtNr`),
  ADD KEY `AufRezeptNr` (`AufRezeptNr`);

--
-- Indizes für die Tabelle `bestellung`
--
ALTER TABLE `bestellung`
  ADD PRIMARY KEY (`BestNr`),
  ADD KEY `BestKdNr` (`BestKdNr`),
  ADD KEY `BestArtNr` (`BestArtNr`);

--
-- Indizes für die Tabelle `kunde`
--
ALTER TABLE `kunde`
  ADD PRIMARY KEY (`KdNr`),
  ADD UNIQUE KEY `KdEmail` (`KdEmail`);

--
-- Indizes für die Tabelle `mitarbeiter`
--
ALTER TABLE `mitarbeiter`
  ADD PRIMARY KEY (`MtNr`),
  ADD UNIQUE KEY `MtEmail` (`MtEmail`);

--
-- Indizes für die Tabelle `rezept`
--
ALTER TABLE `rezept`
  ADD PRIMARY KEY (`RezeptNr`),
  ADD KEY `KdNr` (`KdNr`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `artikel`
--
ALTER TABLE `artikel`
  MODIFY `ArtNr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `artikelbenachrichtigung`
--
ALTER TABLE `artikelbenachrichtigung`
  MODIFY `BenachrichtigungNr` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `auftrag`
--
ALTER TABLE `auftrag`
  MODIFY `AufNr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT für Tabelle `bestellung`
--
ALTER TABLE `bestellung`
  MODIFY `BestNr` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `kunde`
--
ALTER TABLE `kunde`
  MODIFY `KdNr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT für Tabelle `mitarbeiter`
--
ALTER TABLE `mitarbeiter`
  MODIFY `MtNr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT für Tabelle `rezept`
--
ALTER TABLE `rezept`
  MODIFY `RezeptNr` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `artikelbenachrichtigung`
--
ALTER TABLE `artikelbenachrichtigung`
  ADD CONSTRAINT `artikelbenachrichtigung_ibfk_1` FOREIGN KEY (`BenArtNr`) REFERENCES `artikel` (`ArtNr`);

--
-- Constraints der Tabelle `auftrag`
--
ALTER TABLE `auftrag`
  ADD CONSTRAINT `auftrag_ibfk_1` FOREIGN KEY (`AufBestNr`) REFERENCES `bestellung` (`BestNr`),
  ADD CONSTRAINT `auftrag_ibfk_2` FOREIGN KEY (`AufMtNr`) REFERENCES `mitarbeiter` (`MtNr`),
  ADD CONSTRAINT `auftrag_ibfk_3` FOREIGN KEY (`AufRezeptNr`) REFERENCES `rezept` (`RezeptNr`);

--
-- Constraints der Tabelle `bestellung`
--
ALTER TABLE `bestellung`
  ADD CONSTRAINT `bestellung_ibfk_1` FOREIGN KEY (`BestKdNr`) REFERENCES `kunde` (`KdNr`),
  ADD CONSTRAINT `bestellung_ibfk_2` FOREIGN KEY (`BestArtNr`) REFERENCES `artikel` (`ArtNr`);

--
-- Constraints der Tabelle `rezept`
--
ALTER TABLE `rezept`
  ADD CONSTRAINT `rezept_ibfk_1` FOREIGN KEY (`KdNr`) REFERENCES `kunde` (`KdNr`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
