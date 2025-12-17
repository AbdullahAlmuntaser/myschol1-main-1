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

### Design & Style:
- **Theme:** A custom, modern theme with both Light and Dark modes.
- **Typography:** Uses the `google_fonts` package for clean and readable Arabic text.
- **Localization:** Full Right-to-Left (RTL) support and Arabic language strings throughout the app.
- **UI Components:** Consistent use of Material Design components, styled for a cohesive look and feel. Dialogs, buttons, and input fields are all designed to be intuitive.

## Recent Changes

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

### Feature: School Announcements & Notifications Board

This feature will allow administrators and teachers to publish announcements that can be viewed by students and parents, with real-time notifications.

- **Purpose:** Enhance communication within the school ecosystem, ensuring timely dissemination of important information.

- **Files to be created/modified:**
  - `lib/announcement_model.dart`: To define the data structure for announcements.
  - `lib/providers/announcement_provider.dart`: To manage the state and database interactions for announcements.
  - `lib/screens/announcements_screen.dart`: A dedicated screen for viewing and managing announcements.
  - `lib/screens/dashboard_screen.dart`: To display recent announcements on the dashboard.
  - `pubspec.yaml`: To add necessary packages for notifications (e.g., `flutter_local_notifications`).
  - `lib/main.dart`: To initialize notification services.

- **Steps:**
  1.  Define the `Announcement` model.
  2.  Create the `AnnouncementProvider` for state management and database operations.
  3.  Implement a dedicated `AnnouncementsScreen` for creating, viewing, and editing announcements.
  4.  Integrate a section on the `DashboardScreen` to show a summary of recent announcements.
  5.  Add `flutter_local_notifications` to `pubspec.yaml` and run `flutter pub get`.
  6.  Initialize `flutter_local_notifications` in `main.dart`.
  7.  Implement logic in `AnnouncementProvider` to trigger local notifications for new announcements.

- **Status:** In Progress
