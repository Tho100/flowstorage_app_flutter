import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

class ProcessAudio extends StreamAudioSource {

  final Uint8List _buffer;
  final String _contentType;

  ProcessAudio(this._buffer, this._contentType) : super(tag: 'MyAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    
    final offset = start ?? 0;
    final contentLength = (start ?? 0) - (end ?? _buffer.length);
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: contentLength,
      offset: offset,
      stream: Stream.value(_buffer.sublist(offset, end)),
      contentType: _contentType,
    );
  }

}