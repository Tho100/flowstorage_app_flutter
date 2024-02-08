import 'dart:async';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/models/process_audio.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/splash_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class PreviewAudio extends StatefulWidget {
  const PreviewAudio({super.key});

  @override
  State<PreviewAudio> createState() => PreviewAudioState();
}

class PreviewAudioState extends State<PreviewAudio> {

  Duration durationGradient = const Duration(milliseconds: 859);

  final gradientColors = [
    [ThemeColor.secondaryPurple, ThemeColor.justWhite],
    [ThemeColor.secondaryWhite, ThemeColor.darkPurple],
  ];

  final currentGradientIndexNotifier = ValueNotifier<int>(0);

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final sliderValueController = StreamController<double>();

  final audioPositionNotifier = ValueNotifier<double>(0.0);
  final iconPausePlayNotifier = ValueNotifier<IconData>(
                                  Icons.play_arrow_rounded);

  final keepPlayingIconColorNotifier = ValueNotifier<Color>(
                                ThemeColor.thirdWhite);

  final isKeepPlayingEnabledNotifier = ValueNotifier<bool>(false);
  final currentAudioDuration = ValueNotifier<String>("0:00");

  final audioPlayerController = AudioPlayer();  

  String audioDuration = "0:00";

  late String? audioContentType;
  late Uint8List? byteAudio = Uint8List(0);

  Future<Uint8List> callAudioDataAsync() async {

    try {
      
      if (tempData.origin != OriginFile.offline) {

        final fileData = await CallPreviewFileData(
          tableNamePs: GlobalsTable.psAudio, 
          tableNameHome: GlobalsTable.homeAudio, 
          fileValues: Globals.audioType
        ).callData();

        tempData.setFileData(fileData);

        return fileData;

      } else {
        return await OfflineModel().loadOfflineFileByte(tempData.selectedFileName);
        
      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewAudio}", err, st);
      return Future.value(Uint8List(0));
      
    }

  }

  void pauseAudio() {
    audioPlayerController.pause();
    iconPausePlayNotifier.value = Icons.play_arrow_rounded;
    NotificationApi.stopNotification(0);
  }

  void setupAudioDuration() async {

    await audioPlayerController.setAudioSource(ProcessAudio(byteAudio!, audioContentType!));

    final duration = audioPlayerController.duration!;
    final formattedDuration = getDurationString(duration);

    audioDuration = formattedDuration;

  }

  Future<void> playOrPauseAudioAsync() async {

    if (byteAudio!.isEmpty) {
      byteAudio = await callAudioDataAsync();
    }

    if (audioPlayerController.playing) {
      pauseAudio();
      return;
    }

    callNotificationOnAudioPlaying();

    if (audioPlayerController.duration == null) {
      setupAudioDuration();
    }

    audioPlayerController.play();

    iconPausePlayNotifier.value = Icons.pause;

    Timer? progressTimer;

    progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!audioPlayerController.playing) {
        progressTimer?.cancel();
        return;
      }

      final currentPosition = audioPlayerController.position;
      final formattedPosition = getDurationString(currentPosition);

