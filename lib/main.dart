import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/quest_provider.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialisieren
  await SupabaseService.initialize();

  runApp(const FamilyGeocachingApp());
}

class FamilyGeocachingApp extends StatelessWidget {
  const FamilyGeocachingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Family Geocaching',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router(authProvider),
          );
        },
      ),
    );
  }
}
