import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzungsbedingungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Nutzungsbedingungen',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _Section(
            title: '1. Geltungsbereich',
            content:
                'Diese Nutzungsbedingungen gelten für die Nutzung der App '
                '"Family Geocaching". Mit der Registrierung und Nutzung der App '
                'erklärst du dich mit diesen Bedingungen einverstanden.',
          ),
          _Section(
            title: '2. Nutzung durch Kinder',
            content:
                'Die Registrierung von Kindern unter 16 Jahren darf nur mit '
                'Wissen und Zustimmung eines Erziehungsberechtigten erfolgen. '
                'Ein Erziehungsberechtigter muss eine Familie erstellt und den '
                'Einladungscode bereitgestellt haben.',
          ),
          _WarningSection(
            title: '3. Sicherheitshinweise',
            content:
                'Die Nutzung der App erfolgt auf eigene Gefahr. Bitte beachte:\n\n'
                '• Achte stets auf den Straßenverkehr und deine Umgebung\n'
                '• Schaue nicht auf dein Handy während du dich im Verkehr bewegst\n'
                '• Kinder sollten Schatzsuchen nur unter Aufsicht durchführen\n'
                '• Eltern: Wähle nur sichere, für Kinder geeignete Zielorte\n'
                '• Vermeide gefährliche Orte (Straßen, Gewässer, Baustellen)\n'
                '• Betrete keine Privatgrundstücke oder gesperrte Bereiche\n'
                '• Führe Schatzsuchen nur bei geeignetem Wetter und Tageslicht durch',
          ),
          _Section(
            title: '4. Haftungsausschluss',
            content:
                'Der Betreiber haftet nicht für Schäden oder Verletzungen, die '
                'während der Nutzung der App oder der Durchführung von '
                'Schatzsuchen entstehen. Dies umfasst insbesondere:\n\n'
                '• Verletzungen während Schatzsuchen\n'
                '• Eignung und Sicherheit der festgelegten Zielorte\n'
                '• GPS-Ungenauigkeiten oder technische Fehlfunktionen\n'
                '• Schäden an Dritten oder deren Eigentum\n'
                '• Datenverlust oder Nichterreichbarkeit des Dienstes\n\n'
                'Die Aufsichtspflicht für Kinder liegt bei den '
                'Erziehungsberechtigten. Die Haftung für Vorsatz und grobe '
                'Fahrlässigkeit bleibt unberührt.',
          ),
          _Section(
            title: '5. GPS-Genauigkeit',
            content:
                'GPS-Signale können ungenau sein, insbesondere in Gebäuden, '
                'dicht bebauten Gebieten oder bei schlechtem Wetter. Die '
                'angezeigte Position und Entfernung sind Schätzwerte.',
          ),
          _Section(
            title: '6. Fotos',
            content:
                'Hochgeladene Fotos dürfen keine Rechte Dritter verletzen. '
                'Es dürfen keine Fotos von fremden Personen ohne deren '
                'Einwilligung hochgeladen werden. Fotos sind nur für '
                'Familienmitglieder sichtbar.',
          ),
          _Section(
            title: '7. Verbotene Nutzung',
            content:
                '• Erstellen von Schatzsuchen an gefährlichen oder illegalen Orten\n'
                '• Hochladen von unangemessenen oder illegalen Inhalten\n'
                '• Missbrauch der App für Überwachungszwecke\n'
                '• Weitergabe von Zugangsdaten an Dritte außerhalb der Familie',
          ),
          _Section(
            title: '8. Account-Löschung',
            content:
                'Du kannst deinen Account jederzeit unter Profil → Konto löschen '
                'entfernen. Dabei werden alle deine Daten unwiderruflich gelöscht.',
          ),
          _Section(
            title: '9. Anwendbares Recht',
            content:
                'Es gilt das Recht der Bundesrepublik Deutschland.',
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

class _WarningSection extends StatelessWidget {
  final String title;
  final String content;

  const _WarningSection({required this.title, required this.content});

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[800], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
