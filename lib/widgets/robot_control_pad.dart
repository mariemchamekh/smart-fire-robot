import 'package:flutter/material.dart';

class RobotControlPad extends StatelessWidget {
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final VoidCallback? onCenter;
  final VoidCallback? onPower;
  final bool isPowerOn;

  const RobotControlPad({
    super.key,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
    this.onCenter,
    this.onPower,
    this.isPowerOn = true,
  });

  @override
  Widget build(BuildContext context) {
    // Les couleurs basées sur la nouvelle image rouge
    final Color darkBg = const Color(0xFF0D0D11);
    final Color padBg = const Color(0xFF13131A);
    final Color neonRed = const Color(0xFFFF2A2A);
    final Color neonRedDim = const Color(0xFFFF2A2A).withValues(alpha: 0.5);
    final Color powerOnColor = const Color(0xFFFF4040); // LED "ON" rouge

    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: neonRed.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: neonRed.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lignes de design de fond
          Positioned.fill(
            child: CustomPaint(
              painter: _PadBackgroundPainter(neonRed.withValues(alpha: 0.1)),
            ),
          ),

          // Top Left: POWER
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              children: [
                const Text(
                  "POWER",
                  style: TextStyle(
                    color: Color(0xFF9A5A5A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onPower,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkBg,
                      border: Border.all(color: neonRed, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: neonRed.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: neonRed,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "ON",
                      style: TextStyle(
                        color: isPowerOn ? powerOnColor : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 14,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isPowerOn ? powerOnColor : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isPowerOn
                            ? [BoxShadow(color: powerOnColor, blurRadius: 6)]
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top Right: STATUS
          Positioned(
            top: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "STATUS",
                  style: TextStyle(
                    color: Color(0xFF9A5A5A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 12,
                      height: 6,
                      margin: const EdgeInsets.only(left: 4),
                      transform: Matrix4.skewX(-0.5),
                      decoration: BoxDecoration(
                        color: neonRed,
                        boxShadow: [
                          BoxShadow(color: neonRed, blurRadius: 4),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Center: D-Pad & Robot Button
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // UP Arrow
                  Positioned(
                    top: 0,
                    child: _buildDirButton(
                      padBg, neonRed, neonRedDim,
                      Icons.arrow_upward_rounded,
                      onUp,
                    ),
                  ),
                  // DOWN Arrow
                  Positioned(
                    bottom: 0,
                    child: _buildDirButton(
                      padBg, neonRed, neonRedDim,
                      Icons.arrow_downward_rounded,
                      onDown,
                    ),
                  ),
                  // LEFT Arrow
                  Positioned(
                    left: 0,
                    child: _buildDirButton(
                      padBg, neonRed, neonRedDim,
                      Icons.arrow_back_rounded,
                      onLeft,
                    ),
                  ),
                  // RIGHT Arrow
                  Positioned(
                    right: 0,
                    child: _buildDirButton(
                      padBg, neonRed, neonRedDim,
                      Icons.arrow_forward_rounded,
                      onRight,
                    ),
                  ),

                  // Center Button
                  GestureDetector(
                    onTap: onCenter,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: darkBg,
                        border: Border.all(color: neonRed.withValues(alpha: 0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: neonRed.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer segmented ring effect
                          const CircularProgressIndicator(
                            value: 0.75,
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2A2A)),
                            backgroundColor: Colors.transparent,
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: padBg,
                              border: Border.all(color: neonRed, width: 2),
                            ),
                            child: Icon(
                              Icons.smart_toy_rounded,
                              color: neonRed,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom dots
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: neonRed,
                    boxShadow: [BoxShadow(color: neonRed, blurRadius: 6)],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDirButton(
    Color bg,
    Color neonRed,
    Color glow,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: _HexagonClipper(),
        child: Container(
          width: 70,
          height: 70,
          color: bg,
          child: Container(
            margin: const EdgeInsets.all(2), // border
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: neonRed.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Center(
              child: Icon(
                icon,
                color: neonRed,
                size: 36,
                shadows: [Shadow(color: neonRed, blurRadius: 10)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Un simple clipper pour donner une forme biseautée (octogonale/hexagonale)
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double corner = 15.0;

    path.moveTo(corner, 0);
    path.lineTo(w - corner, 0);
    path.lineTo(w, corner);
    path.lineTo(w, h - corner);
    path.lineTo(w - corner, h);
    path.lineTo(corner, h);
    path.lineTo(0, h - corner);
    path.lineTo(0, corner);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Peintre pour les lignes de fond subtiles
class _PadBackgroundPainter extends CustomPainter {
  final Color color;
  _PadBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Coins biseautés internes
    final path = Path();
    final w = size.width;
    final h = size.height;
    final margin = 20.0;
    
    path.moveTo(margin + 20, margin);
    path.lineTo(w - margin - 20, margin);
    
    path.moveTo(margin, margin + 20);
    path.lineTo(margin, h - margin - 20);
    
    path.moveTo(w - margin, margin + 20);
    path.lineTo(w - margin, h - margin - 20);
    
    path.moveTo(margin + 20, h - margin);
    path.lineTo(w - margin - 20, h - margin);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
