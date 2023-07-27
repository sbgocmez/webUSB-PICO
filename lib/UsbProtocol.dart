import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_webusb/src/web_usb.dart';

import 'Protocol.dart';

class UsbProtocol extends Protocol {
  late String name;
  late String version;
  late final endian;

  UsbProtocol() {
    name = 'UsbGateProtocol';
    version = '1.0.0';
    endian = Endian.little;
  }

  ByteBuffer pack(List payload) {
    var offset = 0;
    final int N = payload.length + 13;
    final buffer = Uint8List(N + 6).buffer;
    final dataView = ByteData.view(buffer);

    dataView.setUint16(offset, N, endian);
    offset += 2;

    final time = DateTime.now().microsecondsSinceEpoch;
    final uniqueId = time >>> 0;

    dataView.setUint32(offset, uniqueId, endian);
    offset += 4;

    dataView.setUint32(offset, 0x00, endian);
    offset += 4;

    dataView.setUint16(offset, payload.length, endian);
    offset += 2;

    dataView.setUint16(offset, 0x01, endian);
    offset += 2;

    dataView.setUint8(offset, 0x07);
    offset += 1;

    payload.forEach((element) {
      dataView.setUint8(offset, element);
      offset += 1;
    });

    dataView.setUint32(offset, 0x00, endian);
    offset += 4;

    return buffer;
  }
}
