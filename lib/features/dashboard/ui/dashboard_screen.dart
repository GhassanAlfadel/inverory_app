import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/layout/ui/main_layout.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout();
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة التحكم الرئيسية',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            const ShiftCard(),
            SizedBox(height: 24.h),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800.w
                    ? 3
                    : (constraints.maxWidth > 500.w ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.5,
                  children: const [
                    StatCard(
                      title: 'الفروع النشطة',
                      value: '7',
                      icon: Icons.store,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'إجمالي الأدوية',
                      value: '7',
                      icon: Icons.medication,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'نواقص الأدوية',
                      value: '7',
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
