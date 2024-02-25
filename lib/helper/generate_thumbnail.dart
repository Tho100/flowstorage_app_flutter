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

    final getFileType = fileName.lastIndexOf(".");
    final setupThumbnailName = fileName.replaceRange(getFileType, fileName.length, ".jpeg");

    final appDocDir = await getApplicationDocumentsDirectory();
    final thumbnailPath = '${appDocDir.path}/$setupThumbnailName';

    final tempDir = await getTemporaryDirectory();
    final tempThumbnailPath = '${tempDir.path}/$setupThumbnailName';

    final thumbnailFile = File(tempThumbnailPath);

    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      quality: 20,
    );

    await thumbnailFile.writeAsBytes(thumbnailBytes!);

    await thumbnailFile.copy(thumbnailPath);

    return [thumbnailBytes, thumbnailFile];
    
  }

}