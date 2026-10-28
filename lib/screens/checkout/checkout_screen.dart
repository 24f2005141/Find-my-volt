import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../state/app_state.dart';
import '../main_scaffold.dart';

class CheckoutScreen extends StatefulWidget {
  final int hours;
  final int baseTariff;

  const CheckoutScreen({
    super.key,
    this.hours = 2,
    this.baseTariff = 280,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'wallet';
  final TextEditingController _promoController = TextEditingController(text: 'EVFIRST');
  double _appliedDiscount = 25.0;
  String _promoStatusMessage = 'Coupon "EVFIRST" active (₹25 OFF)';

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    setState(() {
      if (clean == 'EVFIRST') {
        _appliedDiscount = 25.0;
        _promoStatusMessage = 'Coupon "EVFIRST" active (₹25 OFF)';
      } else if (clean == 'GREEN50') {
        _appliedDiscount = 50.0;
        _promoStatusMessage = 'Mega Eco Discount "GREEN50" applied (₹50 OFF)';
      } else if (clean.isEmpty) {
        _appliedDiscount = 0.0;
        _promoStatusMessage = '';
      } else {
        _appliedDiscount = 0.0;
        _promoStatusMessage = 'Invalid promo code. Try "EVFIRST" or "GREEN50"';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final station = appState.selectedStation;
        final vehicle = appState.defaultVehicle;

        const double protectionFee = 14.0;
        final double total = (widget.baseTariff + protectionFee - _appliedDiscount).clamp(0.0, 99999.0);
        final bool canPayWithWallet = appState.walletBalance >= total;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Checkout & Confirmation',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.tertiary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment protected by 256-bit FMC Escrow Guarantee.'),
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
                    // Session Summary Card
                    GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      station.address,
                                      style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${station.powerKw} kW AC',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildSummaryRow(Icons.event, 'Date & Time', 'Today, ${DateTime.now().day} ${_monthName(DateTime.now().month)} • 12:00 - 02:00 PM (${widget.hours} hrs)'),
                          const SizedBox(height: 8),
                          _buildSummaryRow(Icons.directions_car, 'Vehicle', '${vehicle.make} ${vehicle.model} (${vehicle.regNumber})'),
                          const SizedBox(height: 8),
                          _buildSummaryRow(Icons.ev_station, 'Connector', '${station.connectorType} (${station.bayType})'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Promo Code Input Box
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.discount_outlined, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Promo Code (EVFIRST or GREEN50)',
                                    hintStyle: TextStyle(fontSize: 12, color: AppColors.tertiary),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (val) => _applyPromoCode(val),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _applyPromoCode(_promoController.text),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          if (_promoStatusMessage.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              _promoStatusMessage,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _appliedDiscount > 0 ? AppColors.primary : AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Cost Breakdown
                    const Text(
                      'Tariff & Charges',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _buildCostRow('Base Charging Tariff (${widget.hours} hrs @ ₹${station.tariffPerHour.toInt()})', '₹${widget.baseTariff}.00'),
                          const SizedBox(height: 6),
                          _buildCostRow('Parking Convenience Fee', station.parkingFee == 0 ? '₹0.00 (Free)' : '₹${station.parkingFee.toInt()}.00'),
                          const SizedBox(height: 6),
                          _buildCostRow('FMC Safety & Insurance', '₹${protectionFee.toStringAsFixed(2)}'),
                          if (_appliedDiscount > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Promo Code Discount', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                Text('-₹${_appliedDiscount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                              Text(
                                '₹${total.toStringAsFixed(0)}.00',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Payment Method
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),

                    // FMC Wallet Tile
                    GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == 'wallet'
                              ? AppColors.primaryContainer.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedPaymentMethod == 'wallet' ? AppColors.primary : Colors.black.withOpacity(0.08),
                            width: _selectedPaymentMethod == 'wallet' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'FMC Fast Wallet',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryFixed,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('INSTANT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Available: ₹${appState.walletBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: canPayWithWallet ? AppColors.tertiary : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!canPayWithWallet)
                              TextButton(
                                onPressed: () {
                                  appState.topUpWallet(500);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added ₹500 to FMC Fast Wallet!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Text('+₹500', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              )
                            else
                              Icon(
                                _selectedPaymentMethod == 'wallet' ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: _selectedPaymentMethod == 'wallet' ? AppColors.primary : AppColors.tertiary,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildPaymentTile(
                      id: 'upi',
                      title: 'UPI (GPay / PhonePe / Paytm)',
                      subtitle: 'Fast QR & UPI ID payment',
                      icon: Icons.qr_code,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentTile(
                      id: 'card',
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, RuPay',
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 18),

                    // Access PIN Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondaryContainer),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.lock_open, size: 20, color: AppColors.secondary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your 4-digit Smart Gate Pass Code will be activated instantly upon booking confirmation.',
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryTeal, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Confirm & Pay Button
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
                        onPressed: () => _handlePayment(context, appState, total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Confirm & Pay ₹${total.toStringAsFixed(0)}.00',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  void _handlePayment(BuildContext context, AppState appState, double total) {
    if (_selectedPaymentMethod == 'wallet' && appState.walletBalance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient wallet balance. Please top up or select UPI.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final station = appState.selectedStation;
    final vehicle = appState.defaultVehicle;

    // Create Booking in AppState
    appState.createBooking(
      stationId: station.id,
      stationName: station.name,
      hostName: station.hostName,
      vehicleName: '${vehicle.make} ${vehicle.model}',
      vehicleReg: vehicle.regNumber,
      durationHours: widget.hours,
      powerKw: station.powerKw,
      totalAmount: total,
    );

    final passCode = appState.activeBooking?.passCode ?? '#8492';

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
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Gate Access Pass $passCode Generated\n${station.name} (${widget.hours} hrs)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // close dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainScaffold(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View Live Session in Bookings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[(month - 1) % 12];
  }

  Widget _buildSummaryRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$title: ', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }

  Widget _buildPaymentTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
