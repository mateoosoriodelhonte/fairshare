import 'dart:convert';

import 'package:file_selector/file_selector.dart';

/// The only place FairShare touches files outside its own database. Every
/// read and write goes through a user-driven open/save dialog; nothing is
/// written anywhere the user did not choose.
abstract class FileGateway {
  /// Lets the user pick a JSON file. Returns its text, or null if cancelled.
  Future<String?> pickJsonFile();

  /// Lets the user choose where to save [contents]. Returns the chosen path,
  /// or null if cancelled.
  Future<String?> saveTextFile({required String suggestedName, required String contents, required String mimeType});
}

class FileSelectorGateway implements FileGateway {
  const FileSelectorGateway();

  static const XTypeGroup _json = XTypeGroup(
    label: 'FairShare JSON',
    extensions: ['json'],
    mimeTypes: ['application/json'],
  );

  @override
  Future<String?> pickJsonFile() async {
    final file = await openFile(acceptedTypeGroups: const [_json]);
    if (file == null) return null;
    return file.readAsString();
  }

  @override
  Future<String?> saveTextFile({
    required String suggestedName,
    required String contents,
    required String mimeType,
  }) async {
    final extension = suggestedName.contains('.') ? suggestedName.split('.').last : 'txt';
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: extension.toUpperCase(), extensions: [extension], mimeTypes: [mimeType]),
      ],
    );
    if (location == null) return null;
    final file = XFile.fromData(utf8.encode(contents), mimeType: mimeType, name: suggestedName);
    await file.saveTo(location.path);
    return location.path;
  }
}
