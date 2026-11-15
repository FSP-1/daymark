import 'package:material_ui/material_ui.dart';

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
        final cardHeight = cardWidth * 0.92;

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
            final compact = cardHeight < 168;
            return Material(
              key: feature.key,
              color: feature.backgroundColor,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: feature.onTap,
                child: Padding(
                  padding: EdgeInsets.all(compact ? 8 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: feature.foregroundColor.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              feature.icon,
                              size: 23,
                              color: feature.foregroundColor,
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 19,
                            color: feature.foregroundColor.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      Text(
                        feature.title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: feature.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: feature.foregroundColor.withValues(
                            alpha: 0.78,
                          ),
                          height: 1.3,
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
