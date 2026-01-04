import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../permission_model.dart';
import '../utils/app_constants.dart';
import 'dart:developer' as developer;

class PermissionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, bool> _permissions = {};
  bool _isLoading = false;
  String? _currentRole;

  Map<String, bool> get permissions => _permissions;
  bool get isLoading => _isLoading;

  Future<void> loadPermissions(String? role) async {
    if (_currentRole == role && !_isLoading) return; // If role is same and not loading, do nothing
    
    _currentRole = role;
    _isLoading = true;
    notifyListeners();

    if (role == null) {
      _permissions = {};
      _isLoading = false;
      developer.log('Permissions cleared due to null role.', name: 'PermissionProvider');
      notifyListeners();
      return;
    }

    try {
      final permissionsList = await _dbHelper.getPermissionsByRole(role);
      if (permissionsList.isEmpty) {
        _permissions = { AppFeatures.dashboard: true, };
        developer.log('No permissions found for role $role, granting default dashboard access.', name: 'PermissionProvider');
      } else {
        _permissions = { for (var p in permissionsList) p.feature: p.isEnabled };
        developer.log('Permissions loaded for role $role: $_permissions', name: 'PermissionProvider');
      }
    } catch (e, s) {
      developer.log('Error loading permissions for role $role', name: 'PermissionProvider', error: e, stackTrace: s);
      _permissions = { AppFeatures.dashboard: true, };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(String feature) {
    if (_currentRole == 'admin') {
      return true;
    }
    return _permissions[feature] ?? false;
  }

  Future<void> updatePermission(Permission permission) async {
    try {
      await _dbHelper.updatePermission(permission);
      await loadPermissions(permission.role);
    } catch (e, s) {
      developer.log('Error updating permission', name: 'PermissionProvider', error: e, stackTrace: s);
    }
  }
  
  Future<List<Permission>> getPermissions() async {
    return await _dbHelper.getPermissions();
  }

  Future<void> addPermission(Permission permission) async {
    try {
      await _dbHelper.createPermission(permission);
      await loadPermissions(permission.role);
    } catch (e, s) {
      developer.log('Error adding permission', name: 'PermissionProvider', error: e, stackTrace: s);
    }
  }

  Future<void> togglePermission(String role, String feature, bool isEnabled) async {
    try {
      // Find existing permission to get its ID for update, or create a new one.
      final permissions = await _dbHelper.getPermissions();
      Permission? existingPermission;
      try {
        existingPermission = permissions.firstWhere((p) => p.role == role && p.feature == feature);
      } catch (e) {
        existingPermission = null;
      }
      
      final permission = Permission(
        id: existingPermission?.id,
        role: role,
        feature: feature,
        isEnabled: isEnabled,
      );

      if (permission.id != null) {
        await _dbHelper.updatePermission(permission);
      } else {
        await _dbHelper.createPermission(permission);
      }
      
      // If the permissions for the currently logged-in user were changed, reload them.
      if (_currentRole == role) {
        await loadPermissions(role);
      }
    } catch (e, s) {
      developer.log('Error toggling permission', name: 'PermissionProvider', error: e, stackTrace: s);
    }
  }
}
