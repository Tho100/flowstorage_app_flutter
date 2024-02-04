import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  const PreviewVideo({Key? key}) : super(key: key);

  @override
  State<PreviewVideo> createState() => PreviewVideoState();
}

class PreviewVideoState extends State<PreviewVideo> {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  late VideoPlayerController videoPlayerController;

  final sliderValueController = StreamController<double>();
  final videoPositionNotifier = ValueNotifier<double>(0.0);

  final iconPausePlayNotifier = ValueNotifier<IconData>(
                                Icons.play_arrow);
                                
  final videoIsTappedNotifier = ValueNotifier(false);
  final videoDurationNotifier = ValueNotifier<String>("0:00");
  final currentVideoDurationNotifier = ValueNotifier<String>("0:00");

  final endThreshold = const Duration(milliseconds: 200);
  
  bool videoIsPlaying = false;
  bool videoIsLoading = false;
  bool videoIsEnded = false;
  bool buttonPlayPausePressed = true;

  bool isLandscapeMode = false;

  late int indexThumbnail; 
  late Uint8List videoThumbailByte; 
  late Size? videoSize;

  late Uint8List videoBytes = Uint8List(0);

  Future<void> initializeVideoPlayer(String videoUrl, {bool autoPlay = false}) async {

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    if (autoPlay) {
      await videoPlayerController.initialize();
      videoPlayerController.play();

    } else {
      await videoPlayerController.initialize();

    }

    setState(() {
      videoIsPlaying = true;
      videoIsLoading = false;
    });

    videoSize = videoPlayerController.value.size;
    videoDurationNotifier.value = getDurationString(videoPlayerController.value.duration);

    videoIsTappedNotifier.value = true;
    videoPlayerController.addListener(videoPlayerListener);
    
  }


  Future<void> playVideoDataAsync() async {
    
    if (videoBytes.isEmpty) {
      videoIsLoading = true;
      videoBytes = await CallPreviewFileData(
        tableNamePs: GlobalsTable.psVideo, 
        tableNameHome: GlobalsTable.homeVideo, 
        fileValues: Globals.videoType
      ).callData();

      tempData.setFileData(videoBytes);

    } 

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await initializeVideoPlayer(videoUrl, autoPlay: false);

  }