      currentAudioDuration.value = formattedPosition;
      audioPositionNotifier.value = audioPlayerController.position.inSeconds.toDouble();

    });

    audioPlayerController.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        iconPausePlayNotifier.value = Icons.replay_rounded;

        if(isKeepPlayingEnabledNotifier.value) {
          audioPlayerController.seek(Duration.zero);
          audioPlayerController.play();
          iconPausePlayNotifier.value = Icons.pause;

        } else {
          NotificationApi.stopNotification(0);

        }
      }
    });
  }

  Future<void> onReplayPressed() async {

    callNotificationOnAudioPlaying();

    await audioPlayerController.seek(Duration.zero);
    audioPlayerController.play();
    iconPausePlayNotifier.value = Icons.pause;
  }

  void callNotificationOnAudioPlaying() async {
    await CallNotify()
      .audioNotification(audioName: tempData.selectedFileName.substring(0,tempData.selectedFileName.length-4));
  }

  String toTwoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String getDurationString(Duration duration) {

    final twoDigitMinutes = toTwoDigits(
        duration.inMinutes.remainder(60));

    final twoDigitSeconds = toTwoDigits(
        duration.inSeconds.remainder(60));

    return "$twoDigitMinutes:$twoDigitSeconds";
    
  }

  StreamBuilder buildSlider() {
    return StreamBuilder<double>(
      stream: sliderValueController.stream,
      initialData: 0.0,
      builder: (context, snapshot) {
        return ValueListenableBuilder<double>(
          valueListenable: audioPositionNotifier,
          builder: (context, audioPosition, _) {
            return Column(
              children: [
                SliderTheme(
                  data: const SliderThemeData(
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6.0
                    )
                  ),
                  child: Slider(value: audioPosition,
                    min: 0,
                    max: audioPlayerController.duration?.inSeconds.toDouble() ?? 100,
                    thumbColor: ThemeColor.justWhite,
                    inactiveColor: ThemeColor.thirdWhite,
                    activeColor: ThemeColor.justWhite,
                    onChanged: (double value) {
                      sliderValueController.add(value);
                      audioPlayerController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                  child: Row(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: currentAudioDuration,
                        builder: (context, value, child) {
                          return Text(
                            value,
                            style: const TextStyle(
                              color: ThemeColor.secondaryWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          );
                        }
                      ),
                      const Spacer(),
                      Text(
                        audioDuration,
                        style: const TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildPlayPauseButton() {
    return SizedBox(
      width: 72,
      height: 72,
      child: ValueListenableBuilder(
        valueListenable: iconPausePlayNotifier,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              color: ThemeColor.justWhite,
              border: Border.all(
                color: ThemeColor.justWhite,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(65),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                if(value == Icons.replay_rounded) {
                  await onReplayPressed();
                } else {
                  await playOrPauseAudioAsync();
                }
              },
              icon: Icon(value, color: ThemeColor.darkPurple, size: 45),
            ),
          );
        },
      ),
    );
  }

  Widget buildFastBackward() {
    return SizedBox(
      width: 100,
      height: 100,
      child: SplashWidget(
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            forwardingImplementation("negative");
          },
          icon: const Icon(Icons.fast_rewind_rounded, color: ThemeColor.justWhite, size: 50),
        ),
      ),
    );
  }

  Widget buildFastForward() {
    return SizedBox(
      width: 100,
      height: 100,
      child: SplashWidget(
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            forwardingImplementation("positive");
          },
          icon: const Icon(Icons.fast_forward_rounded, color: ThemeColor.justWhite, size: 50),
        ),
      ),
    );
  }

  Widget buildKeepPlaying() {
    return SizedBox(
      width: 100,
      height: 100,
      child: SplashWidget(
        child: ValueListenableBuilder(
          valueListenable: isKeepPlayingEnabledNotifier,
          builder: (context, value, child) {
            return IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                isKeepPlayingEnabledNotifier.value = !isKeepPlayingEnabledNotifier.value;
              },
              icon: Icon(Icons.autorenew_rounded, size: 35, color: value ? ThemeColor.justWhite : ThemeColor.thirdWhite),
            );
          },
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Text(
          tempData.selectedFileName.substring(0,tempData.selectedFileName.length-4),
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 24,
            fontWeight: FontWeight.w700
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          userData.username,
          style: const TextStyle(
            color: ThemeColor.secondaryWhite,
            fontSize: 19,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildBody() {

    final mediaQuery = MediaQuery.of(context).size;

    return Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 172.0),
            child: SizedBox(
              width: mediaQuery.width-90,
              height: mediaQuery.height-570,
              child: ValueListenableBuilder(
                valueListenable: currentGradientIndexNotifier,
                builder: (context, value, child) {
                  return AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors[value],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const Spacer(),

          buildHeader(),

          const SizedBox(height: 10),

          buildSlider(),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              const SizedBox(width: 105),

              buildFastBackward(),
              buildPlayPauseButton(),
              buildFastForward(),
              buildKeepPlaying(),
        
            ],
          ),
          
          const SizedBox(height: 48),

        ],
      
    );
  }

  void forwardingImplementation(String value) {

    if(currentAudioDuration.value == audioDuration && value != "negative") {
      return;
    }

    if(currentAudioDuration.value == audioDuration && value == "negative") {
      iconPausePlayNotifier.value = Icons.pause;
    }

    double currentPosition = audioPlayerController.position.inSeconds.toDouble();
    double newPosition =
        value == "positive" 
        ? currentPosition + 5 
        : currentPosition - 5;

    double maxDuration = audioPlayerController.duration?.inSeconds.toDouble() ?? 0;

    newPosition = newPosition.clamp(0.0, maxDuration);

    audioPositionNotifier.value = newPosition;
    audioPlayerController.seek(Duration(seconds: newPosition.toInt()));

  }

  void initializeAudioContentType() {

    final fileType = tempData.selectedFileName.split('.').last;

    if (fileType == "wav") {
      audioContentType = 'audio/wav';
    } else if (fileType == "mp3") {
      audioContentType = 'audio/mpeg';
    }

  }

  void initializeGradient() {
    Timer.periodic(durationGradient, (timer) {
      if(iconPausePlayNotifier.value == Icons.pause) {
        currentGradientIndexNotifier.value = 
        (currentGradientIndexNotifier.value + 1) % gradientColors.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeAudioContentType();
    playOrPauseAudioAsync();
    initializeGradient();
  }

  @override
  void dispose(){
    NotificationApi.stopNotification(0);
    sliderValueController.close();
    iconPausePlayNotifier.dispose();
    keepPlayingIconColorNotifier.dispose();
    isKeepPlayingEnabledNotifier.dispose();
    currentGradientIndexNotifier.dispose();
    audioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }
}