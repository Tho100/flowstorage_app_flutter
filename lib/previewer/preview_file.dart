import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/update_data.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/external_app.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/helper/open_dialog.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';
import 'package:flowstorage_fsc/models/function_model.dart';
import 'package:flowstorage_fsc/models/system_toggle.dart';
import 'package:flowstorage_fsc/previewer/preview_audio.dart';
import 'package:flowstorage_fsc/previewer/preview_full_scaled_image.dart';
import 'package:flowstorage_fsc/previewer/preview_image.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/previewer/preview_text.dart';
import 'package:flowstorage_fsc/previewer/preview_video.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/file_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';

class PreviewFile extends StatefulWidget {

  final String selectedFilename;
  final int tappedIndex;

  const PreviewFile({
    Key? key,
    required this.selectedFilename,
    required this.tappedIndex,
  }) : super(key: key);

  @override
  PreviewFileState createState() => PreviewFileState();
}

class PreviewFileState extends State<PreviewFile> {

  static final bottomBarVisibleNotifier = ValueNotifier<bool>(true);

  late final appBarTitleNotifier = ValueNotifier<String>('');

  final uploaderNameNotifier = ValueNotifier<String>('');

  late String currentTable;

  final functionModel = FunctionModel();
  final logger = Logger();

  final tempData = GetIt.instance<TempDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  final userData = GetIt.instance<UserDataProvider>();
  
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

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
    _initializeUIData();
    _initializeTableName();
    _initializeUploaderName();
  }

  @override
  void dispose() {
    appBarTitleNotifier.dispose();
    uploaderNameNotifier.dispose();
    _onClose();
    super.dispose();
  }

  void _onClose() {
    tempData.clearFileData();
    _toggleUIVisibility(true);
  }

  void _initializeUIData() {
    appBarTitleNotifier.value = widget.selectedFilename;
    tempData.setCurrentFileName(widget.selectedFilename);
  }

  void _toggleUIVisibility(bool visible) {
    if(tempData.origin != OriginFile.publicSearching) {
      SystemToggle().toggleStatusBarVisibility(visible);
    }
  }

  void _initializeTableName() {

    final fileType = widget.selectedFilename.split('.').last;

    currentTable = tempData.origin != OriginFile.home 
      ? Globals.fileTypesToTableNamesPs[fileType]! 
      : Globals.fileTypesToTableNames[fileType]!;
    
  }

  void _onSlidingUpdate() {

    final selectedFileName = tempData.selectedFileName;
    
    appBarTitleNotifier.value = selectedFileName;

    final fileType = selectedFileName.split('.').last;
    final fileIndex = storageData.fileNamesFilteredList.indexOf(selectedFileName);

    if (Globals.generalFileTypes.contains(fileType) || Globals.videoType.contains(fileType)) {
      _navigateToPreviewFile(selectedFileName, fileIndex);
    } 

    if (tempData.origin == OriginFile.home) {
      currentTable = Globals.fileTypesToTableNames[fileType]!;
    } 
  
    if ([OriginFile.sharedMe, OriginFile.sharedOther].contains(tempData.origin)) {
      _initializeUploaderName();
    }

  }

  void _initializeUploaderName() async {

    const localOriginFrom = {
      OriginFile.home, OriginFile.folder, OriginFile.directory
    };

    const sharingOriginFrom = {
      OriginFile.sharedMe, OriginFile.sharedOther
    };
  
    final uploaderNameIndex = tempData.origin == OriginFile.publicSearching 
      ? psStorageData.psSearchNameList.indexOf(tempData.selectedFileName)
      : storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);

    if(localOriginFrom.contains(tempData.origin)) {
      uploaderNameNotifier.value = userData.username;

    } else if (sharingOriginFrom.contains(tempData.origin)) {
      final uploaderName = tempStorageData.sharedNameList[widget.tappedIndex];
      uploaderNameNotifier.value = uploaderName;

    } else if ([OriginFile.public, OriginFile.publicSearching].contains(tempData.origin)) {
      if(tempData.origin == OriginFile.public) {
        psStorageData.psTitleList[widget.tappedIndex] = psStorageData.psTitleList[uploaderNameIndex];
        uploaderNameNotifier.value = psStorageData.psUploaderList[uploaderNameIndex];

      } else {
        psStorageData.psSearchTitleList[widget.tappedIndex] = psStorageData.psSearchTitleList[uploaderNameIndex];
        uploaderNameNotifier.value = psStorageData.psSearchUploaderList[uploaderNameIndex];
        
      }
      
    } else {
      uploaderNameNotifier.value = userData.username;

    }

  }

  void _navigateToPreviewFile(String selectedFileName, int fileIndex) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PreviewFile(
          selectedFilename: selectedFileName,
          tappedIndex: fileIndex
        ),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
  }

  void _navigateToFullScaledImage() {
    
    final index = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
    final imageBytes = storageData.imageBytesFilteredList[index];

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PreviewFullScaledImage(
          imageBytes: imageBytes,
        ),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
    
    _toggleUIVisibility(false);

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
        NavigatePage.permanentPageHome(context);
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

  void _updateTextChanges(String changesUpdate) async {

    try {

      await UpdateTextData(
        fileName: tempData.selectedFileName, 
        tableName: currentTable,
        userName: userData.username,
        newValue: changesUpdate,
        tappedIndex: widget.tappedIndex
      ).update();

      SnackAlert.okSnack(message: "Changes saved.", icon: Icons.check);

    } catch (err) {
      SnackAlert.errorSnack("Failed to save changes.");
    }
    
  }

  void _saveTextChangesOnPressed() async {

    final textValue = PreviewText.textController.text;
    final isTextType = Globals.textType.contains(tempData.selectedFileName.split('.').last);

    if(textValue.isNotEmpty && isTextType) {
      PreviewText.isChangesSaved = true;
      _updateTextChanges(textValue);
      return;
    } 

  }

  Future _callBottomTrailing() {

    final fileName = tempData.selectedFileName;

    return BottomTrailingOptions().buildBottomTrailing(
      fileName: fileName, 
      onRenamePressed: () {
        Navigator.pop(context);
        OpenOptionsDialog(
          onPressed: () => _onRenameItemPressed(fileName), 
          fileName: fileName
        ).renameDialog();
      }, 
      onDeletePressed: () {
        OpenOptionsDialog(
          onPressed: () => _onDeleteItemPressed(fileName), 
          fileName: fileName
        ).deleteDialog();
      },
      onDownloadPressed: () async {
        Navigator.pop(context);
        await functionModel.downloadFileData(fileName: fileName);
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
        _makeAvailableOfflineOnPressed(fileName);
      }, 
      onMovePressed: () {
        Navigator.pop(context);
        _openMoveFileOnPressed();
      },
      onOpenWithPressed: () => _openWithOnPressed(),
      context: context
    );
    
  }

  void _openMoveFileOnPressed() async {

    final fileByteData = await functionModel
      .retrieveFileDataPreviewer(isCompressed: true);

    final base64Data = base64.encode(fileByteData);

    NavigatePage.goToPageMoveFile(
      [tempData.selectedFileName], [base64Data]
    );

  }

  Widget _buildFileDataWidget() {

    final fileType = widget.selectedFilename.split('.').last;

    if (Globals.videoType.contains(fileType)) {
      return const PreviewVideo();

    } else if (fileType == "pdf") {
      return const PreviewPdf();

    } 

    return _buildPreviewerUnavailable();
    
  }

  Widget _buildFilePreview() {
    return GestureDetector(
      onTap: () {
        bottomBarVisibleNotifier.value = !bottomBarVisibleNotifier.value;
        _toggleUIVisibility(bottomBarVisibleNotifier.value);
      },
      child: _buildFileDataWidget(),
    );
  }

  Widget _buildFilePreviewOnCondition() {
    
    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};
    const audioTables = {GlobalsTable.homeAudio, GlobalsTable.psAudio};
    const imageTables = {GlobalsTable.homeImage, GlobalsTable.psImage};

    if(textTables.contains(currentTable)) {
      return const PreviewText();

    } else if (imageTables.contains(currentTable)) {
      return GestureDetector(
        onTap: () => _navigateToFullScaledImage(),
        child: PreviewImage(onPageChanged: _onSlidingUpdate)
      );

    } else if (audioTables.contains(currentTable)) {
      bottomBarVisibleNotifier.value = false;
      return const PreviewAudio();

    }
    
    return _buildFilePreview();

  }

  Widget _buildReadingModeIconButton() {
    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        bottomBarVisibleNotifier.value = !bottomBarVisibleNotifier.value;
      },
      icon: bottomBarVisibleNotifier.value 
        ? const Icon(CupertinoIcons.book, size: 26)
        : const Icon(Icons.edit_note_outlined, size: 32),
    );
  }

  Widget _buildMoreIconButton() {
    return Transform.translate(
      offset: const Offset(-4, 0),
      child: IconButton(
        onPressed: _callBottomTrailing,
        icon: const Icon(Icons.pending_outlined, size: 25),
      ),
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
                  style: GoogleFonts.inter(
                    color: const Color.fromARGB(255,232,232,232),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,   
                  ),   
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Text(
                  tempData.origin == OriginFile.public 
                  ? psStorageData.psTitleList[widget.tappedIndex]
                  : psStorageData.psSearchTitleList[widget.tappedIndex],
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255,232,232,232),
                      fontWeight: FontWeight.w800,
                      fontSize: 16
                  ),   
                  overflow: TextOverflow.ellipsis,
                ),
                  
                const SizedBox(height: 6),

              ],
            )
          : Text(value, style: GoogleFonts.inter(
              color: const Color.fromARGB(255, 245, 245, 245),
              fontWeight: FontWeight.w800,
              fontSize: 17,          
          ),
        );
      },
    );
  }

  Widget _buildUploadedByText() {

    const generalOrigin = {
      OriginFile.home, OriginFile.sharedMe, 
      OriginFile.directory, OriginFile.folder,
      OriginFile.public, OriginFile.publicSearching,
      OriginFile.offline,
    };

    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Text(
        generalOrigin.contains(tempData.origin) 
        ? "   Uploaded By" : "   Shared To",
        textAlign: TextAlign.start,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: ThemeColor.darkWhite,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

  }

  void _bottomButtonsOnPressed(String buttonType) async {

    if(buttonType == "download") {
      await functionModel.downloadFileData(
        fileName: tempData.selectedFileName
      );

    } else if (buttonType == "comment") {
      NavigatePage.goToPageFileComment(
        tempData.selectedFileName
      );

    } else if (buttonType == "share") {
      NavigatePage.goToPageSharing(
        tempData.selectedFileName
      );

    } else if (buttonType == "save") {
      _saveTextChangesOnPressed();

    }

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
          onPressed: () => _bottomButtonsOnPressed(buttonType),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: textStyle,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {

    final fileType = tempData.selectedFileName.split('.').last;

    final isShowHideBottomBar = fileType == "pdf";

    return Container(
      height: 135,
      width: MediaQuery.of(context).size.width-15,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 7,
            spreadRadius: 5,
            offset: const Offset(0, 0),
          )
        ],
        color: ThemeColor.justWhite,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 10), 
                child: SizedBox(
                  width: 100,
                  child: _buildUploadedByText()
                ),
              ),

              const Spacer(),

              if(isShowHideBottomBar)
              Transform.translate(
                offset: const Offset(-10, 10),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => bottomBarVisibleNotifier.value = false,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColor.darkBlack,
                      shape: const StadiumBorder(),
                    ), 
                    child: Transform.translate(
                      offset: const Offset(-13, 0),
                      child: const Icon(Icons.keyboard_arrow_down)
                    ),
                  ),
                ),
              ),
            ],
          ),

          Transform.translate(
            offset: Offset(0, isShowHideBottomBar ? -5 : 0),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 6),
              child: SizedBox(
                width: 155,
                child: ValueListenableBuilder(
                  valueListenable: uploaderNameNotifier,
                  builder: (context, value, child) {
                    return Text(
                      value == userData.username 
                        ? "$value (You)" : value,
                      style: GoogleFonts.inter(
                        fontSize: 14.2,
                        color: ThemeColor.darkGrey,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    );
                  }
                ),
              ),
            ),
          ),
    
          const Spacer(),
    
          Row(
            
            children: [

              const SizedBox(width: 5),
    
              _buildBottomButtons(
                textStyle: const Icon(CupertinoIcons.ellipses_bubble, size: 23.5), 
                color: ThemeColor.darkBlack, 
                width: 60, 
                height: 45,
                buttonType: "comment", 
              ),
    
              const Spacer(),
  
              Visibility(
                visible: Globals.textType.contains(fileType),
                child: _buildBottomButtons(
                  textStyle: const Icon(CupertinoIcons.floppy_disk, size: 22.5), 
                  color: ThemeColor.darkBlack, 
                  width: 60, 
                  height: 45,
                  buttonType: "save",
                ),
              ),
  
              _buildBottomButtons(
                textStyle: const Icon(Icons.file_download_outlined, size: 22), 
                color: ThemeColor.darkBlack, 
                width: 60, 
                height: 45,
                buttonType: "download",
              ),
    
              Visibility(
                visible: tempData.origin != OriginFile.offline,
                child: _buildBottomButtons(
                  textStyle: Text('Share', style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w800
                    )
                  ),
                  color: ThemeColor.darkBlack,
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
    return Center(
      child: Text(
        "(Preview is not available)",
        style: GoogleFonts.inter(
          color: ThemeColor.secondaryWhite,
          fontSize: 23,
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  Widget _buildTextHeaderTitle() {

    const textTables = {GlobalsTable.homeText, GlobalsTable.psText};

    if (textTables.contains(currentTable)) {
      final displayFileName =
        tempData.selectedFileName.replaceAll(RegExp(r'\.[^\.]*$'), '');

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 12.0, bottom: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width-45,
                  child: Text(
                    displayFileName,
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              if (WidgetVisibility.setVisibleList([OriginFile.public, OriginFile.publicSearching]))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  tempData.origin == OriginFile.public
                    ? psStorageData.psTitleList[widget.tappedIndex]
                    : psStorageData.psSearchTitleList[widget.tappedIndex],
                  style: GoogleFonts.inter(
                    color: ThemeColor.justWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ),

            ],
          ),

        ],
      );

    } 

    return const SizedBox();

  }

  Widget _buildBody() {
    return Column(
      children: [
      
        _buildTextHeaderTitle(),
  
        Expanded(
          child: _buildFilePreviewOnCondition()
        ),
    
        Transform.translate(
          offset: const Offset(0, -10),
          child: ValueListenableBuilder<bool>(
            valueListenable: bottomBarVisibleNotifier,
            builder: (context, value, child) {
              return AnimatedOpacity(
                opacity: value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Visibility(
                  visible: value,
                  child: _buildBottomBar(context)
                ),
              );
            },
          ),
        ),
        
      ]
    );
  }

  PreferredSize _buildCustomAppBar() {

    const hideableAppBarFile = {
      GlobalsTable.homeImage, GlobalsTable.psImage,
      GlobalsTable.homeVideo, GlobalsTable.psVideo
    };

    final isCenterAppBar = tempData.origin != OriginFile.public && tempData.origin != OriginFile.publicSearching;
    final isAudio = Globals.audioType.contains(tempData.selectedFileName.split('.').last);

    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: GestureDetector(
        onTap: () => _copyAppBarTitle(),
        child: ValueListenableBuilder<bool>(
          valueListenable: bottomBarVisibleNotifier,
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: hideableAppBarFile.contains(currentTable) 
                ? (value ? 1.0 : 0.0) : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Visibility(
                visible: hideableAppBarFile.contains(currentTable)
                  ? bottomBarVisibleNotifier.value
                  : true,
                child: AppBar(
                  centerTitle: isCenterAppBar,
                  backgroundColor: isAudio 
                    ? const Color.fromARGB(0, 0, 0, 0) 
                      : filesInfrontAppBar.contains(currentTable)
                        ? ThemeColor.darkBlack
                        : const Color(0x44000000),
                  actions: _buildAppBarActions(),
                  title: _buildAppBarTitle(),
                ),
              ),
            );
          },
        ),
      ),
    );
    
  }

  List<Widget> _buildAppBarActions() {

    final actions = <Widget>[];

    if ([GlobalsTable.homeText, GlobalsTable.psText].contains(currentTable)) {
      actions.add(_buildReadingModeIconButton());
    }

    actions.add(_buildMoreIconButton());

    return actions;
    
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
      )
    );
  }
  
}