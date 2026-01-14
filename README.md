
# Sekundarschulwahl Berlin - Schulnoten Visualisierung

Ein interaktives Dashboard zur Visualisierung von Aufnahmekriterien (Noten) für Sekundarschulen in Berlin-Pankow und Berlin-Lichtenberg.

[Zur Webseite](https://jakobschumacher.github.io/schulnoten_berlin

## Projektübersicht

Dieses Projekt zeigt die durchschnittlichen Noten, die für die Aufnahme an weiterführenden Schulen in Berlin-Pankow und Berlin-Lichtenberg erforderlich sind. Die Daten werden auf einer interaktiven Karte dargestellt, um Eltern und Schülern bei der Schulwahl zu helfen.

## Funktionen

- **Interaktive Karte**: Visualisierung aller Sekundarschulen in Pankow und Lichtenberg
- **Noteninformationen**: Anzeige der Aufnahmekriterien pro Schule
- **Historische Daten**: Vergleich der Noten über mehrere Jahre
- **Schulinformationen**: Links zu den Schulwebsites

## Datenquellen

Die Daten stammen von den Schulämtern Berlin-Pankow und Berlin-Lichtenberg und wurden über [FragDenStaat.de](https://fragdenstaat.de) angefragt:

- **Lichtenberg 2023**: [Anfrage 297001](https://fragdenstaat.de/a/297001)
- **Lichtenberg 2025**: [Anfrage 352602](https://fragdenstaat.de/a/352602)
- **Pankow 2023**: [Anfrage 296999](https://fragdenstaat.de/a/296999)
- **Pankow 2024/25**: [Anfrage 354681](https://fragdenstaat.de/a/354601)

## Technischer Stack

- **R**: Datenverarbeitung und Analyse
- **R Markdown**: Dokumentation und Berichterstellung
- **Leaflet**: Interaktive Kartendarstellung
- **Tidyverse**: Datenmanipulation
- **sf**: Geodatenverarbeitung
- **httr**: API-Anfragen

## Projektstruktur

```
2023_10_18_Sekundarschulwahl_Berlin/
├── data/
│   └── data.csv                          # Verarbeitete Daten
├── get_data.R                            # Datenabruf- und Verarbeitungsfunktionen
├── index.Rmd                             # Haupt-RMarkdown-Dokument
├── index.html                            # Generierte HTML-Visualisierung
└── styles.css                            # CSS-Stile
```

## Installation und Nutzung per Docker 

Die einfachste Methode ist die Verwendung von Docker, die alle Abhängigkeiten automatisch bereitstellt:

#### Voraussetzungen
- Docker installiert
- Docker Compose installiert

#### Schnellstart
```bash
# Docker-Container starten
docker-compose up -d

# RStudio im Browser öffnen: http://localhost:8787

# Beenden
docker-compose down
```

### Daten aktualisieren

Die Daten können durch Aktualisierung der Funktionen in `get_data.R` erweitert werden:

- `get_school_grades_lichtenberg()`: Daten für Lichtenberg
- `get_school_grades_pankow()`: Daten für Pankow
- `get_school_mapdata()`: Geodaten der Schulen

## Beitrag leisten

### Fehlende Daten

Aktuell fehlen die Daten für Lichtenberg 2024. Sie können helfen, indem Sie:

1. Eine Anfrage beim Schulamt Lichtenberg stellen (am besten über [FragDenStaat.de](https://fragdenstaat.de))

### Code-Beiträge

1. Forken Sie das Repository
2. Erstellen Sie einen neuen Branch: `git checkout -b feature/neue-funktion`
3. Führen Sie Ihre Änderungen durch
4. Committen Sie Ihre Änderungen: `git commit -m "Beschreibung der Änderungen"`
5. Pushen Sie den Branch: `git push origin feature/neue-funktion`
6. Erstellen Sie einen Pull Request

## Danksagung

- Die Mitarbeiter:innen in den Schulämtern Berlin für die Bereitstellung der Daten
- Die Open-Source-Projekte: R, RMarkdown, Leaflet, OpenStreetMap
- [Mistral AI](https://mistral.ai/) für die Unterstützung bei der Projektdokumentation

## Kontakt

Bei Fragen oder Anregungen können Sie ein Issue im Repository erstellen.

## Haftungsausschluss

Die bereitgestellten Informationen sind ohne Gewähr. Bitte überprüfen Sie alle Daten unabhängig und kontaktieren Sie die Schulen direkt für offizielle Informationen. Die Visualisierung dient nur zur Orientierung und ersetzt keine offizielle Beratung.
