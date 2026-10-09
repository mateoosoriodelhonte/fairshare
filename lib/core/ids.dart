import 'package:uuid/uuid.dart';

/// Generates stable, collision-resistant identifiers for domain entities.
///
/// FairShare uses random UUID v4 strings as primary keys so that groups can be
/// exported, imported, and merged across devices without coordination.
class Ids {
  Ids._();

  static const Uuid _uuid = Uuid();

  static String next() => _uuid.v4();
}
