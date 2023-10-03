import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker_plus/image_picker_plus.dart';

class PickerModel {

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<SelectedImagesDetails?> galleryPicker({required ImageSource source}) async {

    try {

      final maxUpload = AccountPlan.mapFilesUpload[userData.accountType];
      final currentUpload = storageData.fileNamesFilteredList.length;

      final maximumSelections = maxUpload!-currentUpload;

      ImagePickerPlus picker = ImagePickerPlus(navigatorKey.currentContext!);
      SelectedImagesDetails? details = await picker.pickBoth(
        source: source,
        multiSelection: true,
        galleryDisplaySettings: GalleryDisplaySettings(
          tabsTexts: TabsTexts(
              videoText: "", 
              photoText: "", 
              noImagesFounded: "Gallery is empty",
              acceptAllPermissions: "Permission denied", 
              clearImagesText: "Clear selections"
            ),
          maximumSelection: maximumSelections,
          appTheme: AppTheme(
            focusColor: ThemeColor.justWhite,
            primaryColor: ThemeColor.darkBlack,
          ),
        ),
      );

      return details!;

    } catch (err) {
      return null;
    }
  }

  Future<FilePickerResult?> filePicker() async {

    try {

      const List<String> nonOfflineFileTypes = [...Globals.imageType, ...Globals.audioType, ...Globals.videoType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];
      const List<String> offlineFileTypes = [...Globals.audioType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf","apk","exe"];

      final tempData = GetIt.instance<TempDataProvider>();

      final picker = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: tempData.origin == OriginFile.offline 
          ? offlineFileTypes : nonOfflineFileTypes,
        allowMultiple: tempData.origin == OriginFile.public 
          ? false : true
      );

      return picker;

    } catch (err) {
      return null;
    }
    
  }

}