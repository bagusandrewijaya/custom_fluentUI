import 'dart:convert';

import 'package:example/livekit/widgets/class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'  as http;
extension LKExampleExt on BuildContext {
  //
  Future<bool?> showPublishDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Publish'),
          content: const Text('Would you like to publish your Camera & Mic ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  Future<bool?> showPlayAudioManuallyDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Play Audio'),
          content: const Text(
              'You need to manually activate audio PlayBack for iOS Safari !'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ignore'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Play Audio'),
            ),
          ],
        ),
      );

  Future<bool?> showUnPublishDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('UnPublish'),
          content:
              const Text('Would you like to un-publish your Camera & Mic ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  Future<void> showErrorDialog(dynamic exception) => showDialog<void>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(exception.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            )
          ],
        ),
      );
void setstatus(String statuz)async{
  
     final prefs = await SharedPreferences.getInstance();
LiveKitClass.notedArray = jsonEncode(LiveKitClass.noted.map((note) {
  return {
    'client': note.noClient.toString(),
    'judul': note.judul,
    'catatan': note.notes,
  };
}).toList());
final response = await http.post(Uri.parse("http://api.rsummi.co.id:1842/rsummi-api/SetCostumerLiveKitStatus"),body: {
'uid' : prefs.getString('userid').toString(),
'status' :  "1"
});
print( prefs.getString('userid').toString(),);
final response2 = await http.post(Uri.parse("http://api.rsummi.co.id:1842/rsummi-api/SetLiveKitRecordCall"),body : {
"clientId" : LiveKitClass.clientid.toString(),
"alias": LiveKitClass.alias.toString(),
"uid" : prefs.getString('userid').toString(),
"chat" :LiveKitClass.notedArray.toString()

});

}
  Future<bool?> showDisconnectDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Akhiri Panggilan',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Anda yakin akan mengakhiri panggilan ?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx,false),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xffE73844)),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () async{
   setstatus("1");

            Navigator.pop(ctx, true);

              },
              child: const Text(
                'Akhiri',
              ),
            ),
          ],
        ),
      );

  Future<bool?> showReconnectDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Reconnect'),
          content: const Text('This will force a reconnection'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reconnect'),
            ),
          ],
        ),
      );

  Future<void> showReconnectSuccessDialog() => showDialog<void>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Reconnect'),
          content: const Text('Reconnection was successful.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future<bool?> showDataReceivedDialog(String data) => showDialog<bool>(
      context: this,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New'),
          content: Text("Pesan Baru Masuk"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        );
      });

  Future<bool?> showRecordingStatusChangedDialog(bool isActiveRecording) =>
      showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Room recording reminder'),
          content: Text(isActiveRecording
              ? 'Room recording is active'
              : 'Room recording is stoped'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future<bool?> showSubscribePermissionDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Allow subscription'),
          content: const Text(
              'Allow all participants to subscribe tracks published by local participant?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  Future<SimulateScenarioResult?> showSimulateScenarioDialog() =>
      showDialog<SimulateScenarioResult>(
        context: this,
        builder: (ctx) => SimpleDialog(
          title: const Text('Simulate Scenario'),
          children: SimulateScenarioResult.values
              .map((e) => SimpleDialogOption(
                    child: Text(e.name),
                    onPressed: () => Navigator.pop(ctx, e),
                  ))
              .toList(),
        ),
      );
}

enum SimulateScenarioResult {
  signalReconnect,
  nodeFailure,
  migration,
  serverLeave,
  switchCandidate,
  clear,
  e2eeKeyRatchet,
}
