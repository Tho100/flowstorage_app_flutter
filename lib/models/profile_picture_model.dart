import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/picker_model.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePictureModel {

  final _fileName = "flowstorage_profile_pic.txt";

  Future<void> deleteProfilePicture() async {
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');

    if(await file.exists()) {
      await file.delete();
    }
    
  }

  Future<void> _saveProfilePic(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    await file.writeAsBytes(imageBytes);
  }

  Future<bool> createProfilePicture() async {

    try {

      String fileName = "";

      final details = await PickerModel().galleryPicker(
        source: ImageSource.both, 
        isFromSelectProfilePic: true,
      );

      for(final filesPath in details!.selectedFiles) {

        final pathToString = filesPath.selectedFile.toString()
          .split(" ").last.replaceAll("'", "");
        
        fileName = pathToString.split("/")
          .last.replaceAll("'", "");

        final fileExtension = fileName.split('.').last;

        if(Globals.imageType.contains(fileExtension)) {
          final compressedImage = await CompressorApi
            .compressedByteImage(path: pathToString, quality: 18);

          final decodedImage = Uint8List.fromList(compressedImage);

          await _saveProfilePic(decodedImage);
          
        }

      }

      return fileName.isNotEmpty;

    } catch (err) {
      return false;
    }

  }

  Future<Uint8List?> loadProfilePic() async {

    try {

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      return await file.readAsBytes(); 

    } catch (err) {
      return null;
    }

  }

}