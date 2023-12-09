import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ExternalApp {

  final String fileName;
  final Uint8List bytes;

  ExternalApp({
    required this.fileName,
    required this.bytes
  });

  Future<OpenResult> openFileInExternalApp() async {

    try {

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File tempFile = File('$tempPath/$fileName');
      
      await tempFile.writeAsBytes(bytes, flush: true);

      String filePath = tempFile.path;
      
      final result = await OpenFile.open(filePath);

      return result;
      
    } catch (err) {
      return OpenResult(
        type: ResultType.error,
        message: 'An error occurred while opening the file.',
      );
    }

  }

}