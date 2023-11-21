
import 'package:example/models/patientDetails.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SamplePage extends StatefulWidget {
  const SamplePage({super.key});

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
     header: PageHeader(
        title:  Text('${ PatientUserId.name}'),
        commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
         Icon(Icons.abc_outlined)
        ]),
      ),
      children: [
        Center(child: Container(
          child: ElevatedButton(onPressed: ()  =>   GoRouter.of(context).pop(), child: Text("data")),
        ),)
      ],
    );
  }
}
