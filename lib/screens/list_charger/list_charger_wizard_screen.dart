import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';

class ListChargerWizardScreen extends StatefulWidget {
  const ListChargerWizardScreen({super.key});

  @override
  State<ListChargerWizardScreen> createState() => _ListChargerWizardScreenState();
}

class _ListChargerWizardScreenState extends State<ListChargerWizardScreen> {
  int _currentStep = 1;
  String _selectedBrand = 'Tata Power EZ Home';
  String _selectedConnector = 'Type 2 AC';
  String _selectedPower = '7.4 kW (Fast AC)';
  String _parkingType = 'Stilt Covered Bay';
  double _hourlyRate = 140.0;

  final Map<String, bool> _amenities = {
    'Covered Parking Roof': true,
    '24x7 CCTV Surveillance': true,
    'High-Speed Wi-Fi': true,
    'Restroom Access': false,
    'Drinking Water': true,
    'Gated Society Security': true,
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
        title: const Text(
          'List Your Charger',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Draft saved. You can finish listing anytime.')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save & Exit', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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
                // Step Progress Indicator
                Row(
                  children: [
                    _buildStepIndicator(1, 'Specs', _currentStep >= 1),
                    _buildStepLine(_currentStep >= 2),
                    _buildStepIndicator(2, 'Parking', _currentStep >= 2),
                    _buildStepLine(_currentStep >= 3),
                    _buildStepIndicator(3, 'Amenities', _currentStep >= 3),
                    _buildStepLine(_currentStep >= 4),
                    _buildStepIndicator(4, 'Pricing', _currentStep >= 4),
                  ],
                ),
                const SizedBox(height: 20),

                // Step 1: Equipment & Specs
                const Text(
                  '1. Select Charging Equipment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                const Text('Choose your certified wallbox hardware brand and connector standard', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Tata Power EZ Home',
                    'Exicom Spin Pro',
                    'ABB Terra AC',
                    'Ather Dot',
                    'Schneider EVlink',
                    'Delta AC Max',
                  ].map((brand) {
                    final bool isSel = _selectedBrand == brand;
                    return ChoiceChip(
                      label: Text(brand),
                      selected: isSel,
                      selectedColor: AppColors.primaryContainer.withOpacity(0.2),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? AppColors.primary : AppColors.onSurface,
                      ),
                      side: BorderSide(color: isSel ? AppColors.primary : Colors.black.withOpacity(0.08)),
                      onSelected: (_) => setState(() => _selectedBrand = brand),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Connector Type
                const Text('Connector Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildConnectorOption('Type 2 AC', 'Mennekes', Icons.power),
                    const SizedBox(width: 8),
                    _buildConnectorOption('CCS2 DC', 'Combined Fast', Icons.flash_on),
                    const SizedBox(width: 8),
                    _buildConnectorOption('15A 3-Pin', 'Industrial Plug', Icons.electrical_services),
                  ],
                ),
                const SizedBox(height: 18),

                // Power Output
                const Text('Power Output Rating', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPowerOption('3.3 kW (Slow)'),
                    const SizedBox(width: 8),
                    _buildPowerOption('7.4 kW (Fast AC)'),
                    const SizedBox(width: 8),
                    _buildPowerOption('11 kW (3-Phase)'),
                  ],
                ),
                const SizedBox(height: 24),

                // Step 2: Parking Space Setup
                const Text(
                  '2. Parking Bay Arrangement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildParkingRadio('Stilt Covered Bay', 'Independent ground floor roof with gated access'),
                      const Divider(height: 16),
                      _buildParkingRadio('Private Garage / Villa', 'Enclosed shutter with smart lock pin'),
                      const Divider(height: 16),
                      _buildParkingRadio('Dedicated Society Slot', 'Allocated apartment stilt bay with 24/7 security'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step 3: Amenities Available
                const Text(
                  '3. Amenities Available for Drivers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: _amenities.keys.map((key) {
                        return CheckboxListTile(
                          value: _amenities[key],
                          activeColor: AppColors.primary,
                          title: Text(key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() => _amenities[key] = val ?? false);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Step 4: Pricing Slider
                const Text(
                  '4. Set Hourly Charging Tariff',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
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
                          const Text('Your Hourly Rate', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                          Text(
                            '₹${_hourlyRate.toInt()} / hr',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                          value: _hourlyRate,
                          min: 80,
                          max: 250,
                          divisions: 17,
                          onChanged: (val) => setState(() => _hourlyRate = val),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.savings_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Estimated Monthly Earnings: ₹${(_hourlyRate * 4 * 30).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} at 4 hrs/day occupancy.',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
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

          // Sticky Publish Button
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
                    onPressed: () => _handlePublish(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Publish Charger Bay',
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

  void _handlePublish(BuildContext context) {
    final double powerKw = _selectedPower.contains('11')
        ? 11.0
        : (_selectedPower.contains('3.3') ? 3.3 : 7.4);

    final newStation = ChargerStation(
      id: 'host_bay_${DateTime.now().millisecondsSinceEpoch}',
      name: '$_selectedBrand Bay',
      hostName: 'Rajesh Sharma (You)',
      hostAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA9GvFZmwZhc4TjcwSkuatG7pJPgjmrce8IAYN4d2LeLpWFIBnfZa06KGvCT5oczJi4hEX_PIh4L6BtRoUCTTYl-7YLnDrvhHUCCoZpI1wzOwq0CdiR5zOj2rQRw48VrKPslnZzw4Y1EVC8oOryhtD5AtcNN-VHVcyZiTB-A2zaCPbJ79pRyaWoRfGwMMpU0HwHqMy-oG9ElcvGNvT9QDmqa8tUjt8QKqiFI-zOWQ8',
      hostRating: 5.0,
      hostReviews: 0,
      address: 'Indiranagar 100ft Road, HAL 2nd Stage',
      landmark: 'Near 100ft Metro & Toit',
      distanceKm: 0.9,
      driveTimeMinutes: 5,
      powerKw: powerKw,
      connectorType: _selectedConnector,
      tariffPerHour: _hourlyRate.toInt(),
      parkingFee: 0,
      bayType: _parkingType,
      isCovered: _amenities['Covered Parking Roof'] ?? true,
      hasCctv: _amenities['24x7 CCTV Surveillance'] ?? true,
      hasWifi: _amenities['High-Speed Wi-Fi'] ?? true,
      isSolar: true,
      isOpen: true,
      openUntil: '10:00 PM',
      isOnline: true,
      compatibleVehicles: ['Tata Nexon EV', 'Punch EV', 'MG ZS EV', 'Mahindra XUV400', 'Hyundai Ioniq 5'],
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c',
      ],
      mapX: 0.45,
      mapY: 150,
    );

    AppState().addHostStation(newStation);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Charger Published!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                '$_selectedBrand is now LIVE at ₹${_hourlyRate.toInt()}/hr on the Finder My Charger map network!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Back to My Chargers
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Go to Host Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDone ? Colors.white : AppColors.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDone ? AppColors.primary : AppColors.tertiary),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isDone ? AppColors.primary : AppColors.surfaceContainerHigh,
      ),
    );
  }

  Widget _buildConnectorOption(String label, String sub, IconData icon) {
    final bool isSel = _selectedConnector == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedConnector = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryContainer.withOpacity(0.18) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? AppColors.primary : Colors.black.withOpacity(0.08),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? AppColors.primary : AppColors.tertiary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? AppColors.primary : AppColors.onSurface),
                textAlign: TextAlign.center,
              ),
              Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.tertiary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerOption(String label) {
    final bool isSel = _selectedPower == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPower = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? AppColors.primary : Colors.black.withOpacity(0.08)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? Colors.white : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkingRadio(String title, String desc) {
    final bool isSel = _parkingType == title;
    return GestureDetector(
      onTap: () => setState(() => _parkingType = title),
      child: Row(
        children: [
          Icon(
            isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSel ? AppColors.primary : AppColors.tertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
