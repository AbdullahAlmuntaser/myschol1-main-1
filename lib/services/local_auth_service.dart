import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database_helper.dart';
import '../user_model.dart';
import 'dart:developer' as developer; // Import for logging
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LocalAuthService with ChangeNotifier {
  User? _currentUser; // Holds the currently logged-in user
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isSessionLoading =
      true; // New state to indicate if session is being loaded
  List<User> _users = []; // New: List to hold all fetched users

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isSessionLoading =>
      _isSessionLoading; // Getter for session loading state
  List<User> get users => _users; // New: Getter for all users

  LocalAuthService() {
    _loadUserSession(); // Load session when service is instantiated
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // New method to load user session from shared_preferences
  Future<void> _loadUserSession() async {
    developer.log(
      'LocalAuthService: Attempting to load user session...',
      name: 'LocalAuthService',
    );
    _isSessionLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final userRole = prefs.getString('userRole');

    if (userId != null && userRole != null) {
      // Fetch full user details from DB to reconstruct User object
      final userFromDb = await _databaseHelper.getUserById(userId);
      if (userFromDb != null && userFromDb.role == userRole) {
        _currentUser =
            userFromDb; // Use user from DB to ensure all fields are correct
        developer.log(
          'LocalAuthService: User session loaded for user: ${_currentUser!.username}',
          name: 'LocalAuthService',
        );
      } else {
        // Inconsistent or outdated session, clear it
        await _clearUserSession();
        developer.log(
          'LocalAuthService: Inconsistent user session, cleared.',
          name: 'LocalAuthService',
          level: 900,
        );
      }
    } else {
      developer.log(
        'LocalAuthService: No user session found.',
        name: 'LocalAuthService',
      );
    }
    _isSessionLoading = false;
    notifyListeners(); // Notify UI that session loading is complete
  }

  // New method to save user session to shared_preferences
  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'userId',
      user.id!,
    ); // user.id is guaranteed not null here after successful sign-up/in
    await prefs.setString('userRole', user.role);
    developer.log(
      'LocalAuthService: User session saved for user: ${user.username}',
      name: 'LocalAuthService',
    );
  }

  // New method to clear user session from shared_preferences
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userRole');
    developer.log(
      'LocalAuthService: User session cleared.',
      name: 'LocalAuthService',
    );
  }

  Future<bool> signIn(String username, String password) async {
    developer.log(
      'LocalAuthService: Attempting sign-in for user: $username',
      name: 'LocalAuthService',
    );
    final user = await _databaseHelper.getUserByUsername(username);
    if (user != null) {
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash == hashedPassword) {
        _currentUser = user;
        await _saveUserSession(user); // Save session on successful sign-in
        notifyListeners();
        developer.log(
          'LocalAuthService: Sign-in successful for user: $username',
          name: 'LocalAuthService',
        );
        return true;
      }
    }
    developer.log(
      'LocalAuthService: Sign-in failed for user: $username',
      name: 'LocalAuthService',
      level: 900,
    );
    return false; // Authentication failed
  }

  Future<bool> signUp(String username, String password, String role) async {
    developer.log(
      'LocalAuthService: Attempting sign-up for user: $username with role: $role',
      name: 'LocalAuthService',
    );
    final existingUser = await _databaseHelper.getUserByUsername(username);
    if (existingUser != null) {
      developer.log(
        'LocalAuthService: Sign-up failed. Username already exists: $username',
        name: 'LocalAuthService',
        level: 900,
      );
      return false;
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(
      username: username,
      passwordHash: hashedPassword,
      role: role,
    );

    try {
      final id = await _databaseHelper.createUser(newUser);
      if (id > 0) {
        // Create a new User object with the generated ID from the database
        // _currentUser = newUser.copyWith(id: id); // Do not auto-login after general signup, only for admin created.
        // await _saveUserSession(_currentUser!);
        // notifyListeners();
        developer.log(
          'LocalAuthService: Sign-up successful for user: $username (ID: $id)',
          name: 'LocalAuthService',
          level: 800,
        );
        return true;
      } else {
        developer.log(
          'LocalAuthService: Sign-up failed. Could not create user in database. ID returned: $id',
          name: 'LocalAuthService',
          level: 1000,
        );
        return false;
      }
    } catch (e, s) {
      developer.log(
        'LocalAuthService: Error during user creation for user: $username',
        name: 'LocalAuthService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  void signOut() async {
    developer.log(
      'LocalAuthService: Attempting to sign out user: ${_currentUser?.username}',
      name: 'LocalAuthService',
    );
    _currentUser = null;
    await _clearUserSession(); // Clear session on sign out
    notifyListeners();
    developer.log(
      'LocalAuthService: User signed out.',
      name: 'LocalAuthService',
    );
  }

  // New: Fetch all users and update the _users list
  Future<void> fetchUsers() async {
    developer.log('LocalAuthService: Fetching all users...', name: 'LocalAuthService');
    try {
      _users = await _databaseHelper.getUsers();
      developer.log('LocalAuthService: Fetched ${_users.length} users.', name: 'LocalAuthService');
      notifyListeners();
    } catch (e, s) {
      developer.log(
        'LocalAuthService: Error fetching users: $e',
        name: 'LocalAuthService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
    }
  }

  // New: Update a user's role
  Future<bool> updateUserRole(int userId, String newRole) async {
    developer.log(
      'LocalAuthService: Attempting to update role for user ID: $userId to $newRole',
      name: 'LocalAuthService',
    );
    try {
      final success = await _databaseHelper.updateUserRole(userId, newRole);
      if (success > 0) {
        // Update the user in the local _users list and potentially _currentUser if it's the current user
        await fetchUsers(); // Re-fetch all users to ensure consistency
        if (_currentUser != null && _currentUser!.id == userId) {
          _currentUser = _currentUser!.copyWith(role: newRole);
          await _saveUserSession(_currentUser!); // Update session if current user's role changed
        }
        developer.log(
          'LocalAuthService: Successfully updated role for user ID: $userId',
          name: 'LocalAuthService',
          level: 800,
        );
        return true;
      }
      developer.log(
        'LocalAuthService: Failed to update role for user ID: $userId',
        name: 'LocalAuthService',
        level: 900,
      );
      return false;
    } catch (e, s) {
      developer.log(
        'LocalAuthService: Error updating user role for user ID: $userId: $e',
        name: 'LocalAuthService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  // New: Admin can create a user with a specified role
  Future<bool> adminCreateUser(String username, String password, String role) async {
    developer.log(
      'LocalAuthService: Admin attempting to create user: $username with role: $role',
      name: 'LocalAuthService',
    );
    final existingUser = await _databaseHelper.getUserByUsername(username);
    if (existingUser != null) {
      developer.log(
        'LocalAuthService: Admin create user failed. Username already exists: $username',
        name: 'LocalAuthService',
        level: 900,
      );
      return false;
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(
      username: username,
      passwordHash: hashedPassword,
      role: role,
    );

    try {
      final id = await _databaseHelper.createUser(newUser);
      if (id > 0) {
        await fetchUsers(); // Re-fetch all users to show the newly created one
        developer.log(
          'LocalAuthService: Admin successfully created user: $username (ID: $id) with role: $role',
          name: 'LocalAuthService',
          level: 800,
        );
        return true;
      } else {
        developer.log(
          'LocalAuthService: Admin create user failed. Could not create user in database. ID returned: $id',
          name: 'LocalAuthService',
          level: 1000,
        );
        return false;
      }
    } catch (e, s) {
      developer.log(
        'LocalAuthService: Error during admin user creation for user: $username',
        name: 'LocalAuthService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }
}

extension on User {
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
    );
  }
}
