import 'package:flutter/material.dart';

import 'app_loading_screen.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
    super.key,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AbsorbPointer(child: child),
        const ModalBarrier(dismissible: false),
        Semantics(
          container: true,
          scopesRoute: true,
          explicitChildNodes: true,
          label: message,
          child: const AppLoadingScreen(),
        ),
      ],
    );
  }
}

class InlineLoadingIndicator extends StatelessWidget {
  const InlineLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
