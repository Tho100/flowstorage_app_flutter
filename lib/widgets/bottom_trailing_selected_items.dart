import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingSelectedItems {

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback makeAoOnPressed,
    required VoidCallback saveOnPressed,
    required VoidCallback deleteOnPressed
  }) {

    final tempData = GetIt.instance<TempDataProvider>();

    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      tempData.appBarTitle,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                saveOnPressed();
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.download_rounded),
                  SizedBox(width: 10.0),
                  Text(
                    'Save to device',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisible("offlineFiles"),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  makeAoOnPressed();
                },
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt_rounded),
                    SizedBox(width: 10.0),
                    Text(
                      'Make available offline',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteOnPressed();
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.delete,color: ThemeColor.darkRed),
                  SizedBox(width: 10.0),
                  Text('Delete',
                    style: TextStyle(
                      color: ThemeColor.darkRed,
                      fontSize: 17,
                    )
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }
}