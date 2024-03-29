
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/directory_query/rename_directory.dart';
import 'package:flowstorage_fsc/folder_query/delete_folder.dart';
import 'package:flowstorage_fsc/folder_query/save_folder.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/date_short_form.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/helper/generate_thumbnail.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/interact_dialog/bottom_trailing/folder_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/bottom_trailing/upgrade_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/create_directory_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_selection_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_folder_dialog.dart';
import 'package:flowstorage_fsc/models/function_model.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/models/sorting_model.dart';
import 'package:flowstorage_fsc/models/upload_dialog_model.dart';
import 'package:flowstorage_fsc/pages/intent_share_page.dart';
import 'package:flowstorage_fsc/pages/public_storage/file_search_page.dart';
import 'package:flowstorage_fsc/pages/public_storage/upload_ps_page.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/add_item.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/file_options.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/filter_type.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/folder_options.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/selected_items_options.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/shared_options.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/sorting_options.dart';
import 'package:flowstorage_fsc/widgets/checkbox_item.dart';
import 'package:flowstorage_fsc/widgets/empty_body.dart';
import 'package:flowstorage_fsc/widgets/navigation_bar.dart';
import 'package:flowstorage_fsc/widgets/navigation_buttons.dart';
import 'package:flowstorage_fsc/widgets/responsive_list_view.dart';
import 'package:flowstorage_fsc/widgets/responsive_search_bar.dart';
import 'package:flowstorage_fsc/widgets/sidebar_menu.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/default_grid.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/photos_grid.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/ps_grid.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/recent_ps_grid.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/sub_ps_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();

}

class HomePageState extends State<HomePage> { 

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final dataCaller = DataCaller();
  final deleteData = DeleteData();
  final functionModel = FunctionModel();

  final logger = Logger();

  final sidebarMenuScaffoldKey = GlobalKey<ScaffoldState>();

  final scrollListViewController = ScrollController();

  final searchBarFocusNode = FocusNode();
  final searchBarController = TextEditingController();

  final sortingText = ValueNotifier<String>('Default');
  final searchHintText = ValueNotifier<String>('Search in Flowstorage');

  final psButtonTextNotifier = ValueNotifier<String>('My Files');
  
  final floatingActionButtonVisible = ValueNotifier<bool>(true);

  final gridListViewSelected = ValueNotifier<bool>(false);
  final selectAllItemsIsPressedNotifier = ValueNotifier<bool>(false);

  final selectAllItemsIconNotifier = ValueNotifier<IconData>(
                                      Icons.check_box_outline_blank);
  final ascendingDescendingIconNotifier = ValueNotifier<IconData>(
                                      Icons.expand_more);

  final searchBarVisibleNotifier = ValueNotifier<bool>(true);

  late StreamSubscription intentDataStreamSubscription;

  bool togglePhotosPressed = false;
  bool editAllIsPressed = false;
  bool selectedItemIsChecked = false;

  List<bool> selectedItemsCheckedList = [];
  
  Set<int> selectedPhotosIndex = {};
  Set<String> checkedItemsName = {};

  bool filterPhotosTypeVisible = false;

  bool sortingIsAscendingItemName = false;
  bool sortingIsAscendingUploadDate = false;
  
  Timer? debounceSearchingTimer;

  void _callStorageUsageWarning() async {
    if(tempData.origin != OriginFile.offline) {
      SnackAlert.upgradeSnack();
      await CallNotify().customNotification(
        title: "Warning", 
        subMessage: "Storage usage has exceeded 70%. Upgrade for more storage."
      );
    }
  }

  void _callOnUploadFailed(String message, Object err, StackTrace stackTrace) {
    logger.e(message, err, stackTrace);
    SnackAlert.errorSnack("Upload failed.");
    NotificationApi.stopNotification(0);
  }

  void _addItemButtonVisibility(bool visible) {
    floatingActionButtonVisible.value = visible;
  }

  void _toggleGoBackHome() {
    searchHintText.value = "Search in Flowstorage";
    tempData.setOrigin(OriginFile.home);
    tempData.setAppBarTitle("Home");
    tempData.setCurrentFolder('');
    tempData.setCurrentDirectory('');
  }