  Widget buildDurationText(ValueNotifier<String> notifier) {
    return Container(
      width: 65,
      height: 30,
      decoration: BoxDecoration(
        color: ThemeColor.lightGrey.withOpacity(0.5),
        border: Border.all(
          color: Colors.transparent,
          width: 8.0,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Text(
            value,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14
            ),
            textAlign: TextAlign.center,
          );
        }
      ),
    );
  }

  Widget buildPortraitModeButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 95.0),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: Ink(
                color: ThemeColor.darkBlack,
                child: SizedBox(
                  height: 38,
                  width: 38,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.lightGrey.withOpacity(0.5),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(65),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          isLandscapeMode = !isLandscapeMode;
                        });
                        if (isLandscapeMode) {
                          toLandscapeMode();
                          PreviewFileState.bottomBarVisibleNotifier.value = false;
                        } else {
                          toPortraitMode();
                          PreviewFileState.bottomBarVisibleNotifier.value = true;
                          videoIsTappedNotifier.value = true;
                        }
                      },
                      icon: isLandscapeMode
                          ? const Icon(Icons.zoom_in_map_outlined, color: ThemeColor.secondaryWhite, size: 22)
                          : const Icon(Icons.crop_free_outlined, color: ThemeColor.secondaryWhite, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSkipForward() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Ink(
            color: ThemeColor.darkBlack,
            child: SizedBox(
              height: 45,
              width: 45,
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColor.lightGrey.withOpacity(0.5),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(65),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    forwardingImplementation("positive");
                  },
                  icon: const Icon(Icons.forward_5_rounded, color: ThemeColor.secondaryWhite, size: 35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSkipPrevious() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Ink(
            color: ThemeColor.darkBlack,
            child: SizedBox(
              height: 45,
              width: 45,
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColor.lightGrey.withOpacity(0.5),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(65),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    forwardingImplementation("negative");
                  },
                  icon: const Icon(Icons.replay_5_rounded, color: ThemeColor.secondaryWhite, size: 35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSeekSlider(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildDurationText(currentVideoDurationNotifier),
                  const SizedBox(width: 35),
                  buildSkipPrevious(),
                  const SizedBox(width: 18),
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Ink(
                          color: ThemeColor.darkBlack,
                          child: SizedBox(
                            height: 63,
                            width: 63,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ThemeColor.lightGrey.withOpacity(0.5),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(65),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  
                                  buttonPlayPausePressed = !buttonPlayPausePressed;
                              
                                  if(videoIsEnded) {
                                    iconPausePlayNotifier.value = Icons.pause;
                                    videoPlayerController.play();
                                    videoIsEnded = false;
                                  } else {
                                    iconPausePlayNotifier.value = buttonPlayPausePressed 
                                    ? Icons.play_arrow
                                    : Icons.pause;
                                  }
                                  
                                  if (buttonPlayPausePressed) {
                                    videoPlayerController.pause();
                                  } else {                
                                    iconPausePlayNotifier.value = Icons.pause;
                                    videoPlayerController.play();
                                  }
                              
                                  Future.delayed(const Duration(milliseconds: 0), videoPlayerListener);
                              
                                },
                                icon: ValueListenableBuilder(
                                  valueListenable: iconPausePlayNotifier,
                                  builder: (context, value, child) {
                                    return Icon(
                                      value,
                                      size: 40,
                                      color: ThemeColor.secondaryWhite,
                                    );
                                  }
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  buildSkipForward(),
                  const SizedBox(width: 32),
                  buildDurationText(videoDurationNotifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSeekSlider() {
    return ValueListenableBuilder<double>(
      valueListenable: videoPositionNotifier,
      builder: (context, videoPosition, _) {
        return Column(
          children: [
            SliderTheme(
              data: const SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              ),
              child: Slider(
                value: videoPosition,
                min: 0,
                max: videoPlayerController.value.duration.inSeconds.toDouble(),
                thumbColor: ThemeColor.justWhite,
                inactiveColor: ThemeColor.lightGrey.withOpacity(0.5),
                activeColor: ThemeColor.justWhite,
                onChanged: (double value) {
                  sliderValueController.add(value);
                  videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildVideoWithButtonsOutside() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            videoIsTappedNotifier.value = !videoIsTappedNotifier.value;
            if(!isLandscapeMode) {
            PreviewFileState.bottomBarVisibleNotifier.value =
                !PreviewFileState.bottomBarVisibleNotifier.value;
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: videoSize!.width,
                  height: videoSize!.height,
                  child: VideoPlayer(videoPlayerController),
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: videoIsTappedNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: buildPortraitModeButton()
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: videoIsTappedNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: value && videoBytes.isNotEmpty,
              child: buildButtons(),
            );
          },
        ),
      ],
    );
  }

  Widget buildLoadingVideo() {
    return const Positioned.fill(
      child: Center(
        child: LoadingIndicator()
      ),
    );
  }

  Widget buildThumbnail(bool isVideoPlaying) {
    return Visibility(
      visible: !isVideoPlaying,
      replacement: Container(),
      child: Image.memory(
        videoThumbailByte,
        fit: BoxFit.contain,
      ),
    );
  }

  void forwardingImplementation(String value) {

    final position = videoPlayerController.value.position;
    final duration = videoPlayerController.value.duration;

    final newPosition = 
    value == "positive" 
    ? position + const Duration(seconds: 5) 
    : position - const Duration(seconds: 5);

    if (newPosition <= duration) {
      videoPlayerController.seekTo(newPosition);
    } else {
      iconPausePlayNotifier.value = Icons.pause;
      videoPlayerController.play();
    }
    
  }

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String getDurationString(Duration duration) {

    final twoDigitMinutes = twoDigits(
      duration.inMinutes.remainder(60));

    final twoDigitSeconds = twoDigits(
      duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";

  }

  void videoPlayerListener() {
    final position = videoPlayerController.value.position;
    final duration = videoPlayerController.value.duration;

    String currentDuration = getDurationString(position);
    currentVideoDurationNotifier.value = currentDuration;
    videoPositionNotifier.value = position.inSeconds.toDouble();

    final isVideoInitialized = videoPlayerController.value.isInitialized;
    final isVideoPlaying = videoPlayerController.value.isPlaying;
    final isVideoEnded = isVideoInitialized &&
        !isVideoPlaying &&
        duration - position <= endThreshold;

    if (isVideoInitialized && !isVideoPlaying && isVideoEnded) {
      iconPausePlayNotifier.value = Icons.replay;
      videoIsEnded = true;
      videoIsTappedNotifier.value = true;
      if(!isLandscapeMode) {
        PreviewFileState.bottomBarVisibleNotifier.value = true;
      }
    }
  }

  void initializeVideoConfiguration() {
    indexThumbnail = storageData
      .fileNamesFilteredList.indexOf(tempData.selectedFileName);

    videoThumbailByte = storageData
      .imageBytesFilteredList[indexThumbnail]!;
      
    videoPlayerController = VideoPlayerController.networkUrl(Uri());
  }

  void toPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void toLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void initState() {
    super.initState();
    initializeVideoConfiguration();
    playVideoDataAsync();
  }

  @override
  void dispose() {
    toPortraitMode();
    videoPlayerController.removeListener(videoPlayerListener);
    videoPlayerController.dispose();
    videoDurationNotifier.dispose();
    videoPositionNotifier.dispose();
    currentVideoDurationNotifier.dispose();
    iconPausePlayNotifier.dispose();
    sliderValueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildThumbnail(videoIsPlaying),
          if(videoIsLoading) buildLoadingVideo(),
          if(videoIsPlaying) buildVideoWithButtonsOutside()
        ],
      ),
    );
  }
}