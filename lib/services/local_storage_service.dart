import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child.dart';
import '../models/assessment_session.dart';
import '../models/assessment_result.dart';
import '../models/module_result.dart';

/// Service responsible for local persistence using SharedPreferences.
/// 
/// Provides storage for multiple children, assessment sessions, and results,
/// while isolating the UI and Providers from direct SharedPreferences usage.
class LocalStorageService {
  late final SharedPreferences _prefs;
  bool _isInitialised = false;

  // Keys
  static const String _activeChildIdKey = 'active_child_id';
  static const String _childrenPrefix = 'child_';
  static const String _sessionsPrefix = 'sessions_';
  static const String _resultsPrefix = 'results_';
  static const String _moduleResultsPrefix = 'mod_res_';
  static const String _growthPrefix = 'growth_';
  
  /// Initializes the SharedPreferences instance. Must be called before any operations.
  Future<void> init() async {
    if (_isInitialised) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialised = true;
    } catch (e) {
      debugPrint('[LocalStorageService] Initialization failed: $e');
    }
  }

  bool get isInitialised => _isInitialised;

  // ---------------------------------------------------------------------------
  // Active Child
  // ---------------------------------------------------------------------------

  /// Saves the ID of the currently active child.
  Future<void> saveActiveChildId(String id) async {
    if (!_isInitialised) return;
    await _prefs.setString(_activeChildIdKey, id);
  }

  /// Retrieves the ID of the currently active child, or null if none.
  String? getActiveChildId() {
    if (!_isInitialised) return null;
    return _prefs.getString(_activeChildIdKey);
  }

  /// Clears the active child ID.
  Future<void> clearActiveChildId() async {
    if (!_isInitialised) return;
    await _prefs.remove(_activeChildIdKey);
  }

  // ---------------------------------------------------------------------------
  // Children
  // ---------------------------------------------------------------------------

  /// Saves a child to local storage.
  Future<void> saveChild(Child child) async {
    if (!_isInitialised) return;
    final key = '$_childrenPrefix${child.id}';
    final jsonString = jsonEncode(child.toJson());
    await _prefs.setString(key, jsonString);
  }

  /// Retrieves a specific child by ID.
  Child? getChild(String id) {
    if (!_isInitialised) return null;
    final key = '$_childrenPrefix$id';
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return Child.fromJson(jsonMap);
      } catch (e) {
        debugPrint('[LocalStorageService] Failed to parse child $id: $e');
      }
    }
    return null;
  }

  /// Retrieves all children stored locally.
  List<Child> getAllChildren() {
    if (!_isInitialised) return [];
    final children = <Child>[];
    final keys = _prefs.getKeys().where((k) => k.startsWith(_childrenPrefix));
    
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          children.add(Child.fromJson(jsonMap));
        } catch (e) {
          debugPrint('[LocalStorageService] Failed to parse child at $key: $e');
        }
      }
    }
    return children;
  }

  // ---------------------------------------------------------------------------
  // Assessment Sessions
  // ---------------------------------------------------------------------------

  /// Saves an assessment session for a child.
  Future<void> saveAssessmentSession(AssessmentSession session) async {
    if (!_isInitialised) return;
    final key = '$_sessionsPrefix${session.childId}';
    
    // Retrieve existing sessions for this child
    final existingSessions = getAssessmentSessionsForChild(session.childId);
    
    // Remove if updating, then add
    existingSessions.removeWhere((s) => s.sessionId == session.sessionId);
    existingSessions.add(session);
    
    // Save the list back
    final jsonList = existingSessions.map((s) => s.toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// Retrieves all assessment sessions for a specific child.
  List<AssessmentSession> getAssessmentSessionsForChild(String childId) {
    if (!_isInitialised) return [];
    final key = '$_sessionsPrefix$childId';
    final jsonString = _prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList.map((j) => AssessmentSession.fromJson(j as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalStorageService] Failed to parse sessions for $childId: $e');
      }
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Assessment Results
  // ---------------------------------------------------------------------------

  /// Saves an assessment result for a child.
  Future<void> saveAssessmentResult(AssessmentResult result) async {
    if (!_isInitialised) return;
    final key = '$_resultsPrefix${result.childId}';
    
    // Retrieve existing results for this child
    final existingResults = getAssessmentResultsForChild(result.childId);
    
    // Remove if updating, then add
    existingResults.removeWhere((r) => r.sessionId == result.sessionId);
    existingResults.add(result);
    
    // Save the list back
    final jsonList = existingResults.map((r) => r.toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// Retrieves all assessment results for a specific child.
  List<AssessmentResult> getAssessmentResultsForChild(String childId) {
    if (!_isInitialised) return [];
    final key = '$_resultsPrefix$childId';
    final jsonString = _prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList.map((j) => AssessmentResult.fromJson(j as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalStorageService] Failed to parse results for $childId: $e');
      }
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Generic Module Results
  // ---------------------------------------------------------------------------

  /// Saves a generic module result for future integration (Eye Tracking, Nutrition).
  Future<void> saveModuleResult(ModuleResult result) async {
    if (!_isInitialised) return;
    final key = '$_moduleResultsPrefix${result.childId}_${result.module}';
    final jsonString = jsonEncode(result.toJson());
    await _prefs.setString(key, jsonString);
  }

  /// Retrieves a specific module result for a child.
  ModuleResult? getModuleResult(String childId, String module) {
    if (!_isInitialised) return null;
    final key = '$_moduleResultsPrefix${childId}_$module';
    final jsonString = _prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return ModuleResult.fromJson(jsonMap);
      } catch (e) {
        debugPrint('[LocalStorageService] Failed to parse ModuleResult for $childId/$module: $e');
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Growth Assessments
  // ---------------------------------------------------------------------------

  /// Saves a raw growth assessment for a child.
  Future<void> saveGrowthAssessment(dynamic assessment) async {
    if (!_isInitialised) return;
    // Assuming assessment is GrowthAssessment, but using dynamic to avoid importing 
    // growth_assessment.dart if it creates cyclic dependencies, though it shouldn't.
    final key = '$_growthPrefix${assessment.childId}_${assessment.id}';
    final jsonString = jsonEncode(assessment.toJson());
    await _prefs.setString(key, jsonString);
  }

  /// Retrieves all raw growth assessments for a specific child.
  List<dynamic> getGrowthAssessmentsForChildRaw(String childId) {
    if (!_isInitialised) return [];
    final prefix = '$_growthPrefix${childId}_';
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix));
    
    final assessments = [];
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          assessments.add(jsonDecode(jsonString));
        } catch (e) {
          debugPrint('[LocalStorageService] Failed to parse growth assessment at $key: $e');
        }
      }
    }
    return assessments;
  }
}
