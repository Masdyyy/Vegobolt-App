import 'package:flutter/material.dart';

/// Global state for sidebar expansion
class SidebarState {
  static bool _isExpanded = true;

  static bool get isExpanded => _isExpanded;

  static void toggle() {
    _isExpanded = !_isExpanded;
  }

  static void setExpanded(bool value) {
    _isExpanded = value;
  }
}

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Helper class to determine screen type and get responsive values
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  bool get isMobile => width < ResponsiveBreakpoints.mobile;
  bool get isTablet =>
      width >= ResponsiveBreakpoints.mobile &&
      width < ResponsiveBreakpoints.desktop;
  bool get isDesktop => width >= ResponsiveBreakpoints.desktop;

  /// Returns true if screen is tablet or larger
  bool get isTabletOrLarger => width >= ResponsiveBreakpoints.mobile;

  /// Returns true if screen is desktop or larger
  bool get isDesktopOrLarger => width >= ResponsiveBreakpoints.desktop;

  /// Get responsive value based on screen size
  T getValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get padding value based on screen size
  double getPadding() {
    return getValue(mobile: 16.0, tablet: 24.0, desktop: 32.0);
  }

  /// Get grid columns based on screen size
  int getGridColumns({int mobile = 1, int tablet = 2, int desktop = 3}) {
    return getValue(mobile: mobile, tablet: tablet, desktop: desktop);
  }
}

/// Responsive layout wrapper that constrains max width for larger screens
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool useMaxWidth;
  final double maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.useMaxWidth = true,
    this.maxWidth = 1400,
  });

  @override
  Widget build(BuildContext context) {
    if (!useMaxWidth) return child;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Adaptive scaffold that switches between bottom nav and side rail
class AdaptiveScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavigationChanged;
  final String title;
  final List<NavigationItem> navigationItems;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.title,
    required this.navigationItems,
    this.floatingActionButton,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // For desktop/tablet, use side navigation rail
    if (responsive.isTabletOrLarger) {
      return Scaffold(
        body: Row(
          children: [
            // Side Navigation Rail
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: SidebarState.isExpanded
                  ? (responsive.isDesktop ? 240 : 80)
                  : 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Logo/Brand at the top with collapse button
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 12,
                          ),
                          child:
                              (SidebarState.isExpanded && responsive.isDesktop)
                              ? Image.asset(
                                  'assets/img/vegobolt_logo.png',
                                  height: 120,
                                  fit: BoxFit.contain,
                                )
                              : Center(
                                  child: Image.asset(
                                    'assets/img/vegobolt_logo.png',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                        // Toggle button
                        if (responsive.isDesktop)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                SidebarState.isExpanded
                                    ? Icons.chevron_left
                                    : Icons.chevron_right,
                                color: const Color(0xFF7BA23F),
                              ),
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  SidebarState.toggle();
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                    ),
                    const SizedBox(height: 8),
                    // Navigation Rail
                    Expanded(
                      child: NavigationRail(
                        extended:
                            SidebarState.isExpanded && responsive.isDesktop,
                        backgroundColor: Colors.transparent,
                        selectedIndex: widget.currentIndex,
                        onDestinationSelected: widget.onNavigationChanged,
                        labelType: SidebarState.isExpanded
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.none,
                        selectedIconTheme: const IconThemeData(
                          color: Color(0xFF7BA23F),
                          size: 28,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 24,
                        ),
                        selectedLabelTextStyle: const TextStyle(
                          color: Color(0xFF7BA23F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                        indicatorColor: const Color(
                          0xFF7BA23F,
                        ).withOpacity(0.15),
                        destinations: widget.navigationItems.map((item) {
                          return NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.icon),
                            label: Text(item.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(child: widget.body),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }

    // For mobile, use traditional bottom navigation with custom app bar
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BA23F),
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo on the left
            Image.asset(
              'assets/img/vegobolt_logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            // Notification bell on the right
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                // TODO: Navigate to notifications page
              },
            ),
          ],
        ),
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFF7BA23F),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        currentIndex: widget.currentIndex,
        onTap: widget.onNavigationChanged,
        items: widget.navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Navigation item model
class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({required this.icon, required this.label});
}

/// Responsive grid view
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final columns = responsive.getGridColumns(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(width: itemWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}
