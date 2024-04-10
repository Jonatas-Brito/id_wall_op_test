import 'package:flutter/material.dart';
import 'package:idwall_sdk/domain/model/document_model.dart';
import 'package:idwall_sdk/idwall_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  IdwallSdk.initialize("e87a76d7704a21d35702c1957e1cda3c");
  IdwallSdk.setupPublic([
    "AHYMQP+2/KIo32qYcfqnmSn+N/K3IdSZWlqa2Zan9eY=",
    "tDilFQ4366PMdAmN/kyNiBQy24YHjuDs6Qsa6Oc/4c8="
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo Id Wall'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Press the button to Start Flow',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  IdwallSdk.startFlow(
                    IdwallFlowType.complete,
                    [IdwallDocumentType.rg, IdwallDocumentType.cnh],
                    [
                      IdwallDocumentOption.digital,
                      IdwallDocumentOption.printed
                    ],
                  ).then((token) async {});
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text("Button"),
                )),
          ],
        ),
      ),
    );
  }
}
