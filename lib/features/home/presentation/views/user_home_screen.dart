import 'package:flutter/material.dart';

final class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Welcome
            const Text(
              'Welcome Mario 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// Attendance Card
            _DashboardCard(
              title: 'Attendance',
              subtitle: 'Your attendance this month',
              value: '85%',
              icon: Icons.check_circle_outline,
            ),

            const SizedBox(height: 16),

            /// Services
            const Text(
              'My Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ListView.separated(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),

              itemBuilder: (_, index) {

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.church),
                    ),

                    title: Text(
                      'Primary Service ${index + 1}',
                    ),

                    subtitle: const Text(
                      'Meeting every Friday',
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// Upcoming
            const Text(
              'Upcoming Meetings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Friday Meeting'),
                subtitle: Text('Tomorrow - 7 PM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.blue.shade50,
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            child: Icon(icon),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),

                Text(subtitle),
              ],
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}