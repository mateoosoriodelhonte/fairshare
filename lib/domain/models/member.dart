import 'package:meta/meta.dart';

/// A person in a group. Members are local-only labels; there are no accounts.
@immutable
class Member {
  const Member({
    required this.id,
    required this.groupId,
    required this.name,
    required this.colorIndex,
    required this.createdAt,
  });

  final String id;
  final String groupId;
  final String name;

  /// Index into the avatar palette; keeps colors stable across sessions.
  final int colorIndex;
  final DateTime createdAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Member copyWith({String? name, int? colorIndex}) => Member(
    id: id,
    groupId: groupId,
    name: name ?? this.name,
    colorIndex: colorIndex ?? this.colorIndex,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Member &&
      other.id == id &&
      other.groupId == groupId &&
      other.name == name &&
      other.colorIndex == colorIndex &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, groupId, name, colorIndex, createdAt);

  @override
  String toString() => 'Member($name)';
}
