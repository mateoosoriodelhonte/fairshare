import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../domain/models/models.dart';
import '../../features/groups/group_editor_sheet.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Desktop navigation: overview, the list of groups, and settings.
class Sidebar extends ConsumerWidget {
  const Sidebar({required this.collapsed, super.key});

  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final groups = ref.watch(groupsProvider).value ?? const <Group>[];
    final width = collapsed ? FsLayout.railWidth : FsLayout.sidebarWidth;

    return AnimatedContainer(
      duration: FsMotion.normal,
      curve: FsMotion.standard,
      width: width,
      color: Theme.of(context).brightness == Brightness.dark
          ? context.colors.surfaceContainerLow
          : context.colors.surfaceContainer.withValues(alpha: 0.6),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 0 : FsSpace.xl,
                FsSpace.xl,
                collapsed ? 0 : FsSpace.lg,
                FsSpace.lg,
              ),
              child: _Brand(collapsed: collapsed),
            ),
            _NavItem(
              icon: Icons.space_dashboard_outlined,
              selectedIcon: Icons.space_dashboard_rounded,
              label: 'Overview',
              selected: location == Routes.dashboard,
              collapsed: collapsed,
              onTap: () => context.go(Routes.dashboard),
            ),
            const SizedBox(height: FsSpace.md),
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(FsSpace.xl, FsSpace.sm, FsSpace.lg, FsSpace.xs),
                child: Row(
                  children: [
                    Expanded(child: Text('GROUPS', style: context.text.labelSmall?.copyWith(letterSpacing: 0.8))),
                    Tooltip(
                      message: 'New group',
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        onPressed: () => showGroupEditor(context),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: FsSpace.xs),
                children: [
                  for (final g in groups)
                    _NavItem(
                      emoji: g.emoji,
                      label: g.name,
                      selected: location == Routes.group(g.id),
                      collapsed: collapsed,
                      onTap: () => context.go(Routes.group(g.id)),
                    ),
                  if (groups.isEmpty && !collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(FsSpace.xl, FsSpace.md, FsSpace.xl, 0),
                      child: Text('No groups yet.', style: context.text.bodySmall),
                    ),
                  if (collapsed)
                    _NavItem(
                      icon: Icons.add_rounded,
                      label: 'New group',
                      selected: false,
                      collapsed: true,
                      onTap: () => showGroupEditor(context),
                    ),
                ],
              ),
            ),
            _NavItem(
              icon: Icons.tune_rounded,
              selectedIcon: Icons.tune_rounded,
              label: 'Settings',
              selected: location == Routes.settings,
              collapsed: collapsed,
              onTap: () => context.go(Routes.settings),
            ),
            const SizedBox(height: FsSpace.md),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final mark = BrandMark(size: collapsed ? 30 : 28);
    if (collapsed) return Center(child: mark);
    return Row(
      children: [
        mark,
        const SizedBox(width: FsSpace.md),
        Flexible(
          child: Text(
            'FairShare',
            style: context.text.titleMedium?.copyWith(letterSpacing: -0.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.emoji,
  });

  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? selectedIcon;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.onPrimaryContainer : colors.onSurface;
    final leading = emoji != null
        ? Text(emoji!, style: const TextStyle(fontSize: 18, height: 1))
        : Icon(
            selected ? (selectedIcon ?? icon) : icon,
            size: 20,
            color: selected ? colors.primary : colors.onSurfaceVariant,
          );

    final content = collapsed
        ? Center(child: leading)
        : Row(
            children: [
              SizedBox(width: 24, child: Center(child: leading)),
              const SizedBox(width: FsSpace.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? FsSpace.md : FsSpace.md, vertical: 1),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: collapsed ? label : '',
          child: Material(
            color: selected ? colors.primaryContainer.withValues(alpha: 0.7) : Colors.transparent,
            borderRadius: BorderRadius.circular(FsRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(FsRadius.md),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : FsSpace.md, vertical: 9),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
