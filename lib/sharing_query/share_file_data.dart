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
    required String? fileType,
    dynamic thumbnail,
  }) async {

    try {

      final uploadDate = dateNow.format(DateTime.now());

      const insertSharingData =
      'INSERT INTO cust_sharing(CUST_TO, CUST_FROM, CUST_FILE_PATH, CUST_FILE, UPLOAD_DATE, FILE_EXT, CUST_THUMB, CUST_COMMENT) '
      'VALUES (:to, :from, :filename, :fileval, :date, :type, :thumbnail, :comment)';

      final params = {
        'to': receiverUsername!,
        'from': userData.username,
        'fileval': fileValue!,
        'filename': fileName!,
        'date': uploadDate,
        'type': fileType!,
        'thumbnail': thumbnail ?? '',
        'comment': comment ?? '',
      };

      await crud.insert(query: insertSharingData, params: params);

    } catch (err, st) {
      Logger().e("Exception from startSharing {share_file}", err, st);
    }
  }

  Future<void> insertValuesParams({
    required String? sendTo,
    required String? fileName,
    required String? comment,
    required dynamic fileData,
    required String? fileType,
    dynamic thumbnail,
  }) async {

    try {

      await startSharing(
        receiverUsername: sendTo,
        fileName: fileName,
        comment: comment,
        fileValue: fileData,
        fileType: fileType,
        thumbnail: thumbnail,
      );

      await CallNotify().customNotification(
        title: "File Shared Successfully",
        subMesssage:
        "${ShortenText().cutText(encryption.decrypt(fileName))} Has been shared to $sendTo",
      );

      await CustomFormDialog.startDialog("File Shared Successfully", "${ShortenText().cutText(encryption.decrypt(fileName), customLength: 32)} Has been shared to $sendTo.");

    } catch (err, st) {
      Logger().e("Exception from insertValuesParam {share_file}", err, st);
      await CallNotify().customNotification(
        title: "Something went wrong",
        subMesssage: "Failed to share ${{ShortenText().cutText(EncryptionClass().decrypt(fileName))}}",
      );

    }
  }
}
