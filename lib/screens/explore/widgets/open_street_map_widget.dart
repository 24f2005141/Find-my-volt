import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../theme/app_colors.dart';
import '../../../models/models.dart';
import '../../../state/app_state.dart';

class OpenStreetMapWidget extends StatefulWidget {
  final String selectedPin;
  final ValueChanged<String> onPinSelected;

  const OpenStreetMapWidget({
    super.key,
    required this.selectedPin,
    required this.onPinSelected,
  });

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  late final MapController _mapController;

  // Default User GPS location: 12th Main Road, Indiranagar, Bangalore, India
  static const LatLng _userLocation = LatLng(12.9784, 77.6408);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant OpenStreetMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPin != oldWidget.selectedPin) {
      _centerOnSelectedStation();
    }
  }

  void _centerOnSelectedStation() {
    final stations = AppState().stations;
    final selected = stations.firstWhere(
      (s) => s.id == widget.selectedPin,
      orElse: () => stations.first,
    );
    _mapController.move(
      LatLng(selected.latitude, selected.longitude),
      14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final stations = AppState().filteredStations;

        return Stack(
          children: [
            // Interactive OpenStreetMap Layer
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 13.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // OpenStreetMap Free Tile Provider (Best for India coverage)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.findmyvolt.app',
                  maxZoom: 19,
                ),

                // Markers Layer (Live Stations + User GPS)
                MarkerLayer(
                  markers: [
                    // 1. User Live GPS Location Marker
                    const Marker(
                      point: _userLocation,
                      width: 44,
                      height: 44,
                      child: _LiveGpsPulseMarker(),
                    ),

                    // 2. Real-time Station Markers from AppState / SQLite
                    ...stations.map((station) {
                      final isSelected = widget.selectedPin == station.id;
                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: isSelected ? 120 : 95,
                        height: 46,
                        child: GestureDetector(
                          onTap: () {
                            widget.onPinSelected(station.id);
                            _mapController.move(
                              LatLng(station.latitude, station.longitude),
                              14.2,
                            );
                          },
                          child: _StationMarkerBadge(
                            station: station,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // Map Controls (Zoom In/Out + Recenter GPS)
            Positioned(
              right: 14,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapButton(
                    icon: Icons.add,
                    tooltip: 'Zoom In',
                    onTap: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, zoom + 1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _mapButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom Out',
                    onTap: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, zoom - 1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _mapButton(
                    icon: Icons.my_location,
                    tooltip: 'Recenter to My Location',
                    color: AppColors.primary,
                    iconColor: Colors.white,
                    onTap: () {
                      _mapController.move(_userLocation, 14.5);
                    },
                  ),
                ],
              ),
            ),

            // OpenStreetMap Attribution Pill
            Positioned(
              left: 10,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  '© OpenStreetMap India',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return Material(
      color: color,
      elevation: 4,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _StationMarkerBadge extends StatelessWidget {
  final ChargerStation station;
  final bool isSelected;

  const _StationMarkerBadge({
    required this.station,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary
        : (station.isOnline ? const Color(0xFF0F172A) : const Color(0xFF64748B));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white24,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? AppColors.primary : Colors.black).withValues(alpha: 0.35),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            station.powerKw >= 50 ? Icons.flash_on : Icons.ev_station,
            size: 14,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '₹${station.tariffPerHour}/h',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (station.isSuperhost) ...[
            const SizedBox(width: 3),
            const Icon(Icons.star, size: 10, color: Colors.amber),
          ],
        ],
      ),
    );
  }
}

class _LiveGpsPulseMarker extends StatelessWidget {
  const _LiveGpsPulseMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.navigation, size: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
