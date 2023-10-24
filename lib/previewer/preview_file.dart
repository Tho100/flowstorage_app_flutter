import 'dart:async';
import 'dart:io';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/rename_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/previewer/preview_audio.dart';
import 'package:flowstorage_fsc/previewer/preview_image.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/previewer/preview_text.dart';
import 'package:flowstorage_fsc/previewer/preview_video.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_username.dart';
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/data_query/update_data.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/file_options.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';

class PreviewFile extends StatefulWidget {

  final String selectedFilename;
  final String fileType;
  final int tappedIndex;

  const PreviewFile({
    Key? key,
    required this.selectedFilename,
    required this.fileType,
    required this.tappedIndex
  }) : super(key: key);

  @override
  PreviewFileState createState() => PreviewFileState();
}

class PreviewFileState extends State<PreviewFile> {

  static final bottomBarVisibleNotifier = ValueNotifier<bool>(true);

  late OriginFile originFrom;
  late String fileType;
  late String currentTable;

  late final ValueNotifier<String> appBarTitleNotifier = 
                                    ValueNotifier<String>('');

  final retrieveData = RetrieveData();
  final retrieveSharingName = SharingName();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  
  final textController = TextEditingController();

  final uploaderNameNotifer = ValueNotifier<String>('');

  final fileSizeNotifier = ValueNotifier<String>('');
  final fileResolutionNotifier = ValueNotifier<String>('');

  final filesWithCustomHeader = {
    GlobalsTable.homeText, GlobalsTable.homeAudio, 
    GlobalsTable.psAudio, GlobalsTable.psText};

  final filesInfrontAppBar = {
    GlobalsTable.homeText, GlobalsTable.homePdf, 
    GlobalsTable.psText, GlobalsTable.psPdf};

  @override
  void initState() {
    super.initState();
    fileType = widget.fileType;
    originFrom = tempData.origin;
    appBarTitleNotifier.value = tempData.selectedFileName;
    _initializeTableName();
    _initializeUploaderName();
  }

  @override
  void dispose() {
    textController.dispose();
    appBarTitleNotifier.dispose();
    uploaderNameNotifer.dispose();
    fileResolutionNotifier.dispose();
    fileSizeNotifier.dispose();
    tempData.clearFileData();
    super.dispose();
  }

  void _initializeTableName() {
    currentTable = tempData.origin != OriginFile.home 
    ? Globals.fileTypesToTableNamesPs[fileType]! 
    : Globals.fileTypesToTableNames[fileType]!;
  }

  void _onSlidingUpdate() async {

    final selectedFileName = tempData.selectedFileName;
    appBarTitleNotifier.value = selectedFileName;

    final fileType = selectedFileName.split('.').last;
    final fileIndex = storageData.fileNamesFilteredList.indexOf(selectedFileName);

    if (Globals.generalFileTypes.contains(fileType) || Globals.videoType.contains(fileType)) {
      _navigateToPreviewFile(selectedFileName, fileType, fileIndex);

    } 

    if (tempData.origin == OriginFile.home) {
      currentTable = Globals.fileTypesToTableNames[fileType]!;

    } else {
      currentTable = Globals.fileTypesToTableNamesPs[fileType]!;

    }

    fileSizeNotifier.value = "";
    fileResolutionNotifier.value = "";

    if (tempData.origin == OriginFile.public) {
      psStorageData.psTitleList[widget.tappedIndex] = psStorageData.psTitleList[fileIndex];
      _initializeUploaderName();

    } else if (tempData.origin == OriginFile.sharedMe || tempData.origin == OriginFile.sharedOther) {
      _initializeUploaderName();

    }

  }

