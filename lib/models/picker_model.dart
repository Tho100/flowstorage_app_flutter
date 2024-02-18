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

  Future<SelectedImagesDetails?> galleryPicker({
    required ImageSource source,
    required bool isFromSelectProfilePic,
  }) async {

    try {

      final maxUpload = AccountPlan.mapFilesUpload[userData.accountType];
      final currentUpload = storageData.fileNamesFilteredList.length;
      final maximumSelections = maxUpload! - currentUpload;

      final picker = ImagePickerPlus(navigatorKey.currentContext!);

      return isFromSelectProfilePic
      ? await picker.pickImage(
          source: source,
          multiImages: false,
          galleryDisplaySettings: _buildGalleryDisplaySettings(maximumSelections, true),
        )
      : await picker.pickBoth(
          source: source,
          multiSelection: true,
          galleryDisplaySettings: _buildGalleryDisplaySettings(maximumSelections, false),
        );
        
    } catch (err) {
      return null;
    }

  }

  GalleryDisplaySettings _buildGalleryDisplaySettings(int maximumSelections, bool showImagePreview) {
    return GalleryDisplaySettings(
      showImagePreview: showImagePreview,
      tabsTexts: TabsTexts(
        videoText: "",
        photoText: "",
        noImagesFounded: "Gallery is empty",
        acceptAllPermissions: "Permission denied",
        clearImagesText: "Clear selections",
      ),
      maximumSelection: maximumSelections,
      appTheme: AppTheme(
        focusColor: ThemeColor.justWhite,
        primaryColor: ThemeColor.darkBlack,
      ),
    );
  }


  Future<FilePickerResult?> filePicker() async {

    try {

      final tempData = GetIt.instance<TempDataProvider>();

      const List<String> nonOfflineFileTypes = [...Globals.imageType, ...Globals.audioType, ...Globals.videoType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf", "apk", "exe"];
      const List<String> offlineFileTypes = [...Globals.imageType,...Globals.audioType,...Globals.excelType,...Globals.textType,...Globals.wordType, ...Globals.ptxType, "pdf", "apk", "exe"];

      return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: tempData.origin == OriginFile.offline 
          ? offlineFileTypes : nonOfflineFileTypes,
        allowMultiple: tempData.origin != OriginFile.public 
      );

    } catch (err) {
      return null;
    }
    
  }

}