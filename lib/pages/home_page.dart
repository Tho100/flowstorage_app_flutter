
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/directory_query/save_directory.dart';
import 'package:flowstorage_fsc/folder_query/save_folder.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/date_short_form.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/date_parser.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/helper/generate_thumbnail.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/scanner_pdf.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/interact_dialog/create_directory_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_selection_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_folder_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/upgrade_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/picker_model.dart';
import 'package:flowstorage_fsc/models/update_list_view.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/interact_dialog/sharing_dialog/share_file_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_add_item.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/upload_ps_dialog.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_filter.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_folder.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_selected_items.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_shared.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/bottom_trailing_sorting.dart';
import 'package:flowstorage_fsc/widgets/checkbox_item.dart';
import 'package:flowstorage_fsc/widgets/empty_body.dart';
import 'package:flowstorage_fsc/widgets/navigation_bar.dart';
import 'package:flowstorage_fsc/widgets/navigation_buttons.dart';
import 'package:flowstorage_fsc/widgets/responsive_list_view.dart';
import 'package:flowstorage_fsc/widgets/responsive_search_bar.dart';
import 'package:flowstorage_fsc/widgets/sidebar_menu.dart';
import 'package:flowstorage_fsc/interact_dialog/folder_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';
import 'package:flowstorage_fsc/widgets/staggered_list_view.dart/default_list_view.dart';
import 'package:flowstorage_fsc/widgets/staggered_list_view.dart/photos_list_view.dart';
import 'package:flowstorage_fsc/widgets/staggered_list_view.dart/ps_list_view.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker_plus/image_picker_plus.dart';

import 'package:flowstorage_fsc/directory_query/delete_directory.dart';
import 'package:flowstorage_fsc/directory_query/rename_directory.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/folder_query/delete_folder.dart';
import 'package:flowstorage_fsc/folder_query/rename_folder.dart';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';

import 'package:flowstorage_fsc/directory_query/create_directory.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/extra_query/delete_data.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/extra_query/rename_data.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';

class HomePage extends State<Mainboard> with AutomaticKeepAliveClientMixin { 

  final _locator = GetIt.instance;

  late final UserDataProvider userData;
  late final StorageDataProvider storageData;
  late final PsStorageDataProvider psStorageData;
  late final PsUploadDataProvider psUploadData;
  late final TempDataProvider tempData;

  late List<bool> checkedList = [];

  final fileNameGetterHome = NameGetter();
  final dataGetterHome = DataRetriever();
  final dateGetterHome = DateGetter();
  final retrieveData = RetrieveData();
  final insertData = InsertData();
  final dataCaller = DataCaller();
  final updateListView = UpdateListView();
  final deleteData = DeleteData();

  final crud = Crud();
  final logger = Logger();

  final sidebarMenuScaffoldKey = GlobalKey<ScaffoldState>();

  final scrollListViewController = ScrollController();

  final searchBarFocusNode = FocusNode();
  final searchBarController = TextEditingController();

  final focusNodeRedudane = FocusNode();
  final searchControllerRedudane = TextEditingController();

  final sortingText = ValueNotifier<String>('Default');
  final searchHintText = ValueNotifier<String>('Search in Flowstorage');

  final psButtonTextNotifier = ValueNotifier<String>('My Files');
  
  final navDirectoryButtonVisible = ValueNotifier<bool>(true);
  final floatingActionButtonVisible = ValueNotifier<bool>(true);

  final staggeredListViewSelected = ValueNotifier<bool>(false);
  final selectAllItemsIsPressedNotifier = ValueNotifier<bool>(false);

  final selectAllItemsIconNotifier = ValueNotifier<IconData>(
                                      Icons.check_box_outline_blank);
  final ascendingDescendingIconNotifier = ValueNotifier<IconData>(
                                      Icons.expand_more);

  final searchBarVisibileNotifier = ValueNotifier<bool>(true);

  bool togglePhotosPressed = false;
  bool editAllIsPressed = false;
  bool itemIsChecked = false;

  Set<int> selectedPhotosIndex = {};
  Set<String> checkedItemsName = {};

  bool isAscendingItemName = false;
  bool isAscendingUploadDate = false;
  
  Timer? debounceSearchingTimer;

