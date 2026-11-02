import 'package:flutter/material.dart';

class HomeFeature {
  const HomeFeature({
    this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final Key? key;
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
}

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({required this.features, super.key});

  final List<HomeFeature> features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        final cardHeight = cardWidth * 1.05;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            final textTheme = Theme.of(context).textTheme;
            return Material(
              key: feature.key,
              color: feature.backgroundColor,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: feature.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        feature.icon,
                        size: 26,
                        color: feature.foregroundColor,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: feature.foregroundColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Flexible(
                              child: Text(
                                feature.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: feature.foregroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 22,
                          color: feature.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
