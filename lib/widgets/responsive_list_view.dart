import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ResponsiveListView extends StatelessWidget {

  final Function itemOnLongPress;
  final Function itemOnTap;
  final List<Widget> Function(int index) childrens;
  final List<InlineSpan> Function(int index) inlineSpanWidgets;

  ResponsiveListView({
    required this.itemOnLongPress,
    required this.itemOnTap,
    required this.childrens,
    required this.inlineSpanWidgets,
    Key? key
  }) : super(key: key); 

  final tempData = GetIt.instance<TempDataProvider>();

  final double itemExtentValue = 58.0;
  final double bottomExtraSpacesHeight = 89.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageDataProvider>(
      builder: (context, storageData, child) {
        return RawScrollbar(
          radius: const Radius.circular(38),
          thumbColor: ThemeColor.darkWhite,
          minThumbLength: 2,
          thickness: 2,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: bottomExtraSpacesHeight),
            itemExtent: itemExtentValue,
            itemCount: storageData.fileNamesFilteredList.length,
            itemBuilder: (BuildContext context, int index) {
              
              final fileTitleSearchedValue = storageData.fileNamesFilteredList[index];
              final setLeadingImage = storageData.imageBytesFilteredList.isNotEmpty
                  ? Image.memory(storageData.imageBytesFilteredList[index]!)
                  : null;

              return InkWell(
                onLongPress: () {
                  itemOnLongPress(index);
                },
                onTap: () {
                  itemOnTap(index);
                },
                child: Ink(
                  color: ThemeColor.darkBlack,
                  child: ListTile(
                    leading: setLeadingImage != null
                        ? Image(
                            image: setLeadingImage.image,
                            fit: BoxFit.cover,
                            height: 31,
                            width: 31,
                          )
                        : const SizedBox(),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: childrens(index),
                    ),
                    title: Text(
                      fileTitleSearchedValue,
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: inlineSpanWidgets(index),
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

}