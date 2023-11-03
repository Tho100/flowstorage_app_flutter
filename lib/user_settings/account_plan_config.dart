class AccountPlan {

  static const int _supremeLimitedNumber = 2000;
  static const int _expressLimitedNumber = 800;
  static const int _maxLimitedNumber = 150;
  static const int _basicLimitedNumber = 25;

  static const int _supremeLimitedNumberFolder = 20;
  static const int _expressLimitedNumberFolder = 10;
  static const int _maxLimitedNumberFolder = 5;
  static const int _basicLimitedNumberFolder = 3;

  static const int _supremeLimitedNumberDir = 5;
  static const int _basicLimitedNumberDir = 2;

  static Map<String,int> mapFilesUpload = {
    'Basic': _basicLimitedNumber, 
    'Max': _maxLimitedNumber,
    'Express': _expressLimitedNumber, 
    'Supreme': _supremeLimitedNumber
  };

  static final Map<String,int> mapFoldersUpload = {
    'Basic': _basicLimitedNumberFolder, 
    'Max': _maxLimitedNumberFolder,
    'Express': _expressLimitedNumberFolder, 
    'Supreme': _supremeLimitedNumberFolder
  };

  static final Map<String,int> mapDirectoryUpload = {
    'Basic': _basicLimitedNumberDir, 
    'Max': _basicLimitedNumberDir,
    'Express': _basicLimitedNumberDir, 
    'Supreme': _supremeLimitedNumberDir
  };

}