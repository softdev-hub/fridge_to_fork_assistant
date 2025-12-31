import 'package:flutter/material.dart';
import '../auth/login_view.dart';

const _bgLight = Color(0xFFF7F7F7);

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    _heroImage(),
                    const SizedBox(height: 12),
                    _titleBlock(),
                    const SizedBox(height: 14),
                    _statChips(),
                    const SizedBox(height: 18),
                    _foodBubbles(),
                    const SizedBox(height: 18),
                    _welcomeCopy(),
                    const SizedBox(height: 26),
                    _ctaButton(context),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroImage() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/welcome_logo.png',
        width: 90,
        height: 90,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      children: const [
        Text(
          'Bếp Trợ Lý',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B9A64),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Xin chào!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  Widget _statChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Chip(text: 'Kho nguyên liệu'),
        SizedBox(width: 8),
        _Chip(text: 'Công thức'),
        SizedBox(width: 8),
        _Chip(text: 'Kế hoạch'),
      ],
    );
  }

  Widget _foodBubbles() {
    final avatars = [
      'assets/images/4abbc6e2d2f6bfb9f40d95c5bacc88ff.jpg',
      'assets/images/23eee36498596d260e48e89594fb1e99.jpg',
      'assets/images/66d0223fe509e0428619bc08ca7a5184.jpg',
      'assets/images/81a08e27708cfed5bbbc8b3b19560d9b.jpg',
      'assets/images/82c9a3f0ff53b88cc5f19427197780f8.jpg',
      'assets/images/405a38907e2f3193ed5c228776bcc09d.jpg',
      'assets/images/ef42d2b194710449677cd9dc51952a25.jpg',
      'assets/images/fba57881755eb0429520af44ee8dc6f0.jpg',
    ];
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _circleImage(avatars[0], 130, top: 12),
          _circleImage(avatars[1], 90, left: 10, top: 24),
          _circleImage(avatars[2], 88, right: 12, top: 28),
          _circleImage(avatars[3], 82, left: 40, bottom: 14),
          _circleImage(avatars[4], 78, right: 28, bottom: 20),
          _circleImage(avatars[5], 70, top: 96, left: 0),
          _circleImage(avatars[6], 64, top: 92, right: 0),
        ],
      ),
    );
  }

  Widget _circleImage(
    String url,
    double size, {
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: ClipOval(child: Image.asset(url, fit: BoxFit.cover)),
      ),
    );
  }

  Widget _welcomeCopy() {
    return Column(
      children: const [
        Text(
          'Chào mừng đến Bếp Trợ Lý! 🌿',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Khám phá món ăn từ kho sẵn có, nhắc hạn dùng, và lên kế hoạch nấu nướng thật dễ dàng.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _ctaButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginView()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B9A64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Bắt đầu ngay',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B9A64),
            ),
          ),
        ],
      ),
    );
  }
}
