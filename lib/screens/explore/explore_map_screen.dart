import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import 'widgets/open_street_map_widget.dart';
import '../charger_details/charger_details_screen.dart';
import '../reserve_slot/reserve_slot_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const ExploreMapScreen({
    super.key,
    this.onProfileTap,
  });

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'icon': Icons.bolt},
    {'label': 'Home P2P', 'icon': Icons.home_outlined},
    {'label': 'CCS2 60kW+', 'icon': Icons.flash_on},
    {'label': 'Type 2 AC', 'icon': Icons.ev_station},
    {'label': '< ₹160/hr', 'icon': null},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      AppState().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final selectedStation = appState.selectedStation;
        final filteredStations = appState.filteredStations;
        final otherStations = filteredStations.where((s) => s.id != selectedStation.id).toList();
        final onlineCount = appState.stations.where((s) => s.isOnline).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Scrollable Map + Discovery Experience
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 96),
                  child: Column(
                    children: [
                      // Map + Floating Overlays Container
                      SizedBox(
                        height: 460,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Map Canvas (OpenStreetMap India)
                            Positioned.fill(
                              child: OpenStreetMapWidget(
                                selectedPin: appState.selectedStationId,
                                onPinSelected: (pin) {
                                  appState.selectStation(pin);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected: ${pin.replaceAll('_', ' ').toUpperCase()}'),
                                      duration: const Duration(milliseconds: 1200),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Top Floating Discovery Layer
                            Positioned(
                              top: 10,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Location Capsule + Active Plugs Live Badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: GlassContainer(
                                          borderRadius: 9999,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.near_me, color: AppColors.primary, size: 16),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  selectedStation.address.isNotEmpty
                                                      ? selectedStation.address.split(',').first
                                                      : 'Indiranagar 100ft Rd',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.onSurface,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(Icons.expand_more, color: AppColors.tertiary, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(9999),
                                          border: Border.all(
                                            color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$onlineCount Active Plugs',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Frosted Glass Search Bar
                                  GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: Icon(Icons.search, color: AppColors.tertiary, size: 20),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                                            decoration: const InputDecoration(
                                              hintText: 'Search societies, metro, CCS2 hubs...',
                                              hintStyle: TextStyle(fontSize: 13, color: AppColors.tertiary),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                        if (_searchController.text.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              _searchController.clear();
                                              appState.setSearchQuery('');
                                            },
                                            child: const Icon(Icons.close, color: AppColors.tertiary, size: 18),
                                          ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.mic, color: AppColors.tertiary, size: 18),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.tune, color: AppColors.tertiary, size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Filter Chips Scrollable Track
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: _filters.map((filter) {
                                        final bool isSelected = appState.selectedFilter == filter['label'];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              appState.setSelectedFilter(filter['label']);
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 180),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.white.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(9999),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.06),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (filter['icon'] != null) ...[
                                                    Icon(
                                                      filter['icon'],
                                                      size: 14,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : (filter['label'] == 'Home P2P'
                                                              ? AppColors.secondary
                                                              : AppColors.primary),
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  Text(
                                                    filter['label'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: isSelected ? Colors.white : AppColors.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Sheet Drawer Preview
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grabber Handle
                            Center(
                              child: Container(
                                width: 38,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiarySlate.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // Selected Station Detailed Card
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ChargerDetailsScreen(),
                                  ),
                                );
                              },
                              child: GlassContainer(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Name, Verified Badge, Distance
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      selectedStation.name,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.onSurface,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondaryFixed,
                                                      borderRadius: BorderRadius.circular(9999),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: const [
                                                        Icon(Icons.verified, size: 11, color: AppColors.secondary),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'Verified',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.onSecondaryFixedVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                selectedStation.address,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.tertiary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${selectedStation.distanceKm} km',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              '~${selectedStation.driveTimeMinutes} mins drive',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.tertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Quick Metrics Bento Bar
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const Text('Speed', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                                                const SizedBox(height: 2),
                                                Text('${selectedStation.powerKw} kW', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                                Text(selectedStation.connectorType, style: const TextStyle(fontSize: 10, color: AppColors.secondary), overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  const Text('Tariff', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                                                  const SizedBox(height: 2),
                                                  Text('₹${selectedStation.tariffPerHour.toInt()}/hr', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                  Text(selectedStation.parkingFee == 0 ? '₹0 Parking Fee' : '₹${selectedStation.parkingFee.toInt()} Parking', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const Text('Type', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                                                const SizedBox(height: 2),
                                                Text(selectedStation.bayType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                                Text(selectedStation.isCovered ? 'Covered & CCTV' : 'Open Bay', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Slot Availability & Host Profile Pill
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(9999),
                                                child: selectedStation.hostAvatar.isNotEmpty
                                                    ? Image.network(
                                                        selectedStation.hostAvatar,
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor: AppColors.secondaryFixed,
                                                          child: Text(
                                                            selectedStation.hostName.substring(0, 1),
                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 16,
                                                        backgroundColor: AppColors.secondaryFixed,
                                                        child: Text(
                                                          selectedStation.hostName.isNotEmpty ? selectedStation.hostName.substring(0, 1) : 'H',
                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      selectedStation.hostName,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.onSurface,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star, size: 12, color: AppColors.primaryContainer),
                                                        const SizedBox(width: 2),
                                                        Flexible(
                                                          child: Text(
                                                            '${selectedStation.hostRating} (${selectedStation.hostReviews} reviews)',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: AppColors.tertiary,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.circle, size: 7, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Open till ${selectedStation.openUntil}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Vehicle Match Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainer.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Compatible with ${selectedStation.compatibleVehicles.take(3).join(', ')}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.tertiary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Dual Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            height: 48,
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Starting turn-by-turn route to ${selectedStation.name}... (${selectedStation.distanceKm} km)'),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: AppColors.surfaceContainerHigh,
                                                side: BorderSide.none,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: const Icon(Icons.directions, color: AppColors.secondary, size: 18),
                                              label: const Text(
                                                'Route',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 3,
                                          child: SizedBox(
                                            height: 48,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => const ReserveSlotScreen(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                foregroundColor: Colors.white,
                                                elevation: 4,
                                                shadowColor: AppColors.primary.withOpacity(0.4),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: const Icon(Icons.bolt, size: 20),
                                              label: Text(
                                                'Book Now • ₹${selectedStation.tariffPerHour.toInt()}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Nearby Alternative Carousel
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Other Stations Nearby',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View all ${otherStations.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (otherStations.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No other matching stations found for filter.',
                                    style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                                  ),
                                ),
                              )
                            else
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: otherStations.map((station) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildMiniStationCard(
                                        station: station,
                                        onTap: () {
                                          appState.selectStation(station.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Switched preview to ${station.name}'),
                                              duration: const Duration(milliseconds: 1000),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStationCard({
    required ChargerStation station,
    required VoidCallback onTap,
  }) {
    final bool isFast = station.powerKw >= 30;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 250,
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        station.address,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isFast
                        ? AppColors.primaryContainer.withOpacity(0.18)
                        : AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${station.powerKw.toInt()} kW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isFast ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${station.tariffPerHour.toInt()} / hr',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${station.distanceKm} km • ${station.bayType}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
