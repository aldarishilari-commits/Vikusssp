import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/onboarding_dots.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/discover_step.dart';
import '../widgets/offers_step.dart';
import '../widgets/whatsapp_step.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _steps = const [
    DiscoverStep(),
    OffersStep(),
    WhatsAppStep(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDotTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(title: 'Vikus'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Carousel Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _steps[index];
                },
              ),
            ),

            // Pagination Dots Indicator (Clickable + Animated)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: OnboardingDots(
                totalDots: _steps.length,
                currentIndex: _currentPage,
                onDotTap: _onDotTapped,
              ),
            ),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary Button
                  PrimaryButton(
                    text: 'Entrar a Vikus',
                    onPressed: _navigateToLogin,
                  ),
                  const SizedBox(height: 12),
                  // Guest Button
                  GuestButton(
                    onPressed: _navigateToHome,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
