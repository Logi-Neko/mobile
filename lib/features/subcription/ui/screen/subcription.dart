import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../ui/widgets/subcription_card.dart';

@RoutePage()
class SubscriptionScreen extends StatelessWidget {
  final int accountId;
  final bool isPremium;
  final String? premiumUntil;

  const SubscriptionScreen({
    Key? key,
    required this.accountId,
    required this.isPremium,
    this.premiumUntil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF002171),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () => context.router.push(
                              const HomeRoute(),
                            ),
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            label: const Text("Quay lại", style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                              image: DecorationImage(
                                image: AssetImage("lib/shared/assets/images/LOGO.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'LogiNeko',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Premium card
                      Container(
                        width: 280,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isPremium ? 'LogiNeko Premium (Active)' : 'LogiNeko Premium',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPremium && premiumUntil != null
                                  ? 'Premium until ${premiumUntil!.substring(0, premiumUntil!.length >= 10 ? 10 : premiumUntil!.length)}'
                                  : 'Mở khóa tất cả các cấp độ và tính năng độc quyền',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        isPremium
                            ? 'Bạn đang sử dụng gói Premium'
                            : 'Tham gia để thấy sự tiến bộ với gói Plus',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const SizedBox(height: 45),

                      Text(
                        'Tiết kiệm 20% với gói hàng năm!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 16,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Yearly plan
                      PricingCardWidget(
                        period: '1 năm',
                        originalPrice: '700.000 đ',
                        finalPrice: '549.000 đ',
                        discount: '20% OFF',
                        subPrice: "45.000 đ/tháng"
                      ),
                      const SizedBox(height: 12),

                      // Monthly plan
                      MonthlyPricingCard(),
                      const SizedBox(height: 18),

                      const SizedBox(height: 10),

                      Text(
                        'Truy cập trang web logineko.edu.vn để thanh toán',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 16,
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
