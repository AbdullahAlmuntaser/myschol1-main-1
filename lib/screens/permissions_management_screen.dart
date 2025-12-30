import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';
import '../utils/app_constants.dart'; // Import new constants file

class PermissionsManagementScreen extends StatefulWidget {
  const PermissionsManagementScreen({super.key});

  @override
  State<PermissionsManagementScreen> createState() => _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState extends State<PermissionsManagementScreen> {
  String _selectedRole = 'admin'; // Default role to display
  final List<String> _roles = ['admin', 'teacher', 'student', 'parent'];
  // Dynamically get features that have data in allFeatureData map, excluding 'chat' for now if no specific screen
  final List<String> _features = allFeatureData.keys.where((feature) => feature != AppFeatures.chat && feature != AppFeatures.dashboard).toList();


  @override
  void initState() {
    super.initState();
    _loadPermissionsForRole(_selectedRole);
  }

  Future<void> _loadPermissionsForRole(String role) async {
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    await permissionProvider.loadPermissions(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصلاحيات'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                    _loadPermissionsForRole(newValue);
                  });
                }
              },
              items: _roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'اختر الدور',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<PermissionProvider>(
              builder: (context, permissionProvider, child) {
                if (permissionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: _features.length,
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    final isAllowed = permissionProvider.permissions[feature] ?? false;
                    final featureDetails = allFeatureData[feature];

                    return SwitchListTile(
                      title: Row(
                        children: [
                          if (featureDetails != null) Icon(featureDetails['icon'] as IconData),
                          const SizedBox(width: 8),
                          Text(featureDetails != null ? featureDetails['label'] as String : feature),
                        ],
                      ),
                      value: isAllowed,
                      onChanged: (bool value) async {
                        await permissionProvider.togglePermission(_selectedRole, feature, value);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
