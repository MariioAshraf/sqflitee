import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════
//  OnboardingScreen — شاشة ترحيب تطبيق الكنيسة
//  3 صفحات + زرار "ابدأ" في الأخير
// ════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  /// يُستدعى لما اليوزر يضغط "ابدأ" في آخر صفحة
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Animation controllers ──────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  // ── Onboarding pages data ──────────────────────────────
  static const _pages = [
    _OnboardingData(
      icon: Icons.church_rounded,
      title: 'مرحباً بك في كنيستنا',
      subtitle:
          'تطبيق كنيسة مار جرجس يجمع المؤمنين في مكان واحد،\n'
          'تابع كل أخبار الكنيسة وفعالياتها بسهولة.',
      gradient: [Color(0xFF1a237e), Color(0xFF283593)],
      accentColor: Color(0xFFFFD700),
    ),
    _OnboardingData(
      icon: Icons.menu_book_rounded,
      title: 'القداسات والصلوات',
      subtitle:
          'اعرف مواعيد القداسات والاجتماعات وصلوات الأجبية\n'
          'واستقبل تذكيرات لتبقى دائماً على تواصل مع الله.',
      gradient: [Color(0xFF4a148c), Color(0xFF6a1b9a)],
      accentColor: Color(0xFFE1BEE7),
    ),
    _OnboardingData(
      icon: Icons.favorite_rounded,
      title: 'مجتمع المحبة',
      subtitle:
          'شارك في خدمات الكنيسة، تواصل مع الآباء الكهنة\n'
          'وكن جزءاً من عائلة المحبة والإيمان.',
      gradient: [Color(0xFF880e4f), Color(0xFFad1457)],
      accentColor: Color(0xFFF8BBD9),
    ),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
    );

    _playAnimations();
  }

  void _playAnimations() {
    _fadeCtrl.forward(from: 0);
    _scaleCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  // ── Navigate ───────────────────────────────────────────
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onDone();
    }
  }

  void _skip() => widget.onDone();

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ── Skip button ────────────────────────
                if (!isLast)
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'تخطى',
                        style: TextStyle(
                          color: page.accentColor.withOpacity(0.8),
                          fontSize: 15,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 48),

                // ── Pages ──────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _playAnimations();
                    },
                    itemBuilder: (_, index) =>
                        _OnboardingPage(data: _pages[index]),
                  ),
                ),

                // ── Bottom section ─────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      // Dots indicator
                      _DotsIndicator(
                        count: _pages.length,
                        current: _currentPage,
                        accentColor: page.accentColor,
                      ),

                      const SizedBox(height: 32),

                      // Action button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLast
                            ? _StartButton(
                                accentColor: page.accentColor,
                                onTap: widget.onDone,
                              )
                            : _NextButton(
                                accentColor: page.accentColor,
                                onTap: _nextPage,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Single Onboarding Page
// ════════════════════════════════════════════════════════
class _OnboardingPage extends StatefulWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Decorative circle + icon ───────────────
          ScaleTransition(
            scale: _iconScale,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
                border: Border.all(
                  color: widget.data.accentColor.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.data.accentColor.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                widget.data.icon,
                size: 90,
                color: widget.data.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // ── Title ──────────────────────────────────
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Text(
                widget.data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  height: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Subtitle ───────────────────────────────
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Text(
                widget.data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  fontFamily: 'Cairo',
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Dots Indicator
// ════════════════════════════════════════════════════════
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color accentColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? accentColor
                : Colors.white.withOpacity(0.35),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Next Button (الصفحات الأولى)
// ════════════════════════════════════════════════════════
class _NextButton extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _NextButton({required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Start Button (الصفحة الأخيرة)
// ════════════════════════════════════════════════════════
class _StartButton extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _StartButton({required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'ابدأ الآن',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Cairo',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Data model
// ════════════════════════════════════════════════════════
class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color accentColor;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
  });
}
