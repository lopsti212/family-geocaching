import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Datenschutzerklärung',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _Section(
            title: '1. Welche Daten wir erheben',
            content:
                'Account-Daten (E-Mail, Name, Rolle), Familiendaten, '
                'Quest-Daten (Titel, GPS-Zielkoordinaten, Status), '
                'Fotos (nur wenn von Eltern aktiviert) und Spielfortschritt (XP, Level).',
          ),
          _Section(
            title: '2. Standortdaten',
            content:
                'GPS-Standortdaten werden ausschließlich während einer aktiven '
                'Schatzsuche erhoben und nur lokal auf dem Gerät verarbeitet. '
                'Deine Echtzeit-Position wird nicht auf unseren Servern gespeichert.',
          ),
          _Section(
            title: '3. Fotos',
            content:
                'Fotos werden nur aufgenommen, wenn ein Elternteil das Foto-Feature '
                'für eine Schatzsuche aktiviert hat. Fotos sind nur für '
                'Familienmitglieder sichtbar und werden beim Löschen der Quest entfernt.',
          ),
          _Section(
            title: '4. Kinder und Datenschutz',
            content:
                'Kinder können die App nur nutzen, wenn ein Elternteil eine Familie '
                'erstellt und den Einladungscode bereitstellt. Es werden keine Daten '
                'an Dritte zu Werbezwecken weitergegeben. Die App enthält keine Werbung.',
          ),
          _Section(
            title: '5. Speicherort',
            content:
                'Alle Daten werden auf Servern in der EU (Frankfurt, Deutschland) '
                'bei Supabase gespeichert. Die Übertragung erfolgt verschlüsselt (HTTPS).',
          ),
          _Section(
            title: '6. Deine Rechte',
            content:
                'Du hast das Recht auf Auskunft, Berichtigung und Löschung deiner Daten. '
                'Du kannst deinen Account jederzeit in der App unter Profil löschen. '
                'Dabei werden alle deine Daten unwiderruflich entfernt.',
          ),
          _Section(
            title: '7. Konto löschen',
            content:
                'Du kannst dein Konto jederzeit unter Profil → Konto löschen entfernen. '
                'Dabei werden alle Account-Daten, erstellten Quests und hochgeladenen '
                'Fotos endgültig gelöscht.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
