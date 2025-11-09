import 'package:flutter/material.dart';
import 'package:sproutling/models/plant.dart';
import 'package:sproutling/services/plant_service.dart';
import 'package:sproutling/widgets/plant_card.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final _plantService = PlantService();
  List<Plant> _plantsNeedingWater = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final plants = await _plantService.getPlantsNeedingWater();
    setState(() {
      _plantsNeedingWater = plants;
      _isLoading = false;
    });
  }

  Future<void> _handleWater(String plantId) async {
    await _plantService.markAsWatered(plantId);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Plant watered successfully! 💧'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _waterAll() async {
    for (final plant in _plantsNeedingWater) {
      await _plantService.markAsWatered(plant.id);
    }
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All plants watered! 🎉'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40 - (_plantsNeedingWater.isNotEmpty ? 140 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminders',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _plantsNeedingWater.isEmpty
                                  ? 'All caught up!'
                                  : '${_plantsNeedingWater.length} ${_plantsNeedingWater.length == 1 ? 'plant needs' : 'plants need'} water',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_plantsNeedingWater.isNotEmpty)
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 120),
                            child: ElevatedButton.icon(
                              onPressed: _waterAll,
                              icon: Icon(Icons.water_drop, size: 18, color: theme.colorScheme.onPrimary),
                              label: Text(
                                'Water All',
                                style: TextStyle(color: theme.colorScheme.onPrimary),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _plantsNeedingWater.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '✅',
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'All plants are watered!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for updates',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _plantsNeedingWater.length,
                          itemBuilder: (context, index) {
                            final plant = _plantsNeedingWater[index];
                            final isOverdue = plant.daysOverdue() > 0;
                            
                            return Column(
                              children: [
                                if (isOverdue && (index == 0 || !_plantsNeedingWater[index - 1].needsWatering()))
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_rounded,
                                          size: 16,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Overdue',
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            color: theme.colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                PlantCard(
                                  plant: plant,
                                  showWaterButton: true,
                                  onWater: () => _handleWater(plant.id),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