  Future<void> _openDialogGallery() async {

    try {

      late String? fileBase64Encoded;

      final shortenText = ShortenText();

      final details = await PickerModel()
                        .galleryPicker(source: ImageSource.both);
      
      if(details == null) {
        return;
      }

      int countSelectedFiles = details.selectedFiles.length;

      if (countSelectedFiles == 0) {
        return;
      }

      if (!mounted) return; 
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      if(storageData.fileNamesList.length + countSelectedFiles > AccountPlan.mapFilesUpload[userData.accountType]!) {
        _showUpgradeExceededDialog();
        return;
        
      }

      if(tempData.origin != OriginFile.public) {
        await CallNotify()
          .uploadingNotification(numberOfFiles: countSelectedFiles);
      }

      if(countSelectedFiles > 2) {
        SnakeAlert.uploadingSnake(
          snackState: scaffoldMessenger, 
          message: "Uploading $countSelectedFiles item(s)...");
      }

      for(var filesPath in details.selectedFiles) {

        final pathToString = filesPath.selectedFile.toString().
                              split(" ").last.replaceAll("'", "");
        
        final filesName = pathToString.split("/").last.replaceAll("'", "");
        final fileExtension = filesName.split('.').last;

        if (!Globals.supportedFileTypes.contains(fileExtension)) {
          CustomFormDialog.startDialog("Couldn't upload $filesName","File type is not supported.");
          await NotificationApi.stopNotification(0);
          continue;
        }

        if (storageData.fileNamesList.contains(filesName)) {
          CustomFormDialog.startDialog("Upload Failed", "$filesName already exists.");
          await NotificationApi.stopNotification(0);
          continue;
        } 

        if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
          SnakeAlert.uploadingSnake(
            snackState: scaffoldMessenger, 
            message: "Uploading ${shortenText.cutText(filesName)}"); 
        }

        if (!(Globals.imageType.contains(fileExtension))) {
          fileBase64Encoded = base64.encode(File(pathToString).readAsBytesSync());
        } else {
          final filesBytes = File(pathToString).readAsBytesSync();
          fileBase64Encoded = base64.encode(filesBytes);
        }

        if (Globals.imageType.contains(fileExtension)) {

          List<int> bytes = await CompressorApi.compressedByteImage(path: pathToString, quality: 85);
          String compressedImageBase64Encoded = base64.encode(bytes);

          if(tempData.origin == OriginFile.public) {
            _openPsCommentDialog(filePathVal: pathToString, fileName: filesName, tableName: GlobalsTable.psImage, base64Encoded: fileBase64Encoded);
            return;
          }

          await UpdateListView().processUpdateListView(filePathVal: pathToString, selectedFileName: filesName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

        } else if (Globals.videoType.contains(fileExtension)) {

          final generatedThumbnail = await GenerateThumbnail(
            fileName: filesName, 
            filePath: pathToString
          ).generate();

          final thumbnailBytes = generatedThumbnail[0] as Uint8List;
          final thumbnailFile = generatedThumbnail[1] as File;

          if(tempData.origin == OriginFile.public) {

            _openPsCommentDialog(
              filePathVal: pathToString, fileName: filesName, 
              tableName: GlobalsTable.psVideo, base64Encoded: fileBase64Encoded,
              thumbnail: thumbnailBytes
            );

            return;
          } 

          await UpdateListView().processUpdateListView(
            filePathVal: pathToString, 
            selectedFileName: filesName, 
            tableName: GlobalsTable.homeVideo, 
            fileBase64Encoded: fileBase64Encoded,
            newFileToDisplay: thumbnailFile,
            thumbnailBytes: thumbnailBytes
          );

          await thumbnailFile.delete();

        }

        UpdateListView().addItemToListView(fileName: filesName);

        scaffoldMessenger.hideCurrentSnackBar();

        if(countSelectedFiles < 2) {

          SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(filesName)} Has been added.");
          countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

        }

      }

      await NotificationApi.stopNotification(0);

      if(countSelectedFiles >= 2) {

        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${countSelectedFiles.toString()} Items has been added");
        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

      }

      _itemSearchingImplementation('');

      final storageUsagePercentage = await _getStorageUsagePercentage();
      if(storageUsagePercentage > 70) {
        _callStorageUsageWarning();
      }

    } catch (err, st) {
      logger.e('Exception from _openDialogGallery {main}',err,st);
      SnakeAlert.errorSnake("Upload failed.");
    }
  }

  Future<void> _openDialogFile() async {

    try {

        late String? fileBase64;
        late File? newFileToDisplayPath;

        final shortenText = ShortenText();

        final resultPicker = await PickerModel().filePicker();
        if (resultPicker == null) {
          return;
        }

        if(!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        int countSelectedFiles = resultPicker.files.length;

        final uploadedPsFilesCount = psStorageData.psUploaderList.where((name) => name == userData.username).length;
        final allowedFileUploads = AccountPlan.mapFilesUpload[userData.accountType]!;

        if (tempData.origin == OriginFile.public && uploadedPsFilesCount > allowedFileUploads) {
          _showUpgradeExceededDialog();
          return;

        } else if (tempData.origin != OriginFile.public && storageData.fileNamesList.length + countSelectedFiles > allowedFileUploads) {
          _showUpgradeExceededDialog();
          return;
          
        }

        if(tempData.origin != OriginFile.public) {
          await CallNotify()
            .uploadingNotification(numberOfFiles: countSelectedFiles);
        }

        if(countSelectedFiles > 2) {
          SnakeAlert.uploadingSnake(
            snackState: scaffoldMessenger, 
            message: "Uploading $countSelectedFiles item(s)..."
          );
        } 

        for (final pickedFile in resultPicker.files) {

          final selectedFileName = pickedFile.name;
          final fileExtension = selectedFileName.split('.').last;

          if (!Globals.supportedFileTypes.contains(fileExtension)) {
            CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported.");
            await NotificationApi.stopNotification(0);

            if(tempData.origin == OriginFile.public) 
            { return; } else { continue; }

          }

          if (storageData.fileNamesList.contains(selectedFileName)) {
            CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.");
            await NotificationApi.stopNotification(0);

            if(tempData.origin == OriginFile.public) 
            { return; } else { continue; }

          }

          if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
            SnakeAlert.uploadingSnake(
              snackState: scaffoldMessenger, 
              message: "Uploading ${shortenText.cutText(selectedFileName)}"
            ) ;

          }

          final filePathVal = pickedFile.path.toString();

          if (!(Globals.imageType.contains(fileExtension))) {
            fileBase64 = base64.encode(File(filePathVal).readAsBytesSync());
          }

          if (Globals.imageType.contains(fileExtension)) {

            List<int> bytes = await CompressorApi.compressedByteImage(path: filePathVal,quality: 85);
            String compressedImageBase64Encoded = base64.encode(bytes);

            if(tempData.origin == OriginFile.public) {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: GlobalsTable.psImage, base64Encoded: compressedImageBase64Encoded);
              return;
            }

            await UpdateListView().processUpdateListView(
              filePathVal: filePathVal, 
              selectedFileName: selectedFileName, 
              tableName: GlobalsTable.homeImage, 
              fileBase64Encoded: compressedImageBase64Encoded
            );

          } else if (Globals.videoType.contains(fileExtension)) {

            final generatedThumbnail = await GenerateThumbnail(
              fileName: selectedFileName, 
              filePath: filePathVal
            ).generate();

            final thumbnailBytes = generatedThumbnail[0] as Uint8List;
            final thumbnailFile = generatedThumbnail[1] as File;

            newFileToDisplayPath = thumbnailFile;

            if(tempData.origin == OriginFile.public) {

              _openPsCommentDialog(
                filePathVal: filePathVal, fileName: selectedFileName, 
                tableName: GlobalsTable.psVideo, base64Encoded: fileBase64!,
                newFileToDisplay: newFileToDisplayPath, thumbnail: thumbnailBytes
              );

              return;

            }

            await UpdateListView().processUpdateListView(
              filePathVal: filePathVal, selectedFileName: selectedFileName, 
              tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64!, 
              newFileToDisplay: newFileToDisplayPath, thumbnailBytes: thumbnailBytes
            );

            await thumbnailFile.delete();

          } else {

            final getFileTable = tempData.origin == OriginFile.home 
              ? Globals.fileTypesToTableNames[fileExtension]! 
              : Globals.fileTypesToTableNamesPs[fileExtension]!;

            newFileToDisplayPath = await GetAssets().loadAssetsFile(Globals.fileTypeToAssets[fileExtension]!);

            if(tempData.origin == OriginFile.public) {
              _openPsCommentDialog(filePathVal: filePathVal, fileName: selectedFileName, tableName: getFileTable, base64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
              return;
            }

            await UpdateListView().processUpdateListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: getFileTable,fileBase64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
          }

          UpdateListView().addItemToListView(fileName: selectedFileName);

          scaffoldMessenger.hideCurrentSnackBar();

          if(countSelectedFiles < 2) {
            SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(selectedFileName)} Has been added");
          }

        }

      if(countSelectedFiles > 2) {
        SnakeAlert.temporarySnake(
          snackState: scaffoldMessenger, 
          message: "${countSelectedFiles.toString()} Items has been added"
        );
      }

      await NotificationApi.stopNotification(0);

      if(countSelectedFiles > 0) {
        await CallNotify().uploadedNotification(title: "Upload Finished",count: countSelectedFiles);
      }

      _itemSearchingImplementation('');

      final storageUsagePercentage = await _getStorageUsagePercentage();
      if(storageUsagePercentage > 70) {
        _callStorageUsageWarning();
      }

    } catch (err, st) {
      logger.e('Exception from _openDialogFile {main}', err,st);
      SnakeAlert.errorSnake("Upload failed.");
    }
  }

  Future<void> _openDialogFolder() async {

    try {

      final folderPath = await FilePicker.platform.getDirectoryPath();

      if (folderPath == null) {
        return;
      }

      final folderName = path.basename(folderPath);

      if (storageData.foldersNameList.contains(folderName)) {
        CustomFormDialog.startDialog("Upload Failed", "$folderName already exists.");
        return;
      }

      await CallNotify().customNotification(title: "Uploading folder...", subMesssage: "${ShortenText().cutText(folderName)} In progress");

      if(!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Uploading $folderName folder..."),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      final files = Directory(folderPath).listSync().whereType<File>().toList();

      if(files.length == AccountPlan.mapFilesUpload[userData.accountType]) {
        CustomFormDialog.startDialog("Couldn't upload $folderName", "It looks like the number of files in this folder exceeded the number of file you can upload. Please upgrade your account plan.");
        return;
      }

      await UpdateListView().insertFileDataFolder(
        folderPath: folderPath, 
        folderName: folderName, 
        files: files
      );

      await NotificationApi.stopNotification(0);

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Folder $folderName has been added"),
          duration: const Duration(seconds: 2),
          backgroundColor: ThemeColor.mediumGrey,
        ),
      );

      await CallNotify().customNotification(title: "Folder Uploaded", subMesssage: "$folderName Has been added");

    } catch (err, st) {
      logger.e('Exception from _openDialogFolder {main}',err,st);
      SnakeAlert.errorSnake("Upload failed.");
    }
  }

  void _openPsCommentDialog({
    required String filePathVal,
    required String fileName,
    required String tableName,
    required String base64Encoded,
    File? newFileToDisplay,
    dynamic thumbnail,
  }) async {

    await NotificationApi.stopNotification(0);

    late String? imagePreview = "";

    final fileType = fileName.split('.').last;
    if(Globals.imageType.contains(fileType)) {
      imagePreview = base64Encoded;
    } else if (Globals.videoType.contains(fileType)) {
      imagePreview = base64.encode(thumbnail);
    } 

    if(!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await PsCommentDialog().buildPsCommentDialog(
      fileName: fileName,
      onUploadPressed: () async { 
        
        SnakeAlert.uploadingSnake(
          snackState: scaffoldMessenger, 
          message: "Uploading ${ShortenText().cutText(fileName)}"
        );

        await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress");

        await UpdateListView().processUpdateListView(
          filePathVal: filePathVal, selectedFileName: fileName,
          tableName: tableName, fileBase64Encoded: base64Encoded, 
          newFileToDisplay: newFileToDisplay, thumbnailBytes: thumbnail
        );

        psStorageData.psTitleList.add(psUploadData.psTitleValue);
        psStorageData.psTagsList.add(psUploadData.psTagValue);
        psStorageData.psUploaderList.add(userData.username);

        scaffoldMessenger.hideCurrentSnackBar();

        UpdateListView().addItemToListView(fileName: fileName);
        _scrollEndListView();

        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${ShortenText().cutText(fileName)} Has been added");
        await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

      },
      context: context,
      imageBase64Encoded: imagePreview
    );

    await NotificationApi.stopNotification(0);

  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog( 
      fileName: fileName, 
      onDeletePressed:() async => await _onDeletePressed(fileName, storageData.fileNamesList, storageData.fileNamesFilteredList, storageData.imageBytesList, _itemSearchingImplementation),
      context: context
    );
  }

  void _openRenameDialog(String fileName) {
     RenameDialog().buildRenameFileDialog(
      fileName: fileName, 
      onRenamePressed: () => _onRenamePressed(fileName), 
      context: context
    );
  }

  void _openSharingDialog(String fileName) {
    SharingDialog().buildSharingDialog(
      fileName: fileName, 
      context: context
    );
  }

  void _openRenameFolderDialog(String folderName) {
    RenameFolderDialog().buildRenameFolderDialog(
      context: context, 
      folderName: folderName, 
      renameFolderOnPressed: () async {

        final newFolderName = RenameFolderDialog.folderRenameController.text;

        if (storageData.foldersNameList.contains(newFolderName)) {
          CallToast.call(message: "Folder with this name already exists.");
          RenameFolderDialog.folderRenameController.clear();
          return;

        } 

        if (newFolderName.isNotEmpty) {
          await _renameFolder(folderName, newFolderName);
          RenameFolderDialog.folderRenameController.clear();

        } else {
          CallToast.call(message: "Folder name cannot be empty.");
          return;

        }

      }
    );
  }

  void _openCreateDirectoryDialog() {
    CreateDirectoryDialog().buildCreateDirectoryDialog(
      context: context, 
      createOnPressed: () async {
        
        final getDirectoryTitle = CreateDirectoryDialog.directoryNameController.text.trim();

        if(getDirectoryTitle.isEmpty) {
          return;
        }

        if(storageData.fileNamesList.contains(getDirectoryTitle)) {
          CallToast.call(message: "Directory with this name already exists.");
          return;
        }

        await _buildDirectory(getDirectoryTitle);
        CreateDirectoryDialog.directoryNameController.clear();

      }

    );
  }

  void _openDeleteSelectionDialog() {

    DeleteSelectionDialog().buildDeleteSelectionDialog(
      context: context, 
      appBarTitle: tempData.appBarTitle, 
      deleteOnPressed: () async {
         
        final countSelectedItems = togglePhotosPressed
          ? checkedItemsName.length
          : checkedList.where((item) => item == true).length;
        
        final loadingDialog = SingleTextLoading();
        loadingDialog.startLoading(title: "Deleting...",context: context);

        await _processDeletingAllItems(count: countSelectedItems);

        loadingDialog.stopLoading();

      }
    );
  }

  void _clearPublicStorageData({required bool clearImage}) {
    if(clearImage) {
      psStorageData.psImageBytesList.clear();
      psStorageData.psThumbnailBytesList.clear();
    }
    psStorageData.psUploaderList.clear();
    psStorageData.psTagsList.clear();
    psStorageData.psTitleList.clear();
    psStorageData.psTagsColorList.clear();
  }

  void _clearGlobalData() {
    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.fileDateFilteredList.clear();
    storageData.imageBytesFilteredList.clear();
    storageData.imageBytesList.clear();
  }

  void _togglePhotos() async {

    togglePhotosPressed = !togglePhotosPressed;

    if (togglePhotosPressed) {
      _activatePhotosView();
    } else {
      _deactivatePhotosView();
    }

    if (tempData.origin == OriginFile.public) {
      _clearPublicStorageData(clearImage: true);
      _returnBackHomeFiles();
      await _refreshListView();
    }
  }

  void _activatePhotosView() {

    tempData.setAppBarTitle("Photos");
    searchBarVisibileNotifier.value = false;
    staggeredListViewSelected.value = true;

    _navDirectoryButtonVisibility(false);
    _floatingButtonVisibility(true);

    _itemSearchingImplementation('.png,.jpg,.jpeg,.mp4,.mov,.wmv');
  }

  void _deactivatePhotosView() {

    tempData.setAppBarTitle(Globals.originToName[tempData.origin]!);
    searchBarVisibileNotifier.value = true;
    staggeredListViewSelected.value = false;
    selectedPhotosIndex.clear();

    if (tempData.origin == OriginFile.home || tempData.origin == OriginFile.directory) {
      _floatingButtonVisibility(true);
      _navDirectoryButtonVisibility(true);
    }

    _itemSearchingImplementation('');

  }

  void _togglePublicStorage() async {
    
    if(tempData.origin == OriginFile.public) {
      return;
    }

    if(togglePhotosPressed) {
      togglePhotosPressed = false;
    }

    await _refreshPublicStorage();
  
  }

  void _toggleHome() async {

    if (tempData.origin == OriginFile.home && !togglePhotosPressed) {
      return;
    }

    if (tempData.origin == OriginFile.public) {
      _clearPublicStorageData(clearImage: false);
    }

    if (tempData.origin == OriginFile.home && togglePhotosPressed) {
      _returnBackHomeFiles();
    } else {
      _returnBackHomeFiles();
      await _refreshListView();
    }

    _navDirectoryButtonVisibility(true);
    _floatingButtonVisibility(true);

    togglePhotosPressed = false;
    searchBarVisibileNotifier.value = true;
    staggeredListViewSelected.value = false;

    searchHintText.value = "Search in Flowstorage";

    tempData.setAppBarTitle("Home");
    tempData.setOrigin(OriginFile.home);
    
    _itemSearchingImplementation('');

  }

  Future<void> _sortDataDescendingPs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sortUploadDate();
    _sortUploadDate();
  }

  Future<void> _refreshPublicStorage() async {
    await _callPublicStorageData(); 
    await _sortDataDescendingPs();
    _floatingButtonVisibility(true);
  }

  void _scrollEndListView() {
    scrollListViewController.animateTo(
      scrollListViewController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _clearSelectAll() {

    if(togglePhotosPressed == false) {
      tempData.setAppBarTitle(Globals.originToName[tempData.origin]!);
    } else {
      tempData.setAppBarTitle("Photos");
    }

    setState(() {
      itemIsChecked = false;
      editAllIsPressed = false;
    });

    selectAllItemsIsPressedNotifier.value = false;
    selectedPhotosIndex.clear();
    checkedItemsName.clear();
  }

  Future<void> _selectDirectoryMultipleSave(int count) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      await _callMultipleFilesDownload(count: count, directoryPath: directoryPath);
    } else {
      return;
    }
  }

  Future<void> _callMultipleFilesDownload({
    required int count,
    required String directoryPath
  }) async {

    try {

      final loadingDialog = SingleTextLoading();      
      loadingDialog.startLoading(title: "Saving...", context: context);

      for(int i=0; i<count; i++) {

        late Uint8List getBytes;

        final fileType = checkedItemsName.elementAt(i).split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        if(Globals.imageType.contains(fileType)) {
          final fileIndex = storageData.fileNamesFilteredList.indexOf(checkedItemsName.elementAt(i));
          getBytes = storageData.imageBytesFilteredList.elementAt(fileIndex)!;
        } else {
          getBytes = await _callData(checkedItemsName.elementAt(i),tableName!);
        }

        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: checkedItemsName.elementAt(i), fileData: getBytes);

      }

      loadingDialog.stopLoading();

      SnakeAlert.okSnake(message: "$count item(s) has been saved.",icon: Icons.check);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save files.");
    }

  }

  Future<void> _processSaveOfflineFileSelectAll({required int count}) async {

    try {

      final offlineMode = OfflineMode();

      final singleLoading = SingleTextLoading();
      singleLoading.startLoading(title: "Preparing...", context: context);

      for(int i=0; i<count; i++) {
        
        late final Uint8List fileData;

        final fileType = checkedItemsName.elementAt(i).split('.').last;

        if(Globals.supportedFileTypes.contains(fileType)) {

          final tableName = Globals.fileTypesToTableNames[fileType]!;

          if(Globals.imageType.contains(fileType)) {
            fileData = storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexOf(checkedItemsName.elementAt(i))]!;
          } else {
            fileData = await _callData(checkedItemsName.elementAt(i), tableName);
          }

          await offlineMode.saveOfflineFile(
            fileName: checkedItemsName.elementAt(i), 
            fileData: fileData
          );

        } 

      }

      singleLoading.stopLoading();

      SnakeAlert.okSnake(message: "$count Item(s) now available offline.",icon: Icons.check);

      _clearSelectAll();

    } catch (err) {
      SnakeAlert.errorSnake("An error occurred.");
    }
  }

  String _formatDateTime(DateTime dateTime) {

    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    final adjustedDateTime = difference.isNegative ? dateTime.add(const Duration(days: 1)) : dateTime;
    final adjustedDifference = adjustedDateTime.difference(now).inDays.abs();

    if (adjustedDifference == 0) {
      return '0 days ago ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    } else {
      final daysAgoText = '$adjustedDifference days ago';
      return '$daysAgoText ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
    }
  }

  void _sortUploadDate() {
    isAscendingUploadDate = !isAscendingUploadDate;
    ascendingDescendingIconNotifier.value = isAscendingUploadDate ? Icons.expand_less : Icons.expand_more;
    sortingText.value = tempData.origin == OriginFile.public 
      ? "Default" : "Upload Date";

    _processUploadDateSorting();
  }

  void _sortItemName() {
    isAscendingItemName = !isAscendingItemName;
    ascendingDescendingIconNotifier.value = isAscendingItemName ? Icons.expand_less : Icons.expand_more;
    sortingText.value = "Item Name";
    _processfileNameSorting();
  }

  void _sortDefault() async {
    sortingText.value = "Default";
    isAscendingItemName = false;
    isAscendingUploadDate = false;
    ascendingDescendingIconNotifier.value = Icons.expand_more;
    await _refreshListView();
  }

  void _processUploadDateSorting() {

    final dateParser = DateParser();

    List<Map<String, dynamic>> itemList = [];

    if(tempData.origin != OriginFile.public) {

      for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
        itemList.add({
          'file_name': storageData.fileNamesFilteredList[i],
          'image_byte': storageData.imageBytesFilteredList[i],
          'upload_date': dateParser.parseDate(storageData.fileDateFilteredList[i]),
        });
      }

    } else {

      for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
        itemList.add({
          'file_name': storageData.fileNamesFilteredList[i],
          'image_byte': storageData.imageBytesFilteredList[i],
          'upload_date': dateParser.parseDate(storageData.fileDateFilteredList[i]),
          'title': psStorageData.psTitleList[i],
          'tag_value': psStorageData.psTagsList[i],
          'uploader_name': psStorageData.psUploaderList[i]
        });
      }

      psStorageData.psTitleList.clear();
      psStorageData.psTagsList.clear();
      psStorageData.psUploaderList.clear();

    }

    isAscendingUploadDate 
    ? itemList.sort((a, b) => a['upload_date'].compareTo(b['upload_date']))
    : itemList.sort((a, b) => b['upload_date'].compareTo(a['upload_date']));

    setState(() {

      storageData.fileDateFilteredList.clear();
      storageData.fileNamesFilteredList.clear();
      storageData.imageBytesFilteredList.clear();

      for (var item in itemList) {

        storageData.fileNamesFilteredList.add(item['file_name']);
        storageData.imageBytesFilteredList.add(item['image_byte']);
        storageData.fileDateFilteredList.add(_formatDateTime(item['upload_date']));

        if(tempData.origin == OriginFile.public) {
          psStorageData.psTagsList.add(item['tag_value']);
          psStorageData.psUploaderList.add(item['uploader_name']);
          psStorageData.psTitleList.add(item['title']);
        }

      }
    });

    itemList.clear();

  }

  void _processfileNameSorting() {

   List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      itemList.add({
        'file_name': storageData.fileNamesFilteredList[i],
        'image_byte': storageData.imageBytesFilteredList[i],
        'upload_date': storageData.fileDateFilteredList[i],
      });
    }

    isAscendingItemName 
    ? itemList.sort((a, b) => a['file_name'].compareTo(b['file_name']))
    : itemList.sort((a, b) => b['file_name'].compareTo(a['file_name']));

    setState(() {
      storageData.fileNamesFilteredList.clear();
      storageData.imageBytesFilteredList.clear();
      storageData.fileDateFilteredList.clear();
      for (var item in itemList) {
        storageData.fileNamesFilteredList.add(item['file_name']);
        storageData.imageBytesFilteredList.add(item['image_byte']);
        storageData.fileDateFilteredList.add(item['upload_date']);
      }
    });

    itemList.clear();

  }

  Future<void> _initializeCameraScanner() async {

    try {

      final scannerPdf = ScannerPdf();

      final imagePath = await CunningDocumentScanner.getPictures();

      if(imagePath!.isEmpty) {
        return;
      }

      final generateFileName = Generator.generateRandomString(Generator.generateRandomInt(5,15));

      if(tempData.origin != OriginFile.public) {
        await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress") ;
      }

      for(var images in imagePath) {

        File compressedDocImage = await CompressorApi.processImageCompression(path: images,quality: 65); 
        await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
        
      }

      if(!mounted) return;
      await scannerPdf.savePdf(fileName: generateFileName,context: context);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$generateFileName.pdf');

      final toBase64Encoded = base64.encode(file.readAsBytesSync());
      final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.png");

      if(tempData.origin == OriginFile.public) {
        _openPsCommentDialog(filePathVal: file.path, fileName: "$generateFileName.pdf",tableName: GlobalsTable.psImage, base64Encoded: toBase64Encoded, newFileToDisplay: newFileToDisplay);
        return;

      } else {
        await UpdateListView().processUpdateListView(filePathVal: file.path,selectedFileName: "$generateFileName.pdf",tableName: "file_info_pdf", fileBase64Encoded: toBase64Encoded,newFileToDisplay: newFileToDisplay);
        
      }

      UpdateListView().addItemToListView(fileName: "$generateFileName.pdf");

      await file.delete();

      await NotificationApi.stopNotification(0);

      SnakeAlert.okSnake(message: "$generateFileName.pdf Has been added",icon: Icons.check);

      await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

      _itemSearchingImplementation('');

    } catch (err, st) {
      logger.e('Exception from _initializeCameraScanner {main}',err, st);
      SnakeAlert.errorSnake("Failed to start scanner.");
    }
  }

  Future<void> _deleteMultiSelectedFiles({
    required int count
  }) async {

    for (int i = 0; i < count; i++) {
      final fileName = checkedItemsName.elementAt(i);
      await deleteData.deleteOnMultiSelection(fileName: fileName);

      await Future.delayed(const Duration(milliseconds: 855));
      _removeFileFromListView(fileName: fileName, isFromSelectAll: true);

    }

    _clearSelectAll();

  }

  Future<void> _processDeletingAllItems({
    required int count
  }) async {

    try {

      await _deleteMultiSelectedFiles(count: count);
      SnakeAlert.okSnake(message: "$count item(s) has been deleted.", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from _processDeletingAllItems {main}',err,st);
      SnakeAlert.errorSnake("An error occurred.");
    } 
  }

  void _editAllOnPressed() {
    setState(() {
      editAllIsPressed = !editAllIsPressed;
    });
    if(editAllIsPressed == true) {
      checkedList.clear();
      checkedList = List.generate(storageData.fileNamesFilteredList.length, (index) => false);
    }
    if(!editAllIsPressed) {
      tempData.setAppBarTitle(Globals.originToName[tempData.origin]!);
      setState(() {
        itemIsChecked = false;
      });
    }
  }

  void _updateCheckboxState(int index, bool value) {
    setState(() {
      checkedList[index] = value;
      itemIsChecked = checkedList.where((item) => item == true).isNotEmpty ? true : false;
      value == true ? checkedItemsName.add(storageData.fileNamesFilteredList[index]) : checkedItemsName.removeWhere((item) => item == storageData.fileNamesFilteredList[index]);
    });
    tempData.setAppBarTitle("${(checkedList.where((item) => item == true).length).toString()} item(s) selected");
  }

  void _itemSearchingImplementation(String value) async {

    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 299), () {
      final searchTerms =
          value.split(",").map((term) => term.trim().toLowerCase()).toList();

      final filteredFiles = storageData.fileNamesList.where((file) {
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredByteValues = storageData.imageBytesList
          .where((bytes) => filteredFiles.contains(storageData.fileNamesList[storageData.imageBytesList.indexOf(bytes)]))
          .toList();

      final filteredFilesDate = <String>[];

      for (final file in filteredFiles) {
        final index = storageData.fileNamesList.indexOf(file);
        if (index >= 0 && index < storageData.fileDateList.length) {
          filteredFilesDate.add(storageData.fileDateList[index]);
        } else {
          filteredFilesDate.add(''); 
        }
      }

      setState(() {
        storageData.setFilteredFilesName(filteredFiles);
        storageData.setFilteredImageBytes(filteredByteValues);
        storageData.setFilteredFilesDate(filteredFilesDate);
      });
    });

  }

  void _filterTypePublicStorage(String value) async {

    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 299), () {
      final searchTerms =
          value.split(",").map((term) => term.trim().toLowerCase()).toList();

      final filteredFiles = storageData.fileNamesList.where((file) {
        return searchTerms.any((term) => file.toLowerCase().contains(term));
      }).toList();

      final filteredByteValues = storageData.imageBytesList
          .where((bytes) => filteredFiles.contains(storageData.fileNamesList[storageData.imageBytesList.indexOf(bytes)]))
          .toList();

      final filteredFilesDate = <String>[];

      for (final file in filteredFiles) {
        final index = storageData.fileNamesList.indexOf(file);
        if (index >= 0 && index < storageData.fileDateList.length) {
          filteredFilesDate.add(storageData.fileDateList[index]);
        } else {
          filteredFilesDate.add(''); 
        }
      }

      setState(() {
        storageData.setFilteredFilesName(filteredFiles);
        storageData.setFilteredImageBytes(filteredByteValues);
        storageData.setFilteredFilesDate(filteredFilesDate);
      });
    });
  }

  Future<int> _getStorageUsagePercentage() async {

    try {

      final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;
      final percentage = ((storageData.fileNamesList.length/maxValue) * 100).toInt();

      return percentage;

    } catch (err, st) {
      userData.setAccountType("Basic");
      logger.e('Exception on _getStorageUsagePercentage (main)',err, st);
      return 0;
    }

  }

  void _callStorageUsageWarning() async {
    SnakeAlert.upgradeSnake();
    await CallNotify().customNotification(
      title: "Warning", 
      subMesssage: "Storage usage has exceeded 70%. Upgrade for more storage.");
  }

  void _floatingButtonVisibility(bool visible) {
    floatingActionButtonVisible.value = visible;
  }

  void _navDirectoryButtonVisibility(bool visible) {
    navDirectoryButtonVisible.value = visible;
  }

  void _returnBackHomeFiles() {
    tempData.setOrigin(OriginFile.home);
    tempData.setCurrentFolder('');
    tempData.setCurrentDirectory('');
  }
  
  Future<Uint8List> _callData(String selectedFilename,String tableName) async {
    return await retrieveData.retrieveDataParams(userData.username, selectedFilename, tableName);
  }

  Future<void> _deleteFolderOnPressed(String folderName) async {
    
    try {

      final deleteClass = DeleteFolder();

      await deleteClass.deletionParams(folderName: folderName);

      storageData.foldersNameList.remove(folderName);
      tempData.setOrigin(OriginFile.home);

      await _refreshListView();
      _navDirectoryButtonVisibility(true);
      _floatingButtonVisibility(true);

      if(!mounted) return;
      Navigator.pop(context);

      SnakeAlert.okSnake(message: "$folderName Folder has been deleted.",icon: Icons.check);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to delete this folder.");
    }

  }

  Future<void> _renameFolder(String oldFolderName, String newFolderName) async {

    try {

      final renameClass = RenameFolder();
      await renameClass.renameParams(oldFolderTitle: oldFolderName, newFolderTitle: newFolderName);

      final indexOldFolder = storageData.foldersNameList.indexWhere((name) => name == oldFolderName);
      if(indexOldFolder != -1) {
        storageData.foldersNameList[indexOldFolder] = newFolderName;
      }

      await CallNotify().customNotification(title: "Folder Renamed", subMesssage: "$oldFolderName renamed to $newFolderName");

      SnakeAlert.okSnake(message: "`$oldFolderName` Has been renamed to `$newFolderName`");

    } catch (err) {
      SnakeAlert.errorSnake("Failed to rename this folder.");
    }

  }

  Future<void> _callHomeData() async {
    
    _clearGlobalData();
    await dataCaller.homeData();

  }

  Future<void> _callOfflineData() async {

    _clearGlobalData();

    await dataCaller.offlineData();

    searchBarVisibileNotifier.value = true;

    _clearSelectAll(); 

    _navDirectoryButtonVisibility(false);
    _floatingButtonVisibility(true);
 
  }

  Future<void> _callDirectoryData() async {

    _clearGlobalData();

    await dataCaller.directoryData(directoryName: tempData.appBarTitle);

    _itemSearchingImplementation('');
    searchBarController.text = '';
    searchHintText.value = "Search in ${tempData.appBarTitle}";

  }

  Future<void> _callSharingData(String originFrom) async {

    _clearGlobalData();

    await dataCaller.sharingData(originFrom);
    _itemSearchingImplementation('');

  }

  Future<void> _callPublicStorageData() async {

    _clearGlobalData();

    await dataCaller.publicStorageData(context: context);

    tempData.setAppBarTitle("Public Storage");
    psButtonTextNotifier.value = "My Files";

    searchBarVisibileNotifier.value = false;
    staggeredListViewSelected.value = true;

    _itemSearchingImplementation('');
    searchBarController.text = '';

    _navDirectoryButtonVisibility(false);
    _floatingButtonVisibility(true);

  }

  Future<void> _callMyPublicStorageData() async {

    _clearGlobalData();
    _clearPublicStorageData(clearImage: true);

    await dataCaller.myPublicStorageData(context: context);

    tempData.setAppBarTitle("My Public Storage");
    psButtonTextNotifier.value = "Back";
    
    _itemSearchingImplementation('');
    await _sortDataDescendingPs();

    searchBarController.text = '';

    _floatingButtonVisibility(false);

  }

  Future<void> _callFolderData(String folderTitle) async {

    if(tempData.appBarTitle == folderTitle) {
      return;
    }

    _clearGlobalData();

    await dataCaller.folderData(folderName: folderTitle);
    
    _itemSearchingImplementation('');

    _floatingButtonVisibility(false);
    _navDirectoryButtonVisibility(false);
    
    tempData.setAppBarTitle(tempData.folderName);

    searchBarController.text = '';
    searchBarVisibileNotifier.value = true;

  }

  Future<void> _refreshListView() async {

    switch (tempData.origin) {
      case OriginFile.home:
        await _callHomeData();
        break;

      case OriginFile.sharedOther:
        await _callSharingData("sharedFiles");
        break;

      case OriginFile.sharedMe:
        await _callSharingData("sharedToMe");
        break;

      case OriginFile.folder:
        await _callFolderData(tempData.folderName);
        break;

      case OriginFile.directory:
        await _callDirectoryData();
        break;

      case OriginFile.offline:
        await _callOfflineData();
        break;

      case OriginFile.public:
        tempData.appBarTitle == "Public Storage" 
          ? await _refreshPublicStorage()
          : await _callMyPublicStorageData();
        break;

      default:
        break;
    }

    if(tempData.origin != OriginFile.public) {

      _itemSearchingImplementation('');
      searchBarController.text = '';

      sortingText.value = "Default";
      ascendingDescendingIconNotifier.value = Icons.expand_more;

    }

    if(tempData.origin == OriginFile.home && togglePhotosPressed) {
      _togglePhotos();
    }

    if(storageData.fileNamesList.isEmpty) {
      _buildEmptyBody();
    }

  }

  Future<void> _buildDirectory(String directoryName) async {

    try {

      await DirectoryClass().createDirectory(directoryName, userData.username);

      final directoryImage = await GetAssets().loadAssetsFile('dir1.png');

      storageData.fileDateFilteredList.add("Directory");
      storageData.fileDateList.add("Directory");
      storageData.imageBytesList.add(directoryImage.readAsBytesSync());
      storageData.imageBytesFilteredList.add(directoryImage.readAsBytesSync());

      storageData.directoryImageBytesList.clear();
      storageData.fileNamesFilteredList.add(directoryName);
      storageData.fileNamesList.add(directoryName);

      SnakeAlert.okSnake(message: "Directory $directoryName has been created.", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from _buildDirectory {main}',err,st);
      CustomAlertDialog.alertDialog('Failed to create directory.');
    }
  }
  
  Future<void> _deleteDirectoryData(String directoryName) async {

    try {

      await DeleteDirectory().deleteDirectory(directoryName: directoryName);
    
      storageData.directoryImageBytesList.clear();

      SnakeAlert.okSnake(message: "Directory `$directoryName` has been deleted.");

    } catch (err, st) {
      logger.e('Exception from _deletionDirectory {main}',err,st);
      SnakeAlert.errorSnake("Failed to delete $directoryName");
    }

  }

  Future<void> _onDeletePressed(String fileName, List<String> fileValues, List<String> filteredSearchedFiles, List<Uint8List?> imageByteValues, Function onTextChanged) async {

    final extension = fileName.split('.').last;

    if(extension == fileName) {
      await _deleteDirectoryData(fileName);
    } else {
      await _deleteFileData(userData.username, fileName, Globals.fileTypesToTableNames[extension]!);
    }
    
    if(tempData.origin == OriginFile.home) {
      storageData.homeImageBytesList.clear();
      storageData.homeThumbnailBytesList.clear();
    }

    _removeFileFromListView(fileName: fileName, isFromSelectAll: false);

  }

  Future<void> _initializeCamera() async {

    try {

      final details = await PickerModel()
                        .galleryPicker(source: ImageSource.camera);

      if (details!.selectedFiles.isEmpty) {
        return;
      }

      for(var photoTaken in details.selectedFiles) {

        final imagePath = photoTaken.selectedFile.toString()
                          .split(" ").last.replaceAll("'", "");

        final imageName = imagePath.split("/").last.replaceAll("'", "");
        final fileExtension = imageName.split('.').last;

        if(!(Globals.imageType.contains(fileExtension))) {
          CustomFormDialog.startDialog("Couldn't upload photo","File type is not supported.");
          return;
        }

        List<int> bytes = await CompressorApi.compressedByteImage(path: imagePath, quality: 78);
      
        final imageBase64Encoded = base64.encode(bytes); 

        if(storageData.fileNamesList.contains(imageName)) {
          CustomFormDialog.startDialog("Upload Failed", "$imageName already exists.");
          return;
        }

        if(tempData.origin == OriginFile.public) {
          
          _openPsCommentDialog(filePathVal: imagePath, fileName: imageName, tableName: GlobalsTable.psImage, base64Encoded: imageBase64Encoded);
          return;

        } else if (tempData.origin == OriginFile.offline) {

          final decodeToBytes = base64.decode(imageBase64Encoded);
          final imageBytes = Uint8List.fromList(decodeToBytes);
          await OfflineMode().saveOfflineFile(fileName: imageName, fileData: imageBytes);

          storageData.imageBytesFilteredList.add(decodeToBytes);
          storageData.imageBytesList.add(decodeToBytes);

        } else {

          await UpdateListView().processUpdateListView(
            filePathVal: imagePath, 
            selectedFileName: imageName, 
            tableName: GlobalsTable.homeImage, 
            fileBase64Encoded: imageBase64Encoded
          );
          
        }

        UpdateListView().addItemToListView(fileName: imageName);

        await File(imagePath).delete();

      }

      await CallNotify().uploadedNotification(title: "Upload Finished",count: 1);

      _itemSearchingImplementation('');

    } catch (err) {
      SnakeAlert.errorSnake("Failed to start the camera.");
    }

  }

  Future<void> _makeAvailableOffline({
    required String fileName
  }) async {

    final offlineMode = OfflineMode();
    final singleLoading = SingleTextLoading();

    final fileType = fileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    if(Globals.unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.");
      return;
    } 

    late final Uint8List fileData;
    final indexFile = storageData.fileNamesList.indexOf(fileName);

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      fileData = storageData.imageBytesFilteredList[indexFile]!;
    } else {
      fileData = await _callData(fileName, tableName);
    }
    
    await offlineMode.processSaveOfflineFile(fileName: fileName, fileData: fileData);

    singleLoading.stopLoading();
    _clearSelectAll();

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = tempData.origin != OriginFile.home 
                        ? Globals.fileTypesToTableNamesPs[fileType] 
                        : Globals.fileTypesToTableNames[fileType];

      final isItemDirectory = fileType == fileName;

      if(isItemDirectory) {
        await SaveDirectory().selectDirectoryUserDirectory(directoryName: fileName, context: context);
        return;
      }

      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: "File name  $fileName", context: context);

      if(tempData.origin != OriginFile.offline) {

        late Uint8List getBytes;

        if(Globals.imageType.contains(fileType)) {
          int findIndexImage = storageData.fileNamesFilteredList.indexOf(fileName);
          getBytes = storageData.imageBytesFilteredList[findIndexImage]!;
        } else {
          getBytes = await _callData(fileName,tableName!);
        }

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName!,
          fileData: getBytes
        ).downloadFile();

      } else {
        await OfflineMode().downloadFile(fileName);
      } 

      loadingDialog.stopLoading();

      await CallNotify().downloadedNotification(fileName: fileName);

      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been downloaded.",icon: Icons.check);

    } catch (err) {
      await CallNotify().customNotification(title: "Download Failed", subMesssage: "Failed to download $fileName.");
      SnakeAlert.errorSnake("Failed to download ${ShortenText().cutText(fileName)}");
    }

  }

  void _removeFileFromListView({
    required String fileName, 
    required bool isFromSelectAll, 
  }) {

    final indexOfFile = togglePhotosPressed 
      ? storageData.fileNamesFilteredList.indexOf(fileName)+1
      : storageData.fileNamesFilteredList.indexOf(fileName);
    
    if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
      storageData.fileNamesList.removeAt(indexOfFile);
      storageData.fileNamesFilteredList.removeAt(indexOfFile);
      storageData.imageBytesList.removeAt(indexOfFile);
      storageData.imageBytesFilteredList.removeAt(indexOfFile);
      storageData.fileDateList.removeAt(indexOfFile);
      storageData.fileDateFilteredList.removeAt(indexOfFile);
    }
    if (!isFromSelectAll) {
      Navigator.pop(context);
    }

    if(togglePhotosPressed) {
      _togglePhotos();
      return;
    } else {
      _itemSearchingImplementation('');
    }
    
  }

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    storageData.fileNamesList[indexOldFile] = newFileName;
    storageData.fileNamesFilteredList[indexOldFileSearched] = newFileName;
  }

  Future<void> _renameFileData(String oldFileName, String newFileName) async {
    
    final fileType = oldFileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      tempData.origin != OriginFile.offline 
        ? await RenameData().renameFiles(oldFileName, newFileName, tableName) 
        : await OfflineMode().renameFile(oldFileName,newFileName);

      int indexOldFile = storageData.fileNamesList.indexOf(oldFileName);
      int indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {
        _updateRenameFile(newFileName,indexOldFile,indexOldFileSearched);

        SnakeAlert.okSnake(message: "`${ShortenText().cutText(oldFileName)}` Renamed to `${ShortenText().cutText(newFileName)}`.");
      }

    } catch (err, st) {
      logger.e('Exception from _renameFile {main}', err, st);
      SnakeAlert.errorSnake("Failed to rename this file.");
    }
  }

  void _onRenamePressed(String fileName) async {

    try {

      final verifyItemType = fileName.split('.').last;
      final newItemValue = RenameDialog.renameController.text;

      if(verifyItemType == fileName) {

        await _renameDirectory(oldDirName: fileName, newDirName: newItemValue);

        final indexOldFile = storageData.fileNamesList.indexOf(fileName);
        final indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(fileName);

        _updateRenameFile(newItemValue, indexOldFile, indexOldFileSearched);
        
        return;
      }

      final newRenameValue = "$newItemValue.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.");
      } else {
        await _renameFileData(fileName, newRenameValue);
      }
      
    } catch (err, st) {
      logger.e('Exception from _onRenamedPressed {main}',err,st);
    }
  }

  Future<void> _renameDirectory({
    required String oldDirName, 
    required String newDirName
  }) async {

    await RenameDirectory.renameDirectory(oldDirName,newDirName);

    SnakeAlert.okSnake(message: "Directory `$oldDirName` renamed to `$newDirName`.");
  }

  Future<void> _deleteFileData(String username, String fileName, String tableName) async {

    try {

      if(tempData.origin != OriginFile.offline) {

        final encryptVals = EncryptionClass().encrypt(fileName);
        await DeleteData().deleteFiles(username: username, fileName: encryptVals, tableName: tableName);

        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");

      } else {

        await OfflineMode().deleteFile(fileName);
        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");

      }

    } catch (err, st) {
      logger.e('Exception from _deletionFile {main}',err,st);
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}");
    }

  }

  Future _buildFoldersDialog() async {
    return FolderDialog().buildFolderDialog(
      folderOnPressed: (int index) async {
        
        final loadingDialog = MultipleTextLoading();

        tempData.setCurrentFolder(storageData.foldersNameList[index]);

        loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${tempData.folderName} files.",context: context);
        await _callFolderData(storageData.foldersNameList[index]);

        loadingDialog.stopLoading();
 
        if(!mounted) return;
        Navigator.pop(context);

      },
      trailingOnPressed: (int index) {
        _callBottomTrailingFolder(storageData.foldersNameList[index]);
      }, 
      context: context
    );

  }

  Future _callSelectedItemsBottomTrailing() {

    final length = togglePhotosPressed 
      ? selectedPhotosIndex.length
      : checkedItemsName.length;

    return BottomTrailingSelectedItems().buildTrailing(
      context: context, 
      makeAoOnPressed: () async {
        await _processSaveOfflineFileSelectAll(
          count: length);
      }, 
      saveOnPressed: () async {
        await _selectDirectoryMultipleSave(
          length);
      }, 
      deleteOnPressed: () {
        _openDeleteSelectionDialog();
      }
    );
  }

  Future _callBottomTrailling(int index) {

    final fileName = storageData.fileNamesFilteredList[index];

    return BottomTrailing().buildBottomTrailing(
      fileName: fileName, 
      onRenamePressed: () {
        Navigator.pop(context);
        _openRenameDialog(fileName);
      }, 
      onDownloadPressed: () async {
        Navigator.pop(context);
        await _callFileDownload(fileName: fileName);
      }, 
      onDeletePressed: () {
        _openDeleteDialog(fileName);
      },
      onSharingPressed: () {
        Navigator.pop(context);
        _openSharingDialog(fileName);
      }, 
      onAOPressed: () async {
        Navigator.pop(context);
        await _makeAvailableOffline(fileName: fileName);
      }, 
      context: context
    );
  }

  Future _showUpgradeLimitedDialog(int value)  {
    return UpgradeDialog.buildUpgradeDialog(
      message: "You're currently limited to $value uploads. Upgrade your account to upload more.",
      context: context
    );
  }

    Future _showUpgradeExceededDialog()  {
    return UpgradeDialog.buildUpgradeDialog(
      message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.",
      context: context
    );
  }

  Future _callBottomTrailingAddItem() {

    late String headerText = "";

    if(tempData.origin == OriginFile.public) {
      headerText = "Upload to Public Storage";
    } else if (tempData.origin == OriginFile.directory || tempData.origin == OriginFile.folder) {
      headerText = "Add item to ${tempData.appBarTitle}";
    } else {
      headerText = "Add item to Flowstorage";
    }
    
    final limitUpload = AccountPlan.mapFilesUpload[userData.accountType]!;

    final bottomTrailingAddItem = BottomTrailingAddItem();
    return bottomTrailingAddItem.buildTrailing(
      headerText: headerText, 
      galleryOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          await _openDialogGallery();
        } else {
          _showUpgradeLimitedDialog(limitUpload);
        }

      }, 
      fileOnPressed: () async {

        if (tempData.origin == OriginFile.public) {

          int count = psStorageData.psUploaderList
              .where((uploader) => uploader == userData.username)
              .length;

          if (count < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            _showUpgradeLimitedDialog(limitUpload);
          } 

        } else {

          if(tempData.origin == OriginFile.offline) {
            Navigator.pop(context);
            await _openDialogFile();
          } else if (storageData.fileNamesList.length < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            _showUpgradeLimitedDialog(limitUpload);
          }
        }

      }, 
      folderOnPressed: () async {

        if(storageData.foldersNameList.length != AccountPlan.mapFoldersUpload[userData.accountType]!) {
          await _openDialogFolder();
          
          if(!mounted) return;
          Navigator.pop(context);

        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFoldersUpload[userData.accountType]} folders upload. Upgrade your account plan to upload more folder.",
            context: context
          );
        }

      }, 
      photoOnPressed: () async {

        if (tempData.origin == OriginFile.public) {

          int count = psStorageData.psUploaderList
              .where((uploader) => uploader == userData.username)
              .length;

          if (count < limitUpload) {
            Navigator.pop(context);
            await _openDialogFile();
          } else {
            _showUpgradeLimitedDialog(limitUpload);
          }

        } else {

          if (storageData.fileNamesList.length < limitUpload) {
            Navigator.pop(context);
            await _initializeCamera();
          } else {
            _showUpgradeLimitedDialog(limitUpload);
          }

        }

      }, 
      scannerOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          await _initializeCameraScanner();
        } else {
          _showUpgradeLimitedDialog(limitUpload);
        }

      }, 
      textOnPressed: () async {

        if(storageData.fileNamesList.length < limitUpload) {
          Navigator.pop(context);
          NavigatePage.goToPageCreateText(context);
        } else {
          _showUpgradeLimitedDialog(limitUpload);
        }

      }, 
      directoryOnPressed: () async {

        final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
        if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
          if(countDirectory != AccountPlan.mapDirectoryUpload[userData.accountType]!) {

            if(!mounted) return;
            Navigator.pop(context);

            _openCreateDirectoryDialog();
            
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "Upgrade your account to upload more directory.",
              context: context
            );
          }
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
            context: context
          );
        }

      }, 
      context: context
    );
    
  }

  Future _callBottomTrailingFolder(String folderName) {
    return BottomTrailingFolder().buildFolderBottomTrailing(
      folderName: folderName, 
      context: context, 
      onRenamePressed: () {
        _openRenameFolderDialog(folderName);
      }, 
      onDownloadPressed: () async {
        if(userData.accountType == "Basic") {
          UpgradeDialog.buildUpgradeDialog(
            message: "Upgrade your account to any paid plan to download folder.",
            context: context
          );
        } else {
          await SaveFolder().selectDirectoryUserFolder(folderName: folderName, context: context);
        }
      }, 
      onDeletePressed: () async {
        DeleteDialog().buildDeleteDialog(
          fileName: "$folderName folder", 
          onDeletePressed: () async {
            await _deleteFolderOnPressed(folderName);
          }, 
          context: context
        );
      }
    );
  }

  Future _callBottomTrailingShared() {
    final bottomTrailingShared = BottomTrailingShared();
    return bottomTrailingShared.buildTrailing(
      context: context, 
      sharedToMeOnPressed: () async {
        tempData.setOrigin(OriginFile.sharedMe);
        tempData.setAppBarTitle("Shared to me");

        _floatingButtonVisibility(false);
        _navDirectoryButtonVisibility(false);
        Navigator.pop(context);

        await _callSharingData("sharedToMe");
      }, 
      sharedToOthersOnPressed: () async {
        tempData.setOrigin(OriginFile.sharedOther);
        tempData.setAppBarTitle("Shared files");
        
        _floatingButtonVisibility(false);
        _navDirectoryButtonVisibility(false);
        Navigator.pop(context);

        await _callSharingData("sharedFiles");
      }
    );
  }

  Future _callBottomTrailingSorting() {
    final sortingBottomTrailing = BottomTrailingSorting();
    return sortingBottomTrailing.buildTrailing(
      context: context, 
      sortUploadDateOnPressed: () {
        _sortUploadDate();
        Navigator.pop(context);
      },
      sortItemNameOnPressed: () {
        _sortItemName();
        Navigator.pop(context);
      }, 
      sortDefaultOnPressed: () {
        _sortDefault();
        Navigator.pop(context);
      }
    );
  }

  Widget _buildCheckboxItem(int index) {
    return CheckBoxItems(
      index: index, 
      updateCheckboxState: _updateCheckboxState, 
      checkedList: checkedList
    );
  }

  Widget _buildNavigationButtons() {
    return NavigationButtons(
      isVisible: togglePhotosPressed, 
      isCreateDirectoryVisible: navDirectoryButtonVisible, 
      isStaggeredListViewSelected: staggeredListViewSelected, 
      ascendingDescendingCaret: ascendingDescendingIconNotifier, 
      sortingText: sortingText, 
      sharedOnPressed: () { 
        _callBottomTrailingShared(); 
      }, 
      
      scannerOnPressed: () async {
        if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
          await _initializeCameraScanner();
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
            context: context
          );
        }
      }, 
        
      createDirectoryOnPressed: () async {
        final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
        if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
          if(countDirectory != AccountPlan.mapDirectoryUpload[userData.accountType]!) {
            _openCreateDirectoryDialog();
          } else {
            UpgradeDialog.buildUpgradeDialog(
              message: "You're currently limited to ${AccountPlan.mapDirectoryUpload[userData.accountType]} directory uploads. Upgrade your account to upload more directory.",
              context: context
            );
          }
        } else {
          UpgradeDialog.buildUpgradeDialog(
            message: "You're currently limited to ${AccountPlan.mapFilesUpload[userData.accountType]} uploads. Upgrade your account to upload more.",
            context: context
          );
        }
      }, 
        
      sortingOnPressed: () { _callBottomTrailingSorting(); },
        
      filterTypePsOnPressed: () {
        final bottomTrailingFilter = BottomTrailingFilter();
        bottomTrailingFilter.buildFilterTypeAll(
          filterTypePublicStorage: _filterTypePublicStorage, 
          filterTypeNormal: _itemSearchingImplementation, 
          context: context
        );
      }
    );
  }

  Widget _buildSearchBar() {
    return ResponsiveSearchBar(
      controller: searchBarController,
      visibility: searchBarVisibileNotifier, 
      focusNode: searchBarFocusNode, 
      hintText: tempData.origin != OriginFile.public 
        ? searchHintText.value 
        : "Search in Public Storage", 

      onChanged: (String value) {
        if (value.isEmpty) {
          searchBarFocusNode.unfocus();
        }
        _itemSearchingImplementation(value);
      }, 

      filterTypeOnPressed: () {
        final bottomTrailingFilter = BottomTrailingFilter();
        bottomTrailingFilter.buildFilterTypeAll(
          filterTypePublicStorage: _filterTypePublicStorage, 
          filterTypeNormal: _itemSearchingImplementation, 
          context: context
        );
      }
    );
  }

  Widget _buildSelectAll() {
    return Row(
      children: [
        IconButton(
          icon: editAllIsPressed ? const Icon(Icons.check) : const Icon(Icons.check_box_outlined,size: 26),
          onPressed: () {
            checkedItemsName.clear();
            selectAllItemsIconNotifier.value = Icons.check_box_outline_blank;
            editAllIsPressed ? selectAllItemsIsPressedNotifier.value = false : selectAllItemsIsPressedNotifier.value = true;
            _editAllOnPressed();
          },
        ),
        Visibility(
          visible: selectAllItemsIsPressedNotifier.value,
          child: IconButton(
            icon: Icon(selectAllItemsIconNotifier.value, size: 26),
            onPressed: _onSelectAllItemsPressed,
          ),
        ),
      ],
    );
  }

  void _onSelectAllItemsPressed() {
    checkedItemsName.clear();
    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      final itemsName = storageData.fileNamesFilteredList[i];
      if(itemsName.split('.').last != itemsName) {
        _buildCheckboxItem(i);
        _updateCheckboxState(i, true);
      }
    }
    checkedItemsName.addAll(storageData.fileNamesFilteredList);
    selectAllItemsIsPressedNotifier.value = !selectAllItemsIsPressedNotifier.value;
  }

  Widget _buildMoreOptionsOnSelect() {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        _callSelectedItemsBottomTrailing();
      }
    );
  }

  Widget _buildTunePhotosType() {
    return IconButton(
      onPressed: () {
        final bottomTrailingFilter = BottomTrailingFilter();
        bottomTrailingFilter.buildFilterTypePhotos(
          filterTypePublicStorage: _filterTypePublicStorage, 
          filterTypeNormal: _itemSearchingImplementation, 
          context: context
        );
      },
      icon: const Icon(Icons.tune_outlined, 
        color: Colors.white, size: 26),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {

    final appBarTitleValue = tempData.appBarTitle == '' ? 'Home' : tempData.appBarTitle;

    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AppBar(
          titleSpacing: 5,
          elevation: 0,
          centerTitle: false,
          title: Text(appBarTitleValue,
            style: GlobalsStyle.greetingAppBarTextStyle,
          ),
          actions: [

            if(tempData.origin != OriginFile.public && togglePhotosPressed == false)
            _buildSelectAll(),  

            if(itemIsChecked)
            _buildMoreOptionsOnSelect(),

            if(togglePhotosPressed)
            _buildTunePhotosType(),

            if(tempData.origin == OriginFile.public) 
            _buildMyPsFilesButton()

          ],
          leading: IconButton(
            icon: const Icon(Icons.menu,size: 28),
            onPressed: () {
              sidebarMenuScaffoldKey.currentState?.openDrawer();
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: ThemeColor.darkBlack,
        ),
      ),
    );
  }

  Widget _buildEmptyBody() {
    return EmptyBody(
      refreshList: () async {
        await _refreshListView();
    });
  }

  Future<void> _navigateToPreviewFile(int index) async {

    const Set<String> externalFileTypes = {
    ...Globals.wordType, ...Globals.excelType, ...Globals.ptxType};

    tempData.setCurrentFileName(storageData.fileNamesFilteredList[index]);

    final fileExtension = tempData.selectedFileName.split('.').last;    

    if (Globals.supportedFileTypes.contains(fileExtension) && 
      !(externalFileTypes.contains(fileExtension))) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewFile(
            selectedFilename: tempData.selectedFileName,
            fileType: fileExtension,
            tappedIndex: index
          ),
        ),
      );

    } else if (fileExtension == tempData.selectedFileName && !Globals.supportedFileTypes.contains(fileExtension)) {
      
      tempData.setOrigin(OriginFile.directory);
      tempData.setCurrentDirectory(tempData.selectedFileName);
      tempData.setAppBarTitle(tempData.selectedFileName);

      _navDirectoryButtonVisibility(false);
      
      final loadingDialog = MultipleTextLoading();

      loadingDialog.startLoading(title: "Please wait",subText: "Retrieving ${tempData.directoryName} files.",context: context);
      await _callDirectoryData();

      loadingDialog.stopLoading();

      return;

    } else if (externalFileTypes.contains(fileExtension)) {

      late Uint8List fileData;

      final fileTable = Globals.fileTypesToTableNames[fileExtension]!;

      if(tempData.origin != OriginFile.offline) {
        fileData = await _callData(tempData.selectedFileName, fileTable);
      } else {
        fileData = await OfflineMode().loadOfflineFileByte(tempData.selectedFileName);
      }

      final result = await ExternalApp(
        bytes: fileData, 
        fileName: tempData.selectedFileName
      ).openFileInExternalApp();

      if(result.type != ResultType.done) {
        CustomFormDialog.startDialog(
          "Couldn't open ${tempData.selectedFileName}",
          "No default app to open this file found."
        );
      }
      
      return;

    } else {
      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
        "It looks like you're trying to open a file which is not supported by Flowstorage"
      );
    }
  }

  Widget _buildRecentPsFiles(Uint8List imageBytes, int index) {
    
    final fileName = storageData.fileNamesFilteredList[index];
    final fileType = fileName.split('.').last;

    return GestureDetector(
      onTap: () async {
        await _navigateToPreviewFile(index);
      },
      onLongPress: () {
        _callBottomTrailling(index);
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ThemeColor.lightGrey,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.memory(imageBytes, fit: Globals.generalFileTypes.contains(fileType) 
                                ? BoxFit.scaleDown 
                                : BoxFit.cover),
                ),
              ),

              if(Globals.videoType.contains(fileType))
              Padding(
                padding: const EdgeInsets.only(top: 14.0, left: 16.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColor.mediumGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                ),
              ),

            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ShortenText().cutText(psStorageData.psTitleList[index], customLength: 12),
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ShortenText().cutText(psStorageData.psUploaderList[index], customLength: 12),
                style: const TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 23,
                decoration: BoxDecoration(
                  color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    psStorageData.psTagsList[index],
                    style: const TextStyle(
                      color: ThemeColor.justWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubPsFiles(Uint8List imageBytes, int index) {
    
    final fileName = storageData.fileNamesFilteredList[index];
    final fileType = fileName.split('.').last;

    return GestureDetector(
      onTap: () async {
        await _navigateToPreviewFile(index);
      },
      onLongPress: () {
        _callBottomTrailling(index);
      },
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 185,
                    height: 158,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ThemeColor.lightGrey,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      child: Image.memory(imageBytes, fit: Globals.generalFileTypes.contains(fileType) ? BoxFit.scaleDown : BoxFit.cover),
                    ),
                  ),

                  if(Globals.videoType.contains(fileType))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ThemeColor.mediumGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ShortenText().cutText(psStorageData.psTitleList[index], customLength: 16),
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ShortenText().cutText(fileName, customLength: 16),
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ShortenText().cutText(psStorageData.psUploaderList[index], customLength: 12),
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 23,
                      decoration: BoxDecoration(
                        color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Center(
                        child: Text(
                          psStorageData.psTagsList[index],
                          style: const TextStyle(
                            color: ThemeColor.justWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }

  void _onPhotosItemSelected(int index) {
    if (selectedPhotosIndex.contains(index)) {
      checkedItemsName.remove(storageData.fileNamesFilteredList[index]);
      setState(() {
        selectedPhotosIndex.remove(index);
      });
    } else {
      checkedItemsName.add(storageData.fileNamesFilteredList[index]);
      setState(() {
        selectedPhotosIndex.add(index);
      });
    }

    tempData.setAppBarTitle("${selectedPhotosIndex.length} Item(s) selected");

    if(selectedPhotosIndex.isEmpty) {
      _floatingButtonVisibility(true);
      tempData.setAppBarTitle("Photos");
      itemIsChecked = false;
    }
    
  }

  void _onHoldPhotosItem(int index) {
    itemIsChecked = true;
    setState(() {
      selectedPhotosIndex.add(index);
    });
    
    checkedItemsName.add(storageData.fileNamesFilteredList[index]);
    tempData.setAppBarTitle("${selectedPhotosIndex.length} Item(s) selected");
    
    _floatingButtonVisibility(false);

  }

  Widget _buildStaggeredItems(int index) {

    final imageBytes = storageData.imageBytesFilteredList[index]!;

    String uploaderName = "";
    bool isRecent = false;

    if (tempData.origin == OriginFile.public) {
      uploaderName = psStorageData.psUploaderList[index];
      if (uploaderName == userData.username) {
        uploaderName = "${userData.username} (You)";
      }

      isRecent = index <= 2;
    }

    return Padding(
      padding: EdgeInsets.all(tempData.origin == OriginFile.public ? 0.0 : 2.0),
      child: GestureDetector(
        onLongPress: () {
          if (togglePhotosPressed) {
            _onHoldPhotosItem(index);

          } else {
            if (!isRecent) {
              _callBottomTrailling(index);
            }

          }
        },

        onTap: () async {
          if (togglePhotosPressed && selectedPhotosIndex.isNotEmpty) {
            _onPhotosItemSelected(index);

          } else {
            if (!isRecent) {
              await _navigateToPreviewFile(index);
            }
            
          }
        },
        child: Column(
          children: [
            if (isRecent && tempData.origin == OriginFile.public && index == 0) ... [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0, top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: ThemeColor.justWhite, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Recent",
                        style: TextStyle(
                          fontSize: 23,
                          color: ThemeColor.justWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    _buildRecentPsFiles(storageData.imageBytesFilteredList[0]!, 0),

                    if (storageData.imageBytesFilteredList.length > 1) ... [
                      const SizedBox(width: 12),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[1]!, 1),

                    ],
                    if (storageData.imageBytesFilteredList.length > 2) ... [
                      const SizedBox(width: 12),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[2]!, 2),
                    ],

                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: ThemeColor.whiteGrey),
            ],
            if (tempData.origin == OriginFile.public && index == 3) ... [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSubPsFiles(storageData.imageBytesFilteredList[3]!, 3),
                      const SizedBox(width: 25),
                      if (storageData.imageBytesFilteredList.length > 4)
                        _buildSubPsFiles(storageData.imageBytesFilteredList[4]!, 4),

                      const SizedBox(width: 25),
                      if (storageData.imageBytesFilteredList.length > 5)
                        _buildSubPsFiles(storageData.imageBytesFilteredList[5]!, 5),

                      const SizedBox(width: 25),
                      if (storageData.imageBytesFilteredList.length > 6)
                        _buildSubPsFiles(storageData.imageBytesFilteredList[6]!, 6),

                      const SizedBox(width: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: ThemeColor.whiteGrey),
            ],
            if (tempData.origin == OriginFile.public && !isRecent && index > 6) ... [

              if (index == 7)
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Row(
                      children: [
                        Icon(Icons.explore_outlined, color: ThemeColor.justWhite, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Discover",
                          style: TextStyle(
                            fontSize: 23,
                            color: ThemeColor.justWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              IntrinsicHeight(child: _buildPsStaggeredListView(imageBytes, index, uploaderName)),

            ],
            
            if (tempData.origin != OriginFile.public && !togglePhotosPressed)
              IntrinsicHeight(child: _buildDefaultStaggeredListView(imageBytes, index)),

            if (tempData.origin != OriginFile.public && togglePhotosPressed)
              IntrinsicHeight(child: _buildPhotosStaggeredListView(index)),

          ],
        ),
      ),
    );
  }

  Widget _buildPsStaggeredListView(Uint8List imageBytes, int index, String uploaderName) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = DateShortForm(input: inputDate).convert();

    return PsStaggeredListView(
      imageBytes: imageBytes,
      index: index,
      uploaderName: uploaderName,
      fileType: fileType,
      originalDateValues: shortFormDate,
      callBottomTrailing: _callBottomTrailling,
    );
  }

  Widget _buildDefaultStaggeredListView(Uint8List imageBytes, int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;

    return DefaultStaggeredListView(
      imageBytes: imageBytes, 
      index: index,
      fileType: fileType
    );

  }

  Widget _buildPhotosStaggeredListView(int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final imageBytes = storageData.imageBytesFilteredList[index]!;
    final isSelected = selectedPhotosIndex.contains(index);

    return PhotosStaggeredListView(
      imageBytes: imageBytes, 
      fileType: fileType,
      isPhotosSelected: isSelected,
    );
    
  }

  Widget _buildStaggeredListView() {

    int fitSize = tempData.origin == OriginFile.public ? 5 : 1;

    EdgeInsetsGeometry paddingValue = tempData.origin == OriginFile.public 
    ? const EdgeInsets.only(top: 2.0,left: 0.0, right: 0.0, bottom: 8.0) 
    : const EdgeInsets.only(top: 12.0,left: 8.0, right: 8.0, bottom: 8.0);

    return Consumer<StorageDataProvider>(
      builder: (context, storageData, child) {
        return Padding(
          padding: paddingValue,
          child: StaggeredGridView.countBuilder(
            controller: scrollListViewController,
            shrinkWrap: true,
            itemCount: storageData.fileNamesFilteredList.length,
            itemBuilder: (BuildContext context, int index) => _buildStaggeredItems(index),
            staggeredTileBuilder: (int index) => StaggeredTile.fit(fitSize),
            crossAxisCount: togglePhotosPressed ? 2 : 4,
            mainAxisSpacing: togglePhotosPressed ? 8 : 6.5,
            crossAxisSpacing: togglePhotosPressed ? 8 : 6.5,
          
          ),
        );
      }
    );
  }

  Widget _buildHomeBody() {

    late double mediaHeight;

    final mediaQuery = MediaQuery.of(context).size;

    if(tempData.origin == OriginFile.public) {
      mediaHeight = mediaQuery.height - 194;

    } else if (tempData.origin != OriginFile.public && !togglePhotosPressed) {
      mediaHeight = mediaQuery.height - 310;

    } else if (tempData.origin != OriginFile.public && togglePhotosPressed) {
      mediaHeight = mediaQuery.height - 148;

    }

    return RefreshIndicator(
      color: ThemeColor.darkPurple,
      onRefresh: () async {

        if(tempData.origin == OriginFile.home) {
          storageData.homeImageBytesList.clear();
          storageData.homeImageBytesList.clear();
        }

        if(tempData.origin == OriginFile.public) {
          _clearPublicStorageData(clearImage: true);
        }

        await _refreshListView();
      },
      child: SizedBox(
        height: mediaHeight,
        child: ValueListenableBuilder<bool>(
          valueListenable: staggeredListViewSelected,
          builder: (context, value, child) {
            return value == false ? _buildResponsiveListView() : _buildStaggeredListView();
          }
        ),
      ),
    );
  }

  Widget _buildResponsiveListView() {
    return ResponsiveListView(
      itemOnLongPress: (int index) {
        _callBottomTrailling(index);
      },
      itemOnTap: (int index) async {
        await _navigateToPreviewFile(index);
      }, 
      childrens: (int index) {
        return <Widget>[

          if(tempData.origin == OriginFile.offline) ... [
            const Icon(Icons.offline_bolt_rounded, color: Colors.white, size: 21),
            const SizedBox(width: 8),
          ],

          GestureDetector(
            onTap: () {
              _callBottomTrailling(index);
            },
            child: editAllIsPressed
              ? _buildCheckboxItem(index)
              : const Icon(Icons.more_vert, color: Colors.white),
          ),
        ];
      },
      inlineSpanWidgets: (int index) {

        final originalDateValues = storageData.fileDateFilteredList[index];
        final psFilesCategoryTags = originalDateValues.split(' ').sublist(0, originalDateValues.split(' ').length - 1).join(' ');

        return <InlineSpan>[
          TextSpan(
            text: tempData.origin == OriginFile.public ? psFilesCategoryTags : storageData.fileDateFilteredList[index],
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 12.8,
            ),
          ),

          if(tempData.origin == OriginFile.public) 
          TextSpan(
            text: " ${psStorageData.psTagsList[index]}",
            style: TextStyle(
              color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
              fontWeight: FontWeight.w500,
              fontSize: 12.8,
            ),
        
          ),
        ];
      }
    );
  }

  Widget _buildMyPsFilesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 8.0),
      child: ElevatedButton(
        onPressed: () async {

          if(psButtonTextNotifier.value == "Back") {
            _clearPublicStorageData(clearImage: true);
          }

          if(psButtonTextNotifier.value == "My Files") {
            await Future.delayed(const Duration(milliseconds: 299));
            _sortUploadDate();
            _sortUploadDate();
          }

          psButtonTextNotifier.value == "Back" 
          ? await _refreshPublicStorage()
          : await _callMyPublicStorageData();

        },
        style: GlobalsStyle.btnNavigationBarStyle,
        child: ValueListenableBuilder(
          valueListenable: psButtonTextNotifier,
          builder: (context, value, child) {
            return Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        ),
      ),
    );
  }

  void _initializeProvider() {
    userData = _locator<UserDataProvider>();
    storageData = _locator<StorageDataProvider>();
    psUploadData = _locator<PsUploadDataProvider>();
    tempData = _locator<TempDataProvider>();
    psStorageData = _locator<PsStorageDataProvider>();
  }

  void _initializeCheckedItemList() async {
    checkedList = List.generate(
        storageData.fileNamesFilteredList.length, (index) => false);
  }

  @override
  void initState() {

    super.initState();

    _initializeProvider();
    _initializeCheckedItemList();
    _itemSearchingImplementation('');

  }

  @override 
  void dispose() {

    debounceSearchingTimer!.cancel();
    searchBarFocusNode.dispose();
    searchBarController.dispose();
    searchControllerRedudane.dispose();
    focusNodeRedudane.dispose();
    scrollListViewController.dispose();
    psButtonTextNotifier.dispose();

    staggeredListViewSelected.dispose();
    floatingActionButtonVisible.dispose();
    navDirectoryButtonVisible.dispose();
    selectAllItemsIconNotifier.dispose();
    selectAllItemsIconNotifier.dispose();
    ascendingDescendingIconNotifier.dispose();
    searchBarVisibileNotifier.dispose();
    searchHintText.dispose();

    NotificationApi.stopNotification(0);

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: searchBarFocusNode.unfocus,
      child: Scaffold(
        key: sidebarMenuScaffoldKey,
        drawer: CustomSideBarMenu(
          usageProgress: _getStorageUsagePercentage(),
          offlinePageOnPressed: () async { _callOfflineData(); }
        ),
        appBar: _buildCustomAppBar(),
        body: storageData.fileNamesList.isEmpty 

        ? Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildEmptyBody()]) 
        : Column(
          children: [_buildSearchBar(),_buildNavigationButtons(),_buildHomeBody()]),

        bottomNavigationBar: CustomNavigationBar(
          openFolderDialog: _buildFoldersDialog, 
          toggleHome: _toggleHome,
          togglePhotos: _togglePhotos,
          togglePublicStorage: _togglePublicStorage, 
          context: context
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: floatingActionButtonVisible,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: FloatingActionButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                backgroundColor: ThemeColor.darkPurple,
                onPressed: _callBottomTrailingAddItem,
                child: const Icon(Icons.add, color: ThemeColor.darkBlack, size: 30),
              ),
            );
          },
        ),
      ),
    );
  }

}