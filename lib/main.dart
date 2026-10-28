import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_scaffold.dart';
import 'screens/charger_details/charger_details_screen.dart';
import 'screens/reserve_slot/reserve_slot_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/list_charger/list_charger_wizard_screen.dart';
import 'screens/availability_calendar/availability_calendar_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FindMyVoltApp());
}

class FindMyVoltApp extends StatelessWidget {
  const FindMyVoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find My Volt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) => const MainScaffold(),
        '/home': (context) => const MainScaffold(),
        '/charger-details': (context) => const ChargerDetailsScreen(),
        '/reserve-slot': (context) => const ReserveSlotScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/list-charger': (context) => const ListChargerWizardScreen(),
        '/availability-calendar': (context) => const AvailabilityCalendarScreen(),
      },
    );
  }
}
