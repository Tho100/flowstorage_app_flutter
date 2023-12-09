import 'dart:io';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class ChartUploadCountValue {

  ChartUploadCountValue(this.category, this.totalUpload);

  final String category;
  final int totalUpload;

}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => StatsPageState();
}

class StatsPageState extends State<StatisticsPage> {

  final logger = Logger();
  final crud = Crud();

  final categoryNamesHomeFiles = {'Image', 'Audio', 'Document', 'Video', 'Text'};

  late List<ChartUploadCountValue> data;

  final dataIsLoading = ValueNotifier<bool>(true);

  int totalFilesUpload = 0;
  int totalOfflineFilesUpload = 0;

  int directoryCount = 0;
  int folderCount = 0;

  String categoryWithMostUpload = "";
  String categoryWithLeastUpload = "";

  double usageProgress = 0.0;
  
  List<String> localAccountUsernamesList = [];

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  
  final tempData = GetIt.instance<TempDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  @override
  void initState() {
    super.initState();
    _initializeStatsData();
  }

  @override
  void dispose() {
    dataIsLoading.dispose();
    tempStorageData.statsFileNameList.clear();
    super.dispose();
  }

  Future<void> _readLocalAccountUsernames() async {
    final usernames = await LocalStorageModel().readLocalAccountUsernames();
    localAccountUsernamesList.addAll(usernames);
  }

  Future<void> _initializeStatsData() async {

    try {

      dataIsLoading.value = true;

      final futuresFile = [
        _countFileUpload(GlobalsTable.homeImage),
        _countFileUpload(GlobalsTable.homeAudio),
        _countFileUpload(GlobalsTable.homePdf),
        _countFileUpload(GlobalsTable.homeVideo),
        _countFileUpload(GlobalsTable.homeText),
        _countFileUpload(GlobalsTable.homePtx),
      ];

      final uploadCategoryList = await Future.wait(futuresFile);

      totalFilesUpload = uploadCategoryList
        .reduce((sum, uploadCount) => sum + uploadCount);

      int maxUploadCount = 0;
      int maxCategoryIndex = 0;
      int minUploadCount = 2000;
      int minCategoryIndex = 0;

      for (int i = 0; i < uploadCategoryList.length; i++) {

        final uploadCount = uploadCategoryList[i];

        if (uploadCount > maxUploadCount) {
          maxUploadCount = uploadCount;
          maxCategoryIndex = i;
        }

        if (uploadCount > 0 && uploadCount < minUploadCount) {
          minUploadCount = uploadCount;
          minCategoryIndex = i;
        }
      }

      categoryWithMostUpload = uploadCategoryList[maxCategoryIndex] == 0 ? "None" : categoryNamesHomeFiles.elementAt(maxCategoryIndex);
      categoryWithLeastUpload = categoryNamesHomeFiles.elementAt(minCategoryIndex) == "Image" ? "None" : categoryNamesHomeFiles.elementAt(minCategoryIndex);

      final countDirectories = _countDirectory();

      folderCount = tempStorageData.folderNameList.length;
      directoryCount = countDirectories;

      totalOfflineFilesUpload = await _countOfflineFileUpload();

      final document0 = await _countFileUpload(GlobalsTable.homePdf);
      final document1 = await _countFileUpload(GlobalsTable.homeExcel);
      final document2 = await _countFileUpload(GlobalsTable.homeWord);

      final sumDocument = document0+document1+document2;

      setState(() {
        data = [
          ChartUploadCountValue('Image', uploadCategoryList[0]),
          ChartUploadCountValue('Audio',uploadCategoryList[1]),
          ChartUploadCountValue('Document', sumDocument),
          ChartUploadCountValue('Video', uploadCategoryList[3]),
          ChartUploadCountValue('Text', uploadCategoryList[4])
        ];
      });
      
      dataIsLoading.value = false;

    } catch (err, st) {
      SnakeAlert.errorSnake("No internet connection.");
      logger.e('Exception from _initData {statistics_page}',err,st);
    }

  }

  Future<int> _countFileUpload(String tableName) async {

    try {

      final dataOrigin = tempData.origin != OriginFile.home
        ? tempStorageData.statsFileNameList
        : storageData.fileNamesFilteredList;

      final fileTypeList = <String>[];

      for(int i=0; i<dataOrigin.length; i++) {
        final fileType = dataOrigin.elementAt(i).split('.').last;
        fileTypeList.add(fileType);
      }
      
      int uploadCount = 0;

      for (String fileType in fileTypeList) {
        if (Globals.fileTypesToTableNames.containsKey(fileType) &&
            Globals.fileTypesToTableNames[fileType] == tableName) {
          uploadCount++;
        }
      }

      return uploadCount;

    } catch (err) {
      return 0;
    }

  }

  Future<int> _countOfflineFileUpload() async {

    try {

      final offlineDir = await OfflineMode().returnOfflinePath();
    
      List<FileSystemEntity> files = offlineDir.listSync();
      int fileCount = files.whereType().length;

      return fileCount;

    } catch (err) {
      return 0;
    }

  }

  int _countDirectory() {

    int countDirectory = storageData.fileNamesFilteredList
      .where((dir) => !dir.contains('.')).length;

    return countDirectory;

  }

