# Sekundarschulwahl Berlin - Schulnoten Visualisierung

Ein interaktives Dashboard zur Visualisierung von Aufnahmekriterien (Noten) für Sekundarschulen in Berlin-Pankow und Berlin-Lichtenberg.

## Projektübersicht

Dieses Projekt zeigt die durchschnittlichen Noten, die für die Aufnahme an weiterführenden Schulen in Berlin-Pankow und Berlin-Lichtenberg erforderlich sind. Die Daten werden auf einer interaktiven Karte dargestellt, um Eltern und Schülern bei der Schulwahl zu helfen.

### Live-Demo

Eine fertige HTML-Version der Visualisierung ist verfügbar: [index.html](index.html)

## Funktionen

- **Interaktive Karte**: Visualisierung aller Sekundarschulen in Pankow und Lichtenberg
- **Noteninformationen**: Anzeige der Aufnahmekriterien pro Schule
- **Historische Daten**: Vergleich der Noten über mehrere Jahre
- **Schulinformationen**: Links zu den Schulwebsites
- **Farbcodierung**:
  - **Rot**: Schulen mit Notenauswahl
  - **Grün**: Schulen ohne Notenauswahl
  - **Schwarz**: Keine Daten verfügbar

### Barrierefreiheits-Features

- **Tastaturnavigation**: Volle Unterstützung für Tastaturbenutzer
- **Bildschirmlesegeräte**: ARIA-Attribute und semantische HTML-Struktur
- **Hoher Kontrastmodus**: Unterstützung für Benutzer mit Sehbehinderungen
- **Reduzierte Bewegung**: Respektiert Benutzereinstellungen für reduzierte Animationen
- **Skip-Links**: Schnellnavigation für Tastaturbenutzer
- **Fokusindikatoren**: Klare visuelle Hinweise für fokussierte Elemente
- **Mobile Optimierung**: Größere Touch-Ziele für mobile Geräte
- **Druckfreundlich**: Optimierte Darstellung beim Drucken

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
│   ├── bersichtaufnahmeinfoaneltern.xlsx  # Rohdaten Lichtenberg
│   └── data.csv                           # Verarbeitete Daten
├── get_data.R                            # Datenabruf- und Verarbeitungsfunktionen
├── index.Rmd                             # Haupt-RMarkdown-Dokument
├── index.html                            # Generierte HTML-Visualisierung
├── styles.css                            # CSS-Stile
├── README.md                             # Diese Datei
└── 2023_10_18_Sekundarschulwahl_Berlin.Rproj
```

## Installation und Nutzung

### Option 1: Docker (Empfohlen) 🐳

Die einfachste Methode ist die Verwendung von Docker, die alle Abhängigkeiten automatisch bereitstellt:

#### Voraussetzungen
- Docker installiert
- Docker Compose installiert

#### Schnellstart
```bash
# Docker-Container starten
docker-compose up -d

# RStudio im Browser öffnen: http://localhost:8787
# Benutzername: rstudio
# Passwort: Keines (Authentifizierung ist deaktiviert)

# Beenden
docker-compose down
```

**Vorteile:**
- Keine Systemabhängigkeiten nötig
- Konsistente Umgebung für alle Teammitglieder
- Einfache Einrichtung

### Option 2: Lokale R-Installation

#### Voraussetzungen

- R (Version 4.0 oder höher)
- RStudio (empfohlen)
- Benötigte R-Pakete (werden automatisch installiert):
  ```r
  install.packages(c("dplyr", "httr", "sf", "leaflet", "leaflet.extras", "htmltools", "rio", "janitor", "stringr"))
  ```

### Projekt starten

1. Klonen Sie das Repository oder laden Sie die Dateien herunter
2. Öffnen Sie das Projekt in RStudio
3. Installieren Sie die Abhängigkeiten:
   ```r
   renv::restore()  # Falls renv.lock vorhanden
   ```
4. Öffnen Sie `index.Rmd` und führen Sie es aus, um die Visualisierung zu generieren

### Daten aktualisieren

Die Daten können durch Aktualisierung der Funktionen in `get_data.R` erweitert werden:

- `get_school_grades_lichtenberg()`: Daten für Lichtenberg
- `get_school_grades_pankow()`: Daten für Pankow
- `get_school_mapdata()`: Geodaten der Schulen

## Beitrag leisten

### Fehlende Daten

Aktuell fehlen die Daten für Lichtenberg 2024. Sie können helfen, indem Sie:

1. Eine Anfrage beim Schulamt Lichtenberg stellen (am besten über [FragDenStaat.de](https://fragdenstaat.de))
2. Die erhaltenen Daten im `data/` Ordner ablegen
3. Die entsprechenden Funktionen in `get_data.R` anpassen

### Code-Beiträge

1. Forken Sie das Repository
2. Erstellen Sie einen neuen Branch: `git checkout -b feature/neue-funktion`
3. Führen Sie Ihre Änderungen durch
4. Committen Sie Ihre Änderungen: `git commit -m "Beschreibung der Änderungen"`
5. Pushen Sie den Branch: `git push origin feature/neue-funktion`
6. Erstellen Sie einen Pull Request

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) für Details.

## Danksagung

- Die Mitarbeiter:innen in den Schulämtern Berlin für die Bereitstellung der Daten
- Die Open-Source-Projekte: R, RMarkdown, Leaflet, OpenStreetMap
- [Mistral AI](https://mistral.ai/) für die Unterstützung bei der Projektdokumentation

## Kontakt

Bei Fragen oder Anregungen können Sie ein Issue im Repository erstellen oder eine E-Mail an [Ihre Kontaktinformationen] senden.

## Haftungsausschluss

Die bereitgestellten Informationen sind ohne Gewähr. Bitte überprüfen Sie alle Daten unabhängig und kontaktieren Sie die Schulen direkt für offizielle Informationen. Die Visualisierung dient nur zur Orientierung und ersetzt keine offizielle Beratung.
