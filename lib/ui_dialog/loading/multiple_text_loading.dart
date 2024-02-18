import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MultipleTextLoading {

  late String title;
  late String fileName;
  late BuildContext context;
  
  Future<void> startLoading({
    required String title,
    required String fileName,
    required BuildContext context
  }) {

    this.title = title;
    this.fileName = fileName;
    this.context = context;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => buildLoadingDialog(context),
    );
  }

  final storageData = GetIt.instance<StorageDataProvider>();

  void stopLoading() {
    Navigator.pop(context);
  }

  AlertDialog buildLoadingDialog(BuildContext context) {
    
    const backgroundColor = ThemeColor.darkGrey;
    const color = ThemeColor.darkPurple;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      backgroundColor: backgroundColor,
      content: SizedBox(
        width: MediaQuery.of(context).size.width*4,
        height: 110,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(color: color),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(
                        width: Globals.generalFileTypes.contains(fileName) 
                          ? 38 : 45,
                        height: Globals.generalFileTypes.contains(fileName) 
                          ? 38 : 45,
                        fit: BoxFit.cover, 
                        image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                      ), 
                    ),

                    if(Globals.videoType.contains(fileName.split('.').last))
                    const Padding(
                      padding: EdgeInsets.only(top: 22.0, left: 24.0),
                      child: VideoPlaceholderWidget(),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Text(" | ",
                  style: TextStyle(
                    color: ThemeColor.lightGrey,
                    fontSize: 25
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: ThemeColor.darkRed,
                    ),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );

  }

}