import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../charger_details/charger_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0; // 0: Active, 1: Completed, 2: Cancelled

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final activeBooking = appState.activeBooking;
        final completedBookings = appState.completedBookings;
        final cancelledBookings = appState.cancelledBookings;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your live charging sessions & historical passes',
                  style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                ),
                const SizedBox(height: 16),

                // Tab Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabChip(0, 'Active (${activeBooking != null ? 1 : 0})'),
                      const SizedBox(width: 8),
                      _buildTabChip(1, 'Completed (${completedBookings.length})'),
                      const SizedBox(width: 8),
                      _buildTabChip(2, 'Cancelled (${cancelledBookings.length})'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_selectedTab == 0) ...[
                  // Active Session Card
                  if (activeBooking != null)
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        'CHARGING IN PROGRESS',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  'Pass: ${activeBooking.passCode}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Station Title & Host
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChargerDetailsScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeBooking.stationName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Host: ${activeBooking.hostName} • ${activeBooking.vehicleName}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.tertiary),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Battery Visual Meter (Real-time telemetry)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.battery_charging_full, color: AppColors.primary, size: 22),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${activeBooking.currentSoc.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: Text(
                                        'Target: ${activeBooking.targetSoc.toInt()}% • Live Telemetry',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (activeBooking.currentSoc / 100).clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Telemetry Bento Grid
                          Row(
                            children: [
                              _buildTelemetryTile('Speed', '${activeBooking.powerKw} kW', 'Real-time AC'),
                              const SizedBox(width: 8),
                              _buildTelemetryTile('Delivered', '${activeBooking.currentDeliveredKwh.toStringAsFixed(2)} kWh', '+${(activeBooking.currentDeliveredKwh * 7.5).toInt()} km Range'),
                              const SizedBox(width: 8),
                              _buildTelemetryTile('Session Cost', '₹${activeBooking.currentCost.toStringAsFixed(0)}', '${activeBooking.durationHours} hrs total'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Session Controls
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Route navigation active: 1.2 km to ${activeBooking.stationName}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.directions, color: AppColors.secondary, size: 18),
                                  label: const Text('Route', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showStopSessionDialog(context, appState, activeBooking),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                                  label: const Text('Stop & Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.ev_station, size: 52, color: AppColors.tertiary),
                            const SizedBox(height: 12),
                            const Text(
                              'No active charging session right now',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select a station on the map to reserve a slot and start charging.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ChargerDetailsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text('Explore Nearby Stations'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                if (_selectedTab == 1 || _selectedTab == 0) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Completed Charges',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  if (completedBookings.isEmpty)
                    const Text('No completed bookings yet.', style: TextStyle(fontSize: 12, color: AppColors.tertiary))
                  else
                    ...completedBookings.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildHistoryCard(
                          title: b.stationName,
                          date: '${b.startTime.day} Oct 2026 • ${b.durationHours} hrs',
                          energy: '${b.currentDeliveredKwh.toStringAsFixed(1)} kWh',
                          amount: '₹${b.currentCost.toStringAsFixed(2)}',
                          status: 'Completed',
                          passCode: b.passCode,
                        ),
                      );
                    }),
                ],

                if (_selectedTab == 2) ...[
                  const SizedBox(height: 16),
                  if (cancelledBookings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No cancelled bookings on record.', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                      ),
                    )
                  else
                    ...cancelledBookings.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildHistoryCard(
                          title: b.stationName,
                          date: 'Cancelled',
                          energy: '0 kWh',
                          amount: '₹0.00 Refunded',
                          status: 'Cancelled',
                          passCode: b.passCode,
                        ),
                      );
                    }),
                ],

                const SizedBox(height: 24),

                // Roadside SOS Emergency Help Banner
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.support_agent, color: AppColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '24x7 Find My Volt Roadside Assistance',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                            Text(
                              'Flat tyre, low battery boost, or emergency tow',
                              style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dialing Find My Volt Roadside Support Helpline (1800-VOLT-HELP)...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStopSessionDialog(BuildContext context, AppState appState, ChargingBooking booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Stop Charging Session?'),
          content: Text(
            'The wallbox cable will be automatically unlocked and ₹${booking.currentCost.toStringAsFixed(2)} deducted from your Volt Wallet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Keep Charging', style: TextStyle(color: AppColors.tertiary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                appState.stopActiveChargingSession();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Session Ended. Cable unlocked. ₹${booking.currentCost.toStringAsFixed(2)} billed to Volt Wallet.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Stop & Unlock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabChip(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryTile(String title, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.secondary), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String energy,
    required String amount,
    required String status,
    required String passCode,
  }) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  Text('$date • Pass $passCode', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  Text(energy, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