  Widget _buildInfoUploadedWidget(Size size, String title, String subTitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: size.width-205,
        height: 75,
        decoration: BoxDecoration(
          color: ThemeColor.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColor.darkGrey),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14.0, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  color: ThemeColor.thirdWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 6),
              Text(subTitle,
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTotalUploadWidget(Size size, String title, String numberOfUploads) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: size.width-325,
        height: 75,
        decoration: BoxDecoration(
          color: ThemeColor.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColor.darkGrey),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  color: ThemeColor.thirdWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 6),
              Text(numberOfUploads,
                style: const TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer() {
    
    final mediaQuery = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 5),

        Row(
          children: [
            _buildInfoUploadedWidget(
              mediaQuery, "Most Uploaded", categoryWithMostUpload),
            _buildInfoTotalUploadWidget(
              mediaQuery, "Total Upload", totalFilesUpload.toString()),
          ],
        ),
        Row(
          children: [
            _buildInfoUploadedWidget(
              mediaQuery, "Least Uploaded", categoryWithLeastUpload),
            _buildInfoTotalUploadWidget(
              mediaQuery, "Offline Upload", totalOfflineFilesUpload.toString()),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            _buildInfoTotalUploadWidget(
              mediaQuery, "Directory Count", directoryCount.toString()),
            _buildInfoTotalUploadWidget(
              mediaQuery, "Folder Count", folderCount.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        height: 380,
        width: MediaQuery.of(context).size.width-35,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'File Upload By Type',
            textStyle: const TextStyle(
              color: ThemeColor.whiteGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500
            ),
          ),
          legend: Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<ChartUploadCountValue, String>>[
            ColumnSeries<ChartUploadCountValue, String>(
              color: ThemeColor.darkPurple,
              dataSource: data,
              xValueMapper: (ChartUploadCountValue value, _) => value.category,
              yValueMapper: (ChartUploadCountValue value, _) => value.totalUpload,
              name: 'Files',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatsDetailsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildChart(context),
            const SizedBox(height: 12),
            _buildInfoContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoUsage(String headerText, String subText) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            headerText,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.left,
          ),
          const Spacer(),
          Text(
            subText,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageProgressBar(BuildContext context) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColor.darkBlack,
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          backgroundColor: ThemeColor.lightGrey,
          valueColor: const AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
          value: usageProgress,
        ),
      ),
    );

  }

  Widget _buildLegendUsage() {

    final totalUpload = storageData.fileNamesList.length;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: ThemeColor.darkPurple, 
            border: Border.all(
              color: ThemeColor.darkPurple,
              width: 2.0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("$totalUpload Uploads",
          style: const TextStyle(
            color: ThemeColor.secondaryWhite,
            fontSize: 15,
            fontWeight: FontWeight.w600
          ),
        )
      ],
    );
  }

  Widget _buildLegendLimit() {

    final totalUpload = storageData.fileNamesList.length;
    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;

    final numberOfUploadLeft = (totalUpload-maxValue).abs();

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: ThemeColor.lightGrey, 
            border: Border.all(
              color: ThemeColor.lightGrey,
              width: 2.0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("$numberOfUploadLeft Uploads left",
          style: const TextStyle(
            color: ThemeColor.secondaryWhite,
            fontSize: 15,
            fontWeight: FontWeight.w600
          ),
        )
      ],
    );
  }

  Widget _buildLocalAccountListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: localAccountUsernamesList.length,
      itemExtent: 70,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: ThemeColor.justWhite,
              shape: BoxShape.circle
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                localAccountUsernamesList[index][0],
                style: const TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          title: Text(localAccountUsernamesList[index] == userData.username 
              ? "${localAccountUsernamesList[index]} (Current)" 
              : localAccountUsernamesList[index],
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          ),
        );
      },      
    );
  }

  Widget _buildUsageContainer(BuildContext context) {

    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;
    final totalUpload = storageData.fileNamesList.length;
    final percentage = ((totalUpload/maxValue) * 100).toInt();

    usageProgress = percentage/100.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height-235,
        width: MediaQuery.of(context).size.width-25,
        child: Column(
          children: [
            
            _buildInfoUsage("$totalUpload/$maxValue Uploads", "$percentage%"),
            const SizedBox(height: 12),

            _buildUsageProgressBar(context),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Row(
                children: [
                  _buildLegendUsage(),
                  const SizedBox(width: 25),
                  _buildLegendLimit(),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.only(top: 24, left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Accounts",
                  style: TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<void>(
              future: _readLocalAccountUsernames(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  return _buildLocalAccountListView();

                } else {
                  return const CircularProgressIndicator(color: ThemeColor.darkPurple);

                }
              }
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildUsagePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsageContainer(context),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: ThemeColor.darkPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
     return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statistics",
            style: GlobalsStyle.appBarTextStyle,
          ),
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: ThemeColor.darkPurple,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Usage'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            dataIsLoading.value ? _buildLoading() : _buildStatsDetailsPage(context),
            dataIsLoading.value ? _buildLoading() : _buildUsagePage(context),
          ],
        ),
      ),
    );
  }
}