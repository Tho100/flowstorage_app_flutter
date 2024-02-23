import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class WidgetVisibility {

  static final _tempData = GetIt.instance<TempDataProvider>();

  static bool setNotVisibleList(List<OriginFile> origin) {
    return !(origin.contains(_tempData.origin));
  }

  static bool setNotVisible(OriginFile origin) {
    return _tempData.origin != origin;
  }

  static bool setVisible(OriginFile origin) {
    return _tempData.origin == origin;
  }

  static bool setVisibleList(List<OriginFile> origin) {
    return origin.contains(_tempData.origin);
  }

}