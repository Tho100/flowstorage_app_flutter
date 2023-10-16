import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class CompressorApi {

  static Uint8List compressFile(String filePath) {

    List<int> fileContent = File(filePath).readAsBytesSync();

    final gzipEncoder = GZipEncoder();

    List<int> compressedBytes = gzipEncoder.encode(fileContent)!;
    Uint8List compressedUint8List = Uint8List.fromList(compressedBytes);

    return compressedUint8List;

  }

  static Uint8List decompressFile(Uint8List compressedData) {

    final gzipDecoder = GZipDecoder();

    List<int> decompressedData = gzipDecoder.decodeBytes(compressedData);

    return Uint8List.fromList(decompressedData);

  }

  /*static Uint8List decompressFile(Uint8List compressedData) {

    final archive = ZipDecoder().decodeBytes(compressedData);
    final archiveFile = archive.first;
    
    return Uint8List.fromList(archiveFile.content);

  }

  static Uint8List compressFile(String filePath) {

    List<int> fileContent = File(filePath).readAsBytesSync();

    final archive = ArchiveFile(filePath, fileContent.length, fileContent);
    final zipArchive = Archive()..addFile(archive);

    List<int>? compressedBytes = ZipEncoder().encode(zipArchive);

    Uint8List compressedUint8List = Uint8List.fromList(compressedBytes!);

    return compressedUint8List;
    
  }*/

  static Uint8List compressByte(Uint8List fileBytes) {

    final archive = ArchiveFile("compressed_text_file", fileBytes.length, fileBytes);
    final zipArchive = Archive()..addFile(archive);

    List<int>? compressedBytes = ZipEncoder().encode(zipArchive);

    Uint8List compressedUint8List = Uint8List.fromList(compressedBytes!);

    return compressedUint8List;
  }

  static Future<File> processImageCompression({
    required String path, 
    required int quality
    }) async {

    final compressedFile = await FlutterNativeImage.compressImage(
      path,
      quality: quality,
    );
    
    return Future.value(compressedFile);
  }

  static Future<List<int>> compressedByteImage({
    required String path,
    required int quality,
  }) async {

    File? compressedFile = await processImageCompression(path: path, quality: quality);

    List<int> bytes = await compressedFile.readAsBytes();
    return bytes;

  }
  
}