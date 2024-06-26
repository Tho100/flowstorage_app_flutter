import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class Globals {

  static final _tempData = GetIt.instance<TempDataProvider>();

  static const Set<String> imageType = {"png","jpeg","jpg"};
  static const Set<String> textType = {"txt","csv","html","sql","md","py","xml","js","css"};
  static const Set<String> videoType = {"mp4","wmv","avi","mov","mkv"};
  static const Set<String> wordType = {"docx","doc"};
  static const Set<String> excelType = {"xls","xlsx"};
  static const Set<String> ptxType = {"pptx","ptx"};
  static const Set<String> audioType = {"wav","mp3"};

  static const Map<String, String> fileTypesToTableNames = {
    'png': GlobalsTable.homeImage,
    'jpg': GlobalsTable.homeImage,
    'jpeg': GlobalsTable.homeImage,

    'txt': GlobalsTable.homeText,
    'xml': GlobalsTable.homeText,
    'js': GlobalsTable.homeText,
    'css': GlobalsTable.homeText,
    'py': GlobalsTable.homeText,
    'sql': GlobalsTable.homeText,
    'md': GlobalsTable.homeText,
    'csv': GlobalsTable.homeText,
    'html': GlobalsTable.homeText,

    'pdf': GlobalsTable.homePdf,

    'doc': GlobalsTable.homeWord,
    'docx': GlobalsTable.homeWord,

    'pptx': GlobalsTable.homePtx,
    'ptx': GlobalsTable.homePtx,

    'xlsx': GlobalsTable.homeExcel,
    'xls': GlobalsTable.homeExcel,

    'exe': GlobalsTable.homeExe,
    'msi': GlobalsTable.homeMsi,
    'apk': GlobalsTable.homeApk,

    'mp4': GlobalsTable.homeVideo,
    'avi': GlobalsTable.homeVideo,
    'mov': GlobalsTable.homeVideo,
    'wmv': GlobalsTable.homeVideo,

    'mp3' : GlobalsTable.homeAudio,
    'wav': GlobalsTable.homeAudio
  };

  static const Map<String, String> fileTypesToTableNamesPs = {
    'png': GlobalsTable.psImage,
    'jpg': GlobalsTable.psImage,
    'jpeg': GlobalsTable.psImage,

    'txt': GlobalsTable.psText,
    'sql': GlobalsTable.psText,
    'js': GlobalsTable.psText,
    'css': GlobalsTable.psText,
    'xml': GlobalsTable.psText,
    'py': GlobalsTable.psText,
    'md': GlobalsTable.psText,
    'csv': GlobalsTable.psText,
    'html': GlobalsTable.psText,

    'pdf': GlobalsTable.psPdf,
    'doc': GlobalsTable.psWord,
    'docx': GlobalsTable.psWord,
    'pptx': GlobalsTable.psPtx,
    'ptx': GlobalsTable.psPtx,
    'xlsx': GlobalsTable.psExcel,
    'xls': GlobalsTable.psExcel,
    
    'exe': GlobalsTable.psExe,
    'msi': GlobalsTable.psMsi,
    'apk': GlobalsTable.psApk,

    'mp4': GlobalsTable.psVideo,
    'avi': GlobalsTable.psVideo,
    'mov': GlobalsTable.psVideo,
    'wmv': GlobalsTable.psVideo,

    'mp3' : GlobalsTable.psAudio,
    'wav': GlobalsTable.psAudio
  };

  static const generalFileTypes = {
    ...audioType,
    ...wordType,
    ...textType,
    ...ptxType,
    ...excelType,
    "apk",
    "exe",
    "pdf",
    "msi"
  };

  static const Set<String> supportedFileTypes = {
    ...imageType,...textType, ...videoType, ...wordType,
    ...ptxType, ...audioType, ...excelType,
    "pdf","exe","apk", "msi"
  };

  static Map<OriginFile,String> get originToName {
    return {
      OriginFile.home: 'Home',
      OriginFile.sharedMe: 'Shared to me',
      OriginFile.sharedOther: 'Shared files',
      OriginFile.offline: 'Offline',
      OriginFile.public: 'Public Storage',
      OriginFile.folder: _tempData.folderName,
      OriginFile.directory: _tempData.directoryName
    };
  }

  static const fileTypeToAssets = {
    "txt": "txt0.jpg",
    "csv": "txt0.jpg",
    "xml": "txt0.jpg",
    "js": "txt0.jpg",
    "css": "txt0.jpg",
    "py": "txt0.jpg",
    "html": "txt0.jpg",
    "sql": "txt0.jpg",
    "md": "txt0.jpg",

    "pdf": "pdf0.jpg",

    "doc": "doc0.jpg",
    "docx": "doc0.jpg",

    "xlsx": "exl0.jpg",
    "xls": "exl0.jpg",

    "pptx": "pptx0.jpg",
    "ptx": "pptx0.jpg",

    "exe": "exe0.jpg",
    "msi": "exe0.jpg",
    "apk": "apk0.jpg",

    "mp3": "music0.jpg",
    "wav": "music0.jpg",
    
    "mp4": "vid0.jpg",
    "wmv": "vid0.jpg",
    "avi": "vid0.jpg",
    "mov": "vid0.jpg",
    "mkv": "vid0.jpg",
  };

}