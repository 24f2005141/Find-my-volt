import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../checkout/checkout_screen.dart';

class ReserveSlotScreen extends StatefulWidget {
  const ReserveSlotScreen({super.key});

  @override
  State<ReserveSlotScreen> createState() => _ReserveSlotScreenState();
}

class _ReserveSlotScreenState extends State<ReserveSlotScreen> {
  int _selectedDateIndex = 0;
  final Set<int> _selectedSlotIndices = {2, 3}; // 12:00 PM and 01:00 PM
  double _targetSoc = 85.0;

  late final List<Map<String, String>> _dates = _generateUpcomingDates();

  static List<Map<String, String>> _generateUpcomingDates() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(5, (index) {
      final date = now.add(Duration(days: index));
      final dayLabel = index == 0 ? 'Today' : days[date.weekday - 1];
      final dateLabel = '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
      return {'day': dayLabel, 'date': dateLabel};
    });
  }

  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 - 10:00 AM', 'status': 'past'},
    {'time': '10:00 - 11:00 AM', 'status': 'booked'},
    {'time': '11:00 - 12:00 PM', 'status': 'available'},
    {'time': '12:00 - 01:00 PM', 'status': 'available'},
    {'time': '01:00 - 02:00 PM', 'status': 'available'},
    {'time': '02:00 - 03:00 PM', 'status': 'available'},
    {'time': '03:00 - 04:00 PM', 'status': 'available'},
    {'time': '04:00 - 05:00 PM', 'status': 'peak'},
    {'time': '05:00 - 06:00 PM', 'status': 'available'},
  ];

  void _showChangeVehicleSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Vehicle from Garage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              const Text(
                'Power draw and range estimation adapt to vehicle battery specs',
                style: TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 16),
              ...appState.vehicles.map((v) {
                final isSelected = v.id == appState.defaultVehicle.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer.withOpacity(0.12) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: AppColors.primary),
                    title: Text('${v.make} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${v.regNumber} • ${v.batteryCapacityKwh} kWh • ${v.currentSoc.toInt()}% SoC'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : TextButton(
                            onPressed: () {
                              appState.setDefaultVehicle(v.id);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Select', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final station = appState.selectedStation;
        final vehicle = appState.defaultVehicle;

        final int hoursSelected = max(1, _selectedSlotIndices.length);
        final int totalTariff = hoursSelected * station.tariffPerHour.toInt();
        final double energyDelivered = hoursSelected * station.powerKw;
        final double socGained = min(100.0, vehicle.currentSoc + (energyDelivered / vehicle.batteryCapacityKwh) * 100);
        final int rangeGainedKm = (energyDelivered * 7.5).toInt();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reserve Charging Slot',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                Text(
                  '${station.name} • ${station.address}',
                  style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.tertiary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Need help? Find My Volt 24/7 host booking support is active.'),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Card
                    GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_car, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.make} ${vehicle.model}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                ),
                                Text(
                                  '${vehicle.regNumber} • ${vehicle.currentSoc.toInt()}% Current Battery',
                                  style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showChangeVehicleSheet(context, appState),
                            child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Date Picker
                    const Text(
                      'Select Date',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_dates.length, (index) {
                          final item = _dates[index];
                          final bool isSelected = _selectedDateIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDateIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 68,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.06),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      item['day']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white70 : AppColors.tertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['date']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hourly Slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Time Slots',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text(
                          '${_selectedSlotIndices.length} hrs selected',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_slots.length, (index) {
                        final slot = _slots[index];
                        final String status = slot['status'] as String;
                        final bool isBooked = status == 'booked';
                        final bool isPast = status == 'past';
                        final bool isPeak = status == 'peak';
                        final bool isSelected = _selectedSlotIndices.contains(index);

                        Color bgColor;
                        Color textColor;
                        Color borderColor;

                        if (isPast || isBooked) {
                          bgColor = AppColors.surfaceContainer;
                          textColor = AppColors.tertiary;
                          borderColor = Colors.transparent;
                        } else if (isSelected) {
                          bgColor = AppColors.primary;
                          textColor = Colors.white;
                          borderColor = AppColors.primary;
                        } else {
                          bgColor = Colors.white;
                          textColor = AppColors.onSurface;
                          borderColor = isPeak ? AppColors.warning.withOpacity(0.5) : Colors.black.withOpacity(0.08);
                        }

                        return GestureDetector(
                          onTap: (isPast || isBooked)
                              ? null
                              : () {
                                  setState(() {
                                    if (_selectedSlotIndices.contains(index)) {
                                      if (_selectedSlotIndices.length > 1) {
                                        _selectedSlotIndices.remove(index);
                                      }
                                    } else {
                                      _selectedSlotIndices.add(index);
                                    }
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  slot['time'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                if (isBooked) ...[
                                  const SizedBox(width: 4),
                                  const Text('(Full)', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
                                ],
                                if (isPeak && !isSelected) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.bolt, size: 12, color: AppColors.warning),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Target SoC & Range Estimator
                    const Text(
                      'Target SoC & Charging Estimation',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Target Battery Charge', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                              Text(
                                '${_targetSoc.toInt()}%',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.surfaceContainerHigh,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primaryContainer.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _targetSoc,
                              min: 50,
                              max: 100,
                              divisions: 10,
                              onChanged: (val) => setState(() => _targetSoc = val),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSessionEstimateTile(
                                  icon: Icons.electric_bolt,
                                  title: 'Est. Energy',
                                  value: '${energyDelivered.toStringAsFixed(1)} kWh',
                                ),
                                Container(width: 1, height: 28, color: Colors.black.withOpacity(0.08)),
                                _buildSessionEstimateTile(
                                  icon: Icons.battery_charging_full,
                                  title: 'Est. SoC Gain',
                                  value: '+${(socGained - vehicle.currentSoc).toInt()}% (${socGained.toInt()}%)',
                                ),
                                Container(width: 1, height: 28, color: Colors.black.withOpacity(0.08)),
                                _buildSessionEstimateTile(
                                  icon: Icons.add_road,
                                  title: 'Range Added',
                                  value: '+$rangeGainedKm km',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Bar
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
                              '₹$totalTariff',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '$hoursSelected Hours Session',
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
                                    builder: (_) => CheckoutScreen(
                                      hours: hoursSelected,
                                      baseTariff: totalTariff,
                                    ),
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
                              icon: const Icon(Icons.arrow_forward, size: 20),
                              label: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildSessionEstimateTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }
}
