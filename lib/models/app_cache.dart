import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppCache {

  Future<double> cacheSizeInMb() async {
    return await _getCacheSize() / (1024 * 1024);
  }

  Future<int> _getCacheSize() async {

    final tempDir = await getTemporaryDirectory();
    final tempDirSize = _processCacheSize(tempDir);

    return tempDirSize;

  }

  int _processCacheSize(FileSystemEntity file) {

    if (file is File) {
      return file.lengthSync();

    } else if (file is Directory) {
      int sum = 0;

      final children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _processCacheSize(child);
      }

      return sum;

    }
    
    return 0;

  }

}