import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/pages/public_storage/result_search_page.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/ps_filter_search.dart';
import 'package:flowstorage_fsc/widgets/responsive_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class FileSearchPagePs extends StatefulWidget {

  const FileSearchPagePs({super.key});

  @override
  State<FileSearchPagePs> createState() => FileSearchPagePsState();

}

class FileSearchPagePsState extends State<FileSearchPagePs> {

  bool isSearchingForFile = false; 

  String selectedFilterSearch = "title";

  DateTime now = DateTime.now();

  final isTagsVisibleNotifier = ValueNotifier<bool>(true);

  final searchBarHintTextNotifier = ValueNotifier<String>
                                        ("Enter a keyword");

  final encryption = EncryptionClass();

  final psSearchBarController = TextEditingController();
  final psSearchBarFocusNode = FocusNode();

  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final uploadDateList = <String?>[];

  final generalFileTableName = {
    GlobalsTable.psText, 
    GlobalsTable.psPdf, 
    GlobalsTable.psAudio, 
    GlobalsTable.psExcel, 
    GlobalsTable.psWord, 
    GlobalsTable.psPtx,
    GlobalsTable.psExe, 
    GlobalsTable.psApk
  };

  final tableNameToAsset = {
    GlobalsTable.psText: "txt0.jpg",
    GlobalsTable.psPdf: "pdf0.jpg",
    GlobalsTable.psAudio: "music0.jpg",
    GlobalsTable.psExcel: "exl0.jpg",
    GlobalsTable.psWord: "doc0.jpg",
    GlobalsTable.psExe: "exe0.jpg",
    GlobalsTable.psApk: "apk0.jpg",
    GlobalsTable.psPtx: "pptx0.jpg",
  };

