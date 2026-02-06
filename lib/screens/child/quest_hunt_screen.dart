import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/quest_provider.dart';
import '../../services/location_service.dart';

class QuestHuntScreen extends StatefulWidget {
  final String questId;

  const QuestHuntScreen({super.key, required this.questId});

  @override
  State<QuestHuntScreen> createState() => _QuestHuntScreenState();
}

class _QuestHuntScreenState extends State<QuestHuntScreen>
    with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  Position? _currentPosition;
  double? _compassHeading;
  double? _distanceToTarget;
  double? _bearingToTarget;
  bool _isTargetReached = false;
  bool _showCelebration = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTracking();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startTracking() async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS-Berechtigung benötigt!'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Position Stream
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _updateDistanceAndBearing();
            _checkIfTargetReached();
          });
        }
      },
    );

    // Kompass Stream
    _compassSubscription = _locationService.getCompassStream()?.listen(
      (event) {
        if (mounted) {
          setState(() {
            _compassHeading = event.heading;
          });
        }
      },
    );
  }

  void _updateDistanceAndBearing() {
    final quest = _getQuest();
    if (quest == null || _currentPosition == null) return;

    _distanceToTarget = _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      quest.targetLatitude,
      quest.targetLongitude,
    );

    _bearingToTarget = _locationService.calculateBearing(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      quest.targetLatitude,
      quest.targetLongitude,
    );
  }

  void _checkIfTargetReached() {
    final quest = _getQuest();
    if (quest == null || _currentPosition == null || _isTargetReached) return;

    final reached = _locationService.isTargetReached(
      _currentPosition!,
      quest.targetLatitude,
      quest.targetLongitude,
      quest.detectionRadius,
    );

    if (reached) {
      _isTargetReached = true;
      _showSuccessDialog();
    }
  }

  QuestModel? _getQuest() {
    final questProvider = context.read<QuestProvider>();
    try {
      return questProvider.quests.firstWhere((q) => q.id == widget.questId);
    } catch (e) {
      return null;
    }
  }

  void _showSuccessDialog() {
    setState(() => _showCelebration = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final quest = _getQuest();
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Geschafft!',
                style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Du hast den Schatz gefunden!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Deine Belohnung:'),
                    const SizedBox(height: 8),
                    Text(
                      quest?.reward.displayText ?? '',
                      style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await context.read<QuestProvider>().completeQuest(widget.questId);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  context.go('/child');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Super!'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quest = _getQuest();
    if (quest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schatzsuche')),
        body: const Center(child: Text('Quest nicht gefunden')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(quest.title),
        backgroundColor: AppTheme.getDifficultyColor(quest.difficulty.index + 1),
      ),
      body: Column(
        children: [
          // Belohnung Header
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.secondaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Belohnung: ${quest.reward.displayText}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Hauptinhalt basierend auf Schwierigkeit
          Expanded(
            child: _currentPosition == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('GPS wird gesucht...'),
                      ],
                    ),
                  )
                : _buildHuntView(quest),
          ),

          // Distanz Footer
          if (_distanceToTarget != null)
            _DistanceFooter(distance: _distanceToTarget!),
        ],
      ),
    );
  }

  Widget _buildHuntView(QuestModel quest) {
    switch (quest.difficulty) {
      case QuestDifficulty.level1:
        return _buildMapView(quest, showExactLocation: true);
      case QuestDifficulty.level2:
        return _buildMapView(quest, showExactLocation: false);
      case QuestDifficulty.level3:
        return _buildCompassView(quest);
    }
  }

  // Stufe 1 & 2: Kartenansicht
  Widget _buildMapView(QuestModel quest, {required bool showExactLocation}) {
    final targetLocation = LatLng(quest.targetLatitude, quest.targetLongitude);
    final currentLocation = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.familygeocaching.app',
        ),

        // Stufe 2: Umkreis anzeigen statt exaktem Punkt
        if (!showExactLocation)
          CircleLayer(
            circles: [
              CircleMarker(
                point: targetLocation,
                radius: quest.hintRadius,
                useRadiusInMeter: true,
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderColor: AppTheme.secondaryColor,
                borderStrokeWidth: 2,
              ),
            ],
          ),

        // Stufe 1: Exakter Zielpunkt
        if (showExactLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: targetLocation,
                width: 50,
                height: 50,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppTheme.errorColor,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        // Aktuelle Position
        MarkerLayer(
          markers: [
            Marker(
              point: currentLocation,
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Stufe 3: Nur Kompass
  Widget _buildCompassView(QuestModel quest) {
    final relativeAngle = (_bearingToTarget ?? 0) - (_compassHeading ?? 0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Folge dem Kompass',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Die Nadel zeigt zum Schatz',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // Kompass
          SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hintergrund
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                ),

                // Kompassrose
                ...List.generate(8, (index) {
                  final angle = index * 45.0;
                  final labels = ['N', 'NO', 'O', 'SO', 'S', 'SW', 'W', 'NW'];
                  return Transform.rotate(
                    angle: angle * pi / 180 - (_compassHeading ?? 0) * pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            fontWeight: index == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: index == 0 ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Richtungspfeil zum Ziel
                Transform.rotate(
                  angle: relativeAngle * pi / 180,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              Icons.navigation,
                              size: 80,
                              color: AppTheme.getDifficultyColor(3),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Zentrum
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Hinweis basierend auf Distanz
          if (_distanceToTarget != null) _buildDistanceHint(),
        ],
      ),
    );
  }

  Widget _buildDistanceHint() {
    String hint;
    Color color;

    if (_distanceToTarget! > 500) {
      hint = 'Noch weit entfernt...';
      color = Colors.grey;
    } else if (_distanceToTarget! > 200) {
      hint = 'Du kommst näher!';
      color = AppTheme.level2Color;
    } else if (_distanceToTarget! > 50) {
      hint = 'Fast da!';
      color = AppTheme.level1Color;
    } else {
      hint = 'Ganz nah! Schau dich um!';
      color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hint,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _DistanceFooter extends StatelessWidget {
  final double distance;

  const _DistanceFooter({required this.distance});

  @override
  Widget build(BuildContext context) {
    String distanceText;
    if (distance >= 1000) {
      distanceText = '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      distanceText = '${distance.toInt()} m';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.straighten, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Entfernung: $distanceText',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
