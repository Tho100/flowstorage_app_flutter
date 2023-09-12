import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ResponsiveListView {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Widget buildListView({
    required Function itemOnLongPress,
    required Function itemOnTap,
    required List<Widget> Function(int index) childrens,
    required List<InlineSpan> Function(int index) inlineSpanWidgets,
  }) {
    const double itemExtentValue = 58.0;
    const double bottomExtraSpacesHeight = 89.0;

    return RawScrollbar(
      radius: const Radius.circular(38),
      thumbColor: ThemeColor.darkWhite,
      minThumbLength: 2,
      thickness: 2,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
        itemExtent: itemExtentValue,
        itemCount: storageData.fileNamesFilteredList.length,
        itemBuilder: (BuildContext context, int index) {

          final fileTitleSearchedValue = storageData.fileNamesFilteredList[index];
          final setLeadingImage = 
            storageData.imageBytesFilteredList.isNotEmpty 
            ? Image.memory(storageData.imageBytesFilteredList[index]!) 
            : null;

          return InkWell(
            onLongPress: () { itemOnLongPress(index); },
            onTap: () { itemOnTap(index); },
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
                  children: childrens(index)
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
                    children: inlineSpanWidgets(index)
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}