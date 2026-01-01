# Project Blueprint

## Overview
This document outlines the current state, features, and planned modifications for the MySchol1 Flutter application. The primary goal is to address existing errors and warnings reported by `flutter analyze`, improve code quality, and ensure the application's stability.

## Current Features
*   User authentication (Login, Register)
*   Dashboard for various user roles
*   Academic year management
*   Attendance tracking
*   Book management and library system
*   Class management
*   Event management
*   Grade management
*   Leave management
*   Performance evaluation
*   Permission management
*   Staff and Teacher management
*   Student management and portal
*   Subject management
*   Timetable management
*   User management (Admin)
*   Parent portal

## Pending Tasks (from flutter analyze)

### Remaining Warnings and Info
*   **`warning • The value of the local variable 'db' isn't used • lib/database_helper.dart:528:11 • unused_local_variable`**
*   **`info • The private field _selectedSubjects could be 'final' • lib/screens/add_edit_class_screen.dart:27:17 • prefer_final_fields`**
*   **`warning • The value of the field '_allSubjects' isn't used • lib/screens/add_edit_class_screen.dart:29:17 • unused_field`**
*   **`info • Don't use 'BuildContext's across async gaps • lib/screens/admin_manage_users_screen.dart:136:31 • use_build_context_synchronously` (multiple occurrences)**
*   **`info • The type of the right operand ('String?') isn't a subtype or a supertype of the left operand ('int?') • lib/screens/dashboard_screen.dart:338:51 • unrelated_type_equality_checks` (multiple occurrences)**

## Plan for Current Task: Address Warnings and Info

This plan details the steps to resolve the warnings and info messages identified by `flutter analyze`. Each will be addressed individually, followed by a re-analysis to confirm the fix.

### Steps:
1.  **Fix `lib/database_helper.dart:528:11`**: Remove the unused local variable 'db'.
2.  **Fix `lib/screens/add_edit_class_screen.dart:27:17`**: Change `_selectedSubjects` to `final`.
3.  **Fix `lib/screens/add_edit_class_screen.dart:29:17`**: Comment out the unused `_allSubjects` field.
4.  **Fix `lib/screens/admin_manage_users_screen.dart`**: Add `if (!mounted) return;` checks after `await` calls.
5.  **Fix `lib/screens/dashboard_screen.dart`**: Ensure type consistency in comparisons between `String?` and `int?`.
6.  **Re-run `flutter analyze`**: Verify all warnings and info messages are resolved.