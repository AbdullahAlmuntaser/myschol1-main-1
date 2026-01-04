
# Blueprint: MySchool App

## Overview

This document outlines the architecture, features, and design principles of the MySchool Flutter application. The app is a comprehensive school management system designed to be used by admins, teachers, students, and parents.

## Implemented Features & Design

*   **Authentication:** Local authentication system allowing users to log in with a username and password. User sessions are managed locally.
*   **User Management (Admin):**
    *   Admins can view a list of all users.
    *   Admins can create new users with specific roles (admin, teacher, student, parent).
    *   Admins can update the role of any existing user.
*   **Core School Management (Admin):**
    *   Management of school years, classes, subjects, teachers, and students through a tab-based interface.
    *   Ability to create, view, update, and delete records for each category.
    *   Student promotion system based on end-of-year results.
*   **Code Quality:**
    *   Resolved multiple linter warnings, including `unused_import`, `deprecated_member_use`, and `use_build_context_synchronously`.
    *   Refactored dialog creation to be more robust and prevent context-related runtime errors.
*   **Styling and UX:**
    *   Standard Material Design components.
    *   Arabic language support for the UI.
    *   Responsive layouts for different screen sizes (e.g., using `DataTable` for web).

## Current Plan: Role-Based Access Control & User Dashboards

This major update introduces a role-based access control (RBAC) system, providing a tailored user experience for each user type.

### Feature Description

The application will now display a different user interface depending on the role of the logged-in user (Admin, Teacher, Student, Parent).

*   **Admin:** Will see the full, existing management interface with all tabs and administrative controls.
*   **Teacher:** Will be directed to a new dashboard designed for managing their assigned classes, taking attendance, and entering grades.
*   **Student:** Will see a personalized dashboard showing their profile information, class schedule, grades, and attendance.
*   **Parent:** Will be directed to a dashboard to view the progress, grades, and attendance of their child/children.

### Implementation Steps

1.  **Create Role Dispatcher:** A new widget, `RoleDispatcherScreen`, will be created. After a user successfully logs in, they will be navigated to this screen. It will check the user's role from `LocalAuthService` and redirect them to the appropriate dashboard.
2.  **Create Dashboard Widgets:** Create new placeholder files for each role-specific dashboard:
    *   `lib/screens/dashboards/admin_dashboard.dart`
    *   `lib/screens/dashboards/teacher_dashboard.dart`
    *   `lib/screens/dashboards/student_dashboard.dart`
    *   `lib/screens/dashboards/parent_dashboard.dart`
3.  **Update Login Navigation:** Modify `lib/screens/login_screen.dart` to navigate to `RoleDispatcherScreen` upon successful login instead of the generic `HomeScreen`.
4.  **Implement Student Dashboard:**
    *   Build the UI for `lib/screens/dashboards/student_dashboard.dart`.
    *   It will fetch the logged-in student's data using the `currentUser` from `LocalAuthService`.
    *   It will display:
        *   **Profile Section:** Name, Email, Academic Number, Class, etc.
        *   **Grades Section:** A list of subjects and corresponding grades.
        *   **Schedule Section:** A view of the classes the student is enrolled in.
5.  **Modify Admin User Creation:** The user creation dialog in `AdminToolsScreen` already supports assigning roles, which is sufficient for this new system. No changes are needed there.

