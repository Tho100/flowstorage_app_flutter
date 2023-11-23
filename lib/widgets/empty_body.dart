import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class EmptyBody extends StatelessWidget {

  final dynamic refreshList;

  EmptyBody({
    required this.refreshList,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildOnEmpty(BuildContext context) {

    const originToHeaderMessage = {
      OriginFile.home: "Nothing to see here",
      OriginFile.directory: "This directory is empty",
      OriginFile.folder: "This folder is empty",
      OriginFile.offline: "No files on this device yet",
    };

    const originToSubMessage = {
      OriginFile.home: "Add a new item",
      OriginFile.directory: "Add a new item",
      OriginFile.folder: "Add a new item",
      OriginFile.offline: "Tap 'Make available offline' on file's menu \nto acess them offline",
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.secondaryWhite,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                originToSubMessage[tempData.origin]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.thirdWhite,
                  fontSize: 18,
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
          color: ThemeColor.darkPurple,
          onRefresh: refreshList,
          child: SizedBox(
            child: ListView(
              shrinkWrap: true,
              children: [
                Visibility(
                  visible: storageData.fileNamesList.isEmpty,
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