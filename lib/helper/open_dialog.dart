import 'package:flowstorage_fsc/interact_dialog/delete_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/rename_dialog.dart';

class OpenOptionsDialog {

  final String fileName;
  final Function onPressed;

  const OpenOptionsDialog({
    required this.onPressed, 
    required this.fileName
  });

  void deleteDialog() {
    DeleteDialog().buildDeleteDialog(
      fileName: fileName, 
      onDeletePressed: () => onPressed, 
    );
  }

  void renameDialog() {
    RenameDialog().buildRenameFileDialog(
      fileName: fileName, 
      onRenamePressed: () => onPressed,
    );
  }

}