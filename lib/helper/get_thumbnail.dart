import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as path;

class GetThumbnail {

  final String videoPath;

  GetThumbnail({required this.videoPath});

  Future<String> getVideoThumbnail() async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String thumbnailPath = '${appDocDir.path}/${path.basename(videoPath)}.jpg';

    Directory tempDir = await getTemporaryDirectory();
    String tempThumbnailPath = '${tempDir.path}/${path.basename(videoPath)}.jpg';

    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 40,
    );

    File thumbnailFile = File(tempThumbnailPath);
    await thumbnailFile.writeAsBytes(thumbnailBytes!);

    await thumbnailFile.copy(thumbnailPath);

    return thumbnailPath;
  }
}