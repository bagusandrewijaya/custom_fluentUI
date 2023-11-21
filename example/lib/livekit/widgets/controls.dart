import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:example/livekit/exts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'classchat.dart';


class ControlsWidget extends StatefulWidget {
  //
  final Room? room;
  final LocalParticipant? participant;

  const ControlsWidget(
    this.room,
    this.participant, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ControlsWidgetState();
}

class _ControlsWidgetState extends State<ControlsWidget> {
  //
  CameraPosition position = CameraPosition.front;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;
  List<MediaDevice>? _videoInputs;

  StreamSubscription? _subscription;

  bool _speakerphoneOn = false;
  void setuserchat() async {
    final prefs = await SharedPreferences.getInstance();
    UserSample.uid = prefs.getString('User');
  }

  @override
  void initState() {
    setuserchat();
    super.initState();
    participant.addListener(_onChange);
    _subscription = Hardware.instance.onDeviceChange.stream
        .listen((List<MediaDevice> devices) {
      _loadDevices(devices);
    });
    Hardware.instance.enumerateDevices().then(_loadDevices);
    _speakerphoneOn = Hardware.instance.speakerOn ?? false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    participant.removeListener(_onChange);
    super.dispose();
  }

  LocalParticipant get participant => widget.participant!;

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
    setState(() {});
  }

  void _onChange() {
    // trigger refresh
    setState(() {});
  }

  void _unpublishAll() async {
    final result = await context.showUnPublishDialog();
    if (result == true) await participant.unpublishAllTracks();
  }

  bool get isMuted => participant.isMuted;

  void _disableAudio() async {
    await participant.setMicrophoneEnabled(false);
  }

  Future<void> _enableAudio() async {
    await participant.setMicrophoneEnabled(true);
  }

  void _disableVideo() async {
    await participant.setCameraEnabled(false);
  }

  void _enableVideo() async {
    await participant.setCameraEnabled(true);
  }

  void _selectAudioOutput(MediaDevice device) async {
    await widget.room!.setAudioOutputDevice(device);
    setState(() {});
  }

  void _selectAudioInput(MediaDevice device) async {
    await widget.room!.setAudioInputDevice(device);
    setState(() {});
  }

  void _selectVideoInput(MediaDevice device) async {
    await widget.room!.setVideoInputDevice(device);
    setState(() {});
  }

  void _setSpeakerphoneOn() {
    _speakerphoneOn = !_speakerphoneOn;
    Hardware.instance.setSpeakerphoneOn(_speakerphoneOn);
    setState(() {});
  }

  void _toggleCamera() async {
    //
    final track = participant.videoTracks.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      setState(() {
        position = newPosition;
      });
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
  }

  void _enableScreenShare() async {
    if (lkPlatformIs(PlatformType.android)) {
      // Android specific
      requestBackgroundPermission([bool isRetry = false]) async {
        // Required for android screenshare.
        try {
          bool hasPermissions = await FlutterBackground.hasPermissions;
          if (!isRetry) {
            const androidConfig = FlutterBackgroundAndroidConfig(
              notificationTitle: 'Screen Sharing',
              notificationText: 'LiveKit Example is sharing the screen.',
              notificationImportance: AndroidNotificationImportance.Default,
              notificationIcon: AndroidResource(
                  name: 'livekit_ic_launcher', defType: 'mipmap'),
            );
            hasPermissions = await FlutterBackground.initialize(
                androidConfig: androidConfig);
          }
          if (hasPermissions &&
              !FlutterBackground.isBackgroundExecutionEnabled) {
            await FlutterBackground.enableBackgroundExecution();
          }
        } catch (e) {
          if (!isRetry) {
            return await Future<void>.delayed(const Duration(seconds: 1),
                () => requestBackgroundPermission(true));
          }
          print('could not publish video: $e');
        }
      }

      await requestBackgroundPermission();
    }
    if (lkPlatformIs(PlatformType.iOS)) {
      var track = await LocalVideoTrack.createScreenShareTrack(
        const ScreenShareCaptureOptions(
          useiOSBroadcastExtension: true,
          maxFrameRate: 15.0,
        ),
      );
      await participant.publishVideoTrack(track);
      return;
    }
    await participant.setScreenShareEnabled(true, captureScreenAudio: true);
  }

