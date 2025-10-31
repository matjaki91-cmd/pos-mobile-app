import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';
import 'dart:io';

class StaffCheckinScreen extends StatefulWidget {
  const StaffCheckinScreen({super.key});

  @override
  State<StaffCheckinScreen> createState() => _StaffCheckinScreenState();
}

class _StaffCheckinScreenState extends State<StaffCheckinScreen> {
  final SupabaseService _supabase = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _selectedStaffId;
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  File? _capturedPhoto;
  String _checkInMethod = 'camera'; // 'camera', 'thumbprint', 'manual'

  @override
  void initState() {
    super.initState();
    _loadStaffList();
  }

  Future<void> _loadStaffList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final staff = await _supabase.client
          .from('staff')
          .select('id, name, employee_id, position, status')
          .eq('status', 'active')
          .order('name');
      
      setState(() {
        _staffList = List<Map<String, dynamic>>.from(staff);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading staff: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
      );
      
      if (photo != null) {
        setState(() {
          _capturedPhoto = File(photo.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing photo: $e';
      });
    }
  }

  Future<void> _checkIn() async {
    if (_selectedStaffId == null) {
      setState(() {
        _errorMessage = 'Please select a staff member';
      });
      return;
    }

    if (_checkInMethod == 'camera' && _capturedPhoto == null) {
      setState(() {
        _errorMessage = 'Please capture a photo first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      String? photoUrl;
      
      // Upload photo if captured
      if (_capturedPhoto != null) {
        final fileName = 'checkin_${_selectedStaffId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await _capturedPhoto!.readAsBytes();
        
        await _supabase.client.storage
            .from('staff_photos')
            .uploadBinary(fileName, bytes);
        
        photoUrl = _supabase.client.storage
            .from('staff_photos')
            .getPublicUrl(fileName);
      }
      
      // Create attendance record
      await _supabase.client.from('attendance').insert({
        'staff_id': _selectedStaffId,
        'check_in_time': DateTime.now().toIso8601String(),
        'check_in_method': _checkInMethod,
        'check_in_photo': photoUrl,
        'status': 'checked_in',
      });
      
      final staffName = _staffList.firstWhere((s) => s['id'] == _selectedStaffId)['name'];
      
      setState(() {
        _successMessage = '$staffName checked in successfully!';
        _selectedStaffId = null;
        _capturedPhoto = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage!),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking in: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkOut() async {
    if (_selectedStaffId == null) {
      setState(() {
        _errorMessage = 'Please select a staff member';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Find today's check-in record
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final attendance = await _supabase.client
          .from('attendance')
          .select()
          .eq('staff_id', _selectedStaffId)
          .eq('status', 'checked_in')
          .gte('check_in_time', startOfDay.toIso8601String())
          .order('check_in_time', ascending: false)
          .limit(1);
      
      if (attendance.isEmpty) {
        setState(() {
          _errorMessage = 'No check-in record found for today';
        });
        return;
      }
      
      final attendanceId = attendance.first['id'];
      
      String? photoUrl;
      
      // Upload photo if captured
      if (_capturedPhoto != null) {
        final fileName = 'checkout_${_selectedStaffId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await _capturedPhoto!.readAsBytes();
        
        await _supabase.client.storage
            .from('staff_photos')
            .uploadBinary(fileName, bytes);
        
        photoUrl = _supabase.client.storage
            .from('staff_photos')
            .getPublicUrl(fileName);
      }
      
      // Update attendance record
      await _supabase.client
          .from('attendance')
          .update({
            'check_out_time': DateTime.now().toIso8601String(),
            'check_out_method': _checkInMethod,
            'check_out_photo': photoUrl,
          })
          .eq('id', attendanceId);
      
      final staffName = _staffList.firstWhere((s) => s['id'] == _selectedStaffId)['name'];
      
      setState(() {
        _successMessage = '$staffName checked out successfully!';
        _selectedStaffId = null;
        _capturedPhoto = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage!),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking out: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Check-In/Out'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Check-in method selection
              const Text(
                'Check-In Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'camera',
                    label: Text('Camera'),
                    icon: Icon(Icons.camera_alt),
                  ),
                  ButtonSegment(
                    value: 'thumbprint',
                    label: Text('Thumbprint'),
                    icon: Icon(Icons.fingerprint),
                  ),
                  ButtonSegment(
                    value: 'manual',
                    label: Text('Manual'),
                    icon: Icon(Icons.edit),
                  ),
                ],
                selected: {_checkInMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _checkInMethod = newSelection.first;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Staff selection
              const Text(
                'Select Staff',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: _isLoading && _staffList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _staffList.isEmpty
                        ? const Center(child: Text('No active staff found'))
                        : ListView.builder(
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];
                              final isSelected = _selectedStaffId == staff['id'];
                              
                              return Card(
                                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(staff['name'][0]),
                                  ),
                                  title: Text(
                                    staff['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text('${staff['employee_id']} - ${staff['position']}'),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedStaffId = staff['id'];
                                      _capturedPhoto = null;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
              
              const SizedBox(height: 16),
              
              // Photo capture (if camera method selected)
              if (_checkInMethod == 'camera') ...[
                if (_capturedPhoto != null) ...[
                  Card(
                    child: Column(
                      children: [
                        Image.file(
                          _capturedPhoto!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton.icon(
                            onPressed: _capturePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Retake Photo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              
              // Error/Success messages
              if (_errorMessage != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              if (_successMessage != null) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Check-in/out buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Check Out'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

