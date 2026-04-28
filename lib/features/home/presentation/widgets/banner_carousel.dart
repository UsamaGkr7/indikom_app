import 'package:flutter/material.dart';
import 'package:indikom_app/core/constants/endpoints.dart';
import 'package:indikom_app/core/theme/text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/banner_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const BannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  @override
  void initState() {
    super.initState();

    // Test first banner URL
    if (widget.banners.isNotEmpty) {
      String testUrl = '${Endpoints.baseUrl}${widget.banners.first.bannerFile}';
      print('🔍 Testing URL: $testUrl');
      print('🔍 Base URL: ${Endpoints.baseUrl}');
      print('🔍 Banner File: ${widget.banners.first.bannerFile}');
    }
  }

  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one banner, show it without carousel
    if (widget.banners.length == 1) {
      return _buildBannerItem(widget.banners.first);
    }

    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 250,
            viewportFraction: 0.80,
            enlargeCenterPage: true, // 👈 center big
            enlargeFactor: 0.15, // 👈 scaling
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.banners.map((banner) {
            return _buildBannerItem(banner);
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.banners.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == entry.key
                    ? AppColors.primary
                    : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    // ✅ Construct full image URL
    String imageUrl = banner.bannerFile;

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      // Only prepend base URL if it's a relative path
      imageUrl = '${Endpoints.baseUrl}$imageUrl';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Banner Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.cardBackground,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
