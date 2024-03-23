import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
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

  final transformationController = TransformationController();

  void handlePageChange(int index) {
    tempData.setCurrentFileName(filteredNames[index]);
    widget.onPageChanged(); 
  }

  Widget buildImageWidget(int index) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height-65,
            ),
            child: IntrinsicWidth(
              child: InteractiveViewer(
                transformationController: transformationController,
                onInteractionEnd: (details) {
                  transformationController.value = Matrix4.identity();
                },
                child: Image.memory(
                  filteredImages[index]!,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageOnCondition() {

    if (tempData.origin == OriginFile.publicSearching || tempData.origin == OriginFile.public) {
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
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildImageOnCondition();
  }

}