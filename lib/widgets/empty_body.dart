import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmptyBody extends StatelessWidget {

  final Future<void> Function() refreshList;

  EmptyBody({
    required this.refreshList,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildOnEmpty(BuildContext context) {

    final originToHeaderMessage = {
      OriginFile.home: "Nothing to see here",
      OriginFile.directory: "This directory is empty",
      OriginFile.folder: "This folder is empty",
      OriginFile.offline: "No files on this device yet",
      OriginFile.sharedMe: "No files shared to you yet",
      OriginFile.sharedOther: "You haven't shared any files yet",
    };

    final originToSubMessage = {
      OriginFile.home: "Add a new item",
      OriginFile.directory: "Add a new item",
      OriginFile.folder: "Add a new item",
      OriginFile.offline: "Tap 'Make available offline' on file's menu \nto access them offline",
      OriginFile.sharedMe: "Files shared to you will be shown here",
      OriginFile.sharedOther: "Shared files will be shown here"
    };

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height-375,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                originToHeaderMessage[tempData.origin]!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: ThemeColor.secondaryWhite,
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                originToSubMessage[tempData.origin]!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: ThemeColor.thirdWhite,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    
  }

  @override 
  Widget build(BuildContext context) {
    return Consumer<StorageDataProvider>(
      builder: (context, storageData, child) {
        return RefreshIndicator(
          backgroundColor: ThemeColor.mediumBlack,
          color: ThemeColor.darkPurple,
          onRefresh: refreshList,
          child: SizedBox(
            child: ListView(
              shrinkWrap: true,
              children: [
                Visibility(
                  visible: storageData.fileNamesFilteredList.isEmpty,
                  child: _buildOnEmpty(context),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

}