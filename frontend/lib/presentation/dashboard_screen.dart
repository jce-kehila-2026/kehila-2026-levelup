import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String role; 

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isStaff = role == 'staff';
    final bgColor = isStaff ? const Color(0xFF422969) : const Color(0xFFF0C230);
    final textColor = isStaff ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isStaff ? 'Staff Portal' : 'Student Portal'),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isStaff ? Icons.admin_panel_settings : Icons.school,
              size: 100,
              color: bgColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to LevelUp!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Logged in successfully as:\n${role.toUpperCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}