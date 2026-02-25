import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main/main_screen.dart';
import 'dart:math';

class IntroScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const IntroScreen({super.key, required this.prefs});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color bgColor = const Color(0xFFF2F6FA);
  final Color primaryBlue = const Color(0xFF0049DB);
  final Color descriptionColor = const Color(0xFF687792);

  final List<IntroPageData> _pages = [
    IntroPageData(
      image: 'assets/images/img4.png', // Biz siz uchun...
      title: 'Biz siz uchun Nukusning eng yaxshi joylarini saralab qo\'ydik.',
      description: 'Shaharning eng sara, tekshirilgan va yuqori reytingli restoranlari — bitta ilovada jamlandi.',
    ),
    IntroPageData(
      image: 'assets/images/img1.png', // Nukusning eng sara...
      title: 'Nukusning eng sara ta\'mini kashf eting',
      description: 'Shahardagi eng yaxshi va sertifikatlangan restoranlarni oson toping.',
    ),
    IntroPageData(
      image: 'assets/images/img2.png', // Menyu va narxlarni...
      title: 'Menyu va narxlarni oldindan ko\'ring',
      description: 'Buyurtma berishdan oldin taomlar rasmi va tarkibi bilan tanishing.',
    ),
    IntroPageData(
      image: 'assets/images/img3.png',
      title: 'Haqiqiy baho va sharhlar',
      description: 'Xizmat sifatini baholang va boshqalar fikrini o\'qing.',
    ),
  ];

  Future<void> _completeIntro() async {
    await widget.prefs.setBool('has_seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Rasmlar (Orqa fonda)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 60),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(_pages[index].image, fit: BoxFit.contain),
                    ),
                  ),
                  const Spacer(flex: 4), // Matn kartasi uchun joy
                ],
              );
            },
          ),

          // 2. Progress Circle (Faqat 1-sahifadan keyin)
          if (_currentPage > 0)
            Positioned(
              top: 50,
              right: 25,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  currentStep: _currentPage, // 1/3, 2/3, 3/3 ko'rinishi uchun
                  totalSteps: _pages.length - 1,
                  color: primaryBlue,
                ),
                child: Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    '$_currentPage/${_pages.length - 1}',
                    style: TextStyle(color: descriptionColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pages[_currentPage].title,
                    style: TextStyle(color: primaryBlue, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _pages[_currentPage].description,
                    style: TextStyle(color: descriptionColor, fontSize: 15, height: 1.4),
                  ),
                  const Spacer(),
                  // Tugmalar kartaning ichida, eng pastda
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0), // SHU YERDA: Tugmalarni pastdan ko'tarish
                    child: _buildButtons(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_currentPage == 0) {
      // Birinchi sahifa: Ikkita tugma
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _completeIntro,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('O\'tkazib yuborish', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text('Oldinga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage < _pages.length - 1) {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              _completeIntro();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _currentPage == _pages.length - 1 ? 'Ro\'yxatdan o\'tish' : 'Oldinga',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      );
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Color color;

  CircularProgressPainter({required this.currentStep, required this.totalSteps, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint circle = Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 4..style = PaintingStyle.stroke;
    Paint arc = Paint()..color = color..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, circle);

    double sweepAngle = (2 * pi * currentStep) / totalSteps;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IntroPageData {
  final String image;
  final String title;
  final String description;
  IntroPageData({required this.image, required this.title, required this.description});
}