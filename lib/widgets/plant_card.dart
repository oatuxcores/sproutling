import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutling/models/plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  final VoidCallback? onWater;
  final bool showWaterButton;

  const PlantCard({
    super.key,
    required this.plant,
    this.onTap,
    this.onWater,
    this.showWaterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsWater = plant.needsWatering();
    final daysUntil = plant.daysUntilNextWatering();
    
    String wateringText;
    if (needsWater) {
      final overdue = plant.daysOverdue();
      wateringText = overdue == 0 
        ? 'Water today!' 
        : 'Overdue by $overdue ${overdue == 1 ? 'day' : 'days'}';
    } else {
      wateringText = 'Water in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                  ? Image.network(
                      plant.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            plant.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        plant.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last watered: ${DateFormat('MMM d').format(plant.lastWateredDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: needsWater ? theme.colorScheme.error : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        wateringText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: needsWater ? theme.colorScheme.error : theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showWaterButton && needsWater) ...[
              const SizedBox(width: 12),
              Material(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onWater,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.water_drop,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ] else if (!showWaterButton) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
