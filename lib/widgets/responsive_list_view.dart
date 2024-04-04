import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponsiveListView extends StatelessWidget {

  final Function itemOnLongPress;
  final Function itemOnTap;
  final List<Widget> Function(int index) children;
  final List<InlineSpan> Function(int index) inlineSpanWidgets;

  const ResponsiveListView({
    required this.itemOnLongPress,
    required this.itemOnTap,
    required this.children,
    required this.inlineSpanWidgets,
    Key? key
  }) : super(key: key); 
  
  final itemExtentValue = 68.0;
  final bottomExtraSpacesHeight = 89.0;
  final topExtraSpacesHeight = 5.0;
  final leftExtraSpaces = 4.0;

  @override
  Widget build(BuildContext context) {    
    return Consumer<StorageDataProvider>(
      builder: (context, storageData, child) {
        return RawScrollbar(
          thumbColor: ThemeColor.darkWhite,
          minThumbLength: 2,
          thickness: 2,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()
            ),
            padding: EdgeInsets.only(bottom: bottomExtraSpacesHeight, top: topExtraSpacesHeight, left: leftExtraSpaces),
            itemExtent: itemExtentValue,
            itemCount: storageData.fileNamesFilteredList.length,
            itemBuilder: (context, index) {

              final fileName = storageData.fileNamesFilteredList[index];
              final fileType = fileName.split('.').last;

              final isGeneralFile = Globals.generalFileTypes.contains(fileType);

              const titleOffset = Offset(-3, -6);
              const subtitleOffset = Offset(-2, -4);
              const trailingOffset = Offset(5, -4);

              final leadingXOffset = isGeneralFile ? 2.0 : 0.0;
              const leadingYOffset = 0.0;

              final setLeadingImage = storageData.imageBytesFilteredList.isNotEmpty
                ? Image.memory(storageData.imageBytesFilteredList[index]!)
                : null;

              return InkWell(
                onLongPress: () => itemOnLongPress(index),
                onTap: () => itemOnTap(index),
                child: Ink(
                  color: ThemeColor.darkBlack,
                  child: ListTile(
                    leading: setLeadingImage != null
                      ? Transform.translate(
                        offset: Offset(
                          leadingXOffset, 
                          leadingYOffset
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
                    title: Transform.translate(
                      offset: titleOffset,
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    subtitle: Transform.translate(
                      offset: subtitleOffset,
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: inlineSpanWidgets(index),
                        ),
                      ),
                    ),
                    trailing: Transform.translate(
                      offset: trailingOffset,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: children(index),
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