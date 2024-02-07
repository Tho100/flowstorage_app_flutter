import 'package:flowstorage_fsc/helper/date_parser.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SortingModel {

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  String _formatDateTime(DateTime dateTime) {

    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    final adjustedDateTime = difference.isNegative ? dateTime.add(const Duration(days: 1)) : dateTime;
    final adjustedDifference = adjustedDateTime.difference(now).inDays.abs();

    if (adjustedDifference == 0) {
      return '0 days ago ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';

    } else {
      final daysAgoText = '$adjustedDifference days ago';
      return '$daysAgoText ${GlobalsStyle.dotSeperator} ${DateFormat('MMM dd yyyy').format(adjustedDateTime)}';
      
    }

  }

  void uploadDate({required bool sortingIsAscendingUploadDate}) {

    List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      itemList.add({
        'file_name': storageData.fileNamesFilteredList[i],
        'image_byte': storageData.imageBytesFilteredList[i],
        'upload_date': DateParser(date: storageData.fileDateFilteredList[i]).parse(),
      });
    }

    itemList = itemList.where((item) => item['file_name'].contains('.')).toList();

    sortingIsAscendingUploadDate
        ? itemList.sort((a, b) => a['upload_date'].compareTo(b['upload_date']))
        : itemList.sort((a, b) => b['upload_date'].compareTo(a['upload_date']));

    storageData.fileDateFilteredList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();

    for (final item in itemList) {
      storageData.fileNamesFilteredList.add(item['file_name']);
      storageData.imageBytesFilteredList.add(item['image_byte']);
      storageData.fileDateFilteredList.add(_formatDateTime(item['upload_date']));
    }

    itemList.clear();

  }

  void fileName({required bool sortingIsAscendingItemName}) {

   List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < storageData.fileNamesFilteredList.length; i++) {
      itemList.add({
        'file_name': storageData.fileNamesFilteredList[i],
        'image_byte': storageData.imageBytesFilteredList[i],
        'upload_date': storageData.fileDateFilteredList[i],
      });
    }

    sortingIsAscendingItemName 
    ? itemList.sort((a, b) => a['file_name'].compareTo(b['file_name']))
    : itemList.sort((a, b) => b['file_name'].compareTo(a['file_name']));

    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();
    storageData.fileDateFilteredList.clear();

    for (final item in itemList) {
      storageData.fileNamesFilteredList.add(item['file_name']);
      storageData.imageBytesFilteredList.add(item['image_byte']);
      storageData.fileDateFilteredList.add(item['upload_date']);
    }

    itemList.clear();

  }

}