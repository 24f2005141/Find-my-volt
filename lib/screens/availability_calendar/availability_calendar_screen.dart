import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() => _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState extends State<AvailabilityCalendarScreen> {
  int _scheduleMode = 0; // 0: Weekly recurring, 1: Specific dates
  bool _instantBooking = true;
  bool _dynamicPricing = true;

  final Map<String, Map<String, dynamic>> _weekSchedule = {
    'Monday': {'enabled': true, 'hours': '08:00 AM - 08:00 PM'},
    'Tuesday': {'enabled': true, 'hours': '08:00 AM - 08:00 PM'},
    'Wednesday': {'enabled': true, 'hours': '08:00 AM - 08:00 PM'},
    'Thursday': {'enabled': true, 'hours': '08:00 AM - 08:00 PM'},
    'Friday': {'enabled': true, 'hours': '08:00 AM - 08:00 PM'},
    'Saturday': {'enabled': true, 'hours': '06:00 AM - 10:00 PM'},
    'Sunday': {'enabled': true, 'hours': '06:00 AM - 10:00 PM'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Availability & Scheduling',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            Text(
              'Sharma Villa Stilt Bay (Host Mode)',
              style: TextStyle(fontSize: 11, color: AppColors.tertiary),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Schedule Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _scheduleMode = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _scheduleMode == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _scheduleMode == 0
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Weekly Schedule',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _scheduleMode == 0 ? AppColors.onSurface : AppColors.tertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _scheduleMode = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _scheduleMode == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _scheduleMode == 1
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Blockout Dates',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _scheduleMode == 1 ? AppColors.onSurface : AppColors.tertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (_scheduleMode == 0) ...[
                  // Weekly Schedule Matrix
                  const Text(
                    'Operating Hours by Day',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: _weekSchedule.keys.map((day) {
                        final item = _weekSchedule[day]!;
                        final bool isEnabled = item['enabled'];
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Switch(
                                        value: isEnabled,
                                        activeThumbColor: AppColors.primary,
                                        onChanged: (val) {
                                          setState(() => item['enabled'] = val);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          day,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isEnabled ? AppColors.onSurface : AppColors.tertiary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isEnabled ? AppColors.primaryContainer.withOpacity(0.16) : AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isEnabled ? item['hours'] : 'Closed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isEnabled ? AppColors.primary : AppColors.tertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (day != 'Sunday') const Divider(height: 12),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  // Specific Blockout Dates
                  const Text(
                    'Blockout Specific Dates',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_today, size: 40, color: AppColors.secondary),
                        const SizedBox(height: 10),
                        const Text(
                          'No Blockout Dates Set',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your charger bay is currently open according to your recurring weekly schedule.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.tertiary),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select dates from calendar to mark holiday/vacation.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Vacation Dates'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Host Preference Toggles
                const Text(
                  'Smart Booking Preferences',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _instantBooking,
                          activeThumbColor: AppColors.primary,
                          title: const Text('Instant Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Allow verified EV drivers to book available slots automatically without waiting for manual confirmation.',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _instantBooking = val),
                        ),
                        const Divider(height: 16),
                        SwitchListTile(
                          value: _dynamicPricing,
                          activeThumbColor: AppColors.primary,
                          title: const Text('Dynamic Peak Hour Pricing (+20%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Automatically apply +20% rate during peak EV demand hours (6:00 PM - 10:00 PM).',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _dynamicPricing = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Save Button
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
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Availability Schedule Updated Successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Save Schedule Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
