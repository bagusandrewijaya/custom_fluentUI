import 'package:flutter/material.dart';

import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'pages/connect.dart';

class TelemeDicineHome extends StatefulWidget {
  //
  const TelemeDicineHome({
    Key? key,
  }) : super(key: key);

  @override
  State<TelemeDicineHome> createState() => _TelemeDicineHomeState();
}

class _TelemeDicineHomeState extends State<TelemeDicineHome> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ConnectPage(),
      );
}
