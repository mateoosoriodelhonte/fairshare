/// Thrown when a write would violate a business rule. Messages are written
/// for end users and surfaced directly in the UI.
class DomainRuleException implements Exception {
  const DomainRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  const NotFoundException(this.what, this.id);

  final String what;
  final String id;

  @override
  String toString() => '$what "$id" was not found';
}
