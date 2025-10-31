import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Service for managing Bluetooth connections to weighing scales
/// Supports Aclas OS2CX and Imin DW1 scales
class BluetoothService {
  BluetoothConnection? _connection;
  StreamSubscription? _dataSubscription;
  final StreamController<double> _weightController = StreamController<double>.broadcast();
  
  String? connectedDeviceName;
  bool isConnected = false;
  
  /// Stream of weight readings from the scale
  Stream<double> get weightStream => _weightController.stream;
  
  /// Scan for available Bluetooth devices
  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      final List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices;
    } catch (e) {
      print('Error scanning devices: $e');
      return [];
    }
  }
  
  /// Connect to a Bluetooth device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      connectedDeviceName = device.name;
      isConnected = true;
      
      // Listen to incoming data
      _dataSubscription = _connection!.input!.listen(
        _handleData,
        onDone: () {
          disconnect();
        },
        onError: (error) {
          print('Bluetooth error: $error');
          disconnect();
        },
      );
      
      // Initialize connection based on device type
      final deviceNameUpper = device.name?.toUpperCase();
      if ((deviceNameUpper?.contains('ACLAS') ?? false) || 
          (deviceNameUpper?.contains('OS2') ?? false)) {
        await _initializeAclasScale();
      }
      
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      isConnected = false;
      return false;
    }
  }
  
  /// Initialize Aclas OS2CX scale with passive protocol
  /// Based on official Aclas OS2CX manual communication protocol
  Future<void> _initializeAclasScale() async {
    try {
      // Step 1: Send connection request (0x05)
      await Future.delayed(Duration(milliseconds: 500));
      _connection?.output.add(Uint8List.fromList([0x05]));
      await _connection?.output.allSent;
      
      // Wait for response (0x06)
      await Future.delayed(Duration(milliseconds: 500));
      
      // Step 2: Request continuous weight data (0x11)
      _connection?.output.add(Uint8List.fromList([0x11]));
      await _connection?.output.allSent;
      
      print('Aclas OS2CX initialized successfully');
    } catch (e) {
      print('Error initializing Aclas scale: $e');
    }
  }
  
  /// Handle incoming data from the scale
  void _handleData(Uint8List data) {
    try {
      final deviceNameUpper = connectedDeviceName?.toUpperCase();
      if ((deviceNameUpper?.contains('ACLAS') ?? false) ||
          (deviceNameUpper?.contains('OS2') ?? false)) {
        _parseAclasData(data);
      } else if ((deviceNameUpper?.contains('IMIN') ?? false) ||
                 (deviceNameUpper?.contains('DW1') ?? false)) {
        _parseIminData(data);
      } else {
        // Try both parsers
        try {
          _parseAclasData(data);
        } catch (e) {
          _parseIminData(data);
        }
      }
    } catch (e) {
      print('Error parsing data: $e');
    }
  }
  
  /// Parse Aclas OS2CX weight data
  /// Protocol format (16 bytes):
  /// Head1(0x01) | Head2(0x02) | Flag1 | Sign | Weight(6 bytes) | Unit(2 bytes) | CheckSum | Tail1(0x03) | Tail2(0x04) | Flag2
  void _parseAclasData(Uint8List data) {
    if (data.length < 15) return;
    
    // Verify headers
    if (data[0] != 0x01 || data[1] != 0x02) return;
    
    // Verify tails
    if (data[12] != 0x03 || data[13] != 0x04) return;
    
    // Check Flag1 status
    int flag1 = data[2];
    if (flag1 == 0x46) { // 'F' - Weight is beyond range or not zeroed
      print('Scale not ready or out of range');
      return;
    }
    
    if (flag1 != 0x53) { // 'S' - Weight is stable
      print('Weight is unstable');
      // Still process but mark as unstable
    }
    
    // Get sign
    int sign = data[3];
    bool isNegative = (sign == 0x2D); // '-' character
    
    // Extract weight (6 bytes, ASCII digits)
    String weightStr = '';
    for (int i = 4; i < 10; i++) {
      weightStr += String.fromCharCode(data[i]);
    }
    
    // Extract unit (2 bytes, ASCII)
    String unit = '';
    for (int i = 10; i < 12; i++) {
      unit += String.fromCharCode(data[i]);
    }
    
    // Parse weight value
    double weight = double.tryParse(weightStr.trim()) ?? 0.0;
    if (isNegative) {
      weight = -weight;
    }
    
    // Convert to kg if necessary
    if (unit.trim().toUpperCase() == 'G' || unit.trim().toUpperCase() == 'GR') {
      weight = weight / 1000.0;
    }
    
    // Emit weight
    _weightController.add(weight);
    print('Aclas weight: $weight kg (stable: ${flag1 == 0x53})');
  }
  
  /// Parse Imin DW1 weight data
  /// Protocol format (6 bytes binary):
  /// Status | Weight High | Weight Mid | Weight Low | Unit | Checksum
  void _parseIminData(Uint8List data) {
    if (data.length < 6) return;
    
    // Check status byte
    int status = data[0];
    bool isStable = (status & 0x01) == 0x01;
    bool isNegative = (status & 0x02) == 0x02;
    
    // Extract weight (3 bytes, little-endian)
    int weightRaw = data[1] | (data[2] << 8) | (data[3] << 16);
    
    // Get unit
    int unit = data[4];
    
    // Calculate weight
    double weight = weightRaw / 100.0; // Assuming 2 decimal places
    
    if (isNegative) {
      weight = -weight;
    }
    
    // Convert to kg based on unit
    if (unit == 0x01) { // grams
      weight = weight / 1000.0;
    }
    
    // Emit weight
    _weightController.add(weight);
    print('Imin weight: $weight kg (stable: $isStable)');
  }
  
  /// Request weight reading from scale (for passive mode)
  Future<void> requestWeight() async {
    if (!isConnected || _connection == null) return;
    
    try {
      // Send weight request command (0x11) for Aclas OS2CX
      _connection?.output.add(Uint8List.fromList([0x11]));
      await _connection?.output.allSent;
    } catch (e) {
      print('Error requesting weight: $e');
    }
  }
  
  /// Send tare/zero command to scale
  Future<void> tare() async {
    if (!isConnected || _connection == null) return;
    
    try {
      // Aclas OS2CX tare command
      // STX(0x3C) | Cmd(0x54, 0x4B for tare or 0x5A, 0x4B for zero) | ETX1(0x3E) | ETX2(0x09)
      Uint8List tareCommand = Uint8List.fromList([0x3C, 0x54, 0x4B, 0x3E, 0x09]);
      _connection?.output.add(tareCommand);
      await _connection?.output.allSent;
      
      print('Tare command sent');
    } catch (e) {
      print('Error sending tare command: $e');
    }
  }
  
  /// Send zero command to scale
  Future<void> zero() async {
    if (!isConnected || _connection == null) return;
    
    try {
      // Aclas OS2CX zero command
      // STX(0x3C) | Cmd(0x5A, 0x4B) | ETX1(0x3E) | ETX2(0x09)
      Uint8List zeroCommand = Uint8List.fromList([0x3C, 0x5A, 0x4B, 0x3E, 0x09]);
      _connection?.output.add(zeroCommand);
      await _connection?.output.allSent;
      
      print('Zero command sent');
    } catch (e) {
      print('Error sending zero command: $e');
    }
  }
  
  /// Disconnect from the scale
  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      await _connection?.close();
      _connection = null;
      connectedDeviceName = null;
      isConnected = false;
      print('Disconnected from scale');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    disconnect();
    _weightController.close();
  }
}

