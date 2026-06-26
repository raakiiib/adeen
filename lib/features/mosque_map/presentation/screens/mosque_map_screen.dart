import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/mosque_map/domain/mosque_model.dart';
import 'package:adeen/features/mosque_map/presentation/controllers/mosque_controller.dart';

// Clean Map Style JSON constant to completely remove default POIs (hospitals, retail, etc.)
// Custom Map Style generator that stylizes landscape, water, and roads based on the theme & color presets.
String getDynamicMapStyle(Brightness brightness, String preset) {
  final isDark = brightness == Brightness.dark;
  
  // Custom colors for Water and Landscape based on preset
  String waterColor;
  String landscapeColor;
  String roadColor;
  String roadLabelColor;
  String textOutlineColor;
  String textFillColor;
  
  if (isDark) {
    textOutlineColor = '#000000';
    textFillColor = '#b3b3b3';
    roadColor = '#1f1f1f';
    roadLabelColor = '#595959';
    
    if (preset == 'sapphire') {
      waterColor = '#07182b'; // dark sapphire blue
      landscapeColor = '#050e1a'; // dark sapphire landscape
    } else if (preset == 'ruby') {
      waterColor = '#1a0707'; // dark ruby red
      landscapeColor = '#120404'; // dark ruby landscape
    } else {
      // Emerald
      waterColor = '#05140b'; // dark emerald green
      landscapeColor = '#08140e'; // dark emerald landscape
    }
  } else {
    // Light Mode
    textOutlineColor = '#ffffff';
    textFillColor = '#333333';
    roadColor = '#ffffff';
    roadLabelColor = '#b3b3b3';
    
    if (preset == 'sapphire') {
      waterColor = '#b3c9db'; // light blue water
      landscapeColor = '#f0f3f7'; // sapphire tint landscape
    } else if (preset == 'ruby') {
      waterColor = '#ebd5d5'; // light ruby red water
      landscapeColor = '#FAF5F5'; // ruby tint landscape
    } else {
      // Emerald
      waterColor = '#cbe0d3'; // light emerald water
      landscapeColor = '#F9F6F0'; // emerald tint landscape
    }
  }

  return '''
  [
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [
        { "color": "$textFillColor" }
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.stroke",
      "stylers": [
        { "color": "$textOutlineColor" },
        { "visibility": "on" },
        { "weight": 2 }
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels.icon",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        { "color": "$landscapeColor" }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        { "color": "$roadColor" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        { "color": "$roadLabelColor" }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        { "color": "$waterColor" }
      ]
    }
  ]
  ''';
}

class MosqueMapScreen extends ConsumerStatefulWidget {
  const MosqueMapScreen({super.key});

  @override
  ConsumerState<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends ConsumerState<MosqueMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final activePreset = ref.watch(colorPresetProvider);
    
    final locationState = ref.watch(locationProvider);
    final filteredMosques = ref.watch(filteredMosqueProvider);
    final activeFilter = ref.watch(mosqueFilterProvider);
    final apiError = ref.watch(placesApiErrorProvider);

