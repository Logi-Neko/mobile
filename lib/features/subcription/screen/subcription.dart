import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logi_neko/core/router/app_router.dart';
import '../widgets/subcription_card.dart';

@RoutePage()
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE691F7),
              Color(0xFF9C64F7),
              Color(0xFF4A90E2),
            ],
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
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(color: Colors.black),
                              ),
                            ),
                            onPressed: () => context.router.push(
                              const HomeRoute(),
                            ),                            icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B68EE), Color(0xFF4A90E2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'LogiNeko Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mở khóa tất cả các cấp độ và tính năng độc quyền',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Tham gia để thấy sự tiến bộ với gói Plus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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

                      // Container(
                      //   width: double.infinity,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     gradient: const LinearGradient(
                      //       colors: [
                      //         Color(0xFF4A90E2),
                      //         Color(0xFF357ABD),
                      //       ],
                      //     ),
                      //     borderRadius: BorderRadius.circular(25),
                      //   ),
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       // upgrade
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.transparent,
                      //       shadowColor: Colors.transparent,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(25),
                      //       ),
                      //     ),
                      //     child: const Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           'Nâng cấp lên gói Plus',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //         ),
                      //         SizedBox(width: 8),
                      //         Text(
                      //           '👑',
                      //           style: TextStyle(fontSize: 16),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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