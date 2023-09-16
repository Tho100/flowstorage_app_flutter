import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class GenerateThumbnail {

  final String fileName;
  final String filePath;

  GenerateThumbnail({
    required this.fileName,
    required this.filePath
  });

  Future<List<dynamic>> generate() async {
    String setupThumbnailName = fileName.replaceRange(fileName.lastIndexOf("."), fileName.length, ".jpeg");

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

    Directory tempDir = await getTemporaryDirectory();
    String tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

    File thumbnailFile = File(tempThumbnailPath);
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      quality: 40,
    );

    await thumbnailFile.writeAsBytes(thumbnailBytes!);

    await thumbnailFile.copy(thumbnailPath);

    return [thumbnailBytes, thumbnailFile];
  }

}