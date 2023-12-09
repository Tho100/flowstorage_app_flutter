import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/interact_dialog/bottom_trailing/upgrade_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/create_directory_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/function_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:get_it/get_it.dart';

class QuickActionsModel {

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final dataCaller = DataCaller();

  final context = navigatorKey.currentContext!;

  void _openCreateDirectoryDialog() {
    CreateDirectoryDialog().buildCreateDirectoryDialog(
      context: context, 
      createOnPressed: () async {
        
        final getDirectoryTitle = CreateDirectoryDialog.directoryNameController.text.trim();

        if(getDirectoryTitle.isEmpty) {
          return;
        }

        if(storageData.fileNamesList.contains(getDirectoryTitle)) {
          CallToast.call(message: "Directory with this name already exists.");
          return;
        }

        await FunctionModel().createDirectoryData(getDirectoryTitle);
        CreateDirectoryDialog.directoryNameController.clear();

      }

    );

  }

  void newDirectory() {

    final limitDirectoryUpload = AccountPlan.mapDirectoryUpload[userData.accountType]!;
    final limitFilesUpload = AccountPlan.mapFilesUpload[userData.accountType]!;

    if(storageData.fileNamesList.length < limitFilesUpload) {
      final countDirectory = storageData.fileNamesFilteredList.where((dir) => !dir.contains('.')).length;
      if(countDirectory != limitDirectoryUpload) {
        _openCreateDirectoryDialog();

      } else {
        UpgradeDialog.buildUpgradeBottomSheet(
          message: "You're currently limited to $limitDirectoryUpload directory uploads. Upgrade your account to upload more directory.",
          context: context
        );

      }

    } else {
      UpgradeDialog.buildUpgradeBottomSheet(
        message: "You're currently limited to $limitFilesUpload uploads. Upgrade your account to upload more.",
        context: context
      );
      
    }
    
  }

  Future<void> offline() async {
    await dataCaller.offlineData();
  }

}