import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker_plus/image_picker_plus.dart';

class PickerModel {

  Future<SelectedImagesDetails> galleryPicker() async {

    ImagePickerPlus picker = ImagePickerPlus(navigatorKey.currentContext!);
    SelectedImagesDetails? details = await picker.pickBoth(
      source: ImageSource.both,
      multiSelection: true,
      galleryDisplaySettings: GalleryDisplaySettings(
        maximumSelection: 100,
        appTheme: AppTheme(
          focusColor: Colors.white, 
          primaryColor: ThemeColor.darkBlack,
        ),
      ),
    );

    return details!;

  }

  Future<FilePickerResult?> filePicker() async {
    
    const List<String> nonOfflineFileTypes = [...Globals.imageType, ...Globals.audioType, ...Globals.videoType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];
    const List<String> offlineFileTypes = [...Globals.audioType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];

    final tempData = GetIt.instance<TempDataProvider>();

    final picker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: tempData.origin == OriginFile.offline ? offlineFileTypes : nonOfflineFileTypes,
      allowMultiple: tempData.origin == OriginFile.public ? false : true
    );

    return picker!;

  }

}