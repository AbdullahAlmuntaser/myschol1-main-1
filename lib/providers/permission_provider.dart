import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../permission_model.dart';
import 'dart:developer' as developer;

class PermissionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, bool> _permissions = {};
  bool _isLoading = false;

  Map<String, bool> get permissions => _permissions;
  bool get isLoading => _isLoading;

  Future<void> loadPermissions(String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      final permissionsList = await _dbHelper.getPermissionsByRole(role);
      _permissions = {
        for (var p in permissionsList) p.feature: p.isEnabled
      };
      developer.log('Permissions loaded for role $role: $_permissions', name: 'PermissionProvider');
    } catch (e, s) {
      developer.log('Error loading permissions', name: 'PermissionProvider', error: e, stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(String feature) {
    return _permissions[feature] ?? false;
  }

  Future<void> updatePermission(Permission permission) async {
    try {
      await _dbHelper.updatePermission(permission);
      await loadPermissions(permission.role); // Reload to update the state
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
      final existingPermissions = await _dbHelper.getPermissions();
      Permission? existing;
      try {
        existing = existingPermissions.firstWhere(
          (p) => p.role == role && p.feature == feature,
        );
      } catch (e) {
        existing = null;
      }


      final permissionToUpdate = Permission(
        id: existing?.id,
        role: role,
        feature: feature,
        isEnabled: isEnabled,
      );

      if (permissionToUpdate.id != null) {
        await _dbHelper.updatePermission(permissionToUpdate);
      } else {
        await _dbHelper.createPermission(permissionToUpdate);
      }
      await loadPermissions(role); // Reload to update the state
    } catch (e, s) {
      developer.log('Error toggling permission', name: 'PermissionProvider', error: e, stackTrace: s);
    }
  }
}
