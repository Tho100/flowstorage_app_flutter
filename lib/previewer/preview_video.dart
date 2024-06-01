import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/models/system_toggle.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flowstorage_fsc/widgets/splash_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {

  const PreviewVideo({Key? key}) : super(key: key);

  @override
  State<PreviewVideo> createState() => PreviewVideoState();
  
}

class PreviewVideoState extends State<PreviewVideo> {

  late VideoPlayerController videoPlayerController;

  final systemToggle = SystemToggle();

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

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
  late Uint8List videoThumbnailByte; 
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
    
    try {

      if (videoBytes.isEmpty) {
        
        videoIsLoading = true;

        final fileData = tempData.origin != OriginFile.offline
          ? await CallPreviewFileData(
              tableNamePs: GlobalsTable.psVideo, 
              tableNameHome: GlobalsTable.homeVideo, 
              fileTypes: Globals.videoType
            ).callData()
          : await OfflineModel().loadOfflineFileByte(tempData.selectedFileName);

        tempData.setFileData(fileData);

        videoBytes = fileData;

      } 

    } catch (err, st) {
      videoBytes = Uint8List(0);
      Logger().e("Exception from playVideoDataAsync {preview_video}", err, st);
    }

    final videoUrl = "data:video/mp4;base64,${base64Encode(videoBytes)}";
    await initializeVideoPlayer(videoUrl, autoPlay: false);

  }

  Widget buildDurationText(ValueNotifier<String> currentDuration, ValueNotifier<String> originalDuration) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: ThemeColor.lightGrey.withOpacity(0.5),
          border: Border.all(
            color: Colors.transparent,
            width: 8.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [

            ValueListenableBuilder(
              valueListenable: currentDuration,
              builder: (context, value, child) {
                return Text(
                  "$value / ",
                  style: GoogleFonts.inter(
                    color: ThemeColor.secondaryWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 13
                  ),
                  textAlign: TextAlign.center,
                );
              }
            ),

            ValueListenableBuilder(
              valueListenable: originalDuration,
              builder: (context, value, child) {
                return Text(
                  " $value",
                  style: GoogleFonts.inter(
                    color: ThemeColor.secondaryWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 13
                  ),
                  textAlign: TextAlign.center,
                );
              }
            ),

          ],
        ),
      ),
    );
  }

  Widget buildPortraitModeButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ClipOval(
        child: SplashWidget(
          child: SizedBox(
            height: 38,
            width: 38,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeColor.lightGrey.withOpacity(0.5),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {

                  setState(() {
                    isLandscapeMode = !isLandscapeMode;
                  });

                  if (isLandscapeMode) {
                    systemToggle.toLandscapeMode();
                    PreviewFileState.bottomBarVisibleNotifier.value = false;

                  } else {
                    systemToggle.toPortraitMode();
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
      )
    );
  }

  Widget buildSkipForward() {
    return ClipOval(
      child: SplashWidget(
        child: SizedBox(
          height: 45,
          width: 45,
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColor.lightGrey.withOpacity(0.5),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => forwardingImplementation("positive"),
              icon: const Icon(Icons.forward_5_rounded, color: ThemeColor.secondaryWhite, size: 35),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSkipPrevious() {
    return ClipOval(
      child: SplashWidget(
        child: SizedBox(
          height: 45,
          width: 45,
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColor.lightGrey.withOpacity(0.5),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => forwardingImplementation("negative"),
              icon: const Icon(Icons.replay_5_rounded, color: ThemeColor.secondaryWhite, size: 35),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              buildSkipPrevious(),

              const SizedBox(width: 18),

              ClipOval(
                child: SplashWidget(
                  child: SizedBox(
                    height: 63,
                    width: 63,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeColor.lightGrey.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
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

              const SizedBox(width: 18),

              buildSkipForward(),

            ],
          ),
        ),

      ],
    );
  }

  Widget buildSeekSlider() {
    return ValueListenableBuilder<double>(
      valueListenable: videoPositionNotifier,
      builder: (context, videoPosition, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            SliderTheme(
              data: const SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [

                  buildDurationText(currentVideoDurationNotifier, videoDurationNotifier),
                  
                  const Spacer(),

                  ValueListenableBuilder(
                    valueListenable: videoIsTappedNotifier,
                    builder: (context, value, child) {
                      return AnimatedOpacity(
                        opacity: value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Visibility(
                          visible: value,
                          child: buildPortraitModeButton()
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),

          ],
        );
      },
    );
  }

  Widget buildVideoAndComponents() {
    return Stack(
      children: [

        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: videoSize!.width,
                    height: videoSize!.height,
                    child: VideoPlayer(videoPlayerController),
                  ),
                ),
              ),
              
              ValueListenableBuilder(
                valueListenable: videoIsTappedNotifier,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Visibility(
                      visible: value && videoBytes.isNotEmpty,
                      child: buildButtons(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      
        ValueListenableBuilder(
          valueListenable: videoIsTappedNotifier,
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Visibility(
                visible: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: buildSeekSlider(),
                ),
              ),
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
        videoThumbnailByte,
        fit: BoxFit.contain,
      ),
    );
  }

  void forwardingImplementation(String value) {

    final position = videoPlayerController.value.position;
    final duration = videoPlayerController.value.duration;

    final newPosition = value == "positive" 
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

    final currentDuration = getDurationString(position);

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

    videoThumbnailByte = storageData
      .imageBytesFilteredList[indexThumbnail]!;
      
    videoPlayerController = VideoPlayerController.networkUrl(Uri());
    
  }

  @override
  void initState() {
    super.initState();
    initializeVideoConfiguration();
    playVideoDataAsync();
  }

  @override
  void dispose() {
    systemToggle.toPortraitMode();
    videoPlayerController.removeListener(videoPlayerListener);
    videoPlayerController.dispose();
    videoDurationNotifier.dispose();
    videoPositionNotifier.dispose();
    currentVideoDurationNotifier.dispose();
    iconPausePlayNotifier.dispose();
    sliderValueController.close();
    systemToggle.toggleStatusBarVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        videoIsTappedNotifier.value = !videoIsTappedNotifier.value;
        if(!isLandscapeMode) {
          systemToggle.toggleStatusBarVisibility(videoIsTappedNotifier.value);
          PreviewFileState.bottomBarVisibleNotifier.value =
            !PreviewFileState.bottomBarVisibleNotifier.value;
        }
      },
      child: Center(
        child: Container(
          color: ThemeColor.darkBlack,
          child: Stack(
            children: [
              buildThumbnail(videoIsPlaying),
              if(videoIsLoading) buildLoadingVideo(),
              if(videoIsPlaying) buildVideoAndComponents()
            ],
          ),
        ),
      ),
    );
  }

}