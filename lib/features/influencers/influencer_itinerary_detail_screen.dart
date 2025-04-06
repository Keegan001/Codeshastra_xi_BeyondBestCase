import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/influencer_itinerary.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class InfluencerItineraryDetailScreen extends StatefulWidget {
  final InfluencerItinerary itinerary;

  const InfluencerItineraryDetailScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<InfluencerItineraryDetailScreen> createState() => _InfluencerItineraryDetailScreenState();
}

class _InfluencerItineraryDetailScreenState extends State<InfluencerItineraryDetailScreen> {
  ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Toggle app bar visibility based on scroll position
    if (_scrollController.offset > 180 && !_showAppBar) {
      setState(() {
        _showAppBar = true;
      });
    } else if (_scrollController.offset <= 180 && _showAppBar) {
      setState(() {
        _showAppBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(isDarkMode),
          SliverToBoxAdapter(
            child: _buildHeader(isDarkMode),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfluencerInfo(isDarkMode),
                  const SizedBox(height: 24),
                  _buildItineraryDescription(isDarkMode),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Day by Day Itinerary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 16),
          ),
          _buildDaysList(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: 0,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      title: AnimatedOpacity(
        opacity: _showAppBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Text(
          widget.itinerary.destination,
          style: TextStyle(
            color: widget.itinerary.themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.favorite_border,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to favorites'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.bookmark_border,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved to your collection'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Stack(
      children: [
        // Hero image
        Container(
          height: 250,
          width: double.infinity,
          child: Image.network(
            widget.itinerary.heroImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: widget.itinerary.themeColor.withOpacity(0.2),
                child: const Icon(Icons.image, size: 64, color: Colors.grey),
              );
            },
          ),
        ),
        
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        
        // Destination title
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itinerary.destination,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.itinerary.days.length} Days',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Back button (only visible at top)
        if (!_showAppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfluencerInfo(bool isDarkMode) {
    return Row(
      children: [
        // Influencer profile image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.itinerary.themeColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              widget.itinerary.influencerImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  backgroundColor: widget.itinerary.themeColor,
                  child: const Icon(Icons.person, color: Colors.white),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Influencer details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itinerary.influencerName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.itinerary.influencerHandle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        
        // Follow button
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Following ${widget.itinerary.influencerName}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Follow'),
          style: TextButton.styleFrom(
            foregroundColor: widget.itinerary.themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: widget.itinerary.themeColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryDescription(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this Itinerary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.itinerary.description,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.itinerary.themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.itinerary.themeColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: widget.itinerary.themeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pro Tip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.itinerary.themeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This itinerary is perfect for first-time visitors to ${widget.itinerary.destination}. Follow it day by day, or customize it to fit your travel style.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDaysList(bool isDarkMode) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final day = widget.itinerary.days[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildDayCard(day, index, isDarkMode),
              ),
            ),
          );
        },
        childCount: widget.itinerary.days.length,
      ),
    );
  }

  Widget _buildDayCard(ItineraryDay day, int index, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.itinerary.themeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.dayNumber.toString(),
                      style: TextStyle(
                        color: widget.itinerary.themeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Activities
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: day.activities.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: widget.itinerary.themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getActivityIcon(activity),
                          size: 14,
                          color: widget.itinerary.themeColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getActivityIcon(String activity) {
    // Determine icon based on activity content
    if (activity.toLowerCase().contains('breakfast') || 
        activity.toLowerCase().contains('lunch') || 
        activity.toLowerCase().contains('dinner') ||
        activity.toLowerCase().contains('food') ||
        activity.toLowerCase().contains('restaurant')) {
      return Icons.restaurant;
    } else if (activity.toLowerCase().contains('hotel') || 
               activity.toLowerCase().contains('resort') || 
               activity.toLowerCase().contains('check in') || 
               activity.toLowerCase().contains('accommodation')) {
      return Icons.hotel;
    } else if (activity.toLowerCase().contains('flight') || 
               activity.toLowerCase().contains('airport') || 
               activity.toLowerCase().contains('arrive')) {
      return Icons.flight;
    } else if (activity.toLowerCase().contains('museum') || 
               activity.toLowerCase().contains('gallery') || 
               activity.toLowerCase().contains('temple') || 
               activity.toLowerCase().contains('palace')) {
      return Icons.museum;
    } else if (activity.toLowerCase().contains('beach') || 
               activity.toLowerCase().contains('swim') || 
               activity.toLowerCase().contains('snorkel')) {
      return Icons.beach_access;
    } else if (activity.toLowerCase().contains('tour') || 
               activity.toLowerCase().contains('explore') || 
               activity.toLowerCase().contains('visit')) {
      return Icons.tour;
    } else if (activity.toLowerCase().contains('shop') || 
               activity.toLowerCase().contains('market') || 
               activity.toLowerCase().contains('mall')) {
      return Icons.shopping_bag;
    } else if (activity.toLowerCase().contains('spa') || 
               activity.toLowerCase().contains('massage') || 
               activity.toLowerCase().contains('relax')) {
      return Icons.spa;
    } else {
      return Icons.place;
    }
  }
} 