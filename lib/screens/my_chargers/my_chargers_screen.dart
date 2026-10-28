import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../list_charger/list_charger_wizard_screen.dart';
import '../availability_calendar/availability_calendar_screen.dart';

class MyChargersScreen extends StatefulWidget {
  const MyChargersScreen({super.key});

  @override
  State<MyChargersScreen> createState() => _MyChargersScreenState();
}

class _MyChargersScreenState extends State<MyChargersScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final hostStations = appState.stations.where((s) {
          return s.id == 'sharma_villa' || s.id.startsWith('host_bay_') || s.hostName.contains('Sharma') || s.hostName.contains('You');
        }).toList();

        final hostRequests = appState.hostRequests;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'My Chargers',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Host Dashboard & Bay Operations',
                            style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        appState.toggleHostMode(!appState.hostModeActive);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(appState.hostModeActive ? 'Host Mode Enabled' : 'Host Mode Paused'),
                            duration: const Duration(milliseconds: 1000),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: appState.hostModeActive
                              ? AppColors.primaryContainer.withOpacity(0.2)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: appState.hostModeActive ? AppColors.primary : AppColors.tertiary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: appState.hostModeActive ? AppColors.primary : AppColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              appState.hostModeActive ? 'Host Mode: ON' : 'Host Mode: OFF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: appState.hostModeActive ? AppColors.primary : AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Hero Monetize Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00531C), Color(0xFF146964)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Monetize Your Parking',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Icon(Icons.bolt, color: AppColors.primaryFixed, size: 28),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Earn up to ₹15,000/month by sharing your home EV charger with verified EV drivers in Bengaluru.',
                        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ListChargerWizardScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text(
                            'List a New Charger Bay',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Host Overview Stats Bento Grid
                Row(
                  children: [
                    _buildStatTile(
                      title: 'October Earnings',
                      value: '₹${appState.hostMonthlyEarnings.toStringAsFixed(0)}',
                      delta: '+18% vs Sep',
                      isPositive: true,
                      icon: Icons.currency_rupee,
                    ),
                    const SizedBox(width: 10),
                    _buildStatTile(
                      title: 'Total Sessions',
                      value: '${appState.hostTotalSessions}',
                      delta: '98% completed',
                      isPositive: true,
                      icon: Icons.ev_station,
                    ),
                    const SizedBox(width: 10),
                    _buildStatTile(
                      title: 'Host Rating',
                      value: '${appState.hostRating} ★',
                      delta: 'Top 5% Host',
                      isPositive: true,
                      icon: Icons.verified_user,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Bay Units
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Bay Units (${hostStations.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const Text(
                      'Auto-accept: ON',
                      style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ...hostStations.map((station) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.garage, color: AppColors.primary, size: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            station.name,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${station.powerKw} kW AC • ${station.connectorType}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: station.isOnline,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  appState.toggleStationOnline(station.id, val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(val ? '${station.name} is now ONLINE' : '${station.name} is paused (OFFLINE)'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(milliseconds: 1200),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBayDetail('Tariff', '₹${station.tariffPerHour.toInt()} / hr'),
                              _buildBayDetail('Status', station.isOnline ? 'Online & Free' : 'Paused'),
                              _buildBayDetail('Bay Type', station.bayType),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AvailabilityCalendarScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.secondary.withOpacity(0.35)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.calendar_month, size: 16, color: AppColors.secondary),
                                  label: const Text(
                                    'Calendar & Slots',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Displaying smart QR check-in placard for ${station.name}...'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.black.withOpacity(0.1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.qr_code_2, size: 16, color: AppColors.onSurface),
                                  label: const Text(
                                    'Smart QR Code',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Upcoming Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Driver Requests (${hostRequests.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (hostRequests.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                    ),
                    child: const Center(
                      child: Text('No pending driver booking requests right now.', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                    ),
                  )
                else
                  ...hostRequests.map((req) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.secondaryFixed,
                                  child: Text(
                                    req.driverName.substring(0, 1),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.driverName,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${req.vehicleModel} • ${req.slotTime}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${req.amount.toInt()}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      appState.declineHostRequest(req.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Request from ${req.driverName} declined.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.black.withOpacity(0.1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Decline', style: TextStyle(color: AppColors.tertiary, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      appState.acceptHostRequest(req.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Request Approved! Access pin sent to ${req.driverName}. ₹${req.amount.toInt()} credited!'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Accept Booking', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String delta,
    required bool isPositive,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                Text(
                  delta,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.secondary : AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBayDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }
}
