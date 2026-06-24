import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/area_with_streets_model.dart';
import '../../../data/models/street_model.dart';
import '../../cubits/manage_areas_cubit/areas_cubit.dart';
import '../../cubits/manage_areas_cubit/areas_state.dart';
import 'area_view.dart';

class AreasHomeTab extends StatelessWidget {
  const AreasHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AreasCubit, AreasState>(
      builder: (context, state) {
        if (state is AreasInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AreasFailure) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<AreasCubit>().loadAreas(),
          );
        }
        if (state is AreasLoaded) {
          return Column(
            children: [
              if (state.isSyncing) const _SyncingBanner(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('${state.areasWithStreets.length} Areas',
                        style: TextStyle(color: Colors.grey.shade600)),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _showCreateAreaDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Area'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.areasWithStreets.isEmpty
                    ? const Center(child: Text('No areas yet'))
                    : RefreshIndicator(
                  onRefresh: () =>
                      context.read<AreasCubit>().manualSync(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.areasWithStreets.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (_, i) => _AreaExpandableCard(
                      data: state.areasWithStreets[i],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCreateAreaDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AreasCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create Area'),
            content: TextField(
              controller: ctrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Area Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: ctrl.text.trim().isEmpty
                    ? null
                    : () {
                  context.read<AreasCubit>().createArea(
                    name: ctrl.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncingBanner extends StatelessWidget {
  const _SyncingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.blue.shade50,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Syncing...', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _AreaExpandableCard extends StatelessWidget {
  final AreaWithStreets data;
  const _AreaExpandableCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final area    = data.area;
    final streets = data.streets;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: const Border(),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_city_rounded,
              color: Color(0xFF1A237E), size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(area.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            if (area.isNeedToPostSync) const _PendingBadge(),
          ],
        ),
        subtitle: Text(
          '${streets.length} street${streets.length == 1 ? '' : 's'}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        children: [
          ...streets.map((s) => _StreetTile(street: s)),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => _showCreateStreetDialog(context, area.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Street'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateStreetDialog(BuildContext context, String areaId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AreasCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create Street'),
            content: TextField(
              controller: ctrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Street Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: ctrl.text.trim().isEmpty
                    ? null
                    : () {
                  context.read<AreasCubit>().createStreet(
                    areaId: areaId,
                    name: ctrl.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetTile extends StatelessWidget {
  final StreetModel street;
  const _StreetTile({required this.street});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.turn_right_rounded, size: 18, color: Color(0xFF1A237E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(street.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (street.isNeedToPostSync) const _PendingBadge(),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 12, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text('Pending', style: TextStyle(fontSize: 10, color: Colors.orange.shade700)),
        ],
      ),
    );
  }
}