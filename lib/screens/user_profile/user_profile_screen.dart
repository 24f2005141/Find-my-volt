import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _autoUnlock = true;
  bool _prioritizeSolar = true;
  bool _pushNotifications = true;

  void _showTopUpSheet(BuildContext context, AppState appState) {
    double selectedAmount = 500;
    final customController = TextEditingController(text: '500');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top Up FMC Fast Wallet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: AppColors.tertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current balance: ₹${appState.walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                  ),
                  const SizedBox(height: 16),

                  // Amount quick chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [200, 500, 1000, 2000].map((amt) {
                      final bool isSel = selectedAmount == amt.toDouble();
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedAmount = amt.toDouble();
                            customController.text = '$amt';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.primary : Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            '+₹$amt',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      labelStyle: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      setSheetState(() {
                        selectedAmount = parsed;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (selectedAmount > 0) {
                          appState.topUpWallet(selectedAmount);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('₹${selectedAmount.toInt()} successfully added to FMC Fast Wallet!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.flash_on, size: 18),
                      label: Text(
                        'Add ₹${selectedAmount.toStringAsFixed(0)} Instantly',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
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

  void _showAddVehicleSheet(BuildContext context, AppState appState) {
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final regController = TextEditingController();
    final kwhController = TextEditingController(text: '40.5');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add EV to Your Garage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close, color: AppColors.tertiary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure your vehicle specs for automated telemetry & connector checks',
                style: TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: makeController,
                      decoration: InputDecoration(
                        labelText: 'Make (e.g. Tata, MG, Kia)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: modelController,
                      decoration: InputDecoration(
                        labelText: 'Model (e.g. EV6, Punch EV)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: regController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Reg Plate (e.g. KA 05 EV 1234)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: kwhController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Battery kWh',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final make = makeController.text.trim();
                    final model = modelController.text.trim();
                    final reg = regController.text.trim();
                    final kwh = double.tryParse(kwhController.text.trim()) ?? 40.0;

                    if (make.isNotEmpty && model.isNotEmpty && reg.isNotEmpty) {
                      final newCar = Vehicle(
                        id: 'car_${DateTime.now().millisecondsSinceEpoch}',
                        make: make,
                        model: model,
                        regNumber: reg,
                        batteryCapacityKwh: kwh,
                        currentSoc: 75.0,
                        maxAcSpeedKw: 7.4,
                        maxDcSpeedKw: 50.0,
                        isDefault: false,
                      );
                      appState.addVehicle(newCar);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$make $model successfully added to EV Garage!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all vehicle details.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Vehicle to Garage', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
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
        final vehicles = appState.vehicles;
        final walletBalance = appState.walletBalance;
        final user = appState.currentUser;

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
                            'User Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'EV Garage & Smart Preferences',
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
                            content: Text('App Settings & Preferences (v2.4.0)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Profile Header Card
                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryContainer,
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child: user.avatarUrl.isNotEmpty
                                  ? Image.network(
                                      user.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.secondaryFixed,
                                        child: Center(
                                          child: Text(
                                            user.name.isNotEmpty ? user.name[0] : 'U',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.secondaryFixed,
                                      child: Center(
                                        child: Text(
                                          user.name.isNotEmpty ? user.name[0] : 'U',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.phone} • ${user.email}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.energy_savings_leaf, size: 13, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${user.totalChargingSessions} Trips • ${(user.totalChargingSessions * 20)} kg CO2 Offset',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // FMC Fast Wallet Bento Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF146964), Color(0xFF006E28)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
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
                            'FMC Fast Wallet',
                            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          Icon(Icons.contactless, color: Colors.white70, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showTopUpSheet(context, appState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Auto-Recharge is enabled when balance falls below ₹200')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Auto-Recharge: ON', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // My EV Garage Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My EV Garage (${vehicles.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddVehicleSheet(context, appState),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
                      label: const Text('Add Vehicle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...vehicles.map((v) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildGarageCard(
                      vehicle: v,
                      onTap: () {
                        appState.setDefaultVehicle(v.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${v.make} ${v.model} is now your primary charging EV.'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // EV Charging Preferences
                const Text(
                  'EV Smart Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _autoUnlock,
                          activeThumbColor: AppColors.primary,
                          title: const Text('Auto-Unlock Cable at 100%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Release wallbox connector latch when battery hits 100% to avoid idle fees.',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _autoUnlock = val),
                        ),
                        const Divider(height: 16),
                        SwitchListTile(
                          value: _prioritizeSolar,
                          activeThumbColor: AppColors.primary,
                          title: const Text('Prioritize Rooftop Solar Charging', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Favor P2P hosts generating rooftop solar power for greener net metering.',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _prioritizeSolar = val),
                        ),
                        const Divider(height: 16),
                        SwitchListTile(
                          value: _pushNotifications,
                          activeThumbColor: AppColors.primary,
                          title: const Text('Live Session Telemetry Push', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                            'Notify at 50%, 80%, and full charge completion with invoice summary.',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account & Security Options
                const Text(
                  'Account & Security',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        _buildAccountOption(Icons.payment, 'Payment Methods & Cards', 'HDFC Credit Card ending in 4102'),
                        const Divider(height: 1),
                        _buildAccountOption(Icons.nfc, 'FMC Tap-to-Charge RFID Card', 'Linked: Active (Card #88921)'),
                        const Divider(height: 1),
                        _buildAccountOption(Icons.verified_user_outlined, 'KYC & Driver Verification', 'Aadhaar & DL Verified'),
                        const Divider(height: 1),
                        _buildAccountOption(Icons.help_center_outlined, 'FMC Help Center & FAQ', '24x7 Driver & Host Support Desk'),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: AppColors.error),
                          title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Signed in as ${user.name} (${user.phone})', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                          onTap: () {
                            appState.logout();
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGarageCard({
    required Vehicle vehicle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: vehicle.isDefault ? AppColors.primaryContainer.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: vehicle.isDefault ? AppColors.primary : Colors.black.withOpacity(0.06),
            width: vehicle.isDefault ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: vehicle.isDefault ? AppColors.primary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_car, color: vehicle.isDefault ? Colors.white : AppColors.tertiary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      if (vehicle.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('DEFAULT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(vehicle.regNumber, style: const TextStyle(fontSize: 11, color: AppColors.tertiary, fontWeight: FontWeight.w600)),
                  Text(
                    '${vehicle.batteryCapacityKwh} kWh • ${vehicle.currentSoc.toInt()}% SoC (AC: ${vehicle.maxAcSpeedKw} kW • DC: ${vehicle.maxDcSpeedKw.toInt()} kW)',
                    style: const TextStyle(fontSize: 10, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            Icon(
              vehicle.isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: vehicle.isDefault ? AppColors.primary : AppColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title details'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
