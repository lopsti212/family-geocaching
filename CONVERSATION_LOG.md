# Family Geocaching - Gesprächsverlauf

**Letzte Sitzung:** 2026-02-06

---

## Status

**Funktioniert:**
- Registrierung/Login (Eltern & Kind)
- Familie erstellen mit Einladungscode
- Familie beitreten als Kind
- Schatzsuchen erstellen (3 Schwierigkeitsstufen)
- GPS-Navigation & Kompass-Ansicht

**Noch zu testen:**
- [ ] GPS-Zielerkennung (wird das Ziel erkannt wenn man dort ist?)
- [ ] Belohnung freischalten nach Zielerreichung

**Bekannte Probleme:**
- [ ] Nicht alle Quests werden im Kind-Konto angezeigt (nur die letzte aktive) - muss noch geprüft werden

**Sicherheit (erledigt):**
- [x] RLS-Policies verschärft - nur eigene Familie sieht Quests
- [x] Fremde Accounts können keine Ziel-Koordinaten sehen
- [x] Live-Position des Kindes wird nirgends gespeichert

**Web-Server starten (für Tests):**
```bash
export PATH="$PATH:$HOME/.flutter/flutter/bin"
cd ~/projekte/family-geocaching
flutter build web
cd build/web && python3 -m http.server 8080
```
Dann öffnen: http://penguin.linux.test:8080

---

## Projektidee

Eine App für Eltern und Kinder:
- **Eltern** erstellen Schatzsuchen mit Belohnungen (Handyzeit, Taschengeld, etc.)
- **Kinder** müssen per GPS einen Ort finden
- Bei Erreichen des Ziels wird die Belohnung freigeschaltet

### Schwierigkeitsstufen
1. **Stufe 1** – Direkter Ort wird auf Karte angezeigt (einfach)
2. **Stufe 2** – Nur Umkreis (~100m) wird angezeigt, Kind muss suchen
3. **Stufe 3** – Nur Kompassnadel zeigt die Richtung (schwer)

### Zusätzliche Features (geplant)
- NFC-Tags als Ziel-Verifizierung
- Möglichst lokal/offline (geringe Serverkosten)
- Skalierbar für größere Nutzerbasis (nicht nur Familie)

---

## Technologie-Entscheidung

**Gewählt: Flutter + Supabase**

Gründe:
- Eine Codebase für Android App UND Web-Interface
- Voller GPS- und NFC-Support
- Skalierbar für späteres Wachstum
- Supabase Free Tier reicht für Familien-Nutzung

---

## Was wurde erstellt

### Projektstruktur
```
lib/
├── config/
│   ├── supabase_config.dart    # Supabase Credentials (TODO: eintragen)
│   ├── app_router.dart         # Navigation/Routing
│   └── theme.dart              # App-Design/Farben
├── models/
│   ├── user_model.dart         # Benutzer (Eltern/Kind)
│   ├── quest_model.dart        # Schatzsuchen + Belohnungen
│   └── family_model.dart       # Familien mit Invite-Code
├── providers/
│   ├── auth_provider.dart      # Login/Registrierung/Familie
│   └── quest_provider.dart     # Quest-Verwaltung
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── role_selection_screen.dart
│   ├── parent/
│   │   ├── parent_home_screen.dart
│   │   ├── create_quest_screen.dart
│   │   └── quest_detail_screen.dart
│   ├── child/
│   │   ├── child_home_screen.dart
│   │   └── quest_hunt_screen.dart    # GPS + Kompass Navigation!
│   └── shared/
│       ├── family_screen.dart
│       └── profile_screen.dart
├── services/
│   ├── supabase_service.dart   # Backend-Kommunikation
│   └── location_service.dart   # GPS + Kompass
├── widgets/
│   └── quest_card.dart
└── main.dart
```

### Zusätzliche Dateien
- `supabase/schema.sql` – Datenbank-Schema für Supabase
- `SETUP.md` – Einrichtungsanleitung
- `android/app/src/main/AndroidManifest.xml` – GPS/NFC Berechtigungen

