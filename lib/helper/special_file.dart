import 'package:flowstorage_fsc/global/globals.dart';

class SpecialFile {
  
  bool ignoreEncryption(String fileType) {
    
    const ignore = {
      ...Globals.videoType,
      ...Globals.audioType,
      "apk", "exe", "msi"
    };
    
    return ignore.contains(fileType);

  }

}