import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class CompressorApi {

  static Future<Uint8List> compressFile(String filePath) async {

    final gzipEncoder = GZipEncoder();

    List<int> fileContent = await File(filePath).readAsBytes();

    List<int> compressedBytes = gzipEncoder.encode(fileContent)!;
    Uint8List compressedUint8List = Uint8List.fromList(compressedBytes);

    return compressedUint8List;

  }

  static Uint8List decompressFile(Uint8List compressedData) {

    final gzipDecoder = GZipDecoder();

    List<int> decompressedData = gzipDecoder.decodeBytes(compressedData);

    return Uint8List.fromList(decompressedData);

  }

  static Uint8List compressByte(Uint8List fileBytes) {

    List<int>? compressedBytes = GZipEncoder().encode(fileBytes);

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