  void _navigateToPreviewFile(String selectedFileName, String fileType, int fileIndex) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PreviewFile(
          selectedFilename: selectedFileName,
          fileType: fileType,
          tappedIndex: fileIndex,
        ),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
  }

  void _openWithOnPressed() async {

    final result = await ExternalApp(
      fileName: tempData.selectedFileName, 
      bytes: tempData.fileByteData
    ).openFileInExternalApp();

    if(result.type != ResultType.done) {
      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
        "No default app to open this file found."
      );
    }

  }

  void _onDeletePressed(String fileName) async {

    final fileExtension = fileName.split('.').last;

    await _deleteFileData(userData.username, fileName, Globals.fileTypesToTableNames[fileExtension]!, context);
    _removeFileFromListView(fileName);

  }

   Future<void> _deleteFileData(String username, String fileName, String tableName, BuildContext context) async {

    try {   

      if(tempData.origin != OriginFile.offline) {

        final encryptVals = EncryptionClass().encrypt(fileName);
        await DeleteData().deleteFiles(username: username, fileName: encryptVals, tableName: tableName);

        storageData.homeImageBytesList.clear();
        storageData.homeThumbnailBytesList.clear();

      } else {

        await OfflineMode().deleteFile(fileName);
        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");

      }

      tempData.clearFileData();
      
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");

      if(!mounted) return;
      NavigatePage.permanentPageMainboard(context);

    } catch (err, st) {
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}");
      Logger().e("Exception from _deletionFile {PreviewFile}", err, st);
    }
    
  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog(
      fileName: fileName, 
      onDeletePressed: () => _onDeletePressed(fileName), 
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

  Future _callBottomTrailling() {
  
    final fileName = appBarTitleNotifier.value;

    return BottomTrailingOptions().buildBottomTrailing(
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
        NavigatePage.goToPageSharing(
            context, tempData.selectedFileName);
      }, 
      onAOPressed: () async {
        Navigator.pop(context);
        await _makeAvailableOffline(fileName: tempData.selectedFileName);
      }, 
      onOpenWithPressed: () {
        _openWithOnPressed();
      },
      context: context
    );
  }

  void _updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    storageData.fileNamesList[indexOldFile] = newFileName;
    storageData.fileNamesFilteredList[indexOldFileSearched] = newFileName;
    tempData.setCurrentFileName(newFileName);
    appBarTitleNotifier.value = newFileName;
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
      SnakeAlert.errorSnake("Failed to rename this file.");
      Logger().e("Exception from _renameFile {main}", err, st);
    }
  }

  void _onRenamePressed(String fileName) async {

    try {

      String newItemValue = RenameDialog.renameController.text;
      String newRenameValue = "$newItemValue.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.");
      } else {
        await _renameFileData(fileName, newRenameValue);
      }
      
    } catch (err, st) {
      Logger().e("Exception from _onRenamePressed {main}", err, st);
    }
  }

  Widget _buildFileDataWidget() {

    if(Globals.imageType.contains(fileType)) {
      return PreviewImage(onPageChanged: _onSlidingUpdate);

    } else if (Globals.videoType.contains(fileType)) {
      return const PreviewVideo();

    } else if (fileType == "pdf") {
      return PreviewPdf();

    } else {
      return _buildPreviewerUnavailable();

    }
    
  }

  void _removeFileFromListView(String fileName) {

    try {

      int indexOfFile = storageData.fileNamesFilteredList.indexOf(fileName);

      if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesList.length) {
        storageData.updateRemoveFile(indexOfFile);
      }
      
    } catch (err, st) {
      Logger().e("Exception on _removeFileFromListView {PreviewFile}", err, st);
    }

  }

  Widget _buildFilePreview() {
    return GestureDetector(
      onTap: () {
        bottomBarVisibleNotifier.value = !bottomBarVisibleNotifier.value;
      },
      child: _buildFileDataWidget(),
    );
  }

  Future<void> _updateTextChanges(String changesUpdate, BuildContext context) async {

    try {

      await UpdateTextData(
        fileName: tempData.selectedFileName, 
        tableName: currentTable,
        userName: userData.username,
        newValue: changesUpdate,
        tappedIndex: widget.tappedIndex
      ).update();

      SnakeAlert.okSnake(message: "Changes saved.", icon: Icons.check);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save changes.");

    }
  }

  Future<void> _makeAvailableOffline({
    required String fileName
  }) async {

    final offlineMode = OfflineMode();
    final singleLoading = SingleTextLoading();

    late final Uint8List fileData;
    final fileType = fileName.split('.').last;

    if(Globals.unsupportedOfflineModeTypes.contains(fileType)) {
      CustomFormDialog.startDialog(ShortenText().cutText(fileName), "This file is unavailable for offline mode.");
      return;
    } 

    singleLoading.startLoading(title: "Preparing...", context: context);

    if(Globals.imageType.contains(fileType)) {
      final imageIndex = storageData.fileNamesFilteredList.indexOf(fileName);
      fileData = storageData.imageBytesFilteredList[imageIndex]!;

    } else {
      fileData = CompressorApi.compressByte(tempData.fileByteData);

    }
    
    await offlineMode.processSaveOfflineFile(fileName: fileName,fileData: fileData);

    singleLoading.stopLoading();

  }

  Future<void> _callFileDownload({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      
      final tableName = tempData.origin != OriginFile.home 
        ? Globals.fileTypesToTableNamesPs[fileType]! 
        : Globals.fileTypesToTableNames[fileType];

      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: fileName, context: context);

      late Uint8List fileData;

      if(tempData.origin != OriginFile.offline) {

        if(Globals.imageType.contains(fileType)) {
          fileData = storageData.imageBytesFilteredList[storageData.fileNamesList.indexOf(fileName)]!;

        } else {
          fileData = CompressorApi.compressByte(tempData.fileByteData);

        }

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName!,
          fileData: fileData
        ).downloadFile();

      } else {  
        await OfflineMode().downloadFile(fileName);

      }
    
      loadingDialog.stopLoading();

      if(!mounted) return;
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been downloaded.",icon: Icons.check);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to download ${ShortenText().cutText(fileName)}");
    }

  }

  Widget _buildBottomButtons({
    required Widget textStyle, 
    required Color color, 
    required double? width, 
    required double? height,
    required String buttonType, 
    required BuildContext context
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9.0, top: 9.0, left: 5, right: 4),
      child: SizedBox(
        width: width, 
        height: height, 
        child: ElevatedButton(
          onPressed: () async {
            
            if(buttonType == "download") {

              await _callFileDownload(fileName: tempData.selectedFileName);

            } else if (buttonType == "comment") {

              NavigatePage.goToPageFileComment(
                context, tempData.selectedFileName);

            } else if (buttonType == "share") {
              
              NavigatePage.goToPageSharing(
                context, tempData.selectedFileName);

            } else if (buttonType == "save") {
              
              final textValue = textController.text;
              final isTextType = Globals.textType.contains(tempData.selectedFileName.split('.').last);

              if(textValue.isNotEmpty && isTextType) {
                await _updateTextChanges(textValue, context);
                return;

              } 

            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: textStyle,
        ),
      ),
    );
  }
  
  void _initializeUploaderName() async {

    const localOriginFrom = {OriginFile.home, OriginFile.folder, OriginFile.directory};
    const sharingOriginFrom = {OriginFile.sharedMe, OriginFile.sharedOther};
  
    final uploaderNameIndex = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);

    if(localOriginFrom.contains(originFrom)) {

      uploaderNameNotifer.value = userData.username;

    } else if (sharingOriginFrom.contains(originFrom)) {
      await Future.delayed(const Duration(milliseconds: 450));
      final uploaderName = originFrom == OriginFile.sharedOther 
        ? await retrieveSharingName.shareToOtherName(usernameIndex: uploaderNameIndex) 
        : await retrieveSharingName.sharerName();
      uploaderNameNotifer.value = uploaderName;

    } else if (originFrom == OriginFile.public) {
      uploaderNameNotifer.value = psStorageData.psUploaderList[uploaderNameIndex];
      
    } else {
      uploaderNameNotifer.value = userData.username;

    }

  }

  Future<Size> _getImageResolution(Uint8List imageBytes) async {
    final image = await decodeImageFromList(imageBytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<Uint8List> _getFileByteData() async {

    if(tempData.origin != OriginFile.offline) {
      if(tempData.fileByteData.isNotEmpty) {
        return tempData.fileByteData;
      } 
      
      return await retrieveData.retrieveDataParams(userData.username, tempData.selectedFileName, currentTable);

    } else {
      final offlineDirPath = await OfflineMode().returnOfflinePath();
      final filePath = '${offlineDirPath.path}/${tempData.selectedFileName}';

      final fileBytes = await File(filePath).readAsBytes();

      return fileBytes;

    }

  }

  Future<String> _getFileSize() async {

    final fileType = tempData.selectedFileName.split('.').last;

    final fileIndex = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    final getFileByte = Globals.imageType.contains(fileType) 
      ? storageData.imageBytesFilteredList[fileIndex] 
      : await _getFileByteData();

    double getSizeMB = getFileByte!.lengthInBytes/(1024*1024);
    return getSizeMB.toDouble().toStringAsFixed(2);
    
  }

  Future<String> _returnImageSize() async {

    final indexImage = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    final imageBytes = storageData.imageBytesFilteredList.elementAt(indexImage);

    final imageSize = await _getImageResolution(imageBytes!);
    final imageWidth = imageSize.width.toInt();
    final imageHeight = imageSize.height.toInt();

    final imageResolution = "${imageWidth}x$imageHeight";

    return imageResolution;
  }

  Widget _buildFileInfoHeader(String headerText, String subHeader) {
    return Padding(
      padding: const EdgeInsets.only(left: 42.0),
      child: Row(
    
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
    
        children: [
          Text(headerText,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(ShortenText().cutText(subHeader, customLength: 30),
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: ThemeColor.secondaryWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ]
      ),
    );
  }

  Future _buildBottomInfo() async {
    
    if(fileResolutionNotifier.value.isEmpty) {

      final fileType = tempData.selectedFileName.split('.').last;

      if (Globals.videoType.contains(fileType) || Globals.imageType.contains(fileType)) {
        fileResolutionNotifier.value = await _returnImageSize();
      } else {
        fileResolutionNotifier.value = "N/A";
      } 

    } 

    if(fileSizeNotifier.value.isEmpty) {
      fileSizeNotifier.value = await _getFileSize();
    }

    if(!mounted) return;

    return showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildFileInfoHeader("File Name", tempData.selectedFileName),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: fileResolutionNotifier,
                builder: (context, value, child) {
                  return _buildFileInfoHeader("File Resolution", value);
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: fileSizeNotifier,
                builder: (context, value, child) {
                  return _buildFileInfoHeader("File Size", "$value Mb");
                },
              ),
            ],
          ),
        );
      },
    );

  }

  Widget _buildFileOnCondition() {
    
    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};
    const audioTables = {GlobalsTable.homeAudio, GlobalsTable.psAudio};

    if(textTables.contains(currentTable)) {
      return PreviewText(controller: textController);
    } else if (audioTables.contains(currentTable)) {
      bottomBarVisibleNotifier.value = false;
      return const PreviewAudio();
    } else {
      return _buildFilePreview();
    }

  }

  Widget _buildCopyTextIconButton() {
    return IconButton(
      onPressed: () {
        final textValue = textController.text;
        Clipboard.setData(ClipboardData(text: textValue));
        CallToast.call(message: "Copied to clipboard");
      },
      icon: const Icon(Icons.copy),
    );
  }

  Widget _buildCommentIconButtonAudio() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => CommentPage(fileName: widget.selectedFilename)),
        );
      },
      icon: const Icon(Icons.comment),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio
      ? const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ThemeColor.darkPurple,
            ThemeColor.secondaryPurple,
          ],
        )
      : null,
      color: currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio ? null : ThemeColor.darkBlack,
    );
  }

  Widget _buildMoreIconButton() {
    return IconButton(
      onPressed: _callBottomTrailling,
      icon: const Icon(Icons.more_vert_rounded),
    );
  }

  Widget _buildInfoIconButton() {
    return IconButton(
      onPressed: _buildBottomInfo,
      icon: const Icon(Icons.info_outlined),
    );
  }

  Widget _buildOpenWithIconButton() {
    return IconButton(
      onPressed: _openWithOnPressed,
      icon: const Icon(Icons.open_in_new_outlined),
    );
  }

  Widget _buildAppBarTitle() {

    if (filesWithCustomHeader.contains(currentTable)) {
      return const SizedBox();
    }

    return ValueListenableBuilder<String>(
      valueListenable: appBarTitleNotifier,
      builder: (context, value, child) {
        final isPublicOrigin = tempData.origin == OriginFile.public;

        return isPublicOrigin
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(value, 
                  style: const TextStyle(
                    color: Color.fromARGB(255,232,232,232),
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                  ),   
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Text(
                  psStorageData.psTitleList[widget.tappedIndex],
                    style: const TextStyle(
                      color: Color.fromARGB(255,232,232,232),
                      fontWeight: FontWeight.w500,
                      fontSize: 17
                  ),   
                  overflow: TextOverflow.ellipsis,
                ),
                  
                const SizedBox(height: 6),

              ],
            )
          : Text(value, style: GlobalsStyle.appBarTextStyle);
      },
    );
  }

  Widget _uploadedByText() {

    const generalOrigin = {
      OriginFile.home, OriginFile.sharedMe, OriginFile.folder, 
      OriginFile.directory, OriginFile.public, OriginFile.offline
    };

    return Text(
      generalOrigin.contains(originFrom) 
      ? "   Uploaded By" : "   Shared To",
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 12,
        color: Color.fromARGB(255, 136, 136, 136),
        fontWeight: FontWeight.w500,
      ),
    );

  }

  Widget _buildBottomBar() {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ThemeColor.darkBlack
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
  
          const Divider(height: 1, color: ThemeColor.lightGrey),

          const SizedBox(height: 2),

          Padding(
            padding: const EdgeInsets.only(left: 6, top: 10), 
            child: SizedBox(
              width: double.infinity,
              child: _uploadedByText()
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15, top: 8),
            child: SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder(
                valueListenable: uploaderNameNotifer,
                builder: (context, value, child) {
                  return Text(
                    value == userData.username ? "$value (You)" : value,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
              ),
            ),
          ),
  
          const Spacer(),
  
          Row(
            
            children: [
  
              const SizedBox(width: 5),
  
              _buildBottomButtons(
                textStyle: const Icon(Icons.comment, size: 22), 
                color: ThemeColor.darkGrey, 
                width: 60, 
                height: 45,
                buttonType: "comment", 
                context: context
              ),
  
              const Spacer(),

              Visibility(
                visible: Globals.textType.contains(tempData.selectedFileName.split('.').last),
                child: _buildBottomButtons(
                  textStyle: const Icon(Icons.save, size: 22), 
                  color: ThemeColor.darkPurple, 
                  width: 60, 
                  height: 45,
                  buttonType: "save",
                  context: context
                ),
              ),

              _buildBottomButtons(
                textStyle: const Icon(Icons.download, size: 22), 
                color: ThemeColor.darkPurple, 
                width: 60, 
                height: 45,
                buttonType: "download",
                context: context
              ),
  
              Visibility(
                visible: tempData.origin != OriginFile.offline,
                child: _buildBottomButtons(
                  textStyle: const Text('SHARE',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                  color: ThemeColor.darkPurple,
                  width: 105,
                  height: 45,
                  buttonType: "share",
                  context: context
                ),
              ),
  
              const SizedBox(width: 5),
  
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildPreviewerUnavailable() {
    return const Center(
      child: Text(
        "(Preview is not available)",
        style: TextStyle(
          color: ThemeColor.secondaryWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget _buildTextHeaderTitle() {

    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};

    return textTables.contains(currentTable) ? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                tempData.selectedFileName.length > 28 ? "${tempData.selectedFileName.substring(0,28)}..." : tempData.selectedFileName,
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
              )),
            ),

            if(tempData.origin == OriginFile.public)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Text(
               psStorageData.psTitleList[widget.tappedIndex],
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                softWrap: true,
                textAlign: TextAlign.start,
              ),
            ),

          ],
        ),
      ],
    ) : const SizedBox();
  }

  Widget _buildBody() {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: Column(
        children: [

          _buildTextHeaderTitle(),

          Expanded(
            child: _buildFileOnCondition(),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: bottomBarVisibleNotifier,
            builder: (context, value, child) {
              return Visibility(
                visible: value,
                child: _buildBottomBar(),
              );
            },
          ),

        ],
      ),
    );
  }

  PreferredSize _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: GestureDetector(
        onTap: () { _copyAppBarTitle(); },
        child: ValueListenableBuilder<bool>(
          valueListenable: bottomBarVisibleNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: currentTable == GlobalsTable.homeImage || currentTable == GlobalsTable.psImage ? bottomBarVisibleNotifier.value : true,
              child: AppBar(
                backgroundColor: filesInfrontAppBar.contains(currentTable) ? ThemeColor.darkBlack : const Color(0x44000000),
                actions: <Widget>[ 

                  if(currentTable == GlobalsTable.homeText || currentTable == GlobalsTable.psText)
                  _buildCopyTextIconButton(),

                  if(currentTable == GlobalsTable.homeAudio || currentTable == GlobalsTable.psAudio)
                  _buildCommentIconButtonAudio(),

                  if(currentTable == GlobalsTable.homePdf || currentTable == GlobalsTable.psPdf)
                  _buildOpenWithIconButton(),

                  _buildInfoIconButton(),
                  _buildMoreIconButton(),

                ],
                titleSpacing: 0,
                elevation: 0,
                centerTitle: false,
                title: _buildAppBarTitle(),
              ),
            );
          },
        ),
      ),
    );
  }



  void _copyAppBarTitle() {
    Clipboard.setData(ClipboardData(text: tempData.selectedFileName));
    CallToast.call(message: "Copied to clipboard");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: filesInfrontAppBar.contains(currentTable) ? false : true,
      appBar: _buildCustomAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          bottomBarVisibleNotifier.value = true;
          return true;
        },
        child: _buildBody()
      ),
    );
  }
}