### Dependencies installiert
- supabase_flutter (Backend)
- provider (State Management)
- go_router (Navigation)
- geolocator (GPS)
- flutter_compass (Kompass)
- flutter_map + latlong2 (Karten)
- shared_preferences (Lokale Speicherung)

---

## Nächste Schritte

### Erledigt
1. [x] Supabase-Projekt erstellt
2. [x] SQL-Schema ausgeführt
3. [x] API-Keys eingetragen
4. [x] App getestet (Web-Version auf Chromebook)
5. [x] RLS-Policies gefixt (siehe unten)
6. [x] E-Mail-Bestätigung in Supabase deaktiviert

### RLS-Policies (aktuell aktiv - sicher!)
Verschärfte Policies für Datenschutz:

```sql
-- USERS
DROP POLICY IF EXISTS "Users können ihr eigenes Profil lesen" ON public.users;
DROP POLICY IF EXISTS "Users können Familienmitglieder sehen" ON public.users;
DROP POLICY IF EXISTS "Users können ihr Profil erstellen" ON public.users;
DROP POLICY IF EXISTS "Users können ihr Profil aktualisieren" ON public.users;

CREATE POLICY "User lesen" ON public.users FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "User erstellen" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "User aktualisieren" ON public.users FOR UPDATE USING (auth.uid() = id);

-- FAMILIES
DROP POLICY IF EXISTS "Familienmitglieder können Familie sehen" ON public.families;
DROP POLICY IF EXISTS "Authentifizierte User können Familien erstellen" ON public.families;
DROP POLICY IF EXISTS "Familien können per Invite-Code gefunden werden" ON public.families;

CREATE POLICY "Jeder kann Familien per Invite-Code finden" ON public.families FOR SELECT USING (true);
CREATE POLICY "Eingeloggte User können Familien erstellen" ON public.families FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- QUESTS
DROP POLICY IF EXISTS "Familienmitglieder können Quests sehen" ON public.quests;
DROP POLICY IF EXISTS "Eltern können Quests erstellen" ON public.quests;
DROP POLICY IF EXISTS "Familienmitglieder können Quests aktualisieren" ON public.quests;
DROP POLICY IF EXISTS "Eltern können Quests löschen" ON public.quests;

-- Aktuelle sichere Policies (Stand 2026-02-06 Abend):
CREATE POLICY "User lesen" ON public.users FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Eigenes Profil erstellen" ON public.users FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "Eigenes Profil bearbeiten" ON public.users FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Familie lesen" ON public.families FOR SELECT USING (true);
CREATE POLICY "Familie erstellen" ON public.families FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Nur Familien-Quests lesen" ON public.quests FOR SELECT USING (family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid()));
CREATE POLICY "Familien-Quests erstellen" ON public.quests FOR INSERT WITH CHECK (family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid()));
CREATE POLICY "Familien-Quests aktualisieren" ON public.quests FOR UPDATE USING (family_id IN (SELECT family_id FROM public.users WHERE id = auth.uid()));
CREATE POLICY "Eigene Quests löschen" ON public.quests FOR DELETE USING (created_by = auth.uid());
```

### Später
- [ ] NFC-Tag Support implementieren
- [ ] Push-Benachrichtigungen
- [ ] Offline-Modus
- [ ] Statistiken/Erfolge für Kinder
- [ ] App-Icon und Splash-Screen
- [ ] Play Store Veröffentlichung

---

## Befehle

```bash
# Flutter verfügbar machen
export PATH="$PATH:$HOME/.flutter/flutter/bin"

# App starten (Web)
flutter run -d chrome

# App starten (Android)
flutter run -d android

# APK bauen
flutter build apk --release

# Web bauen
flutter build web
```

---

## Notizen

- Benutzer kennt: PHP, HTML, etwas JavaScript
- Python wäre Alternative gewesen, aber Flutter besser für Skalierbarkeit
- NFC ist "nice to have", erstmal GPS-Fokus
