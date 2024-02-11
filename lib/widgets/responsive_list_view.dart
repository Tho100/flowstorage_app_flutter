import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponsiveListView extends StatelessWidget {

  final Function itemOnLongPress;
  final Function itemOnTap;
  final List<Widget> Function(int index) childrens;
  final List<InlineSpan> Function(int index) inlineSpanWidgets;

  const ResponsiveListView({
    required this.itemOnLongPress,
    required this.itemOnTap,
    required this.childrens,
    required this.inlineSpanWidgets,
    Key? key
  }) : super(key: key); 
  
  final itemExtentValue = 65.0;
  final bottomExtraSpacesHeight = 89.0;
  final topExtraSpacesHeight = 5.0;

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
            padding: EdgeInsets.only(bottom: bottomExtraSpacesHeight, top: topExtraSpacesHeight),
            itemExtent: itemExtentValue,
            itemCount: storageData.fileNamesFilteredList.length,
            itemBuilder: (context, index) {
              
              const titleOffset = Offset(-3, -6);
              const subtitleOffset = Offset(-2, -4);

              final fileName = storageData.fileNamesFilteredList[index];
              final fileType = fileName.split('.').last;

              final isGeneralFile = Globals.generalFileTypes.contains(fileType);

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
                      ? Transform.translate(
                        offset: Offset(
                          isGeneralFile ? 2 : 0, 
                          0
                        ),
                        child: ClipRRect(
                          borderRadius: isGeneralFile ? BorderRadius.circular(4) : BorderRadius.circular(6),
                          child: Image(
                            image: setLeadingImage.image,
                            fit: BoxFit.cover,
                            height: isGeneralFile ? 33 : 35,
                            width: isGeneralFile ? 33 : 35,
                          ),
                        ),
                      )
                      : const SizedBox(),
                    trailing: Transform.translate(
                      offset: titleOffset,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: childrens(index),
                      ),
                    ),
                    title: Transform.translate(
                      offset: subtitleOffset,
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: ThemeColor.justWhite,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    subtitle: Transform.translate (
                      offset: const Offset(-2, -4),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: inlineSpanWidgets(index),
                        ),
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