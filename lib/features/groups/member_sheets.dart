import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repositories/errors.dart';
import '../../domain/models/member.dart';
import '../../ui/widgets/widgets.dart';

/// Adds a member to [groupId], or renames [existing].
Future<void> showMemberEditor(BuildContext context, {required String groupId, Member? existing}) {
  return showAdaptiveSheet<void>(
    context,
    maxWidth: 420,
    builder: (_) => _MemberEditor(groupId: groupId, existing: existing),
  );
}

class _MemberEditor extends ConsumerStatefulWidget {
  const _MemberEditor({required this.groupId, required this.existing});

  final String groupId;
  final Member? existing;

  @override
  ConsumerState<_MemberEditor> createState() => _MemberEditorState();
}

class _MemberEditorState extends ConsumerState<_MemberEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save({bool addAnother = false}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(groupRepositoryProvider);
    try {
      if (widget.existing == null) {
        await repo.addMember(widget.groupId, _name.text);
      } else {
        await repo.updateMember(widget.existing!.copyWith(name: _name.text));
      }
      if (!mounted) return;
      if (addAnother) {
        _name.clear();
        setState(() => _saving = false);
      } else {
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
      title: editing ? 'Rename member' : 'Add member',
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        if (!editing)
          OutlinedButton(onPressed: _saving ? null : () => _save(addAnother: true), child: const Text('Add another')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(editing ? 'Save' : 'Add')),
      ],
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: 'Name', hintText: 'Ana', errorText: _error),
          onSubmitted: (_) => _save(),
        ),
      ],
    );
  }
}

/// Deletes a member after confirmation; explains when it is not allowed.
Future<void> deleteMemberWithConfirmation(BuildContext context, WidgetRef ref, Member member) async {
  final repo = ref.read(groupRepositoryProvider);
  if (await repo.isMemberReferenced(member.id)) {
    if (!context.mounted) return;
    showMessage(context, '${member.name} has expenses or settlements, so they cannot be removed.');
    return;
  }
  if (!context.mounted) return;
  final ok = await confirmDestructive(
    context,
    title: 'Remove ${member.name}?',
    message: 'They have no expenses or settlements yet, so nothing else changes.',
    confirmLabel: 'Remove',
  );
  if (!ok) return;
  try {
    await repo.deleteMember(member.id);
  } on DomainRuleException catch (e) {
    if (context.mounted) showMessage(context, e.message);
  }
}
