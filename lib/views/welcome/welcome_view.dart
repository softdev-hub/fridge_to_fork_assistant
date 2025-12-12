import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF9F0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth
              .clamp(0.0, 480.0)
              .toDouble();
          final double height = constraints.maxHeight;
          final double scale = (height / 820).clamp(0.7, 1.0);
          return Center(
            child: Container(
              width: maxWidth == 0 ? constraints.maxWidth : maxWidth,
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFECFDF5), Color(0xFFDCFCE7)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -120,
                    right: -120,
                    top: -120,
                    child: Container(
                      height: 420,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0x2D22C55E), Color(0x0022C55E)],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        _buildHero(context, scale),
                        _buildFeatures(context, scale),
                        _buildBottomCta(context, scale),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 28 * scale, 20, 8 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170 * scale,
                height: 170 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF86EFAC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2E16A34A),
                      blurRadius: 42,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
              ),
              Container(
                width: 130 * scale,
                height: 130 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x38FFFFFF),
                  border: Border.all(color: Colors.white.withOpacity(.2)),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/welcome_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _floating(
                44 * scale,
                44 * scale,
                left: -6,
                top: 28 * scale,
                delay: 0,
              ),
              _floating(
                32 * scale,
                32 * scale,
                right: 12,
                top: 10 * scale,
                delay: 1,
              ),
              _floating(
                36 * scale,
                36 * scale,
                right: 14,
                bottom: 12 * scale,
                delay: 2,
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Text(
            'Bếp Trợ Lý',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: const Color(0xFF0F172A),
              height: 1.15,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Trợ lý thông minh cho bếp của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF16A34A),
            ),
          ),
          SizedBox(height: 12 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _StatChip(
                  color: Color(0x24EF4444),
                  textColor: Color(0xFF166534),
                  emoji: '⏱',
                  label: 'Thông minh',
                ),
                SizedBox(width: 10),
                _StatChip(
                  color: Color(0x28F59E0B),
                  textColor: Color(0xFF166534),
                  emoji: '⚡',
                  label: 'Nhanh chóng',
                ),
                SizedBox(width: 10),
                _StatChip(
                  color: Color(0x2422C55E),
                  textColor: Color(0xFF166534),
                  emoji: '💚',
                  label: 'Tiết kiệm',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, double scale) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10 * scale, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            _FeatureCard(
              gradient: [Color(0xFFFFF7D6), Color(0xFFFDE68A)],
              icon: '🍽️',
              title: 'Gợi ý món ăn',
              subtitle: 'Dựa trên nguyên liệu có sẵn',
            ),
            _FeatureCard(
              gradient: [Color(0xFFFFE6CF), Color(0xFFFDBA74)],
              icon: '🔔',
              title: 'Nhắc hạn sử dụng',
              subtitle: 'Không bao giờ lãng phí thực phẩm',
            ),
            _FeatureCard(
              gradient: [Color(0xFFDBEAFE), Color(0xFF93C5FD)],
              icon: '📅',
              title: 'Lên kế hoạch',
              subtitle: 'Quản lý bữa ăn và mua sắm dễ dàng',
              marginBottom: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16 * scale, 20, 14 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 12,
                    shadowColor: const Color(0x3816A34A),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.pressed)
                          ? const Color(0xFF0F9A4E)
                          : const Color(0xFF16A34A),
                    ),
                  ),
              child: Text(
                'Bắt đầu ngay',
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Miễn phí • Tài khoản cá nhân hóa • Thông báo nhanh chóng',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16A34A),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floating(
    double w,
    double h, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    int delay = 0,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 1600 + delay * 200),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -4 * (1 - value)),
            child: child,
          );
        },
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F16A34A),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String emoji;
  final String label;
  const _StatChip({
    required this.color,
    required this.textColor,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A16A34A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withOpacity(0.55),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final List<Color> gradient;
  final String icon;
  final String title;
  final String subtitle;
  final double marginBottom;

  const _FeatureCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.marginBottom = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A16A34A),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
        border: Border.all(color: const Color(0x0F16A34A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
