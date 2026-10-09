import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/money/currency.dart';
import '../../data/repositories/errors.dart';
import '../../domain/models/group.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';

const List<String> groupEmojis = [
  '👥',
  '🏠',
  '✈️',
  '🍽️',
  '🎉',
  '💑',
  '🏖️',
  '⛺',
  '🚗',
  '🎿',
  '🛒',
  '🎓',
  '🏋️',
  '🎸',
  '🐶',
  '🌍',
];

/// Creates a new group or edits [existing]. When creating, navigates to the
/// new group on success.
Future<void> showGroupEditor(BuildContext context, {Group? existing, bool canChangeCurrency = true}) {
  return showAdaptiveSheet<void>(
    context,
    builder: (_) => _GroupEditor(existing: existing, canChangeCurrency: canChangeCurrency),
  );
}

class _GroupEditor extends ConsumerStatefulWidget {
  const _GroupEditor({required this.existing, required this.canChangeCurrency});

  final Group? existing;
  final bool canChangeCurrency;

  @override
  ConsumerState<_GroupEditor> createState() => _GroupEditorState();
}

class _GroupEditorState extends ConsumerState<_GroupEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _emoji = widget.existing?.emoji ?? groupEmojis.first;
  late Currency _currency =
      widget.existing?.baseCurrency ?? ref.read(preferencesProvider).value?.defaultCurrency ?? Currencies.usd;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(groupRepositoryProvider);
    try {
      if (widget.existing == null) {
        final group = await repo.createGroup(name: _name.text, baseCurrency: _currency, emoji: _emoji);
        if (!mounted) return;
        Navigator.of(context).pop();
        context.navigateTo(Routes.group(group.id));
      } else {
        await repo.updateGroup(widget.existing!.copyWith(name: _name.text, emoji: _emoji, baseCurrency: _currency));
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } on DomainRuleException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return SheetFrame(
      title: editing ? 'Edit group' : 'New group',
      subtitle: editing ? null : 'Groups live only on this device. No account needed.',
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(editing ? 'Save' : 'Create')),
      ],
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: 'Name', hintText: 'Lisbon trip', errorText: _error),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: FsSpace.lg),
        Text('Icon', style: context.text.labelMedium),
        const SizedBox(height: FsSpace.sm),
        Wrap(
          spacing: FsSpace.sm,
          runSpacing: FsSpace.sm,
          children: [
            for (final e in groupEmojis)
              _EmojiChoice(emoji: e, selected: e == _emoji, onTap: () => setState(() => _emoji = e)),
          ],
        ),
        const SizedBox(height: FsSpace.lg),
        CurrencyField(
          value: _currency,
          enabled: widget.canChangeCurrency,
          label: 'Base currency',
          helper: widget.canChangeCurrency
              ? 'Balances are shown in this currency.'
              : 'Locked because this group already has expenses.',
          onChanged: (c) => setState(() => _currency = c),
        ),
      ],
    );
  }
}

class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({required this.emoji, required this.selected, required this.onTap});

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Icon $emoji',
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(FsRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(FsRadius.md),
          onTap: onTap,
          child: AnimatedContainer(
            duration: FsMotion.fast,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FsRadius.md),
              border: Border.all(color: selected ? colors.primary : Colors.transparent, width: 1.5),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22, height: 1)),
          ),
        ),
      ),
    );
  }
}

/// Searchable currency picker.
class CurrencyField extends StatelessWidget {
  const CurrencyField({
    required this.value,
    required this.onChanged,
    this.label = 'Currency',
    this.helper,
    this.enabled = true,
    this.compact = false,
    super.key,
  });

  final Currency value;
  final ValueChanged<Currency> onChanged;
  final String label;
  final String? helper;
  final bool enabled;

  /// Narrow variant showing only the code (for inline amount rows).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Currency>(
      initialSelection: value,
      enabled: enabled,
      enableFilter: true,
      requestFocusOnTap: true,
      label: Text(label),
      helperText: helper,
      width: compact ? 132 : null,
      expandedInsets: compact ? null : EdgeInsets.zero,
      menuHeight: 320,
      leadingIcon: compact ? null : const Icon(Icons.payments_outlined),
      dropdownMenuEntries: [
        for (final c in Currencies.all)
          DropdownMenuEntry<Currency>(
            value: c,
            label: compact ? c.code : '${c.code} · ${c.name}',
            leadingIcon: compact ? null : SizedBox(width: 28, child: Text(c.symbol, textAlign: TextAlign.center)),
          ),
      ],
      onSelected: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}
