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

      final tempDir = await getTemporaryDirectory();

      final tempFile = File('${tempDir.path}/$fileName');
      
      await tempFile.writeAsBytes(bytes, flush: true);
      
      return await OpenFile.open(tempFile.path);
      
    } catch (err) {
      return OpenResult(
        type: ResultType.error,
        message: 'An error occurred while opening the file.',
      );
    }
    
  }

}