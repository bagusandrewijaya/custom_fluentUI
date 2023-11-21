import 'package:livekit_client/livekit_client.dart';

class LiveKitClass {
    static   Room? room;
    static bool isready = false ;
 static bool z = true;
 static String? clientid; 
static int seconds = 0; 
static bool isread = false;
static bool islogin = false;
static String?  mykey;
static String? keyclient;
static bool sedanglihatriwayat = false;
static List data = [];
static List<dynamic> noted = [];
static String? notedArray;
static String? alias;
}


class Note {
  final String noClient;
  final String judul;
  final String notes;

  Note(this.noClient, this.judul, this.notes);
}