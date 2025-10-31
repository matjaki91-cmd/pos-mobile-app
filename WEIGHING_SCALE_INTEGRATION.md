# Weighing Scale Integration Guide

This document provides detailed instructions for integrating weighing scales (Aclas O2SX and Imin DW1) with the POS mobile app.

## Supported Scales

### 1. Aclas O2SX
- **Connection**: Bluetooth or USB Serial
- **Data Format**: Weight in grams (e.g., "1234.56\r\n")
- **Baud Rate**: 9600
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None

### 2. Imin DW1
- **Connection**: Bluetooth
- **Data Format**: "WT:1234.56\r\n" (weight in grams)
- **Baud Rate**: 9600
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None

## Implementation

### Step 1: Enable Bluetooth Permission

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

Add to `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to weighing scales</string>
<key>NSBluetoothCentralUsageDescription</key>
<string>This app needs Bluetooth to connect to weighing scales</string>
```

### Step 2: Initialize Bluetooth Service

```dart
import 'package:pos_mobile_app/services/bluetooth_service.dart';

final bluetoothService = BluetoothService();

// Enable Bluetooth
await bluetoothService.enableBluetooth();

// Get available devices
final devices = await bluetoothService.getAvailableDevices();
```

### Step 3: Connect to Scale

```dart
// Connect to the first available device
await bluetoothService.connectToDevice(devices[0]);

// Check connection status
if (bluetoothService.isConnected) {
  print('Connected to scale');
}
```

### Step 4: Read Weight Data

Create a listener for weight data:

```dart
// For Aclas O2SX
bluetoothService.setupDataListener();
// The scale will send weight data periodically

// Parse the received data
final weight = BluetoothService.parseAclasWeight("1234.56\r\n");
print('Weight: $weight kg');

// For Imin DW1
final iminWeight = BluetoothService.parseIminWeight("WT:1234.56\r\n");
print('Weight: $iminWeight kg');
```

### Step 5: Send Commands (if needed)

```dart
// Send a command to the scale (e.g., tare/zero)
await bluetoothService.sendCommand("T\r\n");
```

### Step 6: Disconnect

```dart
await bluetoothService.disconnect();
```

## Integration with Product Screen

Example of integrating weighing scale with the products screen:

```dart
import 'package:pos_mobile_app/services/bluetooth_service.dart';

class WeighableProductScreen extends StatefulWidget {
  @override
  State<WeighableProductScreen> createState() => _WeighableProductScreenState();
}

class _WeighableProductScreenState extends State<WeighableProductScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  double? _currentWeight;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeScale();
  }

  Future<void> _initializeScale() async {
    try {
      // Enable Bluetooth
      await _bluetoothService.enableBluetooth();
      
      // Get available devices
      final devices = await _bluetoothService.getAvailableDevices();
      
      if (devices.isNotEmpty) {
        // Connect to first device
        await _bluetoothService.connectToDevice(devices[0]);
        
        setState(() {
          _isConnected = _bluetoothService.isConnected;
        });
      }
    } catch (e) {
      print('Error initializing scale: $e');
    }
  }

  void _updateWeight(String rawData) {
    double? weight;
    
    // Try parsing as Aclas O2SX
    weight = BluetoothService.parseAclasWeight(rawData);
    
    // If that fails, try Imin DW1
    if (weight == null) {
      weight = BluetoothService.parseIminWeight(rawData);
    }
    
    if (weight != null) {
      setState(() {
        _currentWeight = weight;
      });
    }
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weighable Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _isConnected ? 'Scale Connected' : 'Scale Disconnected',
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weight Display
          if (_currentWeight != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Current Weight'),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentWeight!.toStringAsFixed(2)} kg',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Products List
          Expanded(
            child: ListView(
              // Products that require weighing
            ),
          ),
        ],
      ),
    );
  }
}
```

## Troubleshooting

### Scale Not Connecting
1. Ensure Bluetooth is enabled on the device
2. Pair the scale with the device manually first
3. Check that the scale is powered on
4. Verify Bluetooth permissions are granted

### Weight Data Not Received
1. Check the scale's data format matches the parser
2. Verify baud rate and serial settings
3. Ensure the scale is sending data continuously
4. Check for interference from other Bluetooth devices

### Parsing Errors
1. Verify the raw data format from the scale
2. Update the parser regex if needed
3. Add logging to debug the received data

## Data Format Examples

### Aclas O2SX
```
Raw: "1234.56\r\n"
Parsed: 1234.56
```

### Imin DW1
```
Raw: "WT:1234.56\r\n"
Parsed: 1234.56
```

## Advanced Features

### Real-time Weight Display
Implement a StreamBuilder to update UI in real-time:

```dart
StreamBuilder<double>(
  stream: _bluetoothService.weightStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Weight: ${snapshot.data} kg');
    }
    return const Text('No data');
  },
)
```

### Weight Validation
Add validation for reasonable weight ranges:

```dart
bool isValidWeight(double weight) {
  return weight > 0 && weight < 100; // 0-100 kg
}
```

### Tare/Zero Function
Reset the scale to zero:

```dart
Future<void> tareScale() async {
  await _bluetoothService.sendCommand("T\r\n");
}
```

## References

- [Aclas O2SX Documentation](https://data2.manualslib.com/cpdf/27/133/13248/50c669.pdf)
- [Imin DW1 Documentation](https://oss-sg.imin.sg/docs/en/ElectronicScale.html)
- [Flutter Bluetooth Serial Package](https://pub.dev/packages/flutter_bluetooth_serial)

