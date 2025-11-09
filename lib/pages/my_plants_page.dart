import 'package:flutter/material.dart';
import 'package:sproutling/models/plant.dart';
import 'package:sproutling/services/plant_service.dart';
import 'package:sproutling/widgets/plant_card.dart';
import 'package:sproutling/pages/add_edit_plant_page.dart';

class MyPlantsPage extends StatefulWidget {
  const MyPlantsPage({super.key});

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {
  final _plantService = PlantService();
  final _searchController = TextEditingController();
  List<Plant> _plants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _searchController.addListener(_filterPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    final plants = await _plantService.getAllPlants();
    setState(() {
      _plants = plants;
      _filteredPlants = plants;
      _isLoading = false;
    });
  }

  void _filterPlants() {
    final query = _searchController.text;
    setState(() {
      _filteredPlants = query.isEmpty
        ? _plants
        : _plants.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> _navigateToEdit(Plant plant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditPlantPage(plant: plant)),
    );
    _loadPlants();
  }

  Future<void> _deletePlant(Plant plant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _plantService.deletePlant(plant.id);
      _loadPlants();
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
                    Text(
                      'My Plants',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search plants...',
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPlants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🌱',
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                ? 'No plants yet. Add your first plant!'
                                : 'No plants found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPlants,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _filteredPlants.length,
                          itemBuilder: (context, index) {
                            final plant = _filteredPlants[index];
                            return Dismissible(
                              key: Key(plant.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.delete, color: theme.colorScheme.onError),
                              ),
                              confirmDismiss: (direction) async {
                                await _deletePlant(plant);
                                return false;
                              },
                              child: PlantCard(
                                plant: plant,
                                onTap: () => _navigateToEdit(plant),
                              ),
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
