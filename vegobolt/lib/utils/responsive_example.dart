/// Example: Using the Responsive System in Your Pages
///
/// This file shows how to implement responsive design in VegoBolt pages

import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';

class ExampleResponsivePage extends StatelessWidget {
  const ExampleResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return AdaptiveScaffold(
      title: 'Example Page',
      currentIndex: 0,
      onNavigationChanged: (index) {
        // Handle navigation
      },
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.oil_barrel, label: 'Tanks'),
        NavigationItem(icon: Icons.warning, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      body: ResponsiveLayout(
        maxWidth: 1600, // Content won't stretch beyond this width
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            responsive.getPadding(),
          ), // 16/24/32 based on screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title - responsive font size
              Text(
                'Page Title',
                style: TextStyle(
                  fontSize: responsive.getValue(
                    mobile: 22,
                    tablet: 28,
                    desktop: 32,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Responsive Grid Example
              ResponsiveGrid(
                mobileColumns: 1, // Single column on mobile
                tabletColumns: 2, // 2 columns on tablet
                desktopColumns: 3, // 3 columns on desktop
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildCard('Card 1'),
                  _buildCard('Card 2'),
                  _buildCard('Card 3'),
                  _buildCard('Card 4'),
                  _buildCard('Card 5'),
                  _buildCard('Card 6'),
                ],
              ),

              const SizedBox(height: 24),

              // Conditional layout based on screen size
              if (responsive.isMobile)
                _buildMobileOnlyWidget()
              else
                _buildDesktopWidget(),

              // Alternative: Different layouts per screen size
              responsive.getValue(
                mobile: _buildMobileLayout(),
                tablet: _buildTabletLayout(),
                desktop: _buildDesktopLayout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(title),
    );
  }

  Widget _buildMobileOnlyWidget() => const Text('Mobile Only');
  Widget _buildDesktopWidget() => const Text('Desktop/Tablet');
  Widget _buildMobileLayout() => const Text('Mobile Layout');
  Widget _buildTabletLayout() => const Text('Tablet Layout');
  Widget _buildDesktopLayout() => const Text('Desktop Layout');
}

/// RESPONSIVE BREAKPOINTS:
/// Mobile:  width < 600px  - 1 column, bottom nav, compact spacing
/// Tablet:  600px - 1200px - 2 columns, side rail, medium spacing
/// Desktop: width > 1200px - 3 columns, extended rail, large spacing

/// NAVIGATION BEHAVIOR:
/// Mobile:  BottomNavigationBar with AppBar
/// Desktop: NavigationRail (side) with integrated header

/// GRID BEHAVIOR:
/// Cards/Items automatically adjust column count based on screen size
/// Maintains consistent spacing and alignment

/// FORM PAGES (Login/Signup):
/// Mobile:  Full width with side padding
/// Desktop: Max 500px width, centered on screen

/// CONTENT PAGES (Dashboard/Machine):
/// All:     Max 1600px width, centered on screen
/// Mobile:  Full width usage within padding
/// Desktop: Multi-column grids for efficient space usage
