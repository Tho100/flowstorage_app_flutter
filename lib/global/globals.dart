import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class Globals {

  static final _tempData = GetIt.instance<TempDataProvider>();

  static const String fileInfoTable = 'file_info';
  static const String fileInfoExpandTable = 'file_info_expand';
  static const String fileInfoPdfTable = 'file_info_pdf';
  static const String fileInfoAudioTable = 'file_info_audi';
  static const String fileInfoWordTable = 'file_info_word';
  static const String fileInfoPtxTable = 'file_info_ptx';
  static const String fileInfoExcelTable = 'file_info_excel';
  static const String fileInfoMsiTable = 'file_info_msi';
  static const String fileInfoExeTable = 'file_info_exe';
  static const String fileInfoVidTable = 'file_info_vid';
  static const String fileInfoApkTable = 'file_info_apk';

  static const Set<String> imageType = {"png","jpeg","jpg","webp"};
  static const Set<String> textType = {"txt","csv","html","sql","md"};
  static const Set<String> videoType = {"mp4","wmv","avi","mov","mkv"};
  static const Set<String> wordType = {"docx","doc"};
  static const Set<String> excelType = {"xls","xlsx"};
  static const Set<String> ptxType = {"pptx","ptx"};
  static const Set<String> audioType = {"wav","mp3"};

  static const Set<String> unsupportedOfflineModeTypes = {
    "mp4","wmv", "exe", "apk", "msi"
  };

  static const Map<String, String> fileTypesToTableNames = {
    'png': fileInfoTable,
    'jpg': fileInfoTable,
    'webp': fileInfoTable,
    'jpeg': fileInfoTable,

    'txt': fileInfoExpandTable,
    'sql': fileInfoExpandTable,
    'md': fileInfoExpandTable,
    'csv': fileInfoExpandTable,
    'html': fileInfoExpandTable,

    'pdf': fileInfoPdfTable,

    'doc': fileInfoWordTable,
    'docx': fileInfoWordTable,

    'pptx': fileInfoPtxTable,
    'ptx': fileInfoPtxTable,

    'xlsx': fileInfoExcelTable,
    'xls': fileInfoExcelTable,

    'exe': fileInfoExeTable,
    'msi': fileInfoMsiTable,
    'apk': fileInfoApkTable,

    'mp4': fileInfoVidTable,
    'avi': fileInfoVidTable,
    'mov': fileInfoVidTable,

    'mp3' : fileInfoAudioTable,
    'wav': fileInfoAudioTable
  };

  static const Map<String, String> fileTypesToTableNamesPs = {

    'png': 'ps_info_image',
    'jpg': 'ps_info_image',
    'webp': 'ps_info_image',
    'jpeg': 'ps_info_image',

    'txt': 'ps_info_text',
    'sql': 'ps_info_text',
    'md': 'ps_info_text',
    'csv': 'ps_info_text',
    'html': 'ps_info_text',

    'pdf': 'ps_info_pdf',
    'doc': 'file_info_word',
    'docx': 'file_info_word',
    'pptx': 'file_info_ptx',
    'ptx': 'file_info_ptx',
    'xlsx': 'ps_info_excel',
    'xls': 'ps_info_excel',
    
    'exe': 'ps_info_exe',
    'msi': 'ps_info_msi',
    'apk': 'ps_info_apk',

    'mp4': 'ps_info_video',
    'avi': 'ps_info_video',
    'mov': 'ps_info_video',
    
    'mp3' : 'ps_info_audio',
    'wav': 'ps_info_audio'
    
  };

  static const generalFileTypes = {
    ...Globals.audioType,
    ...Globals.wordType,
    ...Globals.textType,
    ...Globals.ptxType,
    ...Globals.excelType,
    "apk",
    "exe",
    "pdf",
    "msi"
  };

  static const Set<String> supportedFileTypes = {
    "png","jpeg","jpg",
    "html","sql","md","txt","pptx","ptx",
    "pdf","doc","docx","mp4","wav","avi","wmv","mov","mp3",
    "exe","xlsx","xls","csv","apk", "msi"
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

  static Map<String,String> get nameToOrigin {
    return {
      'Home': 'homeFiles',
      _tempData.folderName: 'folderFiles',
      _tempData.directoryName: 'dirFiles',
      'Shared to me': 'sharedToMe',
      'Shared files': 'sharedFiles',
      'Offline': 'offlineFiles',
      'Public Storage': 'psFiles',
    };
  }

  static const fileTypeToAssets = {
    "txt": "txt0.jpg",
    "csv": "txt0.jpg",
    "html": "txt0.jpg",
    "sql": "txt0.jpg",
    "md": "txt0.jpg",
    "pdf": "pdf0.jpg",
    "doc": "doc0.jpg",
    "docx": "doc0.jpg",
    "xlsx": "exl0.jpg",
    "xls": "exl0.jpg",
    "pptx": "ptx0.jpg",
    "ptx": "ptx0.jpg",
    "apk": "apk0.jpg",
    "mp3": "music0.jpg",
    "wav": "music0.jpg",
    "exe": "exe0.jpg",
  };

}