import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ShareFileData {

  final dateNow = DateFormat('dd/MM/yyyy');

  final encryption = EncryptionClass();
  final crud = Crud();

  final userData = GetIt.instance<UserDataProvider>();

  Future<void> startSharing({
    required String? receiverUsername,
    required String? fileName,
    required String? comment,
    required dynamic fileValue,
    dynamic thumbnail,
  }) async {

    try {

      final uploadDate = dateNow.format(DateTime.now());

      const insertDataQuery = "INSERT INTO cust_sharing(CUST_TO, CUST_FROM, CUST_FILE_PATH, CUST_FILE, UPLOAD_DATE, CUST_THUMB, CUST_COMMENT) VALUES (:to, :from, :file_name, :file_data, :date, :thumbnail, :comment)";
      final params = {
        'to': receiverUsername!,
        'from': userData.username,
        'file_data': fileValue!,
        'file_name': fileName!,
        'date': uploadDate,
        'thumbnail': thumbnail ?? '',
        'comment': comment ?? '',
      };

      await crud.insert(query: insertDataQuery, params: params);

    } catch (err, st) {
      Logger().e("Exception from startSharing {share_file}", err, st);
    }

  }

  Future<void> insertValuesParams({
    required String? sendTo,
    required String? fileName,
    required String? comment,
    required dynamic fileData,
    dynamic thumbnail,
  }) async {

    try {

      await startSharing(
        receiverUsername: sendTo,
        fileName: fileName,
        comment: comment,
        fileValue: fileData,
        thumbnail: thumbnail,
      );

      await CallNotify().customNotification(
        title: "File Shared Successfully",
        subMessage:
        "${ShortenText().cutText(encryption.decrypt(fileName))} Has been shared to $sendTo",
      );

      await CustomFormDialog.startDialog("File Shared Successfully", "${ShortenText().cutText(encryption.decrypt(fileName), customLength: 32)} Has been shared to $sendTo.");

    } catch (err, st) {
      Logger().e("Exception from insertValuesParam {share_file}", err, st);
      await CallNotify().customNotification(
        title: "Something went wrong",
        subMessage: "Failed to share ${{ShortenText().cutText(EncryptionClass().decrypt(fileName))}}",
      );
    }
    
  }

}
