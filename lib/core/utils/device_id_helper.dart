import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdHelper {
  static const String _deviceIdKey = 'device_id';
  
  // Device ID ni olish yoki yaratish
  static Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      
      if (deviceId == null || deviceId.isEmpty) {
        // Yangi device ID yaratish
        deviceId = const Uuid().v4();
        await prefs.setString(_deviceIdKey, deviceId);
      }
      
      return deviceId;
    } catch (e) {
      throw Exception('Error getting device ID: $e');
    }
  }
}
