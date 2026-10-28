import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../reserve_slot/reserve_slot_screen.dart';

class ChargerDetailsScreen extends StatefulWidget {
  final ChargerStation? station;

  const ChargerDetailsScreen({super.key, this.station});

  @override
  State<ChargerDetailsScreen> createState() => _ChargerDetailsScreenState();
}

class _ChargerDetailsScreenState extends State<ChargerDetailsScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _openHostChatModal(BuildContext context, ChargerStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: AppState(),
          builder: (context, _) {
            final messages = AppState().chatMessages;
            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondaryFixed,
                          child: Text(
                            station.hostName.isNotEmpty ? station.hostName.substring(0, 1) : 'H',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.hostName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Online • Typically replies in 2 mins',
                                    style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: AppColors.tertiary),
                        ),
                      ],
                    ),
                  ),

                  // Chat Message List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final bool isUser = msg['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.primary : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isUser ? Colors.white : AppColors.onSurface,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['time'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : AppColors.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Chat Input Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Ask Rajesh about gate pass, bay clearance...',
                                hintStyle: TextStyle(fontSize: 12, color: AppColors.tertiary),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  AppState().sendChatMessage(val.trim());
                                  _chatController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_chatController.text.trim().isNotEmpty) {
                              AppState().sendChatMessage(_chatController.text.trim());
                              _chatController.clear();
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final station = widget.station ?? AppState().selectedStation;
        final images = station.images.isNotEmpty ? station.images : [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c',
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Charger Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.onSurface),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharable link for ${station.name} copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery Carousel
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) => setState(() => _currentImageIndex = i),
                              itemBuilder: (context, index) {
                                return Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surfaceContainerHigh,
                                    child: const Center(
                                      child: Icon(Icons.ev_station, size: 64, color: AppColors.primary),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1} / ${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Title & Badges
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${station.address} • ${station.distanceKm} km away',
                                      style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, size: 14, color: AppColors.secondary),
                              SizedBox(width: 4),
                              Text(
                                'Verified Bay',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSecondaryFixedVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Host Card
                    GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: station.hostAvatar.isNotEmpty
                                ? Image.network(
                                    station.hostAvatar,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => CircleAvatar(
                                      radius: 22,
                                      child: Text(station.hostName.isNotEmpty ? station.hostName.substring(0, 1) : 'H'),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.secondaryFixed,
                                    child: Text(station.hostName.isNotEmpty ? station.hostName.substring(0, 1) : 'H'),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station.hostName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 13, color: AppColors.primaryContainer),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${station.hostRating} (${station.hostReviews} reviews) • Verified Host',
                                      style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openHostChatModal(context, station),
                            tooltip: 'Chat with host in real-time',
                            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.secondary),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling Host (${station.hostName})... (+91 98450 67890)'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spec Grid
                    Row(
                      children: [
                        _buildSpecTile(Icons.speed, '${station.powerKw} kW AC', 'Dedicated Circuit'),
                        const SizedBox(width: 8),
                        _buildSpecTile(Icons.power, station.connectorType, 'Certified Standard'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSpecTile(Icons.solar_power, station.isSolar ? '100% Solar' : 'Green Grid', station.isSolar ? 'Rooftop PV System' : 'BESCOM Hybrid'),
                        const SizedBox(width: 8),
                        _buildSpecTile(Icons.roofing, station.bayType, station.isCovered ? 'Covered & Lighted' : 'Private Bay'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Compatibility
                    const Text(
                      'Vehicle Compatibility',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: station.compatibleVehicles.map((car) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _VehicleCompatRow(name: car, status: 'Full ${station.powerKw} kW Support'),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amenities & Bay Features
                    const Text(
                      'Amenities & Bay Features',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (station.isCovered) const _AmenityChip(icon: Icons.roofing, label: 'Covered Stilt Bay'),
                        if (station.hasCctv) const _AmenityChip(icon: Icons.videocam, label: '24x7 CCTV Security'),
                        if (station.hasWifi) const _AmenityChip(icon: Icons.wifi, label: 'High-speed Wi-Fi'),
                        const _AmenityChip(icon: Icons.local_drink, label: 'Drinking Water'),
                        const _AmenityChip(icon: Icons.security, label: 'Gated Access'),
                        const _AmenityChip(icon: Icons.volume_off, label: 'Quiet Residential'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Neighborhood & Access Details
                    const Text(
                      'Neighborhood & Access',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pin_drop, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  station.address,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Landmark: ${station.landmark}',
                            style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              Icon(Icons.key, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Smart Gate PIN unlocked upon booking confirmation',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pricing Breakdown
                    const Text(
                      'Pricing Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _PriceRow(label: 'Hourly Charging Tariff', value: '₹${station.tariffPerHour.toStringAsFixed(2)} / hr'),
                          const SizedBox(height: 6),
                          _PriceRow(label: 'Parking Convenience Fee', value: station.parkingFee == 0 ? '₹0.00 (Free)' : '₹${station.parkingFee.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          const _PriceRow(label: 'FMC Platform Security & Insurance', value: 'Included'),
                          const SizedBox(height: 6),
                          const _PriceRow(label: 'Taxes (GST 18%)', value: 'Included'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom CTA
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    border: Border(
                      top: BorderSide(color: Colors.black.withOpacity(0.06), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${station.tariffPerHour.toInt()} / hr',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              station.parkingFee == 0 ? 'Free parking' : '₹${station.parkingFee.toInt()} parking',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 50,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.bolt, size: 20),
                              label: const Text(
                                'Select Slot & Reserve',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecTile(IconData icon, String title, String subtitle) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.tertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCompatRow extends StatelessWidget {
  final String name;
  final String status;

  const _VehicleCompatRow({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }
}
