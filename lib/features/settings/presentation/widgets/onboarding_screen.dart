import 'package:flutter/material.dart';
import 'package:contactsafe/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> _onboardingImages = [
    'assets/onboardtour1.jpg',
    'assets/onboardtour2.jpg',
    'assets/onboardtour3.jpg',
    'assets/onboardtour4.jpg',
    'assets/onboardtour5.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(
              context,
            ).pop(); // Go back to the previous screen (Settings)
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Skip/Done button
            },
            child: Text(
              _currentPage == _onboardingImages.length - 1
                  ? context.loc.translate('done')
                  : context.loc.translate('skip'),
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingImages.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // You can add titles and descriptions here for each page
                      // Example:
                      // Text(
                      //   'Welcome to ContactSafe!',
                      //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      //   textAlign: TextAlign.center,
                      // ),
                      // const SizedBox(height: 20),
                      Image.asset(
                        _onboardingImages[index],
                        fit: BoxFit.contain, // Adjust as needed
                        height:
                            MediaQuery.of(context).size.height *
                            0.5, // Adjust image size
                      ),
                      const SizedBox(height: 30),
                      // Text(
                      //   'A brief description of what this page explains about the app.',
                      //   style: TextStyle(fontSize: 16),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  height: 10.0,
                  width: _currentPage == index ? 24.0 : 10.0,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
