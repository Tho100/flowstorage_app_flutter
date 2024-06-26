import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class FileDetailsPage extends StatefulWidget {

  final String fileName;

  const FileDetailsPage({
    required this.fileName,
    Key? key
  }) : super(key: key);

  @override
  State<FileDetailsPage> createState() => FileDetailsPageState();

}

class FileDetailsPageState extends State<FileDetailsPage> {

  final uploaderNameNotifier = ValueNotifier<String>("Unknown");

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final fileTypeMap = {
    "png": "Image",
    "jpg": "Image",
    "jpeg": "Image",

    "pdf": "Document",
    "docx": "Document",
    "doc": "Document",

    "xls": "Spreadsheet",
    "xlsx": "Spreadsheet",

    "pptx": "Presentation",
    "ptx": "Presentation",

    "mp4": "Video",
    "wmv": "Video",
    "avi": "Video",
    "mkv": "Video",
    "mov": "Video",

    "mp3": "Audio",
    "wav": "Audio",

    "txt": "Text",
    "xml": "Text",
    "js": "Text",
    "css": "Text",
    "py": "Text",
    "sql": "Text",
    "md": "Text",
    "csv": "Text",
    "html": "Text",

    "exe": "Executable",
    "apk": "Android Application",
    "msi": "Installer",

  };

  Future<Size> getImageResolution(Uint8List imageBytes) async {
    final image = await decodeImageFromList(imageBytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<String> returnImageSize() async {

    final index = storageData.fileNamesFilteredList.indexOf(widget.fileName);
    final imageBytes = storageData.imageBytesFilteredList.elementAt(index);

    final imageSize = await getImageResolution(imageBytes!);
    final imageWidth = imageSize.width.toInt();
    final imageHeight = imageSize.height.toInt();

    return "${imageWidth}x$imageHeight";

  }

  Future<String> getFileSize() async {

    final fileType = widget.fileName.split('.').last;
    final fileIndex = storageData.fileNamesFilteredList.indexOf(widget.fileName);
    
    Uint8List? fileBytes = Uint8List(0);

    if(tempData.origin != OriginFile.offline) {
      if(tempData.fileByteData.isNotEmpty) {
        fileBytes = tempData.fileByteData;
      } else {
        final currentTable = tempData.origin != OriginFile.home 
        ? Globals.fileTypesToTableNamesPs[fileType]! 
        : Globals.fileTypesToTableNames[fileType]!;

        fileBytes = Globals.imageType.contains(fileType) 
          ? storageData.imageBytesFilteredList[fileIndex] 
          : await RetrieveData().getFileData(
            userData.username, widget.fileName, currentTable);

      }

    } else {
      final offlineDirPath = await OfflineModel().returnOfflinePath();
      final filePath = '${offlineDirPath.path}/${widget.fileName}';

      fileBytes = await File(filePath).readAsBytes();

    }

    final sizeInMb = fileBytes!.lengthInBytes/(1024*1024);

    return sizeInMb.toDouble().toStringAsFixed(2);
    
  }

  Widget buildResolutionForImage() {
    return FutureBuilder<String>(
      future: returnImageSize(), 
      builder: (context, snapshot) {

        if(snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(color: ThemeColor.darkPurple)
          );
        } 

        return Text(snapshot.data!,
          style: GoogleFonts.inter(
            color: ThemeColor.secondaryWhite,
            fontSize: 15,
            fontWeight: FontWeight.w800
          ),
          textAlign: TextAlign.start,
        );
      
      }
    );
  }

  Widget buildFileSize() {
    return FutureBuilder<String>(
      future: getFileSize(), 
      builder: (context, snapshot) {

        if(snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(color: ThemeColor.darkPurple),
          );
        } 
        
        return Text("${snapshot.data!}Mb",
          style: GoogleFonts.inter(
            color: ThemeColor.secondaryWhite,
            fontSize: 15,
            fontWeight: FontWeight.w800
          ),
          textAlign: TextAlign.start,
        );
      
      }
    );
  }

  Widget buildHeader(String title, String subHeader) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(title,
          style: GoogleFonts.inter(
            color: ThemeColor.thirdWhite,
            fontSize: 15,
            fontWeight: FontWeight.w800
          ),
          textAlign: TextAlign.start,
        ),

        const SizedBox(height: 6),

