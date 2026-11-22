import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked image into the app documents directory (picker files are
/// temporary) and returns the persistent path.
Future<String> savePhoto(XFile image, {required String prefix}) async {
  final appDir = await getApplicationDocumentsDirectory();
  final photosDir = Directory(p.join(appDir.path, 'cat_photos'));
  await photosDir.create(recursive: true);
  final dest = p.join(
    photosDir.path,
    '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await File(image.path).copy(dest);
  return dest;
}

/// Best-effort removal of a stored photo; a missing file is not an error.
Future<void> deletePhoto(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    await File(path).delete();
  } on FileSystemException catch (_) {}
}
