class AccountPlan {

  static const _supremeLimitedNumber = 2000;
  static const _expressLimitedNumber = 800;
  static const _maxLimitedNumber = 150;
  static const _basicLimitedNumber = 25;

  static const _supremeLimitedNumberFolder = 20;
  static const _expressLimitedNumberFolder = 10;
  static const _maxLimitedNumberFolder = 5;
  static const _basicLimitedNumberFolder = 3;

  static const _supremeLimitedNumberDir = 5;
  static const _basicLimitedNumberDir = 2;

  static Map<String, int> mapFilesUpload = {
    'Basic': _basicLimitedNumber, 
    'Max': _maxLimitedNumber,
    'Express': _expressLimitedNumber, 
    'Supreme': _supremeLimitedNumber
  };

  static final Map<String, int> mapFoldersUpload = {
    'Basic': _basicLimitedNumberFolder, 
    'Max': _maxLimitedNumberFolder,
    'Express': _expressLimitedNumberFolder, 
    'Supreme': _supremeLimitedNumberFolder
  };

  static final Map<String, int> mapDirectoryUpload = {
    'Basic': _basicLimitedNumberDir, 
    'Max': _basicLimitedNumberDir,
    'Express': _basicLimitedNumberDir, 
    'Supreme': _supremeLimitedNumberDir
  };

}