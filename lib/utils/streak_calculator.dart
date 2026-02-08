import '../models/quest_model.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;

  StreakData({required this.currentStreak, required this.longestStreak});
}

class StreakCalculator {
  static StreakData calculate(List<QuestModel> completedQuests) {
    if (completedQuests.isEmpty) {
      return StreakData(currentStreak: 0, longestStreak: 0);
    }

    // Einzigartige Tage mit abgeschlossenen Quests
    final dates = completedQuests
        .where((q) => q.completedAt != null)
        .map((q) => _dateOnly(q.completedAt!))
        .toSet()
        .toList()
      ..sort();

    if (dates.isEmpty) return StreakData(currentStreak: 0, longestStreak: 0);

    // Längste Serie berechnen
    int longestStreak = 1;
    int currentRun = 1;

    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentRun++;
      } else {
        currentRun = 1;
      }
      if (currentRun > longestStreak) longestStreak = currentRun;
    }

    // Aktuelle Serie: nur wenn letzter Tag heute oder gestern
    final today = _dateOnly(DateTime.now());
    final lastDate = dates.last;
    int currentStreak = 0;

    if (lastDate == today || lastDate == today.subtract(const Duration(days: 1))) {
      currentStreak = 1;
      for (int i = dates.length - 2; i >= 0; i--) {
        if (dates[i + 1].difference(dates[i]).inDays == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return StreakData(currentStreak: currentStreak, longestStreak: longestStreak);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
