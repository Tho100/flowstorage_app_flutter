import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/models/function_model.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
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
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/data_query/update_data.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/file_options.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';

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
    required this.tappedIndex,
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

  final functionModel = FunctionModel();
  final logger = Logger();

  final tempData = GetIt.instance<TempDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  final userData = GetIt.instance<UserDataProvider>();
  
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final uploaderNameNotifer = ValueNotifier<String>('');

  final filesWithCustomHeader = {
    GlobalsTable.homeText, GlobalsTable.homeAudio, 
    GlobalsTable.psAudio, GlobalsTable.psText
  };

  final filesInfrontAppBar = {
    GlobalsTable.homeText, GlobalsTable.homePdf, 
    GlobalsTable.psText, GlobalsTable.psPdf
  };

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
    appBarTitleNotifier.dispose();
    uploaderNameNotifer.dispose();
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

    if (tempData.origin == OriginFile.public ||
        tempData.origin == OriginFile.publicSearching || 
        tempData.origin == OriginFile.sharedMe ||
        tempData.origin == OriginFile.sharedOther) {
      _initializeUploaderName();
    }

  }

  void _initializeUploaderName() async {

    const localOriginFrom = {
      OriginFile.home, OriginFile.folder, OriginFile.directory};

    const sharingOriginFrom = {
      OriginFile.sharedMe, OriginFile.sharedOther};
  
    final uploaderNameIndex = tempData.origin == OriginFile.publicSearching 
    ? psStorageData.psSearchNameList.indexOf(tempData.selectedFileName)
    : storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);

    if(localOriginFrom.contains(originFrom)) {
      uploaderNameNotifer.value = userData.username;

    } else if (sharingOriginFrom.contains(originFrom)) {
      final uploaderName = tempStorageData.sharedNameList[widget.tappedIndex];
      uploaderNameNotifer.value = uploaderName;

    } else if (originFrom == OriginFile.public || originFrom == OriginFile.publicSearching) {
      if(tempData.origin == OriginFile.public) {
        psStorageData.psTitleList[widget.tappedIndex] = psStorageData.psTitleList[uploaderNameIndex];
        uploaderNameNotifer.value = psStorageData.psUploaderList[uploaderNameIndex];

      } else {
        psStorageData.psSearchTitleList[widget.tappedIndex] = psStorageData.psSearchTitleList[uploaderNameIndex];
        uploaderNameNotifer.value = psStorageData.psSearchUploaderList[uploaderNameIndex];
        
      }
      
    } else {
      uploaderNameNotifer.value = userData.username;

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
          tappedIndex: fileIndex
        ),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
  }

  void _openWithOnPressed() async {

    final fileByteData = await functionModel
      .retrieveFileDataPreviewer(isCompressed: false);

    final result = await ExternalApp(
      fileName: tempData.selectedFileName, 
      bytes: fileByteData
    ).openFileInExternalApp();

    if(result.type != ResultType.done) {
      CustomFormDialog.startDialog(
        "Couldn't open ${tempData.selectedFileName}",
        "No default app to open this file found."
      );
    }

  }

  void _onDeleteItemPressed(String fileName) async {
    
    try {

      final fileExtension = fileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileExtension]!;

      await functionModel.deleteFileData(
        userData.username, fileName, tableName);

      final indexOfFile = storageData.fileNamesFilteredList.indexOf(fileName);

      if (indexOfFile >= 0 && indexOfFile < storageData.fileNamesFilteredList.length) {
        storageData.updateRemoveFile(indexOfFile);
      }

      tempData.clearFileData();
      
      if(mounted) {
        NavigatePage.permanentPageMainboard(context);
      }

    } catch (err, st) {
      logger.e("Exception from _onRenamePressed {preview_file}", err, st);
    }

  }

  void _makeAvailableOfflineOnPressed(String fileName) async {

    try {

      await functionModel.makeAvailableOffline(fileName: fileName);

    } catch (err, st) {
      logger.e('Exception from _makeAvailableOfflineOnPressed {preview_file}', err, st);
    }

  }

  void _onRenameItemPressed(String fileName) async {

    try {

      final newFileName = RenameDialog.renameController.text;
      final newRenameValue = "$newFileName.${fileName.split('.').last}";

      if (storageData.fileNamesList.contains(newRenameValue)) {
        CustomAlertDialog.alertDialogTitle(newRenameValue, "Item with this name already exists.");
        return;
      } 
    
      functionModel.renameFileData(fileName, newRenameValue);

      appBarTitleNotifier.value = newRenameValue;
      tempData.setCurrentFileName(newRenameValue);
      
    } catch (err, st) {
      logger.e("Exception from _onRenamePressed {preview_file}", err, st);
    }

  }

  void _openDeleteDialog(String fileName) {
    DeleteDialog().buildDeleteDialog(
      fileName: fileName, 
      onDeletePressed: () => _onDeleteItemPressed(fileName), 
      context: context
    );
  }

  void _openRenameDialog(String fileName) {
    RenameDialog().buildRenameFileDialog(
      fileName: fileName, 
      onRenamePressed: () => _onRenameItemPressed(fileName),
      context: context
    );
  }

  void _updateTextChanges(String changesUpdate) async {

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

  void _saveTextChangesOnPressed() async {

    final textValue = PreviewText.textController.text;
    final isTextType = Globals.textType.contains(
        tempData.selectedFileName.split('.').last);

    if(textValue.isNotEmpty && isTextType) {
      _updateTextChanges(textValue);
      return;

    } 

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
        await functionModel.downloadFileData(fileName: fileName);
      }, 
      onDeletePressed: () {
        _openDeleteDialog(fileName);
      },
      onSharingPressed: () {
        Navigator.pop(context);
        NavigatePage.goToPageSharing(
          tempData.selectedFileName);
      }, 
      onDetailsPressed: () {
        Navigator.pop(context);
        NavigatePage.goToPageFileDetails(fileName);
      },
      onAOPressed: () async {
        Navigator.pop(context);
        _makeAvailableOfflineOnPressed(fileName);
      }, 
      onOpenWithPressed: () {
        _openWithOnPressed();
      },
      onMovePressed: () {
        Navigator.pop(context);
        _openMoveFileOnPressed(fileName);
      },
      context: context
    );
  }

  void _openMoveFileOnPressed(String fileName) async {

    final fileByteData = await functionModel
        .retrieveFileDataPreviewer(isCompressed: true);

    final base64Data = base64.encode(fileByteData);

    NavigatePage.goToPageMoveFile(
      [fileName], [base64Data]
    );

  }

  Widget _buildFileDataWidget() {

    if(Globals.imageType.contains(fileType)) {
      return PreviewImage(onPageChanged: _onSlidingUpdate);

    } else if (Globals.videoType.contains(fileType)) {
      return const PreviewVideo();

    } else if (fileType == "pdf") {
      return const PreviewPdf();

    } else {
      return _buildPreviewerUnavailable();

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

  Widget _buildFilePreviewOnCondition() {
    
    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};
    const audioTables = {GlobalsTable.homeAudio, GlobalsTable.psAudio};

    if(textTables.contains(currentTable)) {
      return const PreviewText();

    } else if (audioTables.contains(currentTable)) {
      bottomBarVisibleNotifier.value = false;
      return const PreviewAudio();

    } else {
      return _buildFilePreview();

    }

  }

  Widget _buildReadingModeIconButton() {
    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        bottomBarVisibleNotifier.value = !bottomBarVisibleNotifier.value;
      },
      icon: bottomBarVisibleNotifier.value 
      ? const Icon(Icons.import_contacts_outlined, size: 28)
      : const Icon(Icons.edit_note_outlined, size: 32),
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
      onPressed: () {
        NavigatePage.goToPageFileDetails(
          tempData.selectedFileName);
      },
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
        final isPublicOrigin = tempData.origin == OriginFile.public || tempData.origin == OriginFile.publicSearching;

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
                  tempData.origin == OriginFile.public 
                  ? psStorageData.psTitleList[widget.tappedIndex]
                  : psStorageData.psSearchTitleList[widget.tappedIndex],
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

  Widget _buildUploadedByText() {

    const generalOrigin = {
      OriginFile.home, OriginFile.sharedMe, OriginFile.folder, 
      OriginFile.directory, OriginFile.public, OriginFile.publicSearching,
      OriginFile.offline, 
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

  Widget _buildBottomButtons({
    required Widget textStyle, 
    required Color color, 
    required double width, 
    required double height,
    required String buttonType, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 9.0, left: 5, right: 5),
      child: SizedBox(
        width: width, 
        height: height, 
        child: ElevatedButton(
          onPressed: () async {
            
            if(buttonType == "download") {
              await functionModel.downloadFileData(
                fileName: tempData.selectedFileName);

            } else if (buttonType == "comment") {
              NavigatePage.goToPageFileComment(
                tempData.selectedFileName);

            } else if (buttonType == "share") {
              NavigatePage.goToPageSharing(
                tempData.selectedFileName);

            } else if (buttonType == "save") {
              _saveTextChangesOnPressed();

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
              child: _buildUploadedByText()
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
                ),
              ),

              _buildBottomButtons(
                textStyle: const Icon(Icons.download, size: 22), 
                color: ThemeColor.darkPurple, 
                width: 60, 
                height: 45,
                buttonType: "download",
              ),
  
              Visibility(
                visible: tempData.origin != OriginFile.offline,
                child: _buildBottomButtons(
                  textStyle: const Text('SHARE',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                  color: ThemeColor.darkPurple,
                  width: 105,
                  height: 45,
                  buttonType: "share",
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

    if(textTables.contains(currentTable)) {
      final displayFileName = tempData.selectedFileName.replaceAll(RegExp(r'\.[^\.]*$'), '');

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width-15,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    displayFileName,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 240, 240, 240),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                  )),
                ),
              ),

              if(WidgetVisibility.setVisibileList([OriginFile.public, OriginFile.publicSearching]))
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Text(
                  tempData.origin == OriginFile.public 
                  ? psStorageData.psTitleList[widget.tappedIndex]
                  : psStorageData.psSearchTitleList[widget.tappedIndex],
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
      );

    } else {
      return const SizedBox();

    }

  }

  Widget _buildBody() {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: Column(
        children: [
          
          _buildTextHeaderTitle(),

          Expanded(
            child: _buildFilePreviewOnCondition(),
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

    const hideableAppBarFile = {
      GlobalsTable.homeImage, GlobalsTable.psImage, 
      GlobalsTable.homeVideo, GlobalsTable.psVideo
    };

    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: GestureDetector(
        onTap: () { _copyAppBarTitle(); },
        child: ValueListenableBuilder<bool>(
          valueListenable: bottomBarVisibleNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: hideableAppBarFile.contains(currentTable) ? bottomBarVisibleNotifier.value : true,
              child: AppBar(
                backgroundColor: filesInfrontAppBar.contains(currentTable) ? ThemeColor.darkBlack : const Color(0x44000000),
                actions: <Widget>[ 

                  if(currentTable == GlobalsTable.homeText || currentTable == GlobalsTable.psText)
                  _buildReadingModeIconButton(),
                  
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
      extendBodyBehindAppBar: !filesInfrontAppBar.contains(currentTable),
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