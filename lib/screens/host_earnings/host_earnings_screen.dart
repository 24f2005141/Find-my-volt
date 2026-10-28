import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';

class HostEarningsScreen extends StatefulWidget {
  const HostEarningsScreen({super.key});

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> {
  int _selectedMetric = 0; // 0: Revenue, 1: Energy, 2: Occupancy

  final List<double> _revenueData = [5400, 6800, 7150, 5500];
  final List<double> _energyData = [240, 310, 380, 310];
  final List<double> _occupancyData = [65, 78, 85, 72];
  final List<String> _weekLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final recentTransactions = appState.hostRecentTransactions;
        final totalPayout = appState.hostMonthlyEarnings;
        final totalSessions = appState.hostTotalSessions;

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
                            'Earnings & Analytics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Automated Payouts & Grid Telemetry',
                            style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading Oct 2026 Host Earnings Statement (PDF)...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.secondary),
                      tooltip: 'Export Statement',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Net Earnings Highlight Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF006E28), Color(0xFF146964)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total October Payout',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.trending_up, color: AppColors.primaryFixed, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '+18.4%',
                                  style: TextStyle(color: AppColors.primaryFixed, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalPayout.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.account_balance, color: AppColors.secondaryFixed, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Auto-deposit to HDFC Bank (A/C **4102) on Nov 01, 2026',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Metric Tabs: Revenue | Energy | Occupancy
                Row(
                  children: [
                    _buildMetricTab(0, 'Revenue', Icons.currency_rupee),
                    const SizedBox(width: 8),
                    _buildMetricTab(1, 'Energy (kWh)', Icons.bolt),
                    const SizedBox(width: 8),
                    _buildMetricTab(2, 'Occupancy', Icons.pie_chart_outline),
                  ],
                ),
                const SizedBox(height: 14),

                // Interactive Chart Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Weekly Performance',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                          Text(
                            'Oct 01 - Oct 28, 2026',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Custom Bar Chart
                      SizedBox(
                        height: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_weekLabels.length, (index) {
                            double val;
                            double maxVal;
                            String labelText;

                            if (_selectedMetric == 0) {
                              val = _revenueData[index];
                              maxVal = 8000;
                              labelText = '₹${(val / 1000).toStringAsFixed(1)}k';
                            } else if (_selectedMetric == 1) {
                              val = _energyData[index];
                              maxVal = 400;
                              labelText = '${val.toInt()} kWh';
                            } else {
                              val = _occupancyData[index];
                              maxVal = 100;
                              labelText = '${val.toInt()}%';
                            }

                            final double heightPct = (val / maxVal).clamp(0.1, 1.0);
                            final bool isPeak = index == 2;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  labelText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPeak ? AppColors.primary : AppColors.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 38,
                                  height: 100 * heightPct,
                                  decoration: BoxDecoration(
                                    color: isPeak ? AppColors.primary : AppColors.primaryContainer.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _weekLabels[index],
                                  style: const TextStyle(fontSize: 10, color: AppColors.tertiary),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // KPI Grid
                Row(
                  children: [
                    _buildKpiCard('Total Energy Dispensed', '1,240 kWh', '82% Rooftop Solar', Icons.solar_power),
                    const SizedBox(width: 10),
                    _buildKpiCard('Completed Sessions', '$totalSessions Sessions', 'Avg 1h 50m / session', Icons.ev_station),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildKpiCard('Avg Bay Occupancy', '74% Daylight', 'Peak 2:00 - 7:00 PM', Icons.pie_chart),
                    const SizedBox(width: 10),
                    _buildKpiCard('CO2 Emissions Saved', '1,040 kg', 'Equivalent to 52 trees', Icons.energy_savings_leaf),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Charger Bays
                const Text(
                  'Active Charger Bays',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 10),
                _buildBayRow('Sharma Villa Stilt Bay (Indiranagar)', '₹${(totalPayout * 0.78).toStringAsFixed(2)}', '${(totalSessions * 0.7).toInt()} sessions • 7.4 kW AC'),
                const SizedBox(height: 8),
                _buildBayRow('Whitefield Tech Park Annexe', '₹${(totalPayout * 0.22).toStringAsFixed(2)}', '${(totalSessions * 0.3).toInt()} sessions • 11 kW AC'),
                const SizedBox(height: 24),

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions (${recentTransactions.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const Text(
                      'Live Sync',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ...recentTransactions.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTransactionCard(
                      tx['driver'] ?? '',
                      tx['meta'] ?? '',
                      tx['amount'] ?? '',
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

  Widget _buildMetricTab(int index, String label, IconData icon) {
    final bool isSelected = _selectedMetric == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMetric = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.tertiary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String sub, IconData icon) {
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
                Icon(icon, size: 18, color: AppColors.secondary),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.tertiary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.tertiary), overflow: TextOverflow.ellipsis),
            Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildBayRow(String name, String earnings, String sub) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.ev_station, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ],
          ),
          Text(earnings, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(String driver, String meta, String amount) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondaryFixed,
                child: Icon(Icons.person, color: AppColors.secondary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  Text(meta, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
