import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter_webusb/web_usb.dart';
import 'package:flutter_webusb/WebUsb.dart';
import 'package:flutter_webusb/src/web_usb.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebUsbController webusbController = WebUsbController();
  TextEditingController _inputController =
      TextEditingController(); // Controller for the input TextField
  String userInput = ''; // Variable to hold user input

  StreamController<bool> signalStreamController =
      StreamController<bool>(); // Create the StreamController
  List<UsbInTransferResult?> receivedMessages = []; // List to

  @override
  void initState() {
    super.initState();
    //_startListening();
    // You can use the signalStreamController's stream to listen for events
    // and update the UI accordingly.
    //webusbController.readLoop(); // Pass the StreamController to the read() function
  }

  // void _startListening(bool yes) async {
  //   while (yes) {
  //     await Future.delayed(Duration(
  //         milliseconds:
  //             500)); // Delay to control how frequently to check for updates
  //     webusbController.readLoop(); // Call the read function to receive data
  //   }
  // }

  Future<void> _onConnectButtonPressed() async {
    await webusbController.connect();
    //_startListening(true);
    //await getDevice();
  }

  Future<void> _onDisconnectButtonPressed() async {
    //_startListening(false);
    //await webusbController.dataStreamController.close();
    await webusbController.disconnect();
  }

  Future<void> _onWriteButtonPressed() async {
    String inputText =
        _inputController.text; // Get the user input from the TextField
    List<int> integerList = inputText.split(' ').map(int.parse).toList();

    await webusbController.write(integerList);
  }

  @override
  void dispose() {
    _inputController
        .dispose(); // Dispose the input controller when the widget is removed from the tree.
    super.dispose();
    webusbController.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter-WebUSB Plugin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _onConnectButtonPressed(),
                  child: const Text('Connect'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _onDisconnectButtonPressed(),
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            SizedBox(height: 16, width: 20),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Write to usb',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onWriteButtonPressed(),
              child: const Text('Write'),
            ),
            // SizedBox(height: 16),
            // StreamBuilder<UsbInTransferResult>(
            //   stream: webusbController
            //       .dataStream, // Listen to the data stream from WebUsbController
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (snapshot.hasData && snapshot.data != null) {
            //       receivedMessages
            //           .add(snapshot.data); // Add the received data to the list
            //       return Column(
            //         children: receivedMessages
            //             .map((message) => Text('Received Data: $message'))
            //             .toList(),
            //       );
            //     } else {
            //       return Text('No Data');
            //     }
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