    // Apply custom dynamic map style after each build frame completes if controller is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_mapController.isCompleted) {
        final controller = await _mapController.future;
        controller.setMapStyle(getDynamicMapStyle(theme.brightness, activePreset));
      }
    });

    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(locationState.latitude, locationState.longitude),
      zoom: 14.5,
    );

    // Convert MosqueModel items into Google Map Marker objects
    final Set<Marker> markers = filteredMosques.map((mosque) {
      final markerId = MarkerId(mosque.id);
      final double distanceInMeters = Geolocator.distanceBetween(
        locationState.latitude,
        locationState.longitude,
        mosque.latitude,
        mosque.longitude,
      );
      final double distanceInKm = distanceInMeters / 1000.0;

      return Marker(
        markerId: markerId,
        position: LatLng(mosque.latitude, mosque.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          _showMosqueBottomSheet(mosque, distanceInKm);
        },
      );
    }).toSet();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Google Map View with clean POI styling
            GoogleMap(
              initialCameraPosition: initialPosition,
              myLocationEnabled: locationState.status == 'loaded',
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                // Apply custom dynamic map style based on preset & theme brightness
                controller.setMapStyle(getDynamicMapStyle(theme.brightness, activePreset));
              },
            ),

            // 2. Top Filter Chips Bar with Drawer Trigger and Diagnostic Banner
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: theme.colorScheme.primary,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChipsRow(ref, activeFilter, localizations, theme),
                      ),
                    ],
                  ),
                  if (apiError != null) ...[
                    const SizedBox(height: 10),
                    _buildDiagnosticBanner(context, theme, apiError),
                  ],
                ],
              ),
            ),

            // 3. Float button to center on user location
            PositionedDirectional(
              end: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _centerOnUser(locationState),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: AppTheme.warmGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.my_location),
              ),
            ),

            // 4. Float button to refresh/reload mosques
            PositionedDirectional(
              end: 16,
              bottom: 84, // 16 + 56 + 12
              child: FloatingActionButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refreshing nearby mosques...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  try {
                    await ref.read(mosqueListProvider.notifier).loadMosques(forceRefresh: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mosque list updated successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to refresh: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: AppTheme.warmGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnUser(LocationState locationState) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationState.latitude, locationState.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(
    WidgetRef ref,
    MosqueFilter activeFilter,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(ref, MosqueFilter.all, 'All', activeFilter, theme),
          const SizedBox(width: 8),
          _buildChip(
            ref,
            MosqueFilter.womenSection,
            localizations.translate('facility_women'),
            activeFilter,
            theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            ref,
            MosqueFilter.parking,
            localizations.translate('facility_parking'),
            activeFilter,
            theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            ref,
            MosqueFilter.jummahShifts,
            localizations.translate('facility_jummah'),
            activeFilter,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    WidgetRef ref,
    MosqueFilter filterType,
    String label,
    MosqueFilter activeFilter,
    ThemeData theme,
  ) {
    final isSelected = activeFilter == filterType;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          ref.read(mosqueFilterProvider.notifier).state = filterType;
        }
      },
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.cardTheme.color,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? AppTheme.warmGold
            : theme.colorScheme.onSurface,
      ),
    );
  }

  void _showMosqueBottomSheet(MosqueModel mosque, double distanceKm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _MosqueDetailsBottomSheet(
          mosque: mosque,
          distanceKm: distanceKm,
        );
      },
    );
  }

  Widget _buildDiagnosticBanner(BuildContext context, ThemeData theme, String errorMessage) {
    return GestureDetector(
      onTap: () => _showDiagnosticDialog(context, theme, errorMessage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2C1919)
              : const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF6B1D1D)
                : const Color(0xFFF8B4B4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Places API Diagnostic Warning',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFFF8B4B4)
                          : const Color(0xFF9B1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Showing offline mock data. Tap to view error and fix instructions.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFFF8B4B4).withOpacity(0.8)
                          : const Color(0xFF9B1C1C).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFFF8B4B4)
                  : const Color(0xFF9B1C1C),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnosticDialog(BuildContext context, ThemeData theme, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                'Places API Error',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF1B1B1B)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: theme.brightness == Brightness.dark
                          ? Colors.redAccent.shade100
                          : Colors.red.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How to fix this in your Google Cloud Console:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStepItem('1.', 'Go to https://console.cloud.google.com/ and select your project.'),
                _buildStepItem('2.', 'Navigate to "APIs & Services" > "Enabled APIs & Services". Click "+ ENABLE APIS AND SERVICES" and search for "Places API (New)". Make sure it is Enabled.'),
                _buildStepItem('3.', 'Navigate to "APIs & Services" > "Credentials".'),
                _buildStepItem('4.', 'Edit your API key and check the API Restrictions section. Ensure "Places API (New)" is in the allowed list or choose "Don\'t restrict key" for testing.'),
                _buildStepItem('5.', 'Ensure billing is enabled for your Google Cloud Project (required by Places API).'),
                const SizedBox(height: 12),
                Text(
                  'Note: Once configuration is complete, please restart the app or reload the screen.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepItem(String stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.premiumGold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MosqueDetailsBottomSheet extends ConsumerWidget {
  final MosqueModel mosque;
  final double distanceKm;

  const _MosqueDetailsBottomSheet({
    required this.mosque,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Watch filtered mosque state to live-reload bottom sheet if any values update
    final updatedMosque = ref.watch(mosqueListProvider).firstWhere((m) => m.id == mosque.id, orElse: () => mosque);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Name & Distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  updatedMosque.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warmGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${distanceKm.toStringAsFixed(2)} ${localizations.translate('km')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.premiumGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Facilities Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppTheme.warmGold),
                  const SizedBox(width: 6),
                  Text(
                    localizations.translate('facilities') == 'facilities'
                        ? 'Facilities'
                        : localizations.translate('facilities'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, size: 22),
                color: AppTheme.premiumGold,
                onPressed: () => _editFacilities(context, ref, updatedMosque, localizations),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Facilities indicator row
          _buildFacilitiesRow(updatedMosque, localizations, theme),
          const SizedBox(height: 20),

          // Iqamah Times Timetable Header
          Row(
            children: [
              const Icon(Icons.people_outline, size: 18, color: AppTheme.warmGold),
              const SizedBox(width: 6),
              Text(
                localizations.translate('iqamah_time'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Iqamah Times List
          _buildIqamahTimetable(context, ref, updatedMosque, localizations, theme),
          const SizedBox(height: 24),

          // Directions trigger button
          ElevatedButton.icon(
            onPressed: () => _launchDirections(updatedMosque.latitude, updatedMosque.longitude),
            icon: const Icon(Icons.directions, color: Color(0xFF0B2A18)),
            label: Text(
              localizations.translate('get_directions'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0B2A18),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warmGold,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesRow(MosqueModel m, AppLocalizations localizations, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildFacilityTag(
          theme,
          Icons.woman,
          localizations.translate('facility_women'),
          m.hasWomenSection,
        ),
        _buildFacilityTag(
          theme,
          Icons.local_parking,
          localizations.translate('facility_parking'),
          m.hasParking,
        ),
        _buildFacilityTag(
          theme,
          Icons.star_border,
          localizations.translate('facility_jummah'),
          m.hasJummahShifts,
        ),
      ],
    );
  }

  Widget _buildFacilityTag(ThemeData theme, IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? (theme.brightness == Brightness.dark
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : theme.colorScheme.secondary.withOpacity(0.08))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? AppTheme.warmGold : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active
                  ? theme.colorScheme.onSurface
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIqamahTimetable(
    BuildContext context,
    WidgetRef ref,
    MosqueModel m,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        children: m.iqamahTimes.entries.map((entry) {
          final isLast = m.iqamahTimes.keys.last == entry.key;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                      ),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.translate(entry.key.toLowerCase()),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatTo12Hour(entry.value),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warmGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                      color: AppTheme.premiumGold,
                      onPressed: () => _suggestIqamahUpdate(context, ref, m.id, entry.key, entry.value, localizations),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _suggestIqamahUpdate(
    BuildContext context,
    WidgetRef ref,
    String mosqueId,
    String prayer,
    String currentVal,
    AppLocalizations localizations,
  ) async {
    final theme = Theme.of(context);
    final initialParts = currentVal.split(':');
    final initialHour = int.parse(initialParts[0]);
    final initialMin = int.parse(initialParts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.colorScheme.primary,
              onPrimary: AppTheme.warmGold,
              surface: Theme.of(context).cardTheme.color ?? Colors.black,
              onSurface: AppTheme.warmGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';

      await ref.read(mosqueListProvider.notifier).updateIqamahTime(mosqueId, prayer, newTime);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('update_success')),
            backgroundColor: theme.colorScheme.secondary,
          ),
        );
      }
    }
  }

  void _editFacilities(
    BuildContext context,
    WidgetRef ref,
    MosqueModel m,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    bool womenVal = m.hasWomenSection;
    bool parkingVal = m.hasParking;
    bool jummahVal = m.hasJummahShifts;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppTheme.warmGold),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Amenities',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(
                      localizations.translate('facility_women'),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    value: womenVal,
                    activeColor: AppTheme.warmGold,
                    onChanged: (val) {
                      setState(() => womenVal = val);
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      localizations.translate('facility_parking'),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    value: parkingVal,
                    activeColor: AppTheme.warmGold,
                    onChanged: (val) {
                      setState(() => parkingVal = val);
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      localizations.translate('facility_jummah'),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                    value: jummahVal,
                    activeColor: AppTheme.warmGold,
                    onChanged: (val) {
                      setState(() => jummahVal = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    localizations.translate('cancel'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warmGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(mosqueListProvider.notifier).updateAmenities(
                          m.id,
                          hasWomenSection: womenVal,
                          hasParking: parkingVal,
                          hasJummahShifts: jummahVal,
                        );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Amenities updated successfully!'),
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                      );
                    }
                  },
                  child: Text(
                    localizations.translate('save'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B2A18),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _launchDirections(double lat, double lng) async {
    final url = Uri.parse(
      Platform.isIOS
          ? 'https://maps.apple.com/?q=$lat,$lng'
          : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return time24;
    }
  }
}
