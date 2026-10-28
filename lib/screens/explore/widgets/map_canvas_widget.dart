import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MapCanvasWidget extends StatelessWidget {
  final String selectedPin;
  final ValueChanged<String> onPinSelected;

  const MapCanvasWidget({
    super.key,
    required this.selectedPin,
    required this.onPinSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Custom Painted Vector Map
            Positioned.fill(
              child: CustomPaint(
                painter: _IndiranagarMapPainter(),
              ),
            ),

            // Live User Location (Indiranagar 12th Main)
            Positioned(
              left: constraints.maxWidth * 0.44,
              top: 260,
              child: const _UserGpsMarker(),
            ),

            // Pin 1: Nexus 60kW Fast Hub
            Positioned(
              left: 30,
              top: 130,
              child: _buildStationPin(
                id: 'nexus',
                label: 'Nexus 60kW',
                sublabel: '₹21',
                dotColor: AppColors.primary,
                isSelected: selectedPin == 'nexus',
              ),
            ),

            // Pin 2: Koramangala Community Charger
            Positioned(
              right: 30,
              top: 100,
              child: _buildStationPin(
                id: 'koramangala',
                label: '11 kW AC',
                sublabel: '',
                icon: Icons.ev_station,
                dotColor: AppColors.secondary,
                isSelected: selectedPin == 'koramangala',
              ),
            ),

            // Pin 3: Clustered Badge - Prestige Ozone
            Positioned(
              left: 45,
              top: 310,
              child: GestureDetector(
                onTap: () => onPinSelected('prestige_ozone'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: selectedPin == 'prestige_ozone' ? AppColors.primary : AppColors.inverseSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Prestige',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '11kW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Active Highlight Pin: Sharma Villa P2P Charger
            Positioned(
              left: constraints.maxWidth * 0.52 - 65,
              top: 180,
              child: GestureDetector(
                onTap: () => onPinSelected('sharma_villa'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryContainer.withOpacity(0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: AppColors.primaryFixed,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '₹140/hr',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                '7.4 kW • Covered',
                                style: TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: const Size(12, 8),
                      painter: _PinTrianglePainter(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStationPin({
    required String id,
    required String label,
    required String sublabel,
    required Color dotColor,
    required bool isSelected,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () => onPinSelected(id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, size: 13, color: dotColor)
                else
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sublabel.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: _PinTrianglePainter(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UserGpsMarker extends StatelessWidget {
  const _UserGpsMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(10, 8),
          painter: _HeadingConePainter(),
        ),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.secondaryTeal,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryTeal.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadingConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.secondaryTeal;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IndiranagarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Green Parks & Open spaces
    final parkPaint = Paint()
      ..color = const Color(0xFFD7ECD9).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final parkPath1 = Path()
      ..moveTo(-10, 50)
      ..quadraticBezierTo(40, 30, 80, 80)
      ..quadraticBezierTo(120, 160, 20, 170)
      ..close();
    canvas.drawPath(parkPath1, parkPaint);

    final parkPath2 = Path()
      ..moveTo(size.width * 0.65, 20)
      ..quadraticBezierTo(size.width * 0.8, 10, size.width * 0.95, 40)
      ..lineTo(size.width, 130)
      ..lineTo(size.width * 0.72, 120)
      ..close();
    canvas.drawPath(parkPath2, parkPaint);

    // Metro Line (Purple Line elevated track)
    final metroRailPaint = Paint()
      ..color = const Color(0xFF7E57C2).withOpacity(0.8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final metroPath = Path()
      ..moveTo(-20, 160)
      ..lineTo(size.width + 20, 160);
    canvas.drawPath(metroPath, metroRailPaint);

    // Metro station dot
    final stationDotPaint = Paint()..color = Colors.white;
    final stationOutlinePaint = Paint()
      ..color = const Color(0xFF7E57C2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width * 0.52, 160), 4.5, stationDotPaint);
    canvas.drawCircle(Offset(size.width * 0.52, 160), 4.5, stationOutlinePaint);

    // Roads (Main 100ft road and cross avenues)
    final roadCasingPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadFillPaint = Paint()
      ..color = const Color(0xFFD1D8DF)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // 100 Ft Road
    final road100Ft = Path()
      ..moveTo(size.width * 0.58, -20)
      ..lineTo(size.width * 0.52, size.height + 20);
    canvas.drawPath(road100Ft, roadCasingPaint);
    canvas.drawPath(road100Ft, roadFillPaint);

    // Cross roads
    final crossRoadPaintCasing = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;

    final crossRoadPaintFill = Paint()
      ..color = const Color(0xFFD7DEE5)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final crossRoad1 = Path()
      ..moveTo(-20, 240)
      ..lineTo(size.width + 20, 220);
    canvas.drawPath(crossRoad1, crossRoadPaintCasing);
    canvas.drawPath(crossRoad1, crossRoadPaintFill);

    final crossRoad2 = Path()
      ..moveTo(-20, 320)
      ..lineTo(size.width + 20, 300);
    canvas.drawPath(crossRoad2, crossRoadPaintCasing);
    canvas.drawPath(crossRoad2, crossRoadPaintFill);

    // Active Route Path from user to Sharma Villa
    final routeUnderlayPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routeDashPaint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.44 + 12, 260 + 12)
      ..quadraticBezierTo(
        size.width * 0.46,
        225,
        size.width * 0.52,
        195,
      );
    canvas.drawPath(routePath, routeUnderlayPaint);
    canvas.drawPath(routePath, routeDashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