  Widget buildBody() {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 6.0),
          child: Row(
            children: [

              Flexible(
                child: buildSearchBar(),
              ),

              const SizedBox(width: 6),
              buildSearchButton(),

              const SizedBox(width: 6),
              buildMoreOptionsButton(),

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

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0, bottom: 14),
                      child: Text("Tags", 
                        style: GoogleFonts.inter(
                          color: ThemeColor.secondaryWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            buildTagsButton("Entertainment"),
                            buildTagsButton("Data"),
                            buildTagsButton("Creativity"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildTagsButton("Software"),
                          buildTagsButton("Education"),
                          buildTagsButton("Gaming"),
                          buildTagsButton("Music"),
                          buildTagsButton("Random"),
                        ],
                      ),
                    ),
                  ),
                      
                ],
              ),
            );
          }
        ),
                 
        const SizedBox(height: 15),

        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 6, bottom: 10),
            child: Text("Upload date", 
              style: GoogleFonts.inter(
                color: ThemeColor.secondaryWhite,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),

        buildUploadDateButtonsColumn(),

      ],
    );
  }

  Widget buildSearchButton() {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: ThemeColor.lightGrey),
          ),
        ),
        onPressed: () => searchFileOnPressed(),
        child: const Icon(CupertinoIcons.search, color: ThemeColor.justWhite)
      ),
    );
  }

  Widget buildMoreOptionsButton() {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: ThemeColor.lightGrey),
          ),
        ),
        onPressed: () {
          BottomTrailingPsSearchFilter().buildBottomTrailing(
            context: context, 
            onTitlePressed: () {
              selectedFilterSearch = "title";
              searchBarHintTextNotifier.value = "Search title";
            }, 
            onUploaderNamePressed: () {
              selectedFilterSearch = "uploader_name";
              searchBarHintTextNotifier.value = "Search uploader name";
            },
          );
        },
        child: const Icon(CupertinoIcons.ellipsis_vertical, color: ThemeColor.justWhite)
      ),
    );
  }

  Widget buildTagsButton(String tagName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 10.0, top: 1.5),
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: () async => await searchByTagsOnPressed(tagName),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: GlobalsStyle.psTagsToColor[tagName],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.label_outline, color: ThemeColor.justWhite), 
              const SizedBox(width: 8),
              Text(tagName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return ValueListenableBuilder(
      valueListenable: searchBarHintTextNotifier,
      builder: (context, value, child) {
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
          hintText: value, 
          onChanged: (String value) {
            tempData.setOrigin(OriginFile.publicSearching);
          }, 
        );
      }
    );
  }

  Widget buildUploadDateButton({
    required String header, 
    required String subheader,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [

        Expanded(
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 12.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ThemeColor.darkPurple,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: const Icon(Icons.history, color: ThemeColor.justWhite),
                  ),
                
                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        header,
                        style: GlobalsStyle.settingsLeftTextStyle,
                        textAlign: TextAlign.start,
                      ),

                      const SizedBox(height: 10),

                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: SizedBox(
                          width: 305,
                          child: Text(
                            subheader,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: ThemeColor.thirdWhite
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        
      ],
    );
  }

  Widget buildUploadDateButtonsColumn() {
    return Column(
      children: [
        buildUploadDateButton(
          header: "Past day", 
          subheader: "Uploads from last 24 hours",
          onPressed: onPast24HoursPressed
        ),
        buildUploadDateButton(
          header: "Past week",
          subheader: "Uploads from last 7 days",
          onPressed: onPastWeekPressed
        ),
        buildUploadDateButton(
          header: "Past month", 
          subheader: "Uploads from last 30 days",
          onPressed: onPastMonthPressed
        ),
        buildUploadDateButton(
          header: "Past year", 
          subheader: "Uploads from last 365 days",
          onPressed: onPastYearPressed
        ),
      ]
    );
  }

  Future<List<Map<String, String>>> getSearchedFileData(String keywordInput) async {

    List<Map<String, String>> fileDataList = [];

    final filterToQuery = {
      "title": "CUST_TITLE",
      "uploader_name": "CUST_USERNAME"
    };

    final filter = filterToQuery[selectedFilterSearch];

    final conn = await SqlConnection.initializeConnection();

    final queryImage = "SELECT CUST_TITLE, CUST_FILE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_image WHERE $filter LIKE '%$keywordInput%'";
    final queryVideo = "SELECT CUST_TITLE, CUST_THUMB, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_video WHERE $filter LIKE '%$keywordInput%'";

    final resultsImage = await conn.execute(queryImage);
    final resultsVideo = await conn.execute(queryVideo);

    final dataImage = await processSearchingQueryVideosImages(
      resultsImage, true);

    final dataVideo = await processSearchingQueryVideosImages(
      resultsVideo, false);

    fileDataList.addAll(dataImage);
    fileDataList.addAll(dataVideo);

    for(final tables in generalFileTableName) {
      final query = "SELECT CUST_TITLE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM $tables WHERE $filter LIKE '%$keywordInput%'";
      final results = await conn.execute(query);

      final imageData = base64.encode(await GetAssets().loadAssetsData(tableNameToAsset[tables]!));
      final data = await processSearchingQuery(results, imageData);
      fileDataList.addAll(data);

    }

    return fileDataList;

  }

  Future<List<Map<String, String>>> getSearchedFileByDate(
    String startDate, 
    String endDate,
    String filter
  ) async {

    List<Map<String, String>> fileDataList = [];

    final conn = await SqlConnection.initializeConnection();

    final filterQuery = filter == "week" || filter == "month" || filter == "year"
    ? "STR_TO_DATE(UPLOAD_DATE, '%d/%m/%Y') BETWEEN STR_TO_DATE(:startDate, '%d/%m/%Y') AND STR_TO_DATE(:endDate, '%d/%m/%Y')"
    : "UPLOAD_DATE = :date";

    final filterParams = filter == "week" || filter == "month" || filter == "year"
    ? {"startDate": startDate, "endDate": endDate}
    : {"date": startDate};

    final queryImage = "SELECT CUST_TITLE, CUST_FILE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_image WHERE $filterQuery";
    final queryVideo =  "SELECT CUST_TITLE, CUST_THUMB, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_video WHERE $filterQuery";

    final resultsImage = await conn.execute(queryImage, filterParams);
    final resultsVideo = await conn.execute(queryVideo, filterParams);

    final dataImage = await processSearchingQueryVideosImages(
      resultsImage, true);

    final dataVideo = await processSearchingQueryVideosImages(
      resultsVideo, false);

    fileDataList.addAll(dataImage);
    fileDataList.addAll(dataVideo);

    for(final tables in generalFileTableName) {
      final query = "SELECT CUST_TITLE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM $tables WHERE $filterQuery";
      final results = await conn.execute(query, filterParams);

      final imageData = base64.encode(await GetAssets().loadAssetsData(tableNameToAsset[tables]!));
      final data = await processSearchingQuery(results, imageData);
      fileDataList.addAll(data);

    }

    return fileDataList;

  }
  
  Future<void> searchByDateOnPressed(String startDate, String endDate, String filter) async {

    psSearchBarFocusNode.unfocus();

    tempData.setOrigin(OriginFile.public);

    clearSearchingData();

    setState(() {
      isSearchingForFile = true;
    });

    final loading = JustLoading();

    loading.startLoading(context: context);

    final fileDataList = await getSearchedFileByDate(
      startDate, endDate, filter);

    for(final fileData in fileDataList) {
      uploadDateList.add(fileData['upload_date']!);
      psStorageData.psSearchUploaderList.add(fileData['uploader_name']!);
      psStorageData.psSearchNameList.add(fileData['file_name']!);
      psStorageData.psSearchImageBytesList.add(fileData['image']!);
      psStorageData.setPsSearchTitle(fileData['title']!);
    }

    setState(() {
      isSearchingForFile = false;
    });

    loading.stopLoading();

    final filterMap = {
      "24_hours": "From yesterday",
      "week": "From past week",
      "month": "From past month",
      "year": "From past year",
    };

    final title = filterMap[filter];

    if(context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultSearchPagePs(
          selectedCategory: title!, 
          searchDateList: uploadDateList, 
        ))
      );
    }

  }

  Future<void> searchByTagsOnPressed(String tagName) async {

    psSearchBarController.clear();

    tempData.setOrigin(OriginFile.public);

    clearSearchingData();

    setState(() {
      isSearchingForFile = true;
    });

    final loading = JustLoading();

    loading.startLoading(context: context);

    final fileDataList = await getSearchedFileByTags(tagName);

    for(final fileData in fileDataList) {
      uploadDateList.add(fileData['upload_date']!);
      psStorageData.psSearchUploaderList.add(fileData['uploader_name']!);
      psStorageData.psSearchNameList.add(fileData['file_name']!);
      psStorageData.psSearchImageBytesList.add(fileData['image']!);
      psStorageData.setPsSearchTitle(fileData['title']!);
    }

    setState(() {
      isSearchingForFile = false;
    });

    loading.stopLoading();

    if(context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultSearchPagePs(
          selectedCategory: tagName, 
          searchDateList: uploadDateList, 
        ))
      );
    }

  }

  Future<List<Map<String, String>>> getSearchedFileByTags(String selectedTag) async {

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

    for(final tables in generalFileTableName) {
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

      final formattedDate = FormatDate().formatDifference(uploadDateData);

      fileDataList.add({
        'title': titleData, 
        'image': imageData,
        'file_name': fileNameData,
        'upload_date': formattedDate,
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

      final formattedDate = FormatDate().formatDifference(uploadDateData);

      fileDataList.add({
        'title': titleData, 
        'image': imageData,
        'file_name': fileNameData,
        'upload_date': formattedDate,
        'uploader_name': usernameData,
      });

    }

    return fileDataList;

  }

  void openSearchedFile(int index) {

    final fileName = psStorageData.psSearchNameList[index];

    tempData.setCurrentFileName(fileName);
    tempData.setOrigin(OriginFile.publicSearching);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewFile(
          selectedFilename: fileName,
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

    final loading = JustLoading();

    loading.startLoading(context: context);

    final keywordInput = psSearchBarController.text;
    final fileDataList = await getSearchedFileData(keywordInput);

    for(final fileData in fileDataList) {
      uploadDateList.add(fileData['upload_date']!);
      psStorageData.psSearchUploaderList.add(fileData['uploader_name']!);
      psStorageData.psSearchNameList.add(fileData['file_name']!);
      psStorageData.psSearchImageBytesList.add(fileData['image']!);
      psStorageData.setPsSearchTitle(fileData['title']!);
    }

    setState(() {
      isSearchingForFile = false;
    });

    loading.stopLoading();

    if(context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultSearchPagePs(
          selectedCategory: keywordInput, 
          searchDateList: uploadDateList, 
        ))
      );
    }

  }

  void onPastWeekPressed() async {

    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final startDate = DateFormat('dd/MM/yyyy').format(oneWeekAgo);
    final endDate = DateFormat('dd/MM/yyyy').format(now);

    await searchByDateOnPressed(startDate, endDate, "week");

  }

  void onPastYearPressed() async {

    final oneYearAgo = now.subtract(const Duration(days: 365));

    final startDate = DateFormat('dd/MM/yyyy').format(oneYearAgo);
    final endDate = DateFormat('dd/MM/yyyy').format(now);

    await searchByDateOnPressed(startDate, endDate, "year");

  }

  void onPastMonthPressed() async {

    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    final startDate = DateFormat('dd/MM/yyyy').format(oneMonthAgo);
    final endDate = DateFormat('dd/MM/yyyy').format(now);

    await searchByDateOnPressed(startDate, endDate, "month");

  }

  void onPast24HoursPressed() async {

    final todayDate = DateFormat('dd/MM/yyyy').format(now);
    await searchByDateOnPressed(todayDate, "none", "24_hours");

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

    for(final title in titles) {
      psStorageData.setPsSearchTitle(title);
    }
    
    tempData.setOrigin(OriginFile.publicSearching);

  }

  @override
  void dispose() {
    psSearchBarController.dispose();
    psSearchBarFocusNode.dispose();
    isTagsVisibleNotifier.dispose();
    searchBarHintTextNotifier.dispose();
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
        onTap: () {
          tempData.setOrigin(OriginFile.public);
          psSearchBarFocusNode.unfocus(); 
        },
        child: Scaffold(
          appBar: CustomAppBar(
            context: context,
            title: "Search in Public Storage",
            customBackOnPressed: () {
              callOnExit();
              Navigator.pop(context);
            }
          ).buildAppBar(),
          body: buildBody(),
        ),
      ),
    );
  }

}