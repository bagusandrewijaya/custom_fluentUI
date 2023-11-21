import 'dart:async';
import 'dart:math';


import 'package:example/livekit/exts.dart';
import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'dart:ui';

class PreRoomViews extends StatefulWidget {
  const PreRoomViews({Key? key});

  @override
  _PreRoomViewsState createState() => _PreRoomViewsState();
}

class _PreRoomViewsState extends State<PreRoomViews> {
  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  Timer? timer;
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {});
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Latar belakang gambar dari URL dengan efek blur
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'http://simrs.onthewifi.com:1842/fotodokter/full/-95.png', // Ganti dengan URL gambar latar belakang Anda
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black
                      .withOpacity(0.2), // Atur kekaburan sesuai kebutuhan Anda
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Memanggil",
                  style: TextStyle(
                    fontSize: 20, // Ukuran teks
                    color: Colors.white, // Warna teks
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    _connect(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset(
                        "assets/telemedicine/ended.png",
                        scale: 4,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
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
      await room.connect("wsS://api.rsummi.co.id:7880",
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlbyI6eyJyb29tSm9pbiI6dHJ1ZSwicm9vbSI6InJvb20xIiwiY2FuUHVibGlzaCI6dHJ1ZSwiY2FuU3Vic2NyaWJlIjp0cnVlfSwiaWF0IjoxNjk2ODIyNTkzLCJuYmYiOjE2OTY4MjI1OTMsImV4cCI6MTY5Njg0NDE5MywiaXNzIjoiZGV2a2V5Iiwic3ViIjoiYWRtaW4xIiwianRpIjoiYWRtaW4xIn0.eW2zowl_-XrZDjYW3eNPuyYEWs6FZRTMLlmvOa_Tn0M",
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