  Future<void> _openDialogUploadGallery() async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).galleryDialog();

      _itemSearchingImplementation('');

      final storageUsagePercentage = await _getStorageUsagePercentage();

      if(storageUsagePercentage > 70) {
        _callStorageUsageWarning();
      }

    } catch (err, st) {
      _callOnUploadFailed('Exception from _openDialogUploadGallery {main}',err,st);
    }

  }

  Future<void> _openDialogUploadFile() async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).filesDialog(_openPsUploadPage);

      _itemSearchingImplementation('');

      final storageUsagePercentage = await _getStorageUsagePercentage();
      final isShowWarning = storageUsagePercentage > 70 && tempData.origin != OriginFile.offline;
      if(isShowWarning) {
        _callStorageUsageWarning();
      }

    } catch (err, st) {
      _callOnUploadFailed('Exception from _openDialogUploadFile {main}', err,st);
    }

  }

  Future<void> _openDialogUploadFolder() async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).foldersDialog();

    } catch (err, st) {
      _callOnUploadFailed('Exception from _openDialogUploadFolder {main}',err,st);
    }
    
  }

  Future<void> _initializeDocumentScanner() async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).scannerUpload();

      _itemSearchingImplementation('');

    } catch (err) {
      SnackAlert.errorSnack("Failed to start scanner.");
    }
    
  }

  Future<void> _initializePhotoCamera() async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).photoUpload();

      _itemSearchingImplementation('');

    } catch (err) {
      SnackAlert.errorSnack("Failed to start the camera.");
    }

  }

  Future<void> _initializeUploadPs({
    required String filePath,
    required String fileName,
    required String tableName,
    required String fileData,
    File? previewImage,
    Uint8List? videoThumbnail,
  }) async {

    try {

      await UploadDialogModel(
        upgradeExceededDialog: _showUpgradeExceededDialog,
      ).publicStorageUpload(
        fileName: fileName,
        fileData: fileData,
        filePath: filePath,
        tableName: tableName,
        previewData: previewImage,
        videoThumbnail: videoThumbnail
      );

      _scrollEndListView();

    } catch (err, st) {
      _callOnUploadFailed('Exception from _initializeUploadPs {main}',err,st);
    }

  }

  void _openPsUploadPage({
    required String filePath,
    required String fileName,
    required String tableName,
    required String fileData,
    File? previewImage,
    Uint8List? videoThumbnail,
  }) async {

    await NotificationApi.stopNotification(0);

    final fileType = fileName.split('.').last;

    late String? imagePreview = "";
    
    if(Globals.imageType.contains(fileType)) {
      imagePreview = fileData;

    } else if (Globals.videoType.contains(fileType)) {
      imagePreview = base64.encode(videoThumbnail!);

    } 

    if(mounted) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => UploadPsPage(
            fileName: fileName,
            imageBase64Encoded: imagePreview,
            fileBase64Encoded: fileData,
            onUploadPressed: () async {
              await _initializeUploadPs(
                fileName: fileName,
                fileData: fileData,
                filePath: filePath,
                tableName: tableName,
                previewImage: previewImage,
                videoThumbnail: videoThumbnail
              );
            }, 
          )
        )
      );
    }

    await NotificationApi.stopNotification(0);

  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog( 
      fileName: fileName, 
      onDeletePressed:() => _onDeleteItemPressed(fileName, storageData.fileNamesList, storageData.fileNamesFilteredList, storageData.imageBytesList, _itemSearchingImplementation),
    );
  }

  void _openRenameDialog(String fileName) {
     RenameDialog().buildRenameFileDialog(
      fileName: fileName, 
      onRenamePressed: () => _onRenameItemPressed(fileName), 
    );
  }

  void _openRenameFolderDialog(String folderName) {
    RenameFolderDialog().buildRenameFolderDialog(
      folderName: folderName, 
      renameFolderOnPressed: () async {

        final newFolderName = RenameFolderDialog.folderRenameController.text;

        if (tempStorageData.folderNameList.contains(newFolderName)) {
          CallToast.call(message: "Folder with this name already exists.");
          RenameFolderDialog.folderRenameController.clear();
          return;
        } 

        if(newFolderName.isEmpty) {
          CallToast.call(message: "Folder name cannot be empty.");
          return;
        }

        await functionModel.renameFolderData(
          folderName, newFolderName);

        RenameFolderDialog.folderRenameController.clear();

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

        await functionModel.createDirectoryData(getDirectoryTitle);
        CreateDirectoryDialog.directoryNameController.clear();

      }

    );
  }

  void _openDeleteSelectionDialog() {
    DeleteSelectionDialog().buildDeleteSelectionDialog(
      appBarTitle: tempData.appBarTitle, 
      deleteOnPressed: () async {
        final countSelectedItems = togglePhotosPressed
          ? checkedItemsName.length
          : selectedItemsCheckedList.where((checked) => checked).length;
        
        await _deleteMultipleSelectedFiles(count: countSelectedItems);
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

    togglePhotosPressed 
      ? _activatePhotosView() 
      : _deactivatePhotosView();

    if (tempData.origin == OriginFile.public) {
      _clearPublicStorageData(clearImage: true);
      _toggleGoBackHome();
      await _refreshListViewData();
    }
    
  }

  void _activatePhotosView() {

    tempData.setAppBarTitle("Photos");

    searchBarVisibleNotifier.value = false;
    gridListViewSelected.value = true;

    _addItemButtonVisibility(true);

    final combinedTypes = [
      ...Globals.imageType.map((type) => '.$type'),
      ...Globals.videoType.map((type) => '.$type'),
    ].join(',');

    _itemSearchingImplementation(combinedTypes);
    
  }

  void _deactivatePhotosView() {

    tempData.setAppBarTitle(Globals.originToName[tempData.origin]!);

    searchBarVisibleNotifier.value = true;
    gridListViewSelected.value = false;

    filterPhotosTypeVisible = false;
    selectedItemIsChecked = false;

    selectedPhotosIndex.clear();

    if ([OriginFile.home, OriginFile.directory].contains(tempData.origin)) {
      _addItemButtonVisibility(true);
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
      _toggleGoBackHome();

    } else {
      _toggleGoBackHome();
      await _refreshListViewData();

    }

    _addItemButtonVisibility(true);

    selectedItemIsChecked = false;
    togglePhotosPressed = false;
    filterPhotosTypeVisible = false;

    searchBarVisibleNotifier.value = true;
    gridListViewSelected.value = false;
    
    _itemSearchingImplementation('');

  }

  Future<void> _sortDataDescendingPs() async {
    await Future.delayed(const Duration(milliseconds: 890), () {
      _sortUploadDate();
      _sortUploadDate();
    });
  }

  Future<void> _refreshPublicStorage() async {
    await _callPublicStorageData(); 
    await _sortDataDescendingPs();
    _addItemButtonVisibility(true);
  }

  void _scrollEndListView() {
    scrollListViewController.animateTo(
      scrollListViewController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _clearItemSelection() {

    !togglePhotosPressed
      ? tempData.setAppBarTitle(Globals.originToName[tempData.origin]!)
      : tempData.setAppBarTitle("Photos");

    setState(() {
      _addItemButtonVisibility(true);
      selectedItemIsChecked = false;
      editAllIsPressed = false;
    });

    selectAllItemsIsPressedNotifier.value = false;
    selectedPhotosIndex.clear();
    checkedItemsName.clear();

  }

  void _sortUploadDate() {

    sortingIsAscendingUploadDate = !sortingIsAscendingUploadDate;
    ascendingDescendingIconNotifier.value = sortingIsAscendingUploadDate 
      ? Icons.expand_less : Icons.expand_more;
      
    sortingText.value = tempData.origin == OriginFile.public 
      ? "Default" : "Upload Date";

    setState(() {
      SortingModel().uploadDate(sortingIsAscendingUploadDate: sortingIsAscendingUploadDate);
    });

  }

  void _sortItemName() {

    sortingIsAscendingItemName = !sortingIsAscendingItemName;
    ascendingDescendingIconNotifier.value = sortingIsAscendingItemName 
      ? Icons.expand_less : Icons.expand_more;

    sortingText.value = "Item Name";
    
    setState((){
      SortingModel().fileName(sortingIsAscendingItemName: sortingIsAscendingItemName);
    });

  }

  void _sortDefault() async {

    sortingText.value = "Default";
    sortingIsAscendingItemName = false;
    sortingIsAscendingUploadDate = false;
    ascendingDescendingIconNotifier.value = Icons.expand_more;

    await _refreshListViewData();

  }

  void _editAllOnPressed() {

    setState(() {
      _addItemButtonVisibility(false);
      editAllIsPressed = !editAllIsPressed;
    });

    if(editAllIsPressed) {
      selectedItemsCheckedList.clear();
      selectedItemsCheckedList = List.generate(storageData.fileNamesFilteredList.length, (index) => false);
      tempData.setAppBarTitle("Select items");
    }

    if(!editAllIsPressed) {
      tempData.setAppBarTitle(Globals.originToName[tempData.origin]!);
      setState(() {
        _addItemButtonVisibility(true);
        selectedItemIsChecked = false;
      });
    }

  }

  void _updateCheckboxState(int index, bool isChecked) {

    setState(() {
      selectedItemsCheckedList[index] = isChecked;
      selectedItemIsChecked = selectedItemsCheckedList.any((item) => item);

      isChecked 
        ? checkedItemsName.add(storageData.fileNamesFilteredList[index])
        : checkedItemsName.removeWhere((item) => item == storageData.fileNamesFilteredList[index]);
    });

    final setAppBarTitle = "${selectedItemsCheckedList.where((item) => item).length} Selected";

    tempData.setAppBarTitle(setAppBarTitle);

  }

  void _deselectAllPhotosOnPressed() {

    setState(() {
      checkedItemsName.clear();
      selectedPhotosIndex.clear();
      selectedItemIsChecked = false;
    });

    tempData.setAppBarTitle("Photos");

    _addItemButtonVisibility(true);

  }

  void _selectAllPhotosOnPressed() {

    final index = List.generate(storageData.fileNamesFilteredList.length, (index) => index);

    setState(() {
      checkedItemsName.clear();
      selectedPhotosIndex.clear();

      selectedPhotosIndex.addAll(index);
      checkedItemsName.addAll(storageData.fileNamesFilteredList);

      selectedItemIsChecked = true;
    });

    tempData.setAppBarTitle("${selectedPhotosIndex.length} Selected");

  }

  void _onRefreshListView() async {

    if(tempData.origin == OriginFile.home) {
      storageData.homeImageBytesList.clear();
      storageData.homeImageBytesList.clear();
    }

    if(tempData.origin == OriginFile.public) {
      _clearPublicStorageData(clearImage: true);
    }

    await _refreshListViewData();
    
  }

  void _itemSearchingImplementation(String value) async {

    debounceSearchingTimer?.cancel();
    debounceSearchingTimer = Timer(const Duration(milliseconds: 10), () {
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
        final isFileFound = index >= 0 && index < storageData.fileDateList.length;

        isFileFound 
          ? filteredFilesDate.add(storageData.fileDateList[index])
          : filteredFilesDate.add(''); 

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

      final uploadCount = tempData.origin == OriginFile.public 
        ? tempData.psTotalUpload
        : storageData.fileNamesList.length;

      return ((uploadCount/maxValue) * 100).toInt();

    } catch (err, st) {
      userData.setAccountType("Basic");
      logger.e('Exception on _getStorageUsagePercentage (main)',err, st);
      return 0;
    }

  }

  Future<void> _callHomeData() async {
    
    _clearGlobalData();

    await dataCaller.homeData();

    searchHintText.value = "Search in Flowstorage";

  }

  Future<void> _callOfflineData() async {

    _clearGlobalData();

    await dataCaller.offlineData();

    _clearItemSelection(); 

    _addItemButtonVisibility(true);

    searchBarVisibleNotifier.value = true;
    searchHintText.value = "Search in Flowstorage";
 
  }

  Future<void> _callDirectoryData() async {

    _clearGlobalData();

    await dataCaller.directoryData(directoryName: tempData.directoryName);

    _itemSearchingImplementation('');

    searchBarController.text = '';
    searchHintText.value = "Search in ${ShortenText().cutText(tempData.appBarTitle)} directory";

  }

  Future<void> _callSharingData(String originFrom) async {

    _clearGlobalData();

    await dataCaller.sharingData(originFrom);

    _itemSearchingImplementation('');
    _addItemButtonVisibility(false);

    searchHintText.value = "Search in Flowstorage";

  }

  Future<void> _callPublicStorageData() async {

    _clearGlobalData();

    await dataCaller.publicStorageData(context: context);

    _itemSearchingImplementation('');
    _addItemButtonVisibility(true);

    psButtonTextNotifier.value = "My Files";
    searchBarVisibleNotifier.value = false;
    gridListViewSelected.value = true;

    filterPhotosTypeVisible = false;

    searchBarController.text = '';

  }

  Future<void> _callMyPublicStorageData() async {

    _clearGlobalData();
    _clearPublicStorageData(clearImage: true);

    await dataCaller.myPublicStorageData(context: context);

    _itemSearchingImplementation('');
    _addItemButtonVisibility(false);

    await _sortDataDescendingPs();

    psButtonTextNotifier.value = "Back";
    searchBarController.text = '';

  }

  Future<void> _callFolderData(String folderTitle) async {

    if(tempData.appBarTitle == folderTitle) {
      return;
    }

    _clearGlobalData();

    if(togglePhotosPressed) {
      _togglePhotos();
    }

    tempData.setCurrentFolder(folderTitle);

    await dataCaller.folderData(folderName: folderTitle);
    
    _itemSearchingImplementation('');

    _addItemButtonVisibility(false);
    
    searchBarController.text = '';
    searchBarVisibleNotifier.value = true;
    searchHintText.value = "Search in ${ShortenText().cutText(folderTitle)} folder";
    
  }

  Future<void> _refreshListViewData() async {

    if(togglePhotosPressed) {
      return;
    }

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

    if(togglePhotosPressed) {
      searchBarVisibleNotifier.value = false;
    }

    if(storageData.fileNamesList.isEmpty) {
      _buildEmptyBody();
    }

    if(tempData.origin != OriginFile.sharedMe && tempData.origin != OriginFile.sharedOther) {
      tempStorageData.sharedNameList.clear();
    }

  }

  Future<void> _deleteMultipleSelectedFiles({
    required int count
  }) async {

    final loadingDialog = SingleTextLoading();

    loadingDialog.startLoading(title: "Deleting...", context: context);

    try {

      for(final fileName in checkedItemsName) {

        await deleteData.deleteOnMultiSelection(fileName: fileName);

        await Future.delayed(const Duration(milliseconds: 855), () {
          _removeFileFromListView(fileName: fileName, isFromSelectAll: true);
        });
        
        if(tempStorageData.offlineFileNameList.contains(fileName)) {
          setState(() {
            tempStorageData.offlineFileNameList.remove(fileName);
          });
        }

      }

      loadingDialog.stopLoading();

      SnackAlert.okSnack(message: "Deleted $count item(s).", icon: Icons.check);

      _clearItemSelection();

    } catch(err, st) {
      logger.e('Exception from _deleteMultipleSelectedFiles {main}', err, st);
      loadingDialog.stopLoading();
      SnackAlert.errorSnack("An error occurred.");
    }

  }

  Future<void> _makeMultipleSelectedFilesOffline() async {

    try {

      await functionModel.makeMultipleFilesAvailableOffline(
        checkedFilesName: checkedItemsName,
      );
      
      _clearItemSelection();

    } catch (err, st) {
      SnackAlert.errorSnack("An error occurred.");
      logger.e('Exception from _makeMultipleFiles', err, st);
    }
    
  }

  void _makeAvailableOfflineOnPressed({
    required String fileName
  }) async {

    try {

      await functionModel.makeAvailableOffline(fileName: fileName);
      
      _clearItemSelection();

    } catch (err, st) {
      SnackAlert.errorSnack("An error occurred.");
      logger.e('Exception from _makeAvailableOfflineOnPressed {main}', err, st);
    }

  }

  void _removeFileFromListView({
    required String fileName, 
    required bool isFromSelectAll, 
  }) {

    try {

      final indexOfFile = togglePhotosPressed 
        ? storageData.fileNamesFilteredList.indexOf(fileName)+1
        : storageData.fileNamesFilteredList.indexOf(fileName);

      if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
        storageData.updateRemoveFile(indexOfFile);
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

    } catch (err, st) {
      logger.e('Exception from _removeFileFromListView {main}', err, st);
    }
    
  }

  void _onDeleteItemPressed(String fileName, List<String> fileValues, List<String> filteredSearchedFiles, List<Uint8List?> imageByteValues, Function onTextChanged) async {

    try {

      final fileType = fileName.split('.').last;
      final isItemDirectory = fileType == fileName && !Globals.supportedFileTypes.contains(fileType);

      if(isItemDirectory) {
        await functionModel.deleteDirectoryData(fileName);
        
      } else {
        final tableName = tempData.origin == OriginFile.public 
          ? Globals.fileTypesToTableNamesPs[fileType]
          : Globals.fileTypesToTableNames[fileType];

        await functionModel.deleteFileData(
          userData.username, fileName, tableName!);

      }
      
      if(tempData.origin == OriginFile.home) {
        storageData.homeImageBytesList.clear();
        storageData.homeThumbnailBytesList.clear();

      } else if (tempData.origin == OriginFile.public) {
        psStorageData.myPsImageBytesList.clear();
        psStorageData.myPsThumbnailBytesList.clear();

      }

      if(tempStorageData.offlineFileNameList.contains(fileName)) {
        setState(() {
          tempStorageData.offlineFileNameList.remove(fileName);
        });
      } 

      _removeFileFromListView(fileName: fileName, isFromSelectAll: false);
      
    } catch (err, st) {
      logger.e('Exception from _onDeleteItemPressed {main}', err, st);
    }

  }

  void _deleteFolderOnPressed(String folderName) async {
    
    try {

      await DeleteFolder(folderName: folderName).delete();

      tempData.setOrigin(OriginFile.home);

      await _refreshListViewData();
      
      _addItemButtonVisibility(true);

      if(mounted) {
        Navigator.pop(context);
      }

      SnackAlert.okSnack(message: "Deleted $folderName folder.", icon: Icons.check);

    } catch (err) {
      SnackAlert.errorSnack("Failed to delete this folder.");
    }

  }

  void _onRenameItemPressed(String fileName) async {

    try {

      final verifyItemType = fileName.split('.').last;
      final newItemName = RenameDialog.renameController.text;

      if(verifyItemType == fileName) {

        await _renameDirectory(oldDirName: fileName, newDirName: newItemName);

        final indexOldFile = storageData.fileNamesList.indexOf(fileName);
        final indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(fileName);

        storageData.updateRenameFile(
            newItemName, indexOldFile, indexOldFileSearched);
        
        return;
      }

      final newRenameValue = "$newItemName.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.");
        return;
      } 

      await functionModel.renameFileData(fileName, newRenameValue);
      
    } catch (err, st) {
      logger.e('Exception from _onRenamedPressed {main}',err,st);
    }

  }

  Future<void> _selectDirectoryOnMultipleDownload() async {

    final directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath!.isNotEmpty) {
      await functionModel.multipleFilesDownload(
        checkedItemsName: checkedItemsName, 
        directoryPath: directoryPath
      );

    } else {
      return;

    }

  }

  Future<void> _renameDirectory({
    required String oldDirName, 
    required String newDirName
  }) async {

    await RenameDirectory(
      oldDirectoryName: oldDirName, 
      newDirectoryName: newDirName
    ).rename();

    SnackAlert.okSnack(message: "Directory '$oldDirName' renamed to '$newDirName'.");
    
  }

  Future _buildFolderBottomSheet() async {
    return FolderDialog().buildFoldersBottomSheet(
      folderOnPressed: (int index) async {
        
        final loading = SingleTextLoading();

        loading.startLoading(title: "Please wait...", context: context);

        _deactivatePhotosView();

        if (tempData.origin == OriginFile.public) {
          _clearPublicStorageData(clearImage: false);
        }

        await _callFolderData(tempStorageData.folderNameList[index]);

        loading.stopLoading();
 
        if(mounted) {
          Navigator.pop(context);
        }

      },
      trailingOnPressed: (int index) {
        _callBottomTrailingFolder(tempStorageData.folderNameList[index]);
      }, 
      context: context
    );
  }

  Future _callSelectedItemsBottomTrailing() {
    return BottomTrailingSelectedItems().buildTrailing(
      context: context, 
      makeAoOnPressed: () async {
        await _makeMultipleSelectedFilesOffline();
      }, 
      saveOnPressed: () async {
        await _selectDirectoryOnMultipleDownload();
      }, 
      moveOnPressed: () {
        Navigator.pop(context);
        _openMoveMultipleFilePage(checkedItemsName.toList());
      },
      deleteOnPressed: () {
        _openDeleteSelectionDialog();
      },
      itemsName: checkedItemsName
    );
  }

  Future _callBottomTrailing(int index) {

    final fileName = storageData.fileNamesFilteredList[index];

    return BottomTrailingOptions().buildBottomTrailing(
      fileName: fileName, 
      onRenamePressed: () {
        Navigator.pop(context);
        _openRenameDialog(fileName);
      }, 
      onDownloadPressed: () async {
        Navigator.pop(context);
        await functionModel.downloadFileData(fileName: fileName);
      }, 
      onDeletePressed: () {
        _openDeleteDialog(fileName);
      },
      onSharingPressed: () {
        Navigator.pop(context);
        NavigatePage.goToPageSharing(fileName);
      }, 
      onDetailsPressed: () {
        Navigator.pop(context);
        NavigatePage.goToPageFileDetails(fileName);
      },
      onAOPressed: () {
        Navigator.pop(context);
        _makeAvailableOfflineOnPressed(fileName: fileName);
      }, 
      onOpenWithPressed: () {
        _openExternalFileOnSelect(fileName);
      },
      onMovePressed: () {
        Navigator.pop(context);
        _openMoveSingleFilePage(fileName);
      },
      context: context
    );

  }

  Future _showUpgradeLimitedDialog(int value)  {
    return UpgradeDialog.buildUpgradeBottomSheet(
      message: "You're currently limited to $value uploads. Upgrade your account to upload more.",
      context: context
    );
  }

  Future _showUpgradeExceededDialog()  {
    return UpgradeDialog.buildUpgradeBottomSheet(
      message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.",
      context: context
    );
  }

  Future _callBottomTrailingAddItem() async {

    late String headerText = "";

    if(tempData.origin == OriginFile.public) {
      headerText = "Upload to Public Storage";

    } else if ([OriginFile.directory, OriginFile.folder].contains(tempData.origin)) {
      headerText = "Add item to ${tempData.appBarTitle}";

    } else {
      headerText = "Add item to Flowstorage";

    }
    
    final limitUpload = AccountPlan.mapFilesUpload[userData.accountType]!;

    if(tempData.origin == OriginFile.public) {

      final totalPsUpload = psStorageData.psUploaderList
        .where((uploader) => uploader == userData.username)
        .length;

      totalPsUpload < limitUpload
        ? await _openDialogUploadFile()
        : _showUpgradeLimitedDialog(limitUpload);

      return;
      
    }

    final isNotOnUploadLimit = tempData.origin == OriginFile.offline || storageData.fileNamesList.length < limitUpload;

    return BottomTrailingAddItem().buildTrailing(
      context: context,
      headerText: headerText, 
      galleryOnPressed: () async {
        if (isNotOnUploadLimit) {
          Navigator.pop(context);
          await _openDialogUploadGallery();

        } else {
          _showUpgradeLimitedDialog(limitUpload);

        }
      }, 
      fileOnPressed: () async {
        if (tempData.origin == OriginFile.public) {

          final totalPsUpload = psStorageData.psUploaderList
            .where((uploader) => uploader == userData.username)
            .length;

          if (totalPsUpload < limitUpload) {
            Navigator.pop(context);
            await _openDialogUploadFile();

          } else {
            _showUpgradeLimitedDialog(limitUpload);

          } 

        } else {

          if(isNotOnUploadLimit) {
            Navigator.pop(context);
            await _openDialogUploadFile();

          } else {
            _showUpgradeLimitedDialog(limitUpload);

          }

        }
      }, 
      folderOnPressed: () async {
        if(tempStorageData.folderNameList.length != AccountPlan.mapFoldersUpload[userData.accountType]!) {

          if(mounted) {
            Navigator.pop(context);
          }

          await _openDialogUploadFolder();
          
        } else {
          UpgradeDialog.buildUpgradeBottomSheet(
            message: "You're currently limited to ${AccountPlan.mapFoldersUpload[userData.accountType]} folders upload. Upgrade your account plan to upload more folder.",
            context: context
          );

        }
      }, 
      photoOnPressed: () async {
        if (isNotOnUploadLimit) {
          Navigator.pop(context);
          await _initializePhotoCamera();

        } else {
          _showUpgradeLimitedDialog(limitUpload);

        }
      }, 
      scannerOnPressed: () async {
        if(isNotOnUploadLimit) {
          Navigator.pop(context);
          await _initializeDocumentScanner();

        } else {
          _showUpgradeLimitedDialog(limitUpload);

        }
      }, 
      textOnPressed: () {
        if(isNotOnUploadLimit) {
          Navigator.pop(context);
          NavigatePage.goToPageCreateText();

        } else {
          _showUpgradeLimitedDialog(limitUpload);

        }
      }, 
      directoryOnPressed: () {
        final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
        if(storageData.fileNamesList.length < AccountPlan.mapFilesUpload[userData.accountType]!) {
          if(countDirectory != AccountPlan.mapDirectoryUpload[userData.accountType]!) {

            if(mounted) {
              Navigator.pop(context);
            }

            _openCreateDirectoryDialog();
            
          } else {
            UpgradeDialog.buildUpgradeBottomSheet(
              message: "Upgrade your account to upload more directory.",
              context: context
            );
          }

        } else {
          _showUpgradeLimitedDialog(limitUpload);
        }
      }, 
      
    );
  
  }

  Future _callBottomTrailingFolder(String folderName) {
    return BottomTrailingFolder().buildFolderBottomTrailing(
      folderName: folderName, 
      context: context, 
      onRenamePressed: () => _openRenameFolderDialog(folderName),
      onDownloadPressed: () async {
        if(userData.accountType == "Basic") {
          UpgradeDialog.buildUpgradeBottomSheet(
            message: "Upgrade your account to any paid plan to download folder.",
            context: context
          );
          
        } else {
          await SaveFolder().selectDirectoryUserFolder(folderName: folderName, context: context);
        }
        
      }, 
      onDeletePressed: () {
        DeleteDialog().buildDeleteDialog(
          fileName: "$folderName folder", 
          onDeletePressed: () {
            _deleteFolderOnPressed(folderName);
          }, 
        );
      }
    );
  }

  Future _callBottomTrailingShared() {

    final loading = SingleTextLoading();

    return BottomTrailingShared().buildTrailing(
      context: context, 
      sharedToMeOnPressed: () async {
        Navigator.pop(context);

        loading.startLoading(title: "Please wait...", context: context);

        await _callSharingData("sharedToMe");

        loading.stopLoading();

      }, 
      sharedToOthersOnPressed: () async {
        Navigator.pop(context);

        loading.startLoading(title: "Please wait...", context: context);

        await _callSharingData("sharedFiles");

        loading.stopLoading();
        
      }
    );
  }

  Future _callBottomTrailingSorting() {
    return BottomTrailingSorting().buildTrailing(
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
      checkedList: selectedItemsCheckedList
    );
  }

  Widget _buildNavigationButtons() {

    final isVisibleCondition = 
      togglePhotosPressed || tempData.origin == OriginFile.public;

    return NavigationButtons(
      isVisible: isVisibleCondition, 
      isGridListViewSelected: gridListViewSelected, 
      ascendingDescendingCaret: ascendingDescendingIconNotifier, 
      sortingText: sortingText, 
      sortingOnPressed: () => _callBottomTrailingSorting(),
      filterTypeOnPressed: () {
        BottomTrailingFilter(
          context: context, 
          filterTypeFunctionality: _itemSearchingImplementation
        ).buildFilterTypeAll();
      },
      filterPhotosTypeVisibleOnPressed: () {
        setState(() {
          filterPhotosTypeVisible = !filterPhotosTypeVisible;
        });
      },
    );

  }

  Widget _buildSearchBar() {
    return ResponsiveSearchBar(
      controller: searchBarController,
      visibility: searchBarVisibleNotifier, 
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
    );
  }

  Widget _buildSelectAll() {
    return Row(
      children: [
        IconButton(
          icon: editAllIsPressed ? const Icon(Icons.check) : const Icon(Icons.check_box_outlined, size: 26),
          onPressed: () {
            checkedItemsName.clear();
            selectAllItemsIconNotifier.value = Icons.check_box_outline_blank;

            editAllIsPressed 
              ? selectAllItemsIsPressedNotifier.value = false 
              : selectAllItemsIsPressedNotifier.value = true;

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

    tempData.setAppBarTitle("${selectedPhotosIndex.length} Selected");

    if(selectedPhotosIndex.isEmpty) {
      _addItemButtonVisibility(true);
      tempData.setAppBarTitle("Photos");
      selectedItemIsChecked = false;
    }
    
  }

  void _onHoldPhotosItem(int index) {

    selectedItemIsChecked = true;

    setState(() {
      selectedPhotosIndex.add(index);
    });
    
    checkedItemsName.add(storageData.fileNamesFilteredList[index]);
    tempData.setAppBarTitle("${selectedPhotosIndex.length} Selected");
    
    _addItemButtonVisibility(false);

  }

  void _onSelectItemLongPress(int index) {

    selectAllItemsIconNotifier.value = Icons.check_box_outline_blank;

    selectAllItemsIsPressedNotifier.value = true;

    if(checkedItemsName.isEmpty && !editAllIsPressed) {
      _editAllOnPressed();
    }

    setState(() {
      selectedItemsCheckedList[index] = !selectedItemsCheckedList[index]; 
      selectedItemIsChecked = selectedItemsCheckedList.any((item) => item);
      checkedItemsName.contains(storageData.fileNamesFilteredList[index]) 
        ? checkedItemsName.removeWhere((item) => item == storageData.fileNamesFilteredList[index])
        : checkedItemsName.add(storageData.fileNamesFilteredList[index]);
    });

    final setAppBarTitle = "${selectedItemsCheckedList.where((item) => item).length} Selected";

    tempData.setAppBarTitle(setAppBarTitle);

  }

  void _onSelectAllItemsPressed() {

    checkedItemsName.clear();
    
    final removedDirectoryNames = storageData.fileNamesFilteredList
      .where((name) => name.contains('.'));

    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      final itemsName = storageData.fileNamesFilteredList[i];
      if(itemsName.split('.').last != itemsName) {
        _buildCheckboxItem(i);
        _updateCheckboxState(i, true);
      }
    }

    checkedItemsName.addAll(removedDirectoryNames);
    selectAllItemsIsPressedNotifier.value = !selectAllItemsIsPressedNotifier.value;

  }

  Widget _buildFilterPhotosTypeButton() {
    return IconButton(
      onPressed: () {
        BottomTrailingFilter(          
          filterTypeFunctionality: _itemSearchingImplementation, 
          context: context
        ).buildFilterTypePhotos();
      },
      icon: const Icon(Icons.tune_outlined, 
        color: Colors.white, size: 26
      ),
    );
  }

  Widget _buildMoreOptionsOnSelectButton() {
    return IconButton(
      onPressed: () => _callSelectedItemsBottomTrailing(),
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildDeselectAllPhotosButton() {
    return IconButton(
      onPressed: () => _deselectAllPhotosOnPressed(),
      icon: const Icon(Icons.check, 
        color: Colors.white, size: 26
      ),
    );
  }

  Widget _buildSelectAllPhotosButton() {
    return SizedBox(
      width: 105,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _selectAllPhotosOnPressed(),
          style: GlobalsStyle.btnMiniStyle,
          child: const Text("Select All",
            style: TextStyle(
              fontSize: 13.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {

    final appBarTitleValue = tempData.appBarTitle == '' 
      ? 'Home' : tempData.appBarTitle;

    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CustomAppBar(
          context: context,
          title: appBarTitleValue,
          customLeading: IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => sidebarMenuScaffoldKey.currentState?.openDrawer(),
          ),
          actions: [

            if(selectedPhotosIndex.isNotEmpty) ... [
              _buildSelectAllPhotosButton(),
              _buildDeselectAllPhotosButton(),
            ],

            if(tempData.origin != OriginFile.public && !togglePhotosPressed && !filterPhotosTypeVisible)
            _buildSelectAll(),  

            if(selectedItemIsChecked)
            _buildMoreOptionsOnSelectButton(),

            if (togglePhotosPressed && checkedItemsName.isEmpty && !filterPhotosTypeVisible)
            _buildFilterPhotosTypeButton(),

            if(tempData.origin == OriginFile.public) ... [
              _buildPsSearchButton(),
              _buildMyPsFilesButton(),
            ],

          ],
        ).buildAppBar(),
      ),
    );
  }

  Widget _buildEmptyBody() {
    return EmptyBody(
      refreshList: () async => await _refreshListViewData(),
    );
  }

  void _openDirectoryOnSelect() async {

    tempData.setOrigin(OriginFile.directory);
    
    final loading = SingleTextLoading();

    loading.startLoading(title: "Please wait...", context: context);

    tempData.setCurrentDirectory(tempData.selectedFileName);
    tempData.setAppBarTitle(tempData.selectedFileName);

    await _callDirectoryData();
  
    loading.stopLoading();

  }

  void _openGeneralFileOnSelect(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewFile(
          selectedFilename: tempData.selectedFileName,
          tappedIndex: index
        ),
      ),
    );
  }

  void _openMoveSingleFilePage(String fileName) async {

    final fileData = await functionModel.retrieveFileData(
      fileName: fileName, isCompressed: true);

    final base64Data = base64.encode(fileData);

    NavigatePage.goToPageMoveFile(
      [fileName], [base64Data]
    );

  }

  void _openMoveMultipleFilePage(List<String> fileNames) async {

    List<String> fileBase64 = [];

    for(final fileName in fileNames)  {
      final fileData = await functionModel.retrieveFileData(
        fileName: fileName, isCompressed: true);

      final base64Data = base64.encode(fileData);
      fileBase64.add(base64Data);

    }

    NavigatePage.goToPageMoveFile(
      fileNames, fileBase64
    );

  }

  void _openExternalFileOnSelect(String fileName) async {

    final fileData = await functionModel.retrieveFileData(
      fileName: fileName, isCompressed: false);

    final result = await ExternalApp(
      bytes: fileData, 
      fileName: fileName
    ).openFileInExternalApp();

    if(result.type != ResultType.done) {
      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
        "No default app to open this file found."
      );
    }

  }

  void _navigateToPreviewFile(int index) {

    const Set<String> externalFileTypes = 
    {
      ...Globals.wordType, ...Globals.excelType, ...Globals.ptxType, 
    };

    tempData.setCurrentFileName(storageData.fileNamesFilteredList[index]);

    final fileType = tempData.selectedFileName.split('.').last;    

    if (Globals.supportedFileTypes.contains(fileType) && !(externalFileTypes.contains(fileType))) {
      _openGeneralFileOnSelect(index);
      return;

    } else if (fileType == tempData.selectedFileName && !Globals.supportedFileTypes.contains(fileType)) {
      _openDirectoryOnSelect();
      return;

    } else if (externalFileTypes.contains(fileType)) {
      _openExternalFileOnSelect(tempData.selectedFileName);
      return;

    } else {
      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
        "It looks like you're trying to open a file which is not supported by Flowstorage"
      );

    }

  }

  Widget _buildRecentPsFiles(Uint8List imageBytes, int index) {

    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = inputDate == "Just days" 
      ? "Just now" 
      : DateShortForm(input: inputDate).convert();

    return RecentPsListView(
      imageBytes: imageBytes, 
      index: index, 
      uploadDate: shortFormDate,
      fileOnPressed: () => _navigateToPreviewFile(index),
      fileOnLongPressed: () => _callBottomTrailing(index),
    );

  }

  Widget _buildSubPsFiles(Uint8List imageBytes, int index) {

    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = inputDate == "Just days" 
      ? "Just now" 
      : DateShortForm(input: inputDate).convert();

    return SubPsListView(
      imageBytes: imageBytes, 
      index: index, 
      uploadDate: shortFormDate,
      fileOnPressed: () => _navigateToPreviewFile(index), 
      fileOnLongPressed: () => _callBottomTrailing(index),
    ); 

  }

  Widget _buildGridListViewItems(int index) {

    final imageBytes = storageData.imageBytesFilteredList[index]!;

    final isPsRecent = tempData.origin == OriginFile.public
      ? index <= 2
      : false;

    return Padding(
      padding: EdgeInsets.all(tempData.origin == OriginFile.public ? 0.0 : 2.0),
      child: GestureDetector(
        onLongPress: () {
          if (togglePhotosPressed) {
            _onHoldPhotosItem(index);

          } else {
            if (!isPsRecent) {
              _callBottomTrailing(index);
            }

          }
        },

        onTap: () {
          if (togglePhotosPressed && selectedPhotosIndex.isNotEmpty) {
            _onPhotosItemSelected(index);

          } else {
            if (!isPsRecent) {
              _navigateToPreviewFile(index);
            }
            
          }
        },
        child: Column(
          children: [
            if (isPsRecent && tempData.origin == OriginFile.public && index == 0) ... [
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
                      const SizedBox(width: 25),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[1]!, 1),
                    ],

                    if (storageData.imageBytesFilteredList.length > 2) ... [
                      const SizedBox(width: 25),
                      _buildRecentPsFiles(storageData.imageBytesFilteredList[2]!, 2),
                    ],

                    const SizedBox(width: 15),

                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: ThemeColor.lightGrey),
            ],
            if (tempData.origin == OriginFile.public && index == 3) ... [
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        _buildSubPsFiles(storageData.imageBytesFilteredList[3]!, 3),
                        
                        const SizedBox(width: 26),
                        if (storageData.imageBytesFilteredList.length > 4)
                          _buildSubPsFiles(storageData.imageBytesFilteredList[4]!, 4),
              
                        const SizedBox(width: 26),
                        if (storageData.imageBytesFilteredList.length > 5)
                          _buildSubPsFiles(storageData.imageBytesFilteredList[5]!, 5),
              
                        const SizedBox(width: 26),
                        if (storageData.imageBytesFilteredList.length > 6)
                          _buildSubPsFiles(storageData.imageBytesFilteredList[6]!, 6),
              
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(color: ThemeColor.lightGrey),
            ],
            if (tempData.origin == OriginFile.public && !isPsRecent && index > 6) ... [
              if (index == 7)
              Transform.translate(
                offset: const Offset(0, -12),  
                child: const Padding(
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

              IntrinsicHeight(child: _buildPsGridListView(imageBytes, index)),

            ],
            
            if (tempData.origin != OriginFile.public && !togglePhotosPressed)
              IntrinsicHeight(child: _buildDefaultGridListView(imageBytes, index)),

            if (tempData.origin != OriginFile.public && togglePhotosPressed)
              IntrinsicHeight(child: _buildPhotosGridListView(index)),

          ],
        ),
      ),
    );
  }

  Widget _buildPsGridListView(Uint8List imageBytes, int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = inputDate == "Just days" 
      ? "Just now" 
      : DateShortForm(input: inputDate).convert();

    final uploaderName = psStorageData.psUploaderList[index] == userData.username
      ? "${userData.username} (You)"
      : psStorageData.psUploaderList[index];

    return PsGridListView(
      imageBytes: imageBytes,
      index: index,
      uploaderName: uploaderName,
      fileType: fileType,
      originalDateValues: shortFormDate,
      callBottomTrailing: _callBottomTrailing,
      downloadOnPressed: functionModel.downloadFileData,
    );

  }

  Widget _buildDefaultGridListView(Uint8List imageBytes, int index) {

    final lastDotIndex = storageData.fileNamesFilteredList[index].lastIndexOf('.');
    final fileType = lastDotIndex != -1 
      ? storageData.fileNamesFilteredList[index].substring(lastDotIndex) 
      : storageData.fileNamesFilteredList[index];

    return DefaultGridListView(
      imageBytes: imageBytes, 
      index: index,
      fileType: fileType
    );

  }

  Widget _buildPhotosGridListView(int index) {

    final fileType = storageData.fileNamesFilteredList[index].split('.').last;
    final imageBytes = storageData.imageBytesFilteredList[index]!;
    final isSelected = selectedPhotosIndex.contains(index);

    final isSelectionNotEmpty = selectedPhotosIndex.isNotEmpty;

    return PhotosGridListView(
      imageBytes: imageBytes, 
      fileType: fileType,
      isPhotosSelected: isSelected,
      isSelectionNotEmpty: isSelectionNotEmpty,
    );
    
  }

  Widget _buildGridListView() {

    final fitSize = tempData.origin == OriginFile.public ? 5 : 1;

    final paddingValue = tempData.origin == OriginFile.public 
      ? const EdgeInsets.only(top: 2.0) 
      : const EdgeInsets.only(top: 2.0, left: 14.0, right: 14.0, bottom: 2.2);

    return Consumer<StorageDataProvider>(
      builder: (context, storageData, child) {
        return Padding(
          padding: paddingValue,
          child: StaggeredGridView.countBuilder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()
            ),
            controller: scrollListViewController,
            shrinkWrap: true,
            itemCount: storageData.fileNamesFilteredList.length,
            itemBuilder: (context, index) => _buildGridListViewItems(index),
            staggeredTileBuilder: (index) => StaggeredTile.fit(fitSize),
            crossAxisCount: 2,
            mainAxisSpacing: togglePhotosPressed ? 8 : 6.5,
            crossAxisSpacing: togglePhotosPressed ? 8 : 6.5,
          ),
        );
      }
    );
  }

  Widget _buildHomeBody() {

    double mediaHeight = 0.0; 

    final mediaQuery = MediaQuery.of(context).size;

    if (tempData.origin == OriginFile.public) {
      mediaHeight = mediaQuery.height - 162;

    } else {
      mediaHeight = togglePhotosPressed 
        ? mediaQuery.height - 162 
        : mediaQuery.height - 276;

    }

    return RefreshIndicator(
      backgroundColor: ThemeColor.mediumBlack,
      color: ThemeColor.darkPurple,
      onRefresh: () async => _onRefreshListView(),
      child: SizedBox(
        height: mediaHeight,
        child: _buildDefaultOrGridListView(),
      ),
    );

  }

  Widget _buildDefaultOrGridListView() {
    return ValueListenableBuilder<bool>(
      valueListenable: gridListViewSelected,
      builder: (context, isSelected, child) {
        return !isSelected 
          ? _buildResponsiveListView()
          : _buildGridListView();
      }
    );
  }

  Widget _buildResponsiveListView() {

    final fileNamesFilteredList = storageData.fileNamesFilteredList;
    final fileDateFilteredList = storageData.fileDateFilteredList;

    return ResponsiveListView(
      itemOnLongPress: _onSelectItemLongPress,
      itemOnTap: editAllIsPressed ? _onSelectItemLongPress : _navigateToPreviewFile,
      children: (int index) {
        return [
          GestureDetector(
            onTap: () => _callBottomTrailing(index),
            child: editAllIsPressed 
              ? _buildCheckboxItem(index) 
              : const Icon(Icons.more_vert, color: ThemeColor.secondaryWhite),
          ),
        ];
      },
      inlineSpanWidgets: (int index) {
        final originalDateValues = fileDateFilteredList[index];
        final psFilesCategoryTags = originalDateValues.split(' ').sublist(0, originalDateValues.split(' ').length - 1).join(' ');
  
        final isOffline = tempStorageData.offlineFileNameList
                      .contains(fileNamesFilteredList[index]);

        return [

          if (isOffline && WidgetVisibility.setNotVisibleList([OriginFile.sharedMe, OriginFile.sharedOther])) ... [
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(Icons.offline_bolt_rounded, color: ThemeColor.justWhite, size: 16),
              )
            ),
          ],
          
          if(WidgetVisibility.setVisibleList([OriginFile.sharedMe, OriginFile.sharedOther])) 
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(-4, 0),
              child: const Icon(Icons.person, color: ThemeColor.thirdWhite, size: 16)
            )
          ),

          TextSpan(
            text: tempData.origin == OriginFile.public ? psFilesCategoryTags : originalDateValues,
            style: const TextStyle(
              color: ThemeColor.thirdWhite, 
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (tempData.origin == OriginFile.public)
          TextSpan(
            text: " ${psStorageData.psTagsList[index]}",
            style: TextStyle(
              color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
              fontWeight: FontWeight.w500,
              fontSize: 12.8,
            ),
          ),
        ];
      },
    );

  }

  Widget _buildPsSearchButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 8.0),
      child: IconButton(
        icon: const Icon(Icons.search_rounded, size: 26),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileSearchPagePs()
            )
          );
        },
      ),
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
            await Future.delayed(const Duration(milliseconds: 299), () {
              _sortUploadDate();
              _sortUploadDate();
            });
          }

          psButtonTextNotifier.value == "Back" 
            ? await _refreshPublicStorage()
            : await _callMyPublicStorageData();

        },
        style: GlobalsStyle.btnMiniStyle,
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

  Widget _buildFloatingAddItemButton() {
    return ValueListenableBuilder<bool>(
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
    );
  }

  void _initializeOfflineFileNames() async {

    try {

      final offlineDir = await OfflineModel().returnOfflinePath();

      final listOfflineFiles = offlineDir.listSync();

      if(listOfflineFiles.isNotEmpty) {
        final offlineFiles = Set<String>.from(listOfflineFiles.map(
          (entity) => entity.path.split('/').last,
        ));
        tempStorageData.setOfflineFilesName(offlineFiles);

      } else {
        tempStorageData.setOfflineFilesName({});

      }
      
    } catch (err) {
      tempStorageData.setOfflineFilesName({});
    }
    
  }

  void _initializeShowUpgradeOccasionally() async {

    const dayToShow = {DateTime.friday, DateTime.monday, DateTime.wednesday};

    final now = DateTime.now();

    final dayOfWeek = now.weekday;
    final currentHour = now.hour;

    if(dayToShow.contains(dayOfWeek) && 
     ((currentHour >= 6 && currentHour < 11) || 
      (currentHour >= 13 && currentHour < 16) || 
      (currentHour >= 20 && currentHour < 21))) {

      await Future.delayed(const Duration(milliseconds: 759), () {
        if(mounted) {
          UpgradeDialog.buildGetBetterPlanBottomSheet(context: context);
        }      
      });
    }

  }

  void _initializeSharingIntentListener() {

    try {

      intentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream()
      .listen((List<SharedFile> value) {
        final path = value.map((f) => f.value).join(",");
        if(path.isNotEmpty) {
          _navigateToIntentSharing(path);
        } else {
          return;
        }

      }, onError: (err) { return; });

      FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
        final path = value.map((f) => f.value).join(",");
        if(path.isNotEmpty) {
          _navigateToIntentSharing(path);
        } else {
          return;
        }
        
      });

    } catch (err, st) {
      Logger().e("Exception from main {_initializeSharingIntentListener}", err, st);
      return;
    }

  }

  void _navigateToIntentSharing(String filePath) async {

    final file = File(filePath);
    final fileName = file.path.split('/').last;

    final fileBytes = await file.readAsBytes();
    final fileBase64 = base64.encode(fileBytes);

    late String? imagePreview = "";

    final fileType = fileName.split('.').last;
    
    if(Globals.imageType.contains(fileType)) {
      imagePreview = fileBase64;

    } else if (Globals.videoType.contains(fileType)) {
      final generatedThumbnail = await GenerateThumbnail(
        fileName: fileName, 
        filePath: filePath
      ).generate();

      final thumbnailBytes = generatedThumbnail[0] as Uint8List;
      imagePreview = base64.encode(thumbnailBytes);

    } else {
      final getImageAsset = await GetAssets().
        loadAssetsData(Globals.fileTypeToAssets[fileType]!);

      imagePreview = base64.encode(getImageAsset);

    }

    if(mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => 
        IntentSharingPage(
          fileName: fileName, 
          filePath: file.path,
          imageBase64Encoded: imagePreview, 
          fileData: fileBase64
        ))
      );
    }

  }

  @override
  void initState() {
    super.initState();
    _initializeOfflineFileNames();
    _itemSearchingImplementation('');
    _initializeSharingIntentListener();
    _initializeShowUpgradeOccasionally();
  }

  @override 
  void dispose() {
    debounceSearchingTimer!.cancel();
    searchBarFocusNode.dispose();
    searchBarController.dispose();
    scrollListViewController.dispose();
    psButtonTextNotifier.dispose();
    intentDataStreamSubscription.cancel();

    gridListViewSelected.dispose();
    floatingActionButtonVisible.dispose();
    selectAllItemsIconNotifier.dispose();
    ascendingDescendingIconNotifier.dispose();
    searchBarVisibleNotifier.dispose();
    searchHintText.dispose();
    
    tempData.clearFileData();

    NotificationApi.stopNotification(0);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => searchBarFocusNode.unfocus(),
      child: Scaffold(
        key: sidebarMenuScaffoldKey,
        drawer: CustomSideBarMenu(
          usageProgress: _getStorageUsagePercentage(),
          sharedOnPressed: () => _callBottomTrailingShared(),
          offlinePageOnPressed: () async => await _callOfflineData(),
          publicStorageFunction: () async => await _callPublicStorageData(),
        ),
        appBar: _buildCustomAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: _buildSearchBar(),
                ),
                _buildNavigationButtons(),
                storageData.fileNamesList.isEmpty 
                  ? _buildEmptyBody()
                  : _buildHomeBody(),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: _buildFloatingAddItemButton(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          openFolderDialog: _buildFolderBottomSheet, 
          toggleHome: _toggleHome,
          togglePhotos: _togglePhotos,
          togglePublicStorage: _togglePublicStorage, 
          context: context
        ),
      ),
    );
  }

}