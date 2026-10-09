import 'package:fairshare/io/file_gateway.dart';

/// In-memory stand-in for the open/save dialogs.
class FakeFileGateway implements FileGateway {
  /// Text returned by the next "open" dialog; null simulates cancel.
  String? nextPickedJson;

  /// When false, the next "save" dialog is cancelled.
  bool acceptSaves = true;

  final List<SavedFile> saved = [];

  @override
  Future<String?> pickJsonFile() async {
    final text = nextPickedJson;
    nextPickedJson = null;
    return text;
  }

  @override
  Future<String?> saveTextFile({
    required String suggestedName,
    required String contents,
    required String mimeType,
  }) async {
    if (!acceptSaves) return null;
    saved.add(SavedFile(suggestedName, contents, mimeType));
    return '/fake/$suggestedName';
  }
}

class SavedFile {
  const SavedFile(this.name, this.contents, this.mimeType);

  final String name;
  final String contents;
  final String mimeType;
}
