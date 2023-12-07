import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => AcitivtyPageState();
}

class AcitivtyPageState extends State<ActivityPage> {

  final storageData = GetIt.instance<StorageDataProvider>();
  //final storageData = GetIt.instance<StorageDataProvider>();

  Widget buildBody(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        
        buildPublicStorageBanner(width),

        const SizedBox(height: 8),

        const Divider(color: ThemeColor.lightGrey),

        const SizedBox(height: 8),

        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, left: 18.0),
            child: Row(
              children: [
                Icon(Icons.schedule_outlined, color: ThemeColor.justWhite, size: 25),
                SizedBox(width: 8),
                Text("Recent", 
                  style: TextStyle(
                    color: ThemeColor.justWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 18
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 285,
          width: width-18,
          child: buildRecentListView()
        ),

      ],
    );
  }
  
  Widget buildRecentListView() {

    final filteredNames = storageData.fileNamesFilteredList
      .where((fileName) => fileName.contains('.')).toList();

    final filteredDate = storageData.fileDateFilteredList
      .asMap()
      .entries
      .where((entry) => storageData.fileNamesFilteredList[entry.key].contains('.'))
      .map((entry) {
        final fullDate = entry.value;
        final dotIndex = fullDate.indexOf(' • ');
        if (dotIndex != -1 && dotIndex + 4 < fullDate.length) {
          return fullDate.substring(dotIndex + 4);
        }
        return fullDate;
      })
      .toList();

    return ListView.builder(
      itemCount: filteredNames.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {

        final fileType = filteredNames[index].split('.').last;

        final filteredImages = storageData.imageBytesFilteredList
          .asMap()
          .entries
          .where((entry) => storageData.fileNamesFilteredList[entry.key].contains('.'))
          .map((entry) => entry.value)
          .toList()[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: 145,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(filteredImages!,
                      fit: Globals.generalFileTypes.contains(fileType) ? BoxFit.scaleDown : BoxFit.cover, 
                      height: 225, width: 145
                    ),
                  ),

                  if(Globals.videoType.contains(fileType))
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 12),
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
              
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 145,
                  child: Text(filteredNames[index],
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Align(
                alignment: Alignment.bottomLeft,
                child: Text(filteredDate[index],
                  style: const TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget buildPublicStorageBanner(double width) {
    return GestureDetector(
      onTap: () {
        //TODO: Bring user to public page
      },
      child: Container(
        width: width-32,
        height: 100,
        decoration: BoxDecoration(
          color: ThemeColor.justWhite,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
    
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Transform.scale(
                scale: 1.2,
                child: Image.asset('assets/images/public_icon.jpg')
              ),
            ),
    
            const SizedBox(width: 25),
    
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Discover Public Storage",
                  style: TextStyle(
                    color: ThemeColor.darkWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 2),
                Text("Open community for cloud storage",  
                  style: TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
    
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Activity",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: buildBody(context),
    );
  }

}