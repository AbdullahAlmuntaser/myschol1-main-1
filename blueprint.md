# blueprint.md

## Overview
This document outlines the project's purpose and a detailed history of all features, styles, and designs implemented in this comprehensive School Management mobile application.

## Project Outline

This is a complete school management system built using Flutter. The application is designed with a clean, modern, and user-friendly interface that is fully localized in Arabic.

### Core Features:
- **User Authentication:** Secure login and registration for different user roles (Admin, Teacher, Student, Parent).
- **Dashboard:** A central hub displaying key information and navigation to different modules.
- **Student Affairs:** Comprehensive management of student data, including adding, editing, and viewing student profiles.
- **Academic Year Management:** Ability to define and manage academic years.
- **Class & Subject Management:** Tools to create and organize classes and subjects.
- **Teacher Management:** A module for managing teacher profiles and assignments.
- **Timetable:** A visual schedule for classes, with support for adding and editing sessions.
- **Library Management:** A system to track books and borrowing records.
- **Events Calendar:** An interactive calendar to manage and display school events.
- **Leave Management:** A workflow for staff and students to request and manage leave.
- **Staff Management:** Module for handling non-teaching staff information.
- **Parent & Student Portals:** Dedicated interfaces for parents and students to view relevant information like grades and attendance.
- **Local Database:** Utilizes SQLite for persistent on-device storage.
- **Notifications:** Integrated local notifications for reminders and alerts.
- **Biometric Authentication:** Secure access using local device authentication.
- **AI Chat:** An integrated chat screen powered by generative AI.
- **Reporting:** Generation of various reports (e.g., student results).
- **Dynamic Role-Based Access Control (RBAC):** (In Progress) A system to manage permissions for different user roles dynamically.

### Design & Style:
- **Theme:** A custom, modern theme with both Light and Dark modes.
- **Typography:** Uses the `google_fonts` package for clean and readable Arabic text.
- **Localization:** Full Right-to-Left (RTL) support and Arabic language strings throughout the app.
- **UI Components:** Consistent use of Material Design components, styled for a cohesive look and feel. Dialogs, buttons, and input fields are all designed to be intuitive.

## Recent Changes

### Feature: Dynamic Role-Based Access Control (RBAC)
- **Files:**
  - `lib/database_helper.dart`
  - `lib/permission_model.dart`
  - `lib/providers/permission_provider.dart`
  - `lib/screens/permissions_management_screen.dart`
  - `lib/screens/login_screen.dart`
  - `lib/screens/dashboard_screen.dart`
- **Changes:**
  - **Database & Model:** Standardized the `permissions` table and `Permission` model to use `feature` and `isEnabled` fields for better clarity.
  - **Default Permissions:** Implemented a seeding mechanism in `database_helper.dart` to insert a default set of permissions for all user roles (`admin`, `teacher`, `student`, `parent`) on database creation.
  - **State Management:** Refactored `permission_provider.dart` to correctly load permissions and added a `togglePermission` method to simplify create/update logic.
  - **Admin UI:** The `permissions_management_screen.dart` now allows administrators to dynamically enable or disable features for each role.
  - **Initialization:** Permissions are now loaded from the database immediately after a user successfully logs in via the `login_screen.dart`.
  - **Dashboard Integration:** The `dashboard_screen.dart` was refactored to be fully dynamic. It now builds its navigation items and accessible tabs based on the permissions of the currently logged-in user.
- **Reason:** To provide a flexible and secure way to manage application permissions without hardcoding them, allowing administrators to control feature access dynamically.
- **Status:** Completed

### Grades Interface UX Improvement
- **Files:** 
  - `lib/screens/tabs/student_results_tab.dart`
  - `lib/screens/tabs/grades_bulk_entry_tab.dart`
- **Changes:**
  - **Student Results Tab:**
    - Removed the redundant "Update Academic Status" button.
    - Implemented automatic calculation of results with debouncing when filters (Academic Year, Semester, Class) are changed.
    - Removed the manual "Calculate Results" button as it is now automated.
  - **Grades Bulk Entry Tab:**
    - Added a visual indicator (a save icon) next to each student's row to show that a grade has been changed but not yet saved. This provides immediate feedback to the user.
- **Reason:** To improve the user experience of the grades module by making it more automated, intuitive, and visually informative.
- **Status:** Completed

### Linter Fix (use_build_context_synchronously)
- **File:** `lib/screens/tabs/student_results_tab.dart`
- **Change:** Added `if (!mounted) return;` checks before calls to `ScaffoldMessenger.of(context)` and `showDialog` in `async` methods (`_calculateResults` and `_viewGradeDetails`).
- **Reason:** To resolve the `use_build_context_synchronously` lint warning, ensuring that the `BuildContext` is not used across asynchronous gaps.
- **Status:** Completed

## Current Development Plan

(No active development plan.)
