
import 'package:example/livekit/exts.dart';
import 'package:example/models/patientDetails.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
   
      children: [
        Center(child: Container(
          child: ElevatedButton(onPressed: ()  =>   _connect(context), child: Text("data")),
        ),)
      ],
    );
  }


  bool _busy = false;
  Future<void> _connect(BuildContext ctx) async {
    //

    try {
      setState(() {
        _busy = true;
      });

      E2EEOptions? e2eeOptions;

      String preferredCodec = 'VP9';

      // create new room
      final room = Room(
          roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: false,
        defaultAudioPublishOptions: const AudioPublishOptions(
          dtx: true,
        ),
        defaultVideoPublishOptions: VideoPublishOptions(
          simulcast: false,
          videoCodec: preferredCodec,
        ),
        defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
            useiOSBroadcastExtension: true,
            params: VideoParametersPresets.screenShareH1080FPS30),
        e2eeOptions: e2eeOptions,
        defaultCameraCaptureOptions: const CameraCaptureOptions(
          maxFrameRate: 30,
          params: VideoParametersPresets.h720_169,
        ),
      ));

      // Create a Listener before connecting
      final listener = room.createListener();

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect("ws://api.rsummi.co.id:7880",
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlbyI6eyJyb29tSm9pbiI6dHJ1ZSwicm9vbSI6ImNsYmdldy04NjEtcnN1bW1pIiwiY2FuUHVibGlzaCI6dHJ1ZSwiY2FuU3Vic2NyaWJlIjp0cnVlfSwiaWF0IjoxNzAwNTQ5MjgzLCJuYmYiOjE3MDA1NDkyODMsImV4cCI6MTcwMDU3MDg4MywiaXNzIjoiQVBJaDJwZVhLU3hpTjVRIiwic3ViIjoiYW5kcmUiLCJqdGkiOiJhbmRyZSJ9.1w2ksSVUY_biMHFXEno3RWqGh4anjphzwijWeUqn21c",
          fastConnectOptions: FastConnectOptions(
            microphone: const TrackOption(enabled: true),
            camera: const TrackOption(enabled: false),
          ));

      // await Navigator.pushReplacement(
      //   ctx,
      //   MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      // );
    } catch (error) {
      print('Could not connect $error');
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }
}

class SponsorButton extends StatelessWidget {
  const SponsorButton({
    super.key, 
    required this.imageUrl,
    required this.username,
  });

  final String imageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Color.fromARGB(204, 55, 55, 121),
         
      
        ),
      ),
      Text(username),
    ]);
  }
}