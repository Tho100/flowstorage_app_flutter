import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyBody extends StatelessWidget {

  final dynamic refreshList;

  const EmptyBody({
    required this.refreshList,
    Key? key
  }) : super(key: key);

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
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height-375,
                    child: const Center(
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
                ),
              ],
            ),
          ),
        );
      }
    );
  }

}