        title == "Resolution" 
          ? buildResolutionForImage() 
          : title == "Size" 
            ? buildFileSize() 
            : Text(subHeader,
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800
            ),
            textAlign: TextAlign.start,
          )
      ],
    );
  }

  String getProperDate(String date) {
    final dotIndex = date.indexOf(GlobalsStyle.dotSeparator);
    return dotIndex != -1 
      ? date.substring(dotIndex + 4) 
      : date;
  }

  Widget buildBody(BuildContext context) {
    
    final fileType = widget.fileName.split('.').last;

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);
    final isOfflineVideo = tempData.origin == OriginFile.offline && Globals.videoType.contains(fileType);

    final index = tempData.origin == OriginFile.publicSearching 
      ? psStorageData.psSearchNameList.indexOf(widget.fileName)
      : storageData.fileNamesFilteredList.indexOf(widget.fileName);
    
    final imageData = tempData.origin == OriginFile.publicSearching 
      ? base64.decode(psStorageData.psSearchImageBytesList.elementAt(index))
      : storageData.imageBytesFilteredList.elementAt(index);

    final uploadDate = getProperDate(storageData.fileDateFilteredList.elementAt(index));
  
    final width = MediaQuery.of(context).size.width;

    final originToLocation = {
      OriginFile.home: "Home",
      OriginFile.directory: "${tempData.directoryName} Directory",
      OriginFile.folder: "${tempData.folderName} Folder",
      OriginFile.offline: "Offline",
      OriginFile.public: "Public Storage",
      OriginFile.publicSearching: "Public Storage (Search)",
      OriginFile.sharedMe: "Shared to Me",
      OriginFile.sharedOther: "Shared to Others",
    };

    return Column(
      children: [

        Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12),
                child: GestureDetector(
                  onTap: () => NavigatePage.goToPagePongGame(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ThemeColor.mediumGrey,
                      ),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    width: width - 25,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        imageData!,
                        width: width - 25,
                        height: 200,
                        fit: isGeneralFile || isOfflineVideo
                          ? BoxFit.scaleDown
                          : BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),

              if (Globals.videoType.contains(fileType))
              const Padding(
                padding: EdgeInsets.all(26.0),
                child: VideoPlaceholderWidget(),
              ),

            ],
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [

                buildHeader("Type", fileTypeMap[fileType]!),

                const SizedBox(width: 28),
                buildHeader("Created", uploadDate),

                const SizedBox(width: 28),
                buildHeader("Size","0Mb"),

              ],
            )
          ),
        ),

        const SizedBox(height: 35),

        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                
                buildHeader("Location", originToLocation[tempData.origin]!),
                const SizedBox(width: 28),

                if(Globals.imageType.contains(fileType))
                buildHeader("Resolution","240x240"),

              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ValueListenableBuilder(
              valueListenable: uploaderNameNotifier,
              builder: (context, value, child) {
                return buildHeader(
                  tempData.origin == OriginFile.sharedOther 
                  ? "Shared To"
                  : "Uploaded By", 
                  value
                );
              },
            ),
          ),
        ),

      ],
    );
  }

  Future<void> initializeUploaderName() async {

    const placeholder = "Unknown";

    final index = tempData.origin == OriginFile.publicSearching 
      ? psStorageData.psSearchNameList.indexOf(widget.fileName)
      : storageData.fileNamesFilteredList.indexOf(widget.fileName);

    final originToUploaderName = {
      OriginFile.home: "${userData.username} (You)",
      OriginFile.directory: "${userData.username} (You)",
      OriginFile.folder: "${userData.username} (You)",
      OriginFile.offline: "${userData.username} (You)",

      OriginFile.publicSearching: (index < 0 || index >= psStorageData.psSearchUploaderList.length)
      ? placeholder
      : (psStorageData.psSearchUploaderList[index] == userData.username
          ? "${psStorageData.psSearchUploaderList[index]} (You)"
          : psStorageData.psSearchUploaderList[index]),
      
      OriginFile.public: (index < 0 || index >= psStorageData.psUploaderList.length)
      ? placeholder
      : (psStorageData.psUploaderList[index] == userData.username
          ? "${psStorageData.psUploaderList[index]} (You)"
          : psStorageData.psUploaderList[index]), 

      OriginFile.sharedMe: (tempStorageData.sharedNameList.isNotEmpty && index >= 0 && index < tempStorageData.sharedNameList.length)
        ? tempStorageData.sharedNameList[index]
        : placeholder,
        
      OriginFile.sharedOther: (tempStorageData.sharedNameList.isNotEmpty && index >= 0 && index < tempStorageData.sharedNameList.length)
        ? tempStorageData.sharedNameList[index]
        : placeholder, 
    };

    uploaderNameNotifier.value = originToUploaderName[tempData.origin]!;

  }

  void copyFileName() {
    Clipboard.setData(ClipboardData(text: widget.fileName));
    CallToast.call(message: "Copied to clipboard.");
  }

  @override
  void initState() {
    super.initState();
    initializeUploaderName();
  }

  @override
  void dispose() {
    uploaderNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55.0),
        child: GestureDetector(
          onTap: () => copyFileName(),
          child: CustomAppBar(
            context: context, 
            title: widget.fileName
          ).buildAppBar(),
        ),
      ),
      body: buildBody(context),
    );
  }

}