import 'dart:io';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/models/app_cache.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flowstorage_fsc/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class GaugeChartData {

  final String x;
  final double y;

  GaugeChartData(this.x, this.y);

}

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

  final categoryNamesHomeFiles = {'Image', 'Video', 'Document', 'Audio'};

  late List<ChartUploadCountValue> data;

  final dataIsLoading = ValueNotifier<bool>(true);

  int totalFilesUpload = 0;
  int totalOfflineFilesUpload = 0;

  int directoryCount = 0;
  int folderCount = 0;

  String categoryWithMostUpload = "";
  String categoryWithLeastUpload = "";

  double usageProgress = 0.0;
  
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  
  final tempData = GetIt.instance<TempDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  Future<void> _initializeStatsData() async {

    try {

      dataIsLoading.value = true;

      final futuresFile = [
        _countFileUpload(GlobalsTable.homeImage),
        _countFileUpload(GlobalsTable.homeVideo),
        _countFileUpload(GlobalsTable.homeAudio),
      ];

      final uploadCategoryList = await Future.wait(futuresFile);

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

      folderCount = tempStorageData.folderNameList.length;
      directoryCount = tempStorageData.directoryNameList.length;

      totalOfflineFilesUpload = await _countOfflineFileUpload();

      final pdfDocument = await _countFileUpload(GlobalsTable.homePdf);
      final excelDocument = await _countFileUpload(GlobalsTable.homeExcel);
      final wordDocument = await _countFileUpload(GlobalsTable.homeWord);

      final texts = await _countFileUpload(GlobalsTable.homeText);

      final sumDocument = pdfDocument+excelDocument+wordDocument;

      setState(() {
        data = [
          ChartUploadCountValue('Image', uploadCategoryList[0]),
          ChartUploadCountValue('Video', uploadCategoryList[1]),
          ChartUploadCountValue('Document', sumDocument),
          ChartUploadCountValue('Audio', uploadCategoryList[2]),
        ];
      });
      
      totalFilesUpload = uploadCategoryList.fold(0, (sum, uploadCount) => sum + uploadCount) + sumDocument + texts;

      dataIsLoading.value = false;

    } catch (err, st) {
      SnackAlert.errorSnack("No internet connection.");
      logger.e('Exception from _initData {statistics_page}',err,st);
    }

  }

  Future<int> _countFileUpload(String tableName) async {

    try {

      final dataOrigin = tempData.origin != OriginFile.home
        ? tempStorageData.statsFileNameList
        : storageData.fileNamesFilteredList;

      final fileTypeList = <String>[];

      for(final data in dataOrigin) {
        final fileType = data.split('.').last;
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

      final offlineDir = await OfflineModel().returnOfflinePath();
    
      List<FileSystemEntity> files = offlineDir.listSync();

      return files.whereType().length;

    } catch (err) {
      return 0;
    }

  }

  Widget _buildInfoWidget(String header, String subHeader, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Icon(icon, size: 21),

            const SizedBox(width: 5),

            Text(
              header,
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 18, 18, 18),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              textAlign: TextAlign.left,
            ),

          ],
        ),

        Padding(
          padding: const EdgeInsets.only(left: 2.0, top: 2.0),
          child: Text(subHeader,
            style: GoogleFonts.poppins(
              color: ThemeColor.darkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 22
            ),
            textAlign: TextAlign.left,
          ),
        ),
        
      ],
    );
  }

  Widget _buildInfoContainer() {
    
    final mediaQuery = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: mediaQuery.width-35,
            height: 292,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 16.5, top: 18),
                      child: _buildInfoWidget(
                        "MOST UPLOADED", categoryWithMostUpload, Icons.arrow_upward_outlined),
                    ),

                    const SizedBox(width: 30),

                    Padding(
                      padding: const EdgeInsets.only(left: 16.5, top: 18),
                      child: _buildInfoWidget(
                        "LEAST UPLOADED", categoryWithLeastUpload, Icons.arrow_downward_outlined),
                    ),

                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 16.5, top: 16),
                      child: _buildInfoWidget(
                        "TOTAL UPLOAD", totalFilesUpload.toString(), Icons.stacked_line_chart_outlined),
                    ),

                    const SizedBox(width: 30),

                    Padding(
                      padding: const EdgeInsets.only(left: 33.5, top: 14),
                      child: _buildInfoWidget(
                        "OFFLINE UPLOAD", totalOfflineFilesUpload.toString(), Icons.offline_bolt_outlined),
                    ),

                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 16.5, top: 14),
                      child: _buildInfoWidget(
                        "DIRECTORY COUNT", directoryCount.toString(), Icons.folder_outlined),
                    ),

                    const SizedBox(width: 30),

                    Padding(
                      padding: const EdgeInsets.only(left: 4.5, top: 14),
                      child: _buildInfoWidget(
                        "FOLDER COUNT", folderCount.toString(), Icons.folder_outlined),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildChart(context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.justWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 370,
        width: MediaQuery.of(context).size.width-35,
        child: SfCartesianChart(
          plotAreaBorderColor: ThemeColor.justWhite,
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            axisLine: const AxisLine(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
            minorTickLines: const MinorTickLines(size: 0),
            labelStyle: GoogleFonts.poppins(
              color: ThemeColor.mediumGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500
            ),
          ),
          primaryYAxis: CategoryAxis(
            isVisible: false,
          ),
          legend: Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<ChartUploadCountValue, String>>[
            ColumnSeries<ChartUploadCountValue, String>(
              color: ThemeColor.darkPurple,
              borderRadius: BorderRadius.circular(12),
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

            const SizedBox(height: 5),
            _buildInfoContainer(),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoUsage(String headerText, String subText) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, right: 22.0, top: 28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            headerText,
            style: GoogleFonts.poppins(
              color: ThemeColor.darkGrey,
              fontSize: 15,
              fontWeight: FontWeight.w600
            ),
            textAlign: TextAlign.left,
          ),

          const Spacer(),

          Text(
            subText,
            style: GoogleFonts.poppins(
              color: ThemeColor.darkGrey,
              fontSize: 15,
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
      width: MediaQuery.of(context).size.width - 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LinearProgressIndicator(
          backgroundColor: ThemeColor.darkBlack,
          valueColor: const AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
          value: usageProgress,
        ),
      ),
    );
  }

  Widget _buildLegendUsage() {

    final totalUpload = tempData.origin == OriginFile.offline 
      ? 0 : storageData.fileNamesList.length;

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
          style: GoogleFonts.poppins(
            color: ThemeColor.darkGrey,
            fontSize: 15,
            fontWeight: FontWeight.w600
          ),
        ),

      ],
    );

  }

  Widget _buildLegendLimit() {

    final totalUpload = tempData.origin == OriginFile.offline 
      ? 0 : storageData.fileNamesList.length;
      
    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;

    final numberOfUploadLeft = (totalUpload-maxValue).abs();

    return Row(
      children: [

        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: ThemeColor.darkBlack, 
            border: Border.all(
              color: ThemeColor.darkBlack,
              width: 2.0,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text("$numberOfUploadLeft Uploads left",
          style: GoogleFonts.poppins(
            color: ThemeColor.darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w600
          ),
        ),

      ],
    );

  }

  Widget _buildUsageContainer() {

    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;

    final totalUpload = tempData.origin == OriginFile.offline 
      ? 0 : storageData.fileNamesList.length;

    final percentage = ((totalUpload/maxValue) * 100).toInt();

    usageProgress = percentage/100.0;

    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 8.0, right: 8.0),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width-35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ThemeColor.justWhite,
        ),
        child: Column(
          children: [
            
            _buildInfoUsage("$totalUpload/$maxValue Uploads", "$percentage% Used"),
            const SizedBox(height: 12),

            _buildUsageProgressBar(context),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 22.5),
              child: Row(
                children: [

                  _buildLegendUsage(),

                  const SizedBox(width: 25),

                  _buildLegendLimit(),

                ],
              ),
            ),

          ],
        ),
      ),
    );

  }

  Widget _buildAccountPlanContainer() {

    final accountTypeToColor = {
      'Basic': ThemeColor.darkGrey,
      'Max': const Color.fromARGB(255, 250, 195, 4),
      'Express': const Color.fromARGB(255, 40, 100, 169),
      'Supreme': const Color.fromARGB(255, 74, 3, 164)
    };

    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 8.0, right: 8.0),
      child: GestureDetector(
        onTap: () => NavigatePage.goToPageUpgrade(),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: ThemeColor.justWhite,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                
                Row(
                  children: [

                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("PLAN",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.lightGrey,
                        ),
                      ),
                    ),
      
                    const Spacer(),
      
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        children: [

                          Text("Upgrade",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.lightGrey,
                            ),
                          ),

                          const Icon(Icons.arrow_forward_ios,
                            color: ThemeColor.lightGrey,
                            size: 20,
                          ),

                        ],
                      ),
                    ),
                    
                  ],
                ),
      
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(userData.accountType,
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: accountTypeToColor[userData.accountType],
                    ),
                  ),
                ),
      
              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildDictionaryFolderCount(String header, String totalUpload, String uploadLimit) {
    return Container(
      height: 74,
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ThemeColor.justWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const Icon(Icons.folder_outlined, size: 21),

                const SizedBox(width: 5),

                Text(
                  header,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 18, 18, 18),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.left,
                ),

              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 2.0, top: 4.0),
              child: Text("$totalUpload/$uploadLimit",
                style: GoogleFonts.poppins(
                  color: ThemeColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16
                ),
                textAlign: TextAlign.left,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildAppCache(String cacheSize) {
    return Container(
      height: 153,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ThemeColor.justWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Text(
                  "APP CACHE",
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 18, 18, 18),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(cacheSize,
                style: GoogleFonts.poppins(
                  color: ThemeColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 30
                ),
                textAlign: TextAlign.left,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildUsageGaugeContainer() {

    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;

    final totalUpload = tempData.origin == OriginFile.offline 
      ? 0 : storageData.fileNamesList.length;

    final percentage = ((totalUpload/maxValue) * 100).toInt();

    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ThemeColor.justWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Stack(
          children: [
            
            _buildGaugeChart(
              maxValue: maxValue.toDouble(), 
              dataValue: totalUpload.toDouble(),
              text: "${percentage.toString()}%"
            ),

            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Center(
                child: Text(
                  "${percentage.toString()}%", 
                  style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );

  }

  Widget _buildUsageGaugeByTypeContainer() {

    final maxValue = AccountPlan.mapFilesUpload[userData.accountType]!;

    final isOffline = tempData.origin == OriginFile.offline;

    final fileName = storageData.fileNamesList;

    final totalUploadImage = isOffline
      ? 0 : fileName.where((fileName) => Globals.imageType.contains(fileName.split('.').last)).length;

    final imagePercentage = ((totalUploadImage/maxValue) * 100).toInt();

    final othersTotalUpload = isOffline 
      ? 0 : fileName.length-totalUploadImage;
      
    final othersPercentage = ((othersTotalUpload/maxValue) * 100).toInt();

    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ThemeColor.justWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, top: 6.0, right: 14.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    
                    SizedBox(
                      width: 75,
                      height: 75,
                      child: _buildGaugeChart(
                        maxValue: maxValue.toDouble(), 
                        dataValue: totalUploadImage.toDouble(),
                        customColor: ThemeColor.secondaryPurple,
                        text: "$imagePercentage%",
                        textSize: 12.5
                      ),
                    ),

                    Text(
                      "Image", 
                      style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold
                      ),
                    ),

                  ],
                ),
  
                Row(
                  children: [

                    SizedBox(
                      width: 75,
                      height: 75,
                      child: _buildGaugeChart(
                        maxValue: maxValue.toDouble(), 
                        dataValue: othersTotalUpload.toDouble(),
                        customColor: ThemeColor.thirdWhite,
                        text: "$othersPercentage%",
                        textSize: 12.5
                      ),
                    ),

                    Text(
                      "Others", 
                      style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.bold
                      ),
                    ),

                  ],
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
    
  }

  Widget _buildGaugeChart({
    required double maxValue, 
    required double dataValue, 
    required String text,
    double? textSize,
    Color? customColor,
  }) {
    return Stack(
      children: [

        SfCircularChart(
          series: <CircularSeries>[
            RadialBarSeries<GaugeChartData, String>(
              dataSource: <GaugeChartData>[
                GaugeChartData('Data Point', dataValue), 
              ],
              xValueMapper: (GaugeChartData data, _) => data.x,
              yValueMapper: (GaugeChartData data, _) => data.y,
              trackColor: ThemeColor.darkGrey,
              maximumValue: maxValue,
              innerRadius: '80%',
              cornerStyle: CornerStyle.bothCurve,
              gap: '5%',
              radius: '100%',
              pointColorMapper: (GaugeChartData data, _) {
                return customColor ?? ThemeColor.darkPurple;
              },
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: textSize ?? 20, fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),

      ],
    );
  }

  Future<Widget> _buildUsagePage() async {

    final dictionaryUploadLimit = AccountPlan.mapDirectoryUpload[userData.accountType].toString();
    final dictionaryTotalUpload = tempStorageData.directoryNameList.length.toString();

    final folderUploadLimit = AccountPlan.mapFoldersUpload[userData.accountType].toString();
    final folderTotalUpload = tempStorageData.folderNameList.length.toString();

    final cacheSizeInMb = await AppCache().cacheSizeInMb();
    final cacheToString = "${cacheSizeInMb.toDouble().toStringAsFixed(2)}Mb";

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, bottom: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildUsageContainer(),

            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 14.0, right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: _buildUsageGaugeContainer()
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildUsageGaugeByTypeContainer(),
                  ),

                ],
              ),
            ),

            _buildAccountPlanContainer(),

            Padding(
              padding: const EdgeInsets.only(top: 14, left: 8.0, right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Column(
                    children: [

                      _buildDictionaryFolderCount("DICTIONARY", dictionaryTotalUpload, dictionaryUploadLimit),

                      const SizedBox(height: 5),

                      _buildDictionaryFolderCount("FOLDER", folderTotalUpload, folderUploadLimit),

                    ],
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildAppCache(cacheToString)
                  ),

                ],
              ),
            ),

            const SizedBox(height: 2),

          ],
        ),
      ),
    );
    
  }

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

  @override
  Widget build(BuildContext context) {
     return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          context: context,
          title: "Statistics",
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: CustomTabBar(
              tabs: [

                Tab(
                  child: Text(
                    'Details',
                    style: GlobalsStyle.tabBarTextStyle,
                  ),
                ),

                Tab(
                  child: Text(
                    'Storage',
                    style: GlobalsStyle.tabBarTextStyle,
                  ),
                ),

              ],
            ),
          ),
        ).buildAppBar(),
        body: TabBarView(
          children: [
            dataIsLoading.value ? const LoadingIndicator() : _buildStatsDetailsPage(context),
            dataIsLoading.value ? const LoadingIndicator() : FutureBuilder<Widget>(
              future: _buildUsagePage(),
              builder: (context, snapshot) {
                
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } 

                return snapshot.data!;
                
              },
            ),
          ],
        ),
      ),
    );
  }

}