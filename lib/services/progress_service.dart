import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checkpoint.dart';

class ProgressService {
  static const String _checkpointKey = 'checkpoint';
  
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  Future<Checkpoint?> loadCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_checkpointKey);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Checkpoint.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCheckpoint(Checkpoint checkpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(checkpoint.toJson());
    await prefs.setString(_checkpointKey, jsonString);
  }

  Future<void> clearCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkpointKey);
  }
}
