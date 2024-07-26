import 'package:flutter/material.dart';
import 'package:nfc_app/NFC%20APP/readwrite.dart';
//import 'package:nfc_app/nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC MANAGER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReadWriteNFCScreen(),
      //Scaffold(
      //     appBar: AppBar(
      //       title: const Text("NFC App"),
      //     ),
      //     body: ReadWriteNFCScreen()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // create variable to store the reading tags
  String _readFromNfcTag = "";
  final TextEditingController _writeController = TextEditingController();

// function for reading tags
  void _readNfcTag() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag badge) async {
      var ndef = Ndef.from(badge);

      if (ndef != null && ndef.cachedMessage != null) {
        String tempRecord = "";
        for (var record in ndef.cachedMessage!.records) {
          tempRecord =
              "$tempRecord ${String.fromCharCodes(record.payload.sublist(record.payload[0] + 1))}";
        }

        setState(() {
          _readFromNfcTag = tempRecord;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Not read')));
      }

      NfcManager.instance.stopSession();
    });
  }

// to write the nfc tags
  void _writeNfcTag(String record) {
    NfcManager.instance.startSession(onDiscovered: (NfcTag badge) async {
      var ndef = Ndef.from(badge);

      if (ndef != null && ndef.isWritable) {
        NdefRecord ndefRecord = NdefRecord.createText(record);
        NdefMessage message = NdefMessage([ndefRecord]);

        try {
          await ndef.write(message);
        } catch (e) {
          NfcManager.instance
              .stopSession(errorMessage: "Error while writing to badge");
          // ignore: dead_code_catch_following_catch
        }
      }

      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: NfcManager.instance.isAvailable(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            const Center(
              child: Text('Nfc not available'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                        enabled: false,
                        border: const OutlineInputBorder(),
                        hintText: _readFromNfcTag,
                        hintMaxLines: 10),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _readNfcTag();
                        setState(() {
                          _readNfcTag();
                        });
                      },
                      child: const Text("Read")),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _writeController,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () => _writeNfcTag(_writeController.text),
                      child: const Text("Write")),
                ],
              ),
            ),
          );
        });
  }
}
