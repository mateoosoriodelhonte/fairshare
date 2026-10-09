import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

/// Standard page frame: a slim toolbar (back button + actions), a large
/// title in the scroll view, and content constrained to a reading width.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.title,
    required this.slivers,
    this.titleWidget,
    this.subtitle,
    this.actions = const [],
    this.fab,
    this.leading,
    this.showBack,
    super.key,
  });

  final String title;

  /// Replaces the plain [title] text when set (e.g. emoji + name).
  final Widget? titleWidget;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? fab;
  final Widget? leading;

  /// Forces the back button on or off; defaults to "whenever we can pop".
  final bool? showBack;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? (GoRouter.maybeOf(context)?.canPop() ?? Navigator.of(context).canPop());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            leading ??
            (canPop
                ? IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  )
                : null),
        title: null,
        actions: [
          ...actions,
          const SizedBox(width: FsSpace.sm),
        ],
        toolbarHeight: 52,
      ),
      floatingActionButton: fab,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = math.max(FsSpace.lg, (constraints.maxWidth - FsLayout.contentMaxWidth) / 2);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, FsSpace.md),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KeyedSubtree(
                        key: const ValueKey('page-title'),
                        child:
                            titleWidget ??
                            Text(
                              title,
                              style: context.text.headlineLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: FsSpace.xs),
                        Text(
                          subtitle!,
                          style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              for (final s in slivers)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  sliver: s,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
    );
  }
}

/// Convenience for a list of box widgets inside [PageScaffold.slivers].
class SliverBox extends StatelessWidget {
  const SliverBox({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverList(delegate: SliverChildListDelegate.fixed(children));
}
