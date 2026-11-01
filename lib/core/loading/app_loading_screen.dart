import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({super.key});

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      container: true,
      label: strings.loading,
      liveRegion: true,
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = constraints.biggest.shortestSide
                    .clamp(96.0, 220.0)
                    .toDouble();
                final composition = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: reducedMotion
                          ? Image.asset(
                              'assets/branding/daymark-symbol.png',
                              fit: BoxFit.contain,
                            )
                          : RotationTransition(
                              turns: _controller,
                              child: Image.asset(
                                'assets/branding/daymark-symbol.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.loading,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: composition,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
