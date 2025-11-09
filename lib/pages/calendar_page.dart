import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutling/models/plant.dart';
import 'package:sproutling/services/plant_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _plantService = PlantService();
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isLoading = true;
  List<Plant> _plants = [];
  late Map<int, int> _markersCount; // day -> count of watering events

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final plants = await _plantService.getAllPlants();
    setState(() {
      _plants = plants;
      _markersCount = _computeMarkersForMonth(_focusedMonth, plants);
      _isLoading = false;
    });
  }

  Map<int, int> _computeMarkersForMonth(DateTime month, List<Plant> plants) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final markers = <int, int>{};

    for (final plant in plants) {
      if (plant.wateringFrequencyDays <= 0) continue;
      // Start from the first watering day on/after month start
      var day = plant.lastWateredDate;
      if (day.isAfter(lastDayOfMonth)) continue;

      // Move forward to the first date on/after firstDayOfMonth that aligns with the frequency
      if (day.isBefore(firstDayOfMonth)) {
        final diff = firstDayOfMonth.difference(day).inDays;
        final remainder = diff % plant.wateringFrequencyDays;
        day = firstDayOfMonth.add(Duration(days: remainder == 0 ? 0 : (plant.wateringFrequencyDays - remainder)));
      }

      // Add markers for this plant within the month
      while (!day.isAfter(lastDayOfMonth)) {
        final d = day.day;
        markers[d] = (markers[d] ?? 0) + 1;
        day = day.add(Duration(days: plant.wateringFrequencyDays));
      }
    }

    return markers;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _markersCount = _computeMarkersForMonth(_focusedMonth, _plants);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);

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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Calendar',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Row(
                              children: [
                                _MonthButton(icon: Icons.chevron_left, onTap: () => _changeMonth(-1)),
                                const SizedBox(width: 8),
                                _MonthButton(icon: Icons.chevron_right, onTap: () => _changeMonth(1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        monthLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.water_drop, size: 16, color: theme.colorScheme.primary),
                                        const SizedBox(width: 6),
                                        Text('Watering days', style: theme.textTheme.labelMedium),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _CalendarGrid(month: _focusedMonth, markersCount: _markersCount),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Recent watering logs',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildLogs(theme),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildLogs(ThemeData theme) {
    final plantsSorted = [..._plants]..sort((a, b) => b.lastWateredDate.compareTo(a.lastWateredDate));
    return plantsSorted.take(10).map((p) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.water_drop, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text('Watered ${DateFormat('MMM d, yyyy • h:mm a').format(p.lastWateredDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, int> markersCount; // day -> count

  const _CalendarGrid({required this.month, required this.markersCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday; // 1 (Mon) - 7 (Sun)
    final daysInMonth = lastDayOfMonth.day;

    // Build a list of 42 cells (6 weeks) to keep layout consistent
    final totalCells = 42;
    final cells = <Widget>[];

    // Weekday headers
    final weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    cells.addAll(weekdayLabels.map((label) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                )),
          ),
        )));

    // Calculate blanks before the first day (adjust for Monday-start)
    final leadingBlanks = (startingWeekday + 6) % 7; // convert Mon=1..Sun=7 to 0-based index

    // Grid body: 6 weeks x 7 days = 42 cells; but we already added 7 headers above
    final gridItems = <Widget>[];
    for (int i = 0; i < totalCells; i++) {
      final dayNum = i - leadingBlanks + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        gridItems.add(const SizedBox());
      } else {
        final hasWater = markersCount.containsKey(dayNum);
        final count = markersCount[dayNum] ?? 0;
        final isToday = _isSameDate(DateTime.now(), DateTime(month.year, month.month, dayNum));
        gridItems.add(Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isToday ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '$dayNum',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasWater)
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      if (count > 1) ...[
                        const SizedBox(width: 2),
                        Text('x$count', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                      ]
                    ],
                  ),
                ),
            ],
          ),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 7,
            children: weekdayLabels
                .map((label) => Center(
                      child: Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 7,
            children: gridItems,
          ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
