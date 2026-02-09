import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/parent/parent_home_screen.dart';
import '../screens/parent/create_quest_screen.dart';
import '../screens/parent/quest_detail_screen.dart';
import '../screens/child/child_home_screen.dart';
import '../screens/child/quest_hunt_screen.dart';
import '../screens/shared/family_screen.dart';
import '../screens/shared/privacy_screen.dart';
import '../screens/shared/profile_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/role-selection';

        // Nicht eingeloggt und nicht auf Login-Seite -> Login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // Eingeloggt aber auf Login-Seite -> Home
        if (isLoggedIn && isLoggingIn) {
          return authProvider.user?.role == UserRole.parent
              ? '/parent'
              : '/child';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),

        // Parent Routes
        GoRoute(
          path: '/parent',
          builder: (context, state) => const ParentHomeScreen(),
          routes: [
            GoRoute(
              path: 'create-quest',
              builder: (context, state) => const CreateQuestScreen(),
            ),
            GoRoute(
              path: 'quest/:id',
              builder: (context, state) => QuestDetailScreen(
                questId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),

        // Child Routes
        GoRoute(
          path: '/child',
          builder: (context, state) => const ChildHomeScreen(),
          routes: [
            GoRoute(
              path: 'hunt/:id',
              builder: (context, state) => QuestHuntScreen(
                questId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),

        // Shared Routes
        GoRoute(
          path: '/family',
          builder: (context, state) => const FamilyScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyScreen(),
        ),

        // Root redirect
        GoRoute(
          path: '/',
          redirect: (context, state) {
            if (!authProvider.isAuthenticated) {
              return '/login';
            }
            return authProvider.user?.role == UserRole.parent
                ? '/parent'
                : '/child';
          },
        ),
      ],
    );
  }
}
