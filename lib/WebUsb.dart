import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter_webusb/UsbProtocol.dart';
import 'package:flutter_webusb/src/web_usb.dart';

class WebUsbController {
  // usb device information ids
  static const int _vendorId = 0x0b6a;
  static const int _productId = 0x003C;

  // stream received data to UI
  //final StreamController<UsbInTransferResult> _dataStreamController =
  //StreamController<UsbInTransferResult>();

  //Stream<UsbInTransferResult> get dataStream => _dataStreamController.stream;
  //StreamController<UsbInTransferResult> get dataStreamController =>
  //_dataStreamController;

  // usb devices properties
  late UsbDevice _device;
  late int _interfaceNumber;
  late int _endpointIn;
  late int _endpointOut;
  late int _bufferSize;
  // protocol of the usb device
  late UsbProtocol usbGateProtocol = UsbProtocol();

  final queue = Queue<int>();

  // constructor
  WebUsbController() {
    _interfaceNumber = 0;
    _endpointIn = 0;
    _endpointOut = 0;
    _bufferSize = 64;

    usb.subscribeConnect((event) {
      window.console.log("WebUsb Connected Event Received! DeviceName: " +
          event.target.toString());
      window.console.log(event);
    });

    usb.subscribeDisconnect((event) {
      window.console.log("WebUsb Disconnected Event Received! DeviceName: " +
          event.target.toString());
      window.console.log(event);
    });
  }

  // device request filter
  final List<RequestOptionsFilter> _deviceFilter = [
    RequestOptionsFilter(vendorId: _vendorId, productId: _productId),
  ];

  // connect to usb device
  Future<UsbDevice> getDevice() async {
    UsbDevice usbDevice = await usb.requestDevice(RequestOptions(
      filters: _deviceFilter,
    ));
    window.console.log('[INFO] Requesting available devices ..');

    window.console.log('[OK] Product name: ${usbDevice.productName}');
    window.console.log('[OK] Manufacturer name: ${usbDevice.manufacturerName}');
    window.console.log('[OK] Device: $usbDevice');
    window.console.log(usbDevice);

    return usbDevice;
  }

  void readLoop() {
    if (_device != null && _device.opened == true) {
      _device.transferIn(_endpointIn, _bufferSize).then((inResult) {
        window.console.log(
            'WebUSB Read Successful! Status: ${inResult.status}, ${inResult.data.lengthInBytes}');
        //_dataStreamController.add(inResult);
        //return inResult;
        // if (inResult.data != null && inResult.data.lengthInBytes > 0) {
        //   var length = inResult.data.buffer;
        //   const bufView = Uint8Array(length);
        // }
        readLoop();
      }).catchError((onError) {
        window.console.log(onError);
      });
    }
  }

  Future<void> configureEndpoints() async {
    var interfaces = _device.configuration?.interfaces;

    interfaces?.forEach((element) {
      element.alternates.forEach((elementalt) {
        if (elementalt.interfaceClass == 0xff) {
          _interfaceNumber = element.interfaceNumber;
          elementalt.endpoints.forEach((elementendpoint) {
            if (elementendpoint.direction == "out") {
              _endpointOut = elementendpoint.endpointNumber;
              window.console.log('OUT ENDPOINT : $_endpointOut');
            }
            if (elementendpoint.direction == "in") {
              _endpointIn = elementendpoint.endpointNumber;
              window.console.log('IN ENDPOINT : $_endpointIn');
            }
          });
        }
      });
    });

    // interfaces?.forEach((element) {
    //   var alternatee = element.alternates
    //       .where((elementalt) => elementalt.interfaceClass == 0xff);
    //   _endpointIn = alternatee.first.endpoints
    //       .where((ep) => ep.direction == 'in')
    //       .first
    //       .endpointNumber;
    //   _endpointOut = alternatee.first.endpoints
    //       .where((ep) => ep.direction == 'out')
    //       .first
    //       .endpointNumber;
    // });
  }

  Future<void> configureInterfaces() async {
    await _device.claimInterface(_interfaceNumber);
    await _device.selectAlternateInterface(_interfaceNumber, 0);
  }

  Future<void> configureControlTransfer({required int value_}) async {
    await _device.controlTransferOut(ControlTransferOutSetup(
      requestType: 'class',
      recipient: 'interface',
      request: 0x22,
      value: value_,
      index: _interfaceNumber,
    ));
  }

  // connect to usb device
  Future<void> connect() async {
    // if (_dataStreamController.isClosed == true) {
    //   _dataStreamController.sink;
    // }
    _device = await getDevice();
    await _device.open();

    if (_device.configuration == null) {
      _device.selectConfiguration(1);
    }

    await configureEndpoints();
    await configureInterfaces();
    await configureControlTransfer(value_: 0x01);

    window.console.log('WebUSB Open Successful!');
    window.console.log('$_endpointIn, $_endpointOut, $_interfaceNumber');
    readLoop();
  }

  Future<void> disconnect() async {
    await configureControlTransfer(value_: 0x00);
    await _device.close();
    //await _dataStreamController.close();
  }

  Future<void> write(List<int> input) async {
    window.console.log('[INFO] User input for writing $input');
    var ret = usbGateProtocol.pack(input);
    try {
      await _device.transferOut(_endpointOut, Uint8List.view(ret));
    } catch (writeError) {
      window.console.log('[ERROR] $writeError');
    }
    return;
  }
}
