# Family Geocaching - Setup Anleitung

## 1. Supabase einrichten

1. Gehe zu [supabase.com](https://supabase.com) und erstelle ein kostenloses Konto
2. Erstelle ein neues Projekt
3. Warte bis das Projekt bereit ist (~2 Minuten)

### Datenbank einrichten

1. Gehe zu **SQL Editor** in deinem Supabase Dashboard
2. Kopiere den Inhalt von `supabase/schema.sql`
3. Führe das SQL aus (Run)

### API Credentials

1. Gehe zu **Settings** → **API**
2. Kopiere:
   - **Project URL** (z.B. `https://abcdefg.supabase.co`)
   - **anon public** Key

3. Trage diese in `lib/config/supabase_config.dart` ein:

```dart
static const String supabaseUrl = 'https://DEIN_PROJEKT.supabase.co';
static const String supabaseAnonKey = 'DEIN_ANON_KEY';
```

## 2. Flutter einrichten

### Flutter PATH setzen

Füge zu deiner `~/.bashrc` oder `~/.zshrc` hinzu:

```bash
export PATH="$PATH:$HOME/.flutter/flutter/bin"
```

Dann:
```bash
source ~/.bashrc  # oder source ~/.zshrc
```

### App testen

```bash
cd family-geocaching
flutter run
```

Für Web:
```bash
flutter run -d chrome
```

Für Android (Emulator oder Gerät):
```bash
flutter run -d android
```

## 3. Android APK bauen

```bash
flutter build apk --release
```

Die APK findest du unter: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Web Version bauen

```bash
flutter build web
```

Die Web-Dateien findest du unter: `build/web/`

---

## Projektstruktur

```
lib/
├── config/           # Konfiguration (Supabase, Router, Theme)
├── models/           # Datenmodelle (User, Quest, Family)
├── providers/        # State Management (Auth, Quests)
├── screens/          # UI Screens
│   ├── auth/         # Login, Register
│   ├── parent/       # Eltern-Bereich
│   ├── child/        # Kind-Bereich
│   └── shared/       # Gemeinsame Screens
├── services/         # Backend-Services (Supabase, Location)
├── widgets/          # Wiederverwendbare Widgets
└── main.dart         # App-Einstiegspunkt
```

## Features

### Implementiert:
- [x] Benutzer-Registrierung (Eltern/Kind)
- [x] Familien erstellen und beitreten
- [x] Quests erstellen (Eltern)
- [x] Kartenansicht für Zielauswahl
- [x] 3 Schwierigkeitsstufen
- [x] GPS-Tracking
- [x] Kompass-Navigation (Stufe 3)
- [x] Belohnungssystem
- [x] Echtzeit-Updates

### Geplant:
- [ ] NFC-Tag Support
- [ ] Statistiken/Erfolge
- [ ] Push-Benachrichtigungen
- [ ] Offline-Modus
- [ ] Mehrsprachigkeit
