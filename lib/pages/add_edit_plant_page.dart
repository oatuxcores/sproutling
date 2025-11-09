import 'package:flutter/material.dart';
import 'package:sproutling/models/plant.dart';
import 'package:sproutling/services/plant_service.dart';

class AddEditPlantPage extends StatefulWidget {
  final Plant? plant;

  const AddEditPlantPage({super.key, this.plant});

  @override
  State<AddEditPlantPage> createState() => _AddEditPlantPageState();
}

class _AddEditPlantPageState extends State<AddEditPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _plantService = PlantService();
  final _nameController = TextEditingController();
  int _wateringFrequency = 7;
  String _selectedEmoji = '🌿';
  String _imageUrl = '';
  bool _usePhoto = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  final List<String> _emojiOptions = [
    '🌿', '🪴', '🍃', '🌺', '🌳', '🌵', '🌱', '🌴', '🌸', '🌼', '🌻', '🌹'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _wateringFrequency = widget.plant!.wateringFrequencyDays;
      _selectedEmoji = widget.plant!.emoji;
      _imageUrl = widget.plant!.imageUrl ?? '';
      _usePhoto = _imageUrl.isNotEmpty;
    } else {
      _usePhoto = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final plant = Plant(
      id: widget.plant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      emoji: _selectedEmoji,
      imageUrl: _usePhoto && _imageUrl.trim().isNotEmpty ? _imageUrl.trim() : null,
      wateringFrequencyDays: _wateringFrequency,
      lastWateredDate: widget.plant?.lastWateredDate ?? now,
      userId: 'user1',
      createdAt: widget.plant?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.plant == null) {
      await _plantService.addPlant(plant);
    } else {
      await _plantService.updatePlant(plant);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    if (widget.plant == null) return;
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${widget.plant!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      await _plantService.deletePlant(widget.plant!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.plant != null;

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _BackPill(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Plant' : 'Add New Plant',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        if (isEdit)
                          _TrashPill(
                            onTap: _isDeleting ? null : _delete,
                            isBusy: _isDeleting,
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Plant visual',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usePhoto = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_usePhoto ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_usePhoto ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_emotions, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Use Emoji', style: theme.textTheme.labelLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usePhoto = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _usePhoto ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _usePhoto ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Use Photo', style: theme.textTheme.labelLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_usePhoto) ...[
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
                        child: TextFormField(
                          initialValue: _imageUrl,
                          onChanged: (v) => _imageUrl = v,
                          decoration: const InputDecoration(
                            hintText: 'Paste a photo URL (https://...)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (value) {
                            if (_usePhoto) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Please provide a photo URL or switch to Emoji';
                              if (!v.startsWith('http')) return 'Please enter a valid URL starting with http';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageUrl.trim().isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, color: theme.colorScheme.primary),
                                    const SizedBox(height: 8),
                                    Text('Preview', style: theme.textTheme.labelMedium),
                                  ],
                                ),
                              )
                            : Image.network(
                                _imageUrl.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Center(
                                  child: Text('Could not load image', style: theme.textTheme.labelMedium),
                                ),
                              ),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _emojiOptions.map((emoji) {
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      'Plant name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Monstera Deliciosa',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a plant name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Watering frequency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Every $_wateringFrequency ${_wateringFrequency == 1 ? 'day' : 'days'}',
                                style: theme.textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: _wateringFrequency > 1
                                      ? () => setState(() => _wateringFrequency--)
                                      : null,
                                    color: theme.colorScheme.primary,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: _wateringFrequency < 30
                                      ? () => setState(() => _wateringFrequency++)
                                      : null,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Slider(
                            value: _wateringFrequency.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (value) => setState(() => _wateringFrequency = value.toInt()),
                          ),
                        ],
                      ),
                    ),
                    // Removed "Last watered date" section per request
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.water_drop, color: theme.colorScheme.onPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  isEdit ? 'Update Plant' : 'Add Plant',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Back',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrashPill extends StatelessWidget {
  final VoidCallback? onTap; // nullable to allow disabled state
  final bool isBusy;
  const _TrashPill({required this.onTap, this.isBusy = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onTap == null;
    return Material(
      color: theme.colorScheme.error,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBusy)
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.onError),
                  ),
                )
              else
                Icon(Icons.delete, color: theme.colorScheme.onError, size: 18),
              const SizedBox(width: 6),
              Text(
                'Delete',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

