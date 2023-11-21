import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../exts.dart';
import '../widgets/classchat.dart';
import '../widgets/controls.dart';
import '../widgets/participant.dart';
import '../widgets/participant_info.dart';

class RoomPage extends StatefulWidget {
  //
  final Room room;
  final EventsListener<RoomEvent> listener;

  const RoomPage(
    this.room,
    this.listener, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  //
  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  @override
  void initState() {
    startCount();
    super.initState();
    // add callback for a `RoomEvent` as opposed to a `ParticipantEvent`
    widget.room.addListener(_onRoomDidUpdate);
    // add callbacks for finer grained events
    _setUpListeners();
    _sortParticipants();
    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _askPublish();
      }
    });

    Hardware.instance.setSpeakerphoneOn(true);
  }

  /// for more information, see [event types](https://docs.livekit.io/client/events/#events)
  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        print('Room disconnected: reason => ${event.reason}');
      }
      WidgetsBindingCompatible.instance
          ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    })
    ..on<ParticipantEvent>((event) {
      print('Participant event');
      // sort participants on many track events as noted in documentation linked above
      _sortParticipants();
    })
    ..on<RoomRecordingStatusChanged>((event) {
      context.showRecordingStatusChangedDialog(event.activeRecording);
    })
    ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
    ..on<TrackE2EEStateEvent>(_onE2EEStateEvent)
    ..on<ParticipantNameUpdatedEvent>((event) {
      print(
          'Participant name updated: ${event.participant.identity}, name => ${event.name}');
    })
    ..on<DataReceivedEvent>((event) {
      String decoded = 'Failed to decode';
      try {
        decoded = utf8.decode(event.data);
      } catch (_) {
        print('Failed to decode: $_');
      }
      context.showDataReceivedDialog(decoded);
      setState(() {
        ChatData.chat.add(decoded);
      });
    })
    ..on<AudioPlaybackStatusChanged>((event) async {
      if (!widget.room.canPlaybackAudio) {
        print('Audio playback failed for iOS Safari ..........');
        bool? yesno = await context.showPlayAudioManuallyDialog();
        if (yesno == true) {
          await widget.room.startAudio();
        }
      }
    });

  void _askPublish() async {
    final result = await context.showPublishDialog();
    if (result != true) return;
    // video will fail when running in ios simulator
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      print('could not publish video: $error');
      await context.showErrorDialog(error);
    }
    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      print('could not publish audio: $error');
      await context.showErrorDialog(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    print('e2ee state: $e2eeState');
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    for (var participant in widget.room.participants.values) {
      for (var t in participant.videoTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }
    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = widget.room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: true,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }
    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
    });
  }

  int minutes = 0; // Mulai dari 20 menit
  int seconds = 0;
  Timer? timer;
  void startCount() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds == 59) {
          seconds = 0;
          if (minutes == 59) {
            minutes = 0;
            // Anda bisa menambahkan logika tambahan di sini jika diperlukan
          } else {
            minutes += 1;
          }
        } else {
          seconds += 1;
        }
      });
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      await widget.room.dispose();
      ChatData.chat.clear();
    })();

    super.dispose();
  }

  double _xPosition = 10;
  double _yPosition = 200;
  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            width: 600,
            child: Center(
              child: Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: participantTracks.isNotEmpty
                          ? ParticipantWidget.widgetFor(participantTracks.first,
                              showStatsLayer: false)
                          : Container()),
                  Positioned(
                      left: _xPosition,
                      top: _yPosition,
                      right: 0,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _xPosition += details.delta.dx;
                            _yPosition += details.delta.dy;
                          });
                        },
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                math.max(0, participantTracks.length - 1),
                            itemBuilder: (BuildContext context, int index) =>
                                SizedBox(
                              width: 180,
                              height: 120,
                              child: ParticipantWidget.widgetFor(
                                  participantTracks[index + 1]),
                            ),
                          ),
                        ),
                      )),
                  if (widget.room.localParticipant != null)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height *
                          0.04, // Jarak dari bagian bawah layar
                      left: 0, // Posisi horizontal kiri
                      right: 0, // Posisi horizontal kanan
                      child: SafeArea(
                        top: false,
                        child: ControlsWidget(
                          widget.room,
                          widget.room.localParticipant!,
                        ),
                      ),
                    ),
                  Positioned(
                      right: 10,
                      top: MediaQuery.of(context).size.height * 0.1,
                      child: Container(
                        width: 60,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(
                            "$formattedTime",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
