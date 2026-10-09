import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/expenses/expense_editor_screen.dart';
import '../features/groups/group_screen.dart';
import '../features/recurring/recurring_screen.dart';
import '../features/recurring/template_editor_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settlements/settle_screen.dart';
import '../ui/shell/app_shell.dart';

/// Route table. Paths are stable so deep links and tests can rely on them.
class Routes {
  Routes._();

  static const dashboard = '/';
  static const settings = '/settings';
  static String group(String id) => '/groups/$id';
  static String settle(String groupId) => '/groups/$groupId/settle';
  static String recurring(String groupId) => '/groups/$groupId/recurring';
  static String newTemplate(String groupId) => '/groups/$groupId/recurring/new';
  static String template(String groupId, String templateId) => '/groups/$groupId/recurring/$templateId';
  static String newExpense(String groupId) => '/groups/$groupId/expenses/new';
  static String expense(String groupId, String expenseId) => '/groups/$groupId/expenses/$expenseId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (context, state) => const _ShellPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) => const _ShellPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: '/groups/:groupId',
            pageBuilder: (context, state) => _ShellPage(
              key: state.pageKey,
              child: GroupScreen(groupId: state.pathParameters['groupId']!),
            ),
            routes: [
              GoRoute(
                path: 'recurring',
                pageBuilder: (context, state) => _ShellPage(
                  key: state.pageKey,
                  child: RecurringScreen(groupId: state.pathParameters['groupId']!),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => _ShellPage(
                      key: state.pageKey,
                      child: TemplateEditorScreen(groupId: state.pathParameters['groupId']!),
                    ),
                  ),
                  GoRoute(
                    path: ':templateId',
                    pageBuilder: (context, state) => _ShellPage(
                      key: state.pageKey,
                      child: TemplateEditorScreen(
                        groupId: state.pathParameters['groupId']!,
                        templateId: state.pathParameters['templateId'],
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'settle',

                pageBuilder: (context, state) => _ShellPage(
                  key: state.pageKey,
                  child: SettleScreen(groupId: state.pathParameters['groupId']!),
                ),
              ),
              GoRoute(
                path: 'expenses/new',
                pageBuilder: (context, state) => _ShellPage(
                  key: state.pageKey,
                  child: ExpenseEditorScreen(groupId: state.pathParameters['groupId']!),
                ),
              ),
              GoRoute(
                path: 'expenses/:expenseId',
                pageBuilder: (context, state) => _ShellPage(
                  key: state.pageKey,
                  child: ExpenseEditorScreen(
                    groupId: state.pathParameters['groupId']!,
                    expenseId: state.pathParameters['expenseId'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Pages inside the shell use the theme's page transitions.
class _ShellPage extends MaterialPage<void> {
  const _ShellPage({required super.child, super.key});
}
