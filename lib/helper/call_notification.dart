import 'package:flowstorage_fsc/api/notification_api.dart';

class CallNotify {

  Future<void> uploadedNotification({
    required String title,
    required int count
  }) async {

    final setupBodyMessage = count == 1 
      ?  "1 File has been added" 
      : "$count Files has been added";

    await NotificationApi.showOnFinishTaskNotification(
      title: title,
      body: setupBodyMessage,
      payload: 'h_collin001'
    );
  }

  Future<void> downloadedNotification({
    required String fileName,
  }) async {
    await NotificationApi.showOnFinishTaskNotification(
      title: "Download Completed",
      body: "$fileName Has been downloaded",
      payload: 'h_collin01'
    );
  }

  Future<void> uploadingNotification({
    required int numberOfFiles
  }) async {
    await NotificationApi.showUploadingNotification(
      title: "Uploading...",
      body: "$numberOfFiles File(s) in progress",
      payload: 'h_collin2'
    );
  }

  Future<void> audioNotification({
    required String audioName
  }) async {
    await NotificationApi.showAudioNotification(
      title: "Audio Player",
      body: "Playing $audioName",
      payload: 'h_collin3'
    );
  }

  Future<void> customNotification({
    required String title,
    required String subMessage
  }) async {
    await NotificationApi.showOnFinishTaskNotification(
      title: title,
      body: subMessage,
      payload: 'h_collin1'
    );
  }

}