  void _disableScreenShare() async {
    await participant.setScreenShareEnabled(false);
    if (Platform.isAndroid) {
      // Android specific
      try {
        //   await FlutterBackground.disableBackgroundExecution();
      } catch (error) {
        print('error disabling screen share: $error');
      }
    }
  }

  void _onTapDisconnect() async {
    final result = await context.showDisconnectDialog();
    if (result == true) await widget.room!.disconnect();
  }

  void _onTapUpdateSubscribePermission() async {
    final result = await context.showSubscribePermissionDialog();
    if (result != null) {
      try {
        widget.room!.localParticipant?.setTrackSubscriptionPermissions(
          allParticipantsAllowed: result,
        );
      } catch (error) {
        await context.showErrorDialog(error);
      }
    }
  }

  void _onTapSimulateScenario() async {
    final result = await context.showSimulateScenarioDialog();
    if (result != null) {
      print('${result}');

      if (SimulateScenarioResult.e2eeKeyRatchet == result) {
        await widget.room!.e2eeManager?.ratchetKey();
      }

      await widget.room!.sendSimulateScenario(
        signalReconnect:
            result == SimulateScenarioResult.signalReconnect ? true : null,
        nodeFailure: result == SimulateScenarioResult.nodeFailure ? true : null,
        migration: result == SimulateScenarioResult.migration ? true : null,
        serverLeave: result == SimulateScenarioResult.serverLeave ? true : null,
        switchCandidate:
            result == SimulateScenarioResult.switchCandidate ? true : null,
      );
    }
  }

  bool isModalVisible = false;

  void _toggleModalVisibility() {
    setState(() {
      isModalVisible = !isModalVisible;
    });
  }


  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Expanded(
  
      child: Padding(
        padding: const EdgeInsets.symmetric(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              Container(
               padding: EdgeInsets.all(8),
             child: Image.asset("images/rsummifix.png",fit: BoxFit.fill,),
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.1,
                  ), 
              Column(
                   mainAxisAlignment: MainAxisAlignment.end,
                children: [
                
                    if (participant.isMicrophoneEnabled())
                  GestureDetector(
                    onTap: _disableAudio,
                    child: Container(
                        width: 50,
                       height: 50,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                             image: DecorationImage(image: AssetImage("images/micon.png"),fit: BoxFit.fill),
                     
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                          ],
                        )),
                  )
                else
                  GestureDetector(
                    onTap: _enableAudio,
                    child: Container(
                       width: 50,
                       height: 50,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          
                                   image: DecorationImage(image: AssetImage("images/micof.png"),fit: BoxFit.fill),
                              borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                          ],
                        )),
                  ),
                SizedBox(
                   height: 16,
                ),
                GestureDetector(
                  onTap: _onTapDisconnect,
                  child: Container(
                       width: 50,
                       height: 50,
                      padding: EdgeInsets.all(6),
                             decoration: BoxDecoration(
                              
                          image: DecorationImage(image: AssetImage("images/ended.png"),fit: BoxFit.fill),
                          borderRadius: BorderRadius.circular(50)),
                       
                          
                          ),
                ),
                SizedBox(
                  height: 16,
                ),
              //   GestureDetector(
              //     onTap: () {},
              //     child: Container(
              //         width: 50,
              //          height: 50,
              //         padding: EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //             color: Color.fromARGB(151, 78, 78, 78),
              //             borderRadius: BorderRadius.circular(50)),
              //         child: Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
                        
              //           ],
              //         )),
              //   ),
              // SizedBox(
              //      height: 16,
              //   ),
           
                ],
              )
           
           
          ],
        ),
      ),
    );
  }
}
