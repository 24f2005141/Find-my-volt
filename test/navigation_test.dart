import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_volt/main.dart';
import 'package:find_my_volt/state/app_state.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  void close({bool force = false}) {}
  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  static const List<int> _transparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82
  ];

  @override
  Stream<List<int>> asBroadcastStream({void Function(StreamSubscription<List<int>> subscription)? onListen, void Function(StreamSubscription<List<int>> subscription)? onCancel}) =>
      Stream.value(_transparentImage).asBroadcastStream();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream.value(_transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    AppState.enableRealtimeTimer = false;
    AppState().stopSimulation();
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Complete end-to-end navigation test across all 10 screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      AppState().stopSimulation();
    });

    await tester.pumpWidget(const FindMyVoltApp());
    await tester.pumpAndSettle();

    // 0. Verify Initial Screen: Login Screen (Auth First requirement)
    expect(find.text('Find My Volt'), findsOneWidget);
    expect(find.text('Sign In / Register'), findsOneWidget);

    // Sign in via quick demo button
    await tester.tap(find.text('Sign In as Vikram (Tata Nexon EV Driver)'));
    await tester.pumpAndSettle();

    // 1. Verify Initial Screen: Explore Map
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('12th Main Road'), findsOneWidget);
    expect(find.text('Sharma Villa P2P Charger'), findsOneWidget);

    // 2. Navigate to Bookings Tab
    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('My Bookings'), findsWidgets);
    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('Completed (2)'), findsOneWidget);

    // 3. Navigate to Chargers Tab
    await tester.tap(find.text('Chargers'));
    await tester.pumpAndSettle();
    expect(find.text('My Chargers'), findsWidgets);
    expect(find.text('Monetize Your Parking'), findsOneWidget);
    expect(find.text('Sharma Villa P2P Charger'), findsWidgets);

    // 4. Navigate to Earnings Tab
    await tester.tap(find.text('Earnings'));
    await tester.pumpAndSettle();
    expect(find.text('Earnings & Analytics'), findsWidgets);
    expect(find.text('₹18,420.00'), findsOneWidget);

    // 5. Navigate to Profile Tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Vikramaditya Rao'), findsOneWidget);
    expect(find.text('FMC Fast Wallet'), findsOneWidget);
    expect(find.text('Tata Nexon EV Max'), findsWidgets);

    // 6. Navigate back to Explore Tab
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    // 7. Open Charger Details Screen by tapping "Sharma Villa P2P Charger"
    await tester.tap(find.text('Sharma Villa P2P Charger').first);
    await tester.pumpAndSettle();
    expect(find.text('Charger Details'), findsOneWidget);
    expect(find.text('Rajesh Sharma'), findsOneWidget);
    expect(find.text('Vehicle Compatibility'), findsOneWidget);
    expect(find.text('Pricing Breakdown'), findsOneWidget);

    // 8. Open Reserve Slot Screen by tapping "Select Slot & Reserve"
    await tester.tap(find.text('Select Slot & Reserve'));
    await tester.pumpAndSettle();
    expect(find.text('Reserve Charging Slot'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Available Time Slots'), findsOneWidget);

    // 9. Open Checkout Screen by tapping "Proceed to Checkout"
    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Checkout & Confirmation'), findsOneWidget);
    expect(find.text('FMC Fast Wallet'), findsOneWidget);

    // 10. Confirm & Pay
    await tester.tap(find.textContaining('Confirm & Pay'));
    await tester.pumpAndSettle();
    expect(find.text('Booking Confirmed!'), findsOneWidget);

    // Close confirmation dialog and view active session
    await tester.tap(find.text('View Live Session in Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('My Bookings'), findsWidgets);

    // 11. Test Host Mode Flow: My Chargers -> List a Charger Wizard
    await tester.tap(find.text('Chargers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('List a New Charger Bay'));
    await tester.pumpAndSettle();
    expect(find.text('List Your Charger'), findsOneWidget);
    expect(find.text('1. Select Charging Equipment'), findsOneWidget);

    // Publish charger from wizard
    await tester.tap(find.text('Publish Charger Bay'));
    await tester.pumpAndSettle();
    expect(find.text('Charger Published!'), findsOneWidget);
    await tester.tap(find.text('Go to Host Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('My Chargers'), findsWidgets);

    // 12. Test Availability Calendar Flow
    await tester.tap(find.text('Calendar & Slots').first);
    await tester.pumpAndSettle();
    expect(find.text('Availability & Scheduling'), findsOneWidget);
    expect(find.text('Operating Hours by Day'), findsOneWidget);
    await tester.tap(find.text('Save Schedule Changes'));
    await tester.pumpAndSettle();
    expect(find.text('My Chargers'), findsWidgets);
  });
}
