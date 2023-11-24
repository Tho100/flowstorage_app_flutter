import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flowstorage_fsc/widgets/responsive_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:provider/provider.dart';

class FileSearchPagePs extends StatefulWidget {

  const FileSearchPagePs({super.key});

  @override
  State<FileSearchPagePs> createState() => FileSearchPagePsState();

}

class FileSearchPagePsState extends State<FileSearchPagePs> {

  bool shouldReloadListView = false; 
  bool isSearchingForFile = false; 

  final isTagsVisibleNotifier = ValueNotifier<bool>(true);

  final encryption = EncryptionClass();

  final psSearchBarController = TextEditingController();
  final psSearchBarFocusNode = FocusNode();

  final scrollListViewController = ScrollController();

  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final uploadDateList = [];

  Widget buildBody() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 6.0),
          child: Row(
            children: [
              Flexible(
                child: buildSearchBar(),
              ),
              const SizedBox(width: 10),
              buildSearchButton(),
            ],
          ),
        ),

        ValueListenableBuilder(
          valueListenable: isTagsVisibleNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: Column(
                children: [

                  const SizedBox(height: 16),

                  const Divider(color: ThemeColor.lightGrey, height: 2),

                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 14.0, bottom: 6),
                      child: Text("Tags", 
                        style: TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        buildTagsButton("Entertainment", "en"),
                        buildTagsButton("Data", "en"),
                        buildTagsButton("Creativity", "en"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        buildTagsButton("Software", "en"),
                        buildTagsButton("Education", "en"),
                        buildTagsButton("Gaming", "en"),
                      ],
                    ),
                  ),
                      
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        buildTagsButton("Music", "en"),
                        buildTagsButton("Random", "en"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        ),
                 
        const SizedBox(height: 8),

        const Divider(color: ThemeColor.lightGrey),

        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 14.0, top: 6),
            child: Text("Discover", 
              style: TextStyle(
                color: ThemeColor.secondaryWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),

        buildResultWidget(),

      ],
    );
  }

  Widget buildTagsButton(
    String tagName,  
    String tagType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () async { 

          tempData.setOrigin(OriginFile.public);

          clearSearchingData();

          setState(() {
            isSearchingForFile = true;
          });

          isTagsVisibleNotifier.value = false;

          final fileDataList = await getSearchedFileByTags(tagName);

          for(final fileData in fileDataList) {
            uploadDateList.add(fileData['upload_date']);
            psStorageData.psSearchUploaderList.add(fileData['uploader_name']!);
            psStorageData.psSearchNameList.add(fileData['file_name']!);
            psStorageData.psSearchImageBytesList.add(fileData['image']!);
            psStorageData.setPsSearchTitle(fileData['title']!);
          }

          psSearchBarController.text = "Tag: [$tagName]";

          setState(() {
            shouldReloadListView = !shouldReloadListView;
            isSearchingForFile = false;
          });

        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: GlobalsStyle.psTagsToColor[tagName],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35.0),
          ),
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.label_outline, color: ThemeColor.justWhite), 
            const SizedBox(width: 8),
            Text(tagName),
          ],
        ),
      ),
    );
  }

  Widget buildOnEmpty() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No results found",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColor.secondaryWhite,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Try broadening your search or checking for typos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColor.thirdWhite,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return ResponsiveSearchBar(
      autoFocus: false,
      controller: psSearchBarController,
      focusNode: psSearchBarFocusNode, 
      cancelSearchOnPressed: () {
        isTagsVisibleNotifier.value = true;
        psSearchBarController.clear();    
      },
      customWidth: 0.98,
      visibility: null, 
      hintText: "Enter a keyword", 
      onChanged: (String value) {
        tempData.setOrigin(OriginFile.publicSearching);
      }, 
    );
  }

  Widget buildListView() {

    const itemExtentValue = 90.0;
    const bottomExtraSpacesHeight = 95.0;

    return Consumer<PsStorageDataProvider>(
      builder: (context, storageData, child) {
        return RawScrollbar(
          radius: const Radius.circular(38),
          thumbColor: ThemeColor.darkWhite,
          minThumbLength: 2,
          thickness: 2,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
            itemExtent: itemExtentValue,
            itemCount: storageData.psSearchTitleList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  final fileType = storageData.psSearchNameList[index].split('.').last;
                  openSearchedFile(index, fileType);
                },
                child: Ink(
                  color: ThemeColor.darkBlack,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(base64.decode(psStorageData.psSearchImageBytesList[index]),
                        fit: BoxFit.cover, height: 65, width: 62
                      ),
                    ),
                    title: Transform.translate(
                      offset: const Offset(0, -6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storageData.psSearchTitleList[index],
                            style: const TextStyle(
                              color: ThemeColor.justWhite,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),              
                          const SizedBox(height: 3),      
                          Text(
                            "Uploaded by ${storageData.psSearchUploaderList[index]}",
                            style: const TextStyle(
                              color: ThemeColor.justWhite,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(uploadDateList[index],
                            style: const TextStyle(color: ThemeColor.secondaryWhite, fontSize: 12.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildResultWidget() {

    final mediaQuery = isTagsVisibleNotifier.value == true 
      ? MediaQuery.of(context).size.height-385
      : MediaQuery.of(context).size.height-195;

    final verifySearching = psStorageData.psSearchTitleList.isNotEmpty;

    if (isSearchingForFile) {
      return const LoadingIndicator();

    } else if (verifySearching) {
      return SizedBox(
        height: mediaQuery,
        child: buildListView(),
      );

    } else {
      return buildOnEmpty();

    } 

  }

  Future<List<Map<String, String>>> getSearchedFileData(String keywordInput) async {

    const generalFileTableName = {
      GlobalsTable.psText, 
      GlobalsTable.psPdf, 
      GlobalsTable.psAudio, 
      GlobalsTable.psExcel, 
      GlobalsTable.psWord, 
      GlobalsTable.psExe, 
      GlobalsTable.psApk
    };

    const tableNameToAsset = {
      GlobalsTable.psText: "txt0.jpg",
      GlobalsTable.psPdf: "pdf0.jpg",
      GlobalsTable.psAudio: "music0.jpg",
      GlobalsTable.psExcel: "exl0.jpg",
      GlobalsTable.psWord: "doc0.jpg",
      GlobalsTable.psExe: "exe0.jpg",
      GlobalsTable.psApk: "apk0.jpg",
    };

    List<Map<String, String>> fileDataList = [];

    final conn = await SqlConnection.initializeConnection();

    final queryImage = "SELECT CUST_TITLE, CUST_FILE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_image WHERE CUST_TITLE LIKE '%$keywordInput%'";
    final queryVideo = "SELECT CUST_TITLE, CUST_THUMB, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_video WHERE CUST_TITLE LIKE '%$keywordInput%'";

    final resultsImage = await conn.execute(queryImage);
    final resultsVideo = await conn.execute(queryVideo);

    final dataImage = await processSearchingQueryVideosImages(
      resultsImage, true);

    final dataVideo = await processSearchingQueryVideosImages(
      resultsVideo, false);

    fileDataList.addAll(dataImage);
    fileDataList.addAll(dataVideo);

    for(var tables in generalFileTableName) {
      final query = "SELECT CUST_TITLE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM $tables WHERE CUST_TITLE LIKE '%$keywordInput%'";
      final results = await conn.execute(query);

      final imageData = base64.encode(await GetAssets().loadAssetsData(tableNameToAsset[tables]!));
      final data = await processSearchingQuery(results, imageData);
      fileDataList.addAll(data);

    }

    return fileDataList;

  }

  Future<List<Map<String, String>>> getSearchedFileByTags(String selectedTag) async {

    const generalFileTableName = {
      GlobalsTable.psText, 
      GlobalsTable.psPdf, 
      GlobalsTable.psAudio, 
      GlobalsTable.psExcel, 
      GlobalsTable.psWord, 
      GlobalsTable.psExe, 
      GlobalsTable.psApk
    };

    const tableNameToAsset = {
      GlobalsTable.psText: "txt0.jpg",
      GlobalsTable.psPdf: "pdf0.jpg",
      GlobalsTable.psAudio: "music0.jpg",
      GlobalsTable.psExcel: "exl0.jpg",
      GlobalsTable.psWord: "doc0.jpg",
      GlobalsTable.psExe: "exe0.jpg",
      GlobalsTable.psApk: "apk0.jpg",
    };

    List<Map<String, String>> fileDataList = [];

    final conn = await SqlConnection.initializeConnection();

    const queryImage = "SELECT CUST_TITLE, CUST_FILE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_image WHERE CUST_TAG = :tag";
    const queryVideo = "SELECT CUST_TITLE, CUST_THUMB, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_video WHERE CUST_TAG = :tag";

    final params = {"tag": selectedTag};

    final resultsImage = await conn.execute(queryImage, params);
    final resultsVideo = await conn.execute(queryVideo, params);

    final dataImage = await processSearchingQueryVideosImages(
      resultsImage, true);

    final dataVideo = await processSearchingQueryVideosImages(
      resultsVideo, false);

    fileDataList.addAll(dataImage);
    fileDataList.addAll(dataVideo);

    for(var tables in generalFileTableName) {
      final query = "SELECT CUST_TITLE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM $tables WHERE CUST_TAG = :tag";
      final params = {"tag": selectedTag};
      final results = await conn.execute(query, params);

      final imageData = base64.encode(await GetAssets().loadAssetsData(tableNameToAsset[tables]!));
      final data = await processSearchingQuery(results, imageData);
      fileDataList.addAll(data);

    }

    return fileDataList;

  }

  Future<List<Map<String, String>>> processSearchingQuery(IResultSet results, String assetImage) async {

    List<Map<String, String>> fileDataList = [];

    for (final row in results.rows) {

      final rowAssoc = row.assoc();

      final titleData = rowAssoc['CUST_TITLE']!;
      final usernameData = rowAssoc['CUST_USERNAME']!;
      final uploadDateData = rowAssoc['UPLOAD_DATE']!;
      final fileNameData = encryption.decrypt(rowAssoc['CUST_FILE_PATH']!);
      final imageData = assetImage;

      final dateValueWithDashes = uploadDateData.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);
      final dateString = '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate';

      fileDataList.add({
        'title': titleData, 
        'image': imageData,
        'file_name': fileNameData,
        'upload_date': dateString,
        'uploader_name': usernameData,
      });

    }

    return fileDataList;

  }

  Future<List<Map<String, String>>> processSearchingQueryVideosImages(IResultSet results, bool isFromImage) async {

    List<Map<String, String>> fileDataList = [];

    for (final row in results.rows) {

      final rowAssoc = row.assoc();

      final titleData = rowAssoc['CUST_TITLE']!;
      final usernameData = rowAssoc['CUST_USERNAME']!;
      final uploadDateData = rowAssoc['UPLOAD_DATE']!;
      final fileNameData = encryption.decrypt(rowAssoc['CUST_FILE_PATH']!);
      final imageData = isFromImage 
            ? encryption.decrypt(rowAssoc['CUST_FILE']!) 
            : rowAssoc['CUST_THUMB']!;

      final dateValueWithDashes = uploadDateData.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);
      final dateString = '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate';

      fileDataList.add({
        'title': titleData, 
        'image': imageData,
        'file_name': fileNameData,
        'upload_date': dateString,
        'uploader_name': usernameData,
      });

    }

    return fileDataList;

  }

  void openSearchedFile(int index, String fileType) {

    final fileName = psStorageData.psSearchNameList[index];

    tempData.setCurrentFileName(fileName);
    tempData.setOrigin(OriginFile.publicSearching);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewFile(
          selectedFilename: fileName,
          fileType: fileType,
          tappedIndex: index
        ),
      ),
    );

  }

  void searchFileOnPressed() async {

    if(psSearchBarController.text.isEmpty) {
      return;
    }

    psSearchBarFocusNode.unfocus();
    tempData.setOrigin(OriginFile.public);

    clearSearchingData();

    setState(() {
      isSearchingForFile = true;
    });

    isTagsVisibleNotifier.value = false;

    final keywordInput = psSearchBarController.text;
    final fileDataList = await getSearchedFileData(keywordInput);

    for(final fileData in fileDataList) {
      uploadDateList.add(fileData['upload_date']);
      psStorageData.psSearchUploaderList.add(fileData['uploader_name']!);
      psStorageData.psSearchNameList.add(fileData['file_name']!);
      psStorageData.psSearchImageBytesList.add(fileData['image']!);
      psStorageData.setPsSearchTitle(fileData['title']!);
    }

    setState(() {
      shouldReloadListView = !shouldReloadListView;
      isSearchingForFile = false;
    });

  }

  Widget buildSearchButton() {
    return GestureDetector(
      onTap: () {
        searchFileOnPressed();
      },
      child: Container(
        width: 48.0,
        height: 48.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColor.mediumGrey, 
        ),
        child: const Center(
          child: Icon(
            Icons.search,
            color: Colors.white, 
          ),
        ),
      ),
    );
  }

  void clearSearchingData() {
    uploadDateList.clear();
    psStorageData.psSearchUploaderList.clear();
    psStorageData.psSearchTitleList.clear();
    psStorageData.psSearchImageBytesList.clear();
    psStorageData.psSearchNameList.clear();
  }

  void callOnExit() {
    clearSearchingData();
    setState(() {
      tempData.setOrigin(OriginFile.public);
    });
  }

  void callInitialData() {

    const itemCount = 6;

    List<String> fileName = [];
    List<String> uploadDate = [];
    List<String> uploaderName = [];
    List<String> imageBytes = [];
    List<String> titles = [];

    for (int i = 0; i < itemCount; i++) {
      fileName.add(storageData.fileNamesFilteredList[i]);
      uploadDate.add(storageData.fileDateFilteredList[i]);
      uploaderName.add(psStorageData.psUploaderList[i]);
      imageBytes.add(base64.encode(storageData.imageBytesFilteredList[i]!));
      titles.add(psStorageData.psTitleList[i]);
    }

    uploadDateList.addAll(uploadDate);
    psStorageData.psSearchNameList.addAll(fileName);
    psStorageData.psSearchImageBytesList.addAll(imageBytes);
    psStorageData.psSearchUploaderList.addAll(uploaderName);

    for(var title in titles) {
      psStorageData.setPsSearchTitle(title);
    }

    shouldReloadListView = !shouldReloadListView;
    
    tempData.setOrigin(OriginFile.publicSearching);

  }

  @override
  void dispose() {
    psSearchBarController.dispose();
    scrollListViewController.dispose();
    psSearchBarFocusNode.dispose();
    isTagsVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    callInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        callOnExit();
        return true;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          tempData.setOrigin(OriginFile.public);
          psSearchBarFocusNode.unfocus(); 
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: ThemeColor.darkBlack,
            title: const Text("Search in Public Storage",
              style: GlobalsStyle.appBarTextStyle,
            ),
          ),
          body: buildBody(),
        ),
      ),
    );
  }

}