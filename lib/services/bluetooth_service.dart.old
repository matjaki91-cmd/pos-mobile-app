import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  


  Future<bool> enableBluetooth() async {
    if (!(await _bluetooth.isEnabled ?? false)) {
      await _bluetooth.requestEnable();
    }
    return await _bluetooth.isEnabled ?? false;
  }

  Future<List<BluetoothDevice>> getAvailableDevices() async {
    final devices = await _bluetooth.getBondedDevices();
    return devices.toList();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _setupDataListener();
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  void _setupDataListener() {
    if (_connection != null) {
      _connection!.input!.listen((List<int> data) {
        // Handle incoming data from weighing scale
        // String receivedData = String.fromCharCodes(data);
        // Process data from weighing scale
      }).onDone(() {
        // Bluetooth connection closed
      });
    }
  }

  Future<void> sendCommand(String command) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      await _connection!.output.allSent;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  bool get isConnected => _connection != null && _connection!.isConnected;

  // Parse weight data from Aclas O2SX scale
  static double? parseAclasWeight(String data) {
    try {
      // Aclas O2SX typically sends weight in format like "1234.56\r\n"
      final cleanData = data.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanData);
    } catch (e) {
      return null;
    }
  }

  // Parse weight data from Imin DW1 scale
  static double? parseIminWeight(String data) {
    try {
      // Imin DW1 typically sends weight in format like "WT:1234.56\r\n"
      final regex = RegExp(r'WT:(\d+\.?\d*)');
      final match = regex.firstMatch(data);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

