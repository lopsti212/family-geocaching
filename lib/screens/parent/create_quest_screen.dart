import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quest_provider.dart';
import '../../services/location_service.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardValueController = TextEditingController();
  final _customRewardController = TextEditingController();
  final _mapController = MapController();
  final _locationService = LocationService();

  QuestDifficulty _difficulty = QuestDifficulty.level1;
  RewardType _rewardType = RewardType.screenTime;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = true;
  double _hintRadius = 100.0;
  bool _requiresPhoto = false;
  final _photoDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } else {
      setState(() {
        // Fallback: Berlin Mitte
        _selectedLocation = const LatLng(52.52, 13.405);
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardValueController.dispose();
    _customRewardController.dispose();
    _photoDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _createQuest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle einen Ort auf der Karte')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final questProvider = context.read<QuestProvider>();

    final reward = Reward(
      type: _rewardType,
      value: double.tryParse(_rewardValueController.text) ?? 0,
      customDescription: _rewardType == RewardType.custom
          ? _customRewardController.text
          : null,
    );

    final success = await questProvider.createQuest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      createdBy: authProvider.user!.id,
      familyId: authProvider.family!.id,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      difficulty: _difficulty,
      reward: reward,
      hintRadius: _difficulty == QuestDifficulty.level2 ? _hintRadius : null,
      requiresPhoto: _requiresPhoto,
      photoDescription: _requiresPhoto ? _photoDescriptionController.text.trim() : null,
    );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schatzsuche erstellt!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else if (mounted && questProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(questProvider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = context.watch<QuestProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Schatzsuche'),
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Titel
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      hintText: 'z.B. "Schatz im Park"',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Titel eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Beschreibung
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Beschreibung (optional)',
                      hintText: 'Hinweise für die Suche...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Schwierigkeit
                  Text(
                    'Schwierigkeit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _DifficultySelector(
                    selected: _difficulty,
                    onChanged: (d) => setState(() => _difficulty = d),
                  ),
                  if (_difficulty == QuestDifficulty.level2) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Hinweisradius: ${_hintRadius.round()}m',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hintRadius,
                      min: 25,
                      max: 500,
                      divisions: 19,
                      label: '${_hintRadius.round()}m',
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setState(() => _hintRadius = v),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Karte
                  Text(
                    'Zielort (tippe auf die Karte)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 400,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedLocation!,
                              initialZoom: 15,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _selectedLocation = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.familygeocaching.app',
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: AppTheme.errorColor,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Column(
                              children: [
                                FloatingActionButton.small(
                                  heroTag: 'zoom_in',
                                  onPressed: () {
                                    final zoom = _mapController.camera.zoom;
                                    _mapController.move(
                                      _mapController.camera.center,
                                      zoom + 1,
                                    );
                                  },
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 4),
                                FloatingActionButton.small(
                                  heroTag: 'zoom_out',
                                  onPressed: () {
                                    final zoom = _mapController.camera.zoom;
                                    _mapController.move(
                                      _mapController.camera.center,
                                      zoom - 1,
                                    );
                                  },
                                  child: const Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Belohnung
                  Text(
                    'Belohnung',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _RewardTypeSelector(
                    selected: _rewardType,
                    onChanged: (r) => setState(() => _rewardType = r),
                  ),
                  const SizedBox(height: 12),
                  if (_rewardType == RewardType.custom)
                    TextFormField(
                      controller: _customRewardController,
                      decoration: const InputDecoration(
                        labelText: 'Belohnung beschreiben',
                        hintText: 'z.B. "Eis essen gehen"',
                        prefixIcon: Icon(Icons.card_giftcard),
                      ),
                      validator: (value) {
                        if (_rewardType == RewardType.custom &&
                            (value == null || value.isEmpty)) {
                          return 'Bitte Belohnung beschreiben';
                        }
                        return null;
                      },
                    )
                  else
                    TextFormField(
                      controller: _rewardValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _rewardType == RewardType.screenTime
                            ? 'Minuten Handyzeit'
                            : 'Betrag in Euro',
                        prefixIcon: Icon(
                          _rewardType == RewardType.screenTime
                              ? Icons.timer
                              : Icons.euro,
                        ),
                      ),
                      validator: (value) {
                        if (_rewardType != RewardType.custom) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Wert eingeben';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Bitte gültige Zahl eingeben';
                          }
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),

                  // Foto erforderlich
                  Text(
                    'Foto am Ziel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Foto erforderlich'),
                    subtitle: const Text(
                      'Kind muss am Ziel ein Foto machen',
                    ),
                    value: _requiresPhoto,
                    onChanged: (v) => setState(() => _requiresPhoto = v),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_requiresPhoto) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _photoDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Was soll fotografiert werden?',
                        hintText: 'z.B. "Den Brunnen im Park"',
                        prefixIcon: Icon(Icons.photo_camera),
                      ),
                      validator: (value) {
                        if (_requiresPhoto &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Bitte beschreibe, was fotografiert werden soll';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Erstellen Button
                  ElevatedButton(
                    onPressed: questProvider.isLoading ? null : _createQuest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: questProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Schatzsuche erstellen',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final QuestDifficulty selected;
  final ValueChanged<QuestDifficulty> onChanged;

  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: QuestDifficulty.values.map((d) {
        final isSelected = d == selected;
        final color = AppTheme.getDifficultyColor(d.index + 1);

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(d),
            child: Container(
              margin: EdgeInsets.only(
                right: d != QuestDifficulty.values.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.white,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    d == QuestDifficulty.level1
                        ? Icons.looks_one
                        : d == QuestDifficulty.level2
                            ? Icons.looks_two
                            : d == QuestDifficulty.level3
                                ? Icons.looks_3
                                : Icons.looks_4,
                    color: isSelected ? color : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d == QuestDifficulty.level1
                        ? 'Direkt'
                        : d == QuestDifficulty.level2
                            ? 'Radius'
                            : d == QuestDifficulty.level3
                                ? 'Kompass'
                                : 'Blind',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RewardTypeSelector extends StatelessWidget {
  final RewardType selected;
  final ValueChanged<RewardType> onChanged;

  const _RewardTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: RewardType.values.map((r) {
        final isSelected = r == selected;
        return ChoiceChip(
          label: Text(
            r == RewardType.screenTime
                ? 'Handyzeit'
                : r == RewardType.pocketMoney
                    ? 'Taschengeld'
                    : 'Eigene',
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(r),
          selectedColor: AppTheme.secondaryColor.withOpacity(0.3),
        );
      }).toList(),
    );
  }
}
