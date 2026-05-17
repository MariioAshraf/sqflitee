import 'package:flutter/material.dart';

final class PriestHomeScreen extends StatelessWidget {
  const PriestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Priest Dashboard'), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Welcome Father Angelos ✨',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            /// Statistics
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Services',
                    value: '4',
                    icon: Icons.church,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    title: 'Classes',
                    value: '18',
                    icon: Icons.class_,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Servants',
                    value: '32',
                    icon: Icons.groups,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    title: 'Students',
                    value: '210',
                    icon: Icons.people_alt_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Services
            const Text(
              'Managed Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: 3,

              separatorBuilder: (_, __) => const SizedBox(height: 12),

              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.church)),

                    title: Text('Primary Service ${index + 1}'),

                    subtitle: const Text('6 Classes • 75 Students'),

                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Reports'),
                        ),

                        const PopupMenuItem(
                          value: 'attendance',
                          child: Text('Attendance'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// Visits
            const Text(
              'Recent Visits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text('Family: Michael'),
                subtitle: Text('Last visit: 2 days ago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.orange.shade50,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(title),
        ],
      ),
    );
  }
}
