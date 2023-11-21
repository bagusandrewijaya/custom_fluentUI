import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

enum StatsType {
  kUnknown,
  kLocalAudioSender,
  kLocalVideoSender,
  kRemoteAudioReceiver,
  kRemoteVideoReceiver,
}

class ParticipantStatsWidget extends StatefulWidget {
  const ParticipantStatsWidget({Key? key, required this.participant})
      : super(key: key);
  final Participant participant;
  @override
  State<StatefulWidget> createState() => _ParticipantStatsWidgetState();
}

class _ParticipantStatsWidgetState extends State<ParticipantStatsWidget> {
  List<EventsListener<TrackEvent>> listeners = [];
  StatsType statsType = StatsType.kUnknown;
  Map<String, String> stats = {};

  void _setUpListener(Track track) {
    var listener = track.createListener();
    listeners.add(listener);
    if (track is LocalVideoTrack) {
      statsType = StatsType.kLocalVideoSender;
      listener.on<VideoSenderStatsEvent>((event) {
        setState(() {
          stats['koneksi '] = '${event.currentBitrate.toInt()} kpbs';
        });
      });
    } else if (track is RemoteVideoTrack) {
      statsType = StatsType.kRemoteVideoReceiver;
      listener.on<VideoReceiverStatsEvent>((event) {
        setState(() {
          stats['koneksi '] = '${event.currentBitrate.toInt()} kpbs';
        });
      });
    } else if (track is LocalAudioTrack) {
      statsType = StatsType.kLocalAudioSender;
    } else if (track is RemoteAudioTrack) {
      statsType = StatsType.kRemoteAudioReceiver;
    }
  }

  _onParticipantChanged() {
    for (var element in listeners) {
      element.dispose();
    }
    listeners.clear();
    for (var track in [
      ...widget.participant.videoTracks,
      ...widget.participant.audioTracks
    ]) {
      if (track.track != null) {
        _setUpListener(track.track!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    // trigger initial change
    _onParticipantChanged();
  }

  @override
  void deactivate() {
    for (var element in listeners) {
      element.dispose();
    }
    widget.participant.removeListener(_onParticipantChanged);
    super.deactivate();
  }

  num sendBitrate = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 248, 248, 248).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ),
      child: Column(
          children:
              stats.entries.map((e) => Text('${e.key}: ${e.value}')).toList()),
    );
  }
}
