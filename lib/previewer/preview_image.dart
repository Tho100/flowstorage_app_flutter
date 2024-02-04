import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PreviewImage extends StatefulWidget {

  final VoidCallback onPageChanged;

  const PreviewImage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  PreviewImageState createState() => PreviewImageState();
}

class PreviewImageState extends State<PreviewImage> {

  int currentSelectedIndex = 0;

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  late final PageController pageController;

  late final List<String> filteredNames;
  late final List<Uint8List?> filteredImages;
  
  @override
  void initState() {
    super.initState();

    filteredNames = storageData.fileNamesFilteredList
      .where((fileName) => fileName.contains('.')).toList();

    filteredImages = storageData.imageBytesFilteredList
      .asMap()
      .entries
      .where((entry) => storageData.fileNamesFilteredList[entry.key].contains('.'))
      .map((entry) => entry.value)
      .toList();

    currentSelectedIndex = filteredNames.indexOf(tempData.selectedFileName);
    pageController = PageController(initialPage: currentSelectedIndex);
    
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handlePageChange(int index) {
    tempData.setCurrentFileName(filteredNames[index]);
    widget.onPageChanged(); 
  }

  Widget buildImageWidget(int index) {

    final fileTypes = filteredNames[index].split('.').last;

    return InteractiveViewer(
      scaleEnabled: true,
      panEnabled: true,
      child: Container(
        constraints: const BoxConstraints.expand(),
        child: Image.memory(
          filteredImages[index]!,
          fit: Globals.generalFileTypes.contains(fileTypes)
              ? BoxFit.scaleDown
              : BoxFit.fitWidth,
        ),
      ),
    );

  }

  Widget buildImageOnCondition() {

    if (tempData.origin == OriginFile.publicSearching) {
      return buildImageWidget(currentSelectedIndex);

    } else {
      return PageView.builder(
        physics: const ClampingScrollPhysics(),
        controller: pageController,
        itemCount: filteredNames.length,
        onPageChanged: handlePageChange,
        itemBuilder: (context, index) => buildImageWidget(index),
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return buildImageOnCondition();
  }

}