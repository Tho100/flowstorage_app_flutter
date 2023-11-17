import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flowstorage_fsc/widgets/responsive_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class FileSearchPagePs extends StatefulWidget {

  const FileSearchPagePs({super.key});

  @override
  State<FileSearchPagePs> createState() => FileSearchPagePsState();

}

class FileSearchPagePsState extends State<FileSearchPagePs> {

  bool shouldReloadListView = false; 
  bool isSearchingForFile = false; 

  final encryption = EncryptionClass();

  final searchBarController = TextEditingController();
  final scrollListViewController = ScrollController();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final titleList = [];
  final imageBytesList = [];
  final uploaderNameList = [];
  final uploadDateList = [];
  final fileNameList = [];

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

        const SizedBox(height: 12),

        const Divider(color: ThemeColor.lightGrey),

        buildResultWidget(),

      ],
    );
  }

  Future<List<Map<String, String>>> getSearchedFileNameData(String keywordInput) async {

    final query = "SELECT CUST_TITLE, CUST_FILE, CUST_USERNAME, UPLOAD_DATE, CUST_FILE_PATH FROM ps_info_image WHERE CUST_TITLE LIKE '$keywordInput%'";
    
    final conn = await SqlConnection.initializeConnection();
    
    final results = await conn.execute(query);

    List<Map<String, String>> fileDataList = [];

    for (final row in results.rows) {

      final rowAssoc = row.assoc();

      final titleData = rowAssoc['CUST_TITLE']!;
      final usernameData = rowAssoc['CUST_USERNAME']!;
      final uploadDateData = rowAssoc['UPLOAD_DATE']!;
      final fileNameData = encryption.decrypt(rowAssoc['CUST_FILE_PATH']!);
      final imageData = encryption.decrypt(rowAssoc['CUST_FILE']!);

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

  Widget buildOnEmpty() {
    return const Expanded(
      child: Center(
        child: Center(
          child: Text(
            "It's empty here...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(248, 94, 93, 93),
              fontSize: 26,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return ResponsiveSearchBar(
      controller: searchBarController,
      customWidth: 0.98,
      visibility: null, 
      focusNode: null, 
      hintText: "Enter a keyword", 
      onChanged: (String value) {
        //
      }, 
      filterTypeOnPressed: () {
        //
      }
    );
  }

  Widget buildListView() {

    const itemExtentValue = 58.0;
    const bottomExtraSpacesHeight = 89.0;

    return RawScrollbar(
      radius: const Radius.circular(38),
      thumbColor: ThemeColor.darkWhite,
      minThumbLength: 2,
      thickness: 2,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
        itemExtent: itemExtentValue,
        itemCount: titleList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onLongPress: () {
              // Handle long press
            },
            onTap: () {
            },
            child: Ink(
              color: ThemeColor.darkBlack,
              child: ListTile(
                leading: Image.memory(base64.decode(imageBytesList[index]!),
                  fit: BoxFit.cover, height: 40, width: 40
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    1, 
                    (index) => GestureDetector(
                      onTap: () => _callBottomTrailing(index),
                      child: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(
                  titleList[index],
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(uploadDateList[index],
                  style: const TextStyle(color: ThemeColor.secondaryWhite, fontSize: 12.8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildResultWidget() {

    final mediaQuery = MediaQuery.of(context).size.height-180;

    if (isSearchingForFile) {
      return const LoadingIndicator();

    } else if (titleList.isNotEmpty && searchBarController.text.isNotEmpty) {
      return SizedBox(
        height: mediaQuery,
        child: buildListView(),
      );

    } else {
      return buildOnEmpty();

    }
  }

  void _callBottomTrailing(int index) {

  }

  void clearData() {
    titleList.clear();
    fileNameList.clear();
    uploadDateList.clear();
    imageBytesList.clear();
    uploaderNameList.clear();
  }

  void searchFileOnPressed() async {
    
    clearData();

    setState(() {
      isSearchingForFile = true;
    });

    final keywordInput = searchBarController.text;
    final fileDataList = await getSearchedFileNameData(keywordInput);

    for(final fileData in fileDataList) {
      titleList.add(fileData['title']);
      uploadDateList.add(fileData['upload_date']);
      imageBytesList.add(fileData['image']);
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

  @override
  void dispose() {
    searchBarController.dispose();
    scrollListViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Search in Public Storage",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: buildBody(),
    );
  }

}