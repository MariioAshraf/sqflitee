import 'package:flutter/material.dart';
import 'package:sqflitee/features/home/presentation/views/widgets/areas_home_tab.dart';
class PriestHomeScreen extends StatelessWidget {
  const PriestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
        centerTitle: true,
      ),
      body: const AreasHomeTab(),
    );
  }
}
