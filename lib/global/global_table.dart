class GlobalsTable {

  static const homeImage = "file_info";
  static const homeText = "file_info_expand";
  static const homeVideo = "file_info_vid";
  static const homeExcel = "file_info_excel";
  static const homePdf = "file_info_pdf";
  static const homeWord = "file_info_word";
  static const homePtx = "file_info_ptx";
  static const homeApk = "file_info_apk";
  static const homeAudio = "file_info_audi";
  static const homeExe = "file_info_exe";
  static const homeMsi = "file_info_msi";

  static const directoryInfoTable = "file_info_directory";
  static const directoryUploadTable = "upload_info_directory";
  static const folderUploadTable = "folder_upload_info";

  static const psImage = "ps_info_image";
  static const psText = "ps_info_text";
  static const psVideo = "ps_info_video";
  static const psExcel = "ps_info_excel";
  static const psPdf = "ps_info_pdf";
  static const psWord = "ps_info_word";
  static const psPtx = "ps_info_ptx";
  static const psApk = "ps_info_apk";
  static const psAudio = "ps_info_audio";
  static const psExe = "ps_info_exe";
  static const psMsi = "ps_info_msi";

  static const Set<String> tableNames = {
    directoryInfoTable, homeImage, homeText, homeExe, homePdf,
    homeVideo,homeExcel, homePtx, homeAudio, homeWord,
    directoryUploadTable
  };

  static const Set<String> tableNamesPs = {
    psImage, psText, psVideo, psExcel, psWord, psAudio,
    psMsi, psExe, psApk, psPdf, psPtx
  };

  static const Map<String,String> publicToPsTables = {
    homeImage: psImage,
    homeVideo: psVideo,
    homeExcel: psExcel,
    homeText: psText,
    homeWord: psWord,
    homePtx: psPtx,
    homePdf: psPdf,
    homeApk: psApk,
    homeExe: psExe,
    homeAudio: psAudio,
  };

}