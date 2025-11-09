import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sproutling/models/plant.dart';

class PlantService {
  static const String _plantsKey = 'plants';
  static const String _initializedKey = 'plants_initialized';

  Future<void> _initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_initializedKey) ?? false;

    if (!isInitialized) {
      final now = DateTime.now();
      final userId = 'user1';

      final samplePlants = [
        Plant(
          id: '1',
          name: 'Monstera Deliciosa',
          emoji: '🌿',
          wateringFrequencyDays: 7,
          lastWateredDate: now.subtract(const Duration(days: 8)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
        Plant(
          id: '2',
          name: 'Snake Plant',
          emoji: '🪴',
          wateringFrequencyDays: 14,
          lastWateredDate: now.subtract(const Duration(days: 5)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        Plant(
          id: '3',
          name: 'Pothos',
          emoji: '🍃',
          wateringFrequencyDays: 5,
          lastWateredDate: now.subtract(const Duration(days: 6)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 45)),
          updatedAt: now.subtract(const Duration(days: 6)),
        ),
        Plant(
          id: '4',
          name: 'Peace Lily',
          emoji: '🌺',
          wateringFrequencyDays: 3,
          lastWateredDate: now.subtract(const Duration(days: 2)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        Plant(
          id: '5',
          name: 'Fiddle Leaf Fig',
          emoji: '🌳',
          wateringFrequencyDays: 7,
          lastWateredDate: now.subtract(const Duration(days: 4)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 90)),
          updatedAt: now.subtract(const Duration(days: 4)),
        ),
        Plant(
          id: '6',
          name: 'Succulents Mix',
          emoji: '🌵',
          wateringFrequencyDays: 21,
          lastWateredDate: now.subtract(const Duration(days: 10)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        Plant(
          id: '7',
          name: 'Spider Plant',
          emoji: '🕷️',
          wateringFrequencyDays: 7,
          lastWateredDate: now.subtract(const Duration(days: 7)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 50)),
          updatedAt: now.subtract(const Duration(days: 7)),
        ),
        Plant(
          id: '8',
          name: 'Aloe Vera',
          emoji: '🌱',
          wateringFrequencyDays: 14,
          lastWateredDate: now.subtract(const Duration(days: 15)),
          userId: userId,
          createdAt: now.subtract(const Duration(days: 100)),
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
      ];

      final plantsJson = samplePlants.map((p) => p.toJson()).toList();
      await prefs.setString(_plantsKey, json.encode(plantsJson));
      await prefs.setBool(_initializedKey, true);
    }
  }

  Future<List<Plant>> getAllPlants() async {
    await _initializeSampleData();
    final prefs = await SharedPreferences.getInstance();
    final plantsString = prefs.getString(_plantsKey);

    if (plantsString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(plantsString);
      final List<Plant> result = [];
      bool skipped = false;
      for (final item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            result.add(Plant.fromJson(item));
          } else if (item is Map) {
            result.add(Plant.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          skipped = true;
        }
      }
      if (skipped) {
        // Auto-sanitize by writing back a clean list
        final plantsJson = result.map((p) => p.toJson()).toList();
        await prefs.setString(_plantsKey, json.encode(plantsJson));
      }
      return result;
    } catch (e) {
      // Corrupted JSON; reset to empty to avoid repeated failures
      await prefs.setString(_plantsKey, json.encode([]));
      return [];
    }
  }

  Future<Plant?> getPlantById(String id) async {
    final plants = await getAllPlants();
    try {
      return plants.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addPlant(Plant plant) async {
    final plants = await getAllPlants();
    plants.add(plant);
    await _savePlants(plants);
  }

  Future<void> updatePlant(Plant plant) async {
    final plants = await getAllPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      plants[index] = plant;
      await _savePlants(plants);
    }
  }

  Future<void> deletePlant(String id) async {
    final plants = await getAllPlants();
    plants.removeWhere((p) => p.id == id);
    await _savePlants(plants);
  }

  Future<void> _savePlants(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final plantsJson = plants.map((p) => p.toJson()).toList();
    await prefs.setString(_plantsKey, json.encode(plantsJson));
  }

  Future<List<Plant>> getPlantsNeedingWater() async {
    final plants = await getAllPlants();
    return plants.where((p) => p.needsWatering()).toList()
      ..sort((a, b) => b.daysOverdue().compareTo(a.daysOverdue()));
  }

  Future<double> getWateringProgress() async {
    final plants = await getAllPlants();
    if (plants.isEmpty) return 0.0;
    
    final wateredCount = plants.where((p) => !p.needsWatering()).length;
    return wateredCount / plants.length;
  }

  Future<void> markAsWatered(String plantId) async {
    final plant = await getPlantById(plantId);
    if (plant != null) {
      final updatedPlant = plant.copyWith(
        lastWateredDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await updatePlant(updatedPlant);
    }
  }

  Future<List<Plant>> searchPlants(String query) async {
    final plants = await getAllPlants();
    if (query.isEmpty) return plants;
    
    return plants.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
