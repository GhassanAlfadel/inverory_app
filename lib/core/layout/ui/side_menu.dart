import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/navigation_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';

class SideMenu extends StatelessWidget {
  final bool isExpanded;
  const SideMenu({super.key, this.isExpanded = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isExpanded ? 260.w : 70.w,
      color: const Color(0xFF1a233a),
      child: Column(
        children: [
          // Header / Logo
          Container(
            height: 64.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: isExpanded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.computer, color: Colors.blue, size: 28.r),
                      SizedBox(width: 8.w),
                      Text(
                        'إلكترو شوب',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Icon(Icons.computer, color: Colors.blue, size: 28.r),
          ),

          // Navigation Items
          Expanded(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, navState) {
                final currentScreen = navState.screen;
                return ListView(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  children: [
                    // Stock Section
                    if (isExpanded) ...[
                      _buildSectionHeader('إدارة المخزون'),
                      _buildSubItem(
                        'المنتجات',
                        Icons.inventory_2,
                        isActive:
                            currentScreen == NavigationScreen.medicines ||
                            currentScreen == NavigationScreen.addProduct ||
                            currentScreen == NavigationScreen.editProduct,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.medicines,
                        ),
                      ),
                      _buildSubItem(
                        'التصنيفات',
                        Icons.category,
                        isActive: currentScreen == NavigationScreen.categories,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.categories,
                        ),
                      ),
                      _buildSubItem(
                        'المشتريات',
                        Icons.shopping_cart,
                        isActive:
                            currentScreen == NavigationScreen.purchases ||
                            currentScreen == NavigationScreen.addPurchase,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.purchases,
                        ),
                      ),
                      _buildSubItem(
                        'الموردين',
                        Icons.local_shipping_outlined,
                        isActive: currentScreen == NavigationScreen.suppliers,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.suppliers,
                        ),
                      ),
                    ] else ...[
                      // Collapsed icons for sections
                      const Divider(),
                      _buildNavItem(
                        context,
                        'المخزون',
                        Icons.inventory,
                        currentScreen == NavigationScreen.medicines ||
                            currentScreen == NavigationScreen.addProduct ||
                            currentScreen == NavigationScreen.editProduct,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.medicines,
                        ),
                      ),
                      _buildNavItem(
                        context,
                        'التصنيفات',
                        Icons.category,
                        currentScreen == NavigationScreen.categories,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.categories,
                        ),
                      ),
                    ],

                    // Finance Section
                    if (isExpanded) ...[
                      _buildSectionHeader('المالية والورديات'),
                      _buildSubItem(
                        'نقطة البيع (الكاشير)',
                        Icons.point_of_sale,
                        isActive: currentScreen == NavigationScreen.pos,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.pos,
                        ),
                      ),
                      _buildSubItem('ورديتي الحالية', Icons.timer),
                      _buildSubItem(
                        'المصروفات',
                        Icons.money_off,
                        isActive: currentScreen == NavigationScreen.expenses,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.expenses,
                        ),
                      ),
                      _buildSubItem(
                        'الفواتير',
                        Icons.receipt_long,
                        isActive:
                            currentScreen == NavigationScreen.invoices ||
                            currentScreen == NavigationScreen.invoiceDetails,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.invoices,
                        ),
                      ),
                      _buildSubItem(
                        'التقارير',
                        Icons.bar_chart,
                        isActive: currentScreen == NavigationScreen.reports,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.reports,
                        ),
                      ),
                    ] else ...[
                      const Divider(),
                      _buildNavItem(
                        context,
                        'نقطة البيع',
                        Icons.point_of_sale,
                        currentScreen == NavigationScreen.pos,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.pos,
                        ),
                      ),
                      _buildNavItem(
                        context,
                        'المصروفات',
                        Icons.money_off,
                        currentScreen == NavigationScreen.expenses,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.expenses,
                        ),
                      ),
                      _buildNavItem(
                        context,
                        'التقارير',
                        Icons.bar_chart,
                        currentScreen == NavigationScreen.reports,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.reports,
                        ),
                      ),
                    ],
                    // Management Section
                    if (isExpanded) ...[
                      _buildSectionHeader('الإدارة النظام'),
                      _buildSubItem(
                        'المستخدمين',
                        Icons.people,
                        isActive: currentScreen == NavigationScreen.users,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.users,
                        ),
                      ),
                      _buildSubItem(
                        'الإعدادات',
                        Icons.settings,
                        isActive: currentScreen == NavigationScreen.settings,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.settings,
                        ),
                      ),
                    ] else ...[
                      const Divider(),
                      _buildNavItem(
                        context,
                        'المستخدمين',
                        Icons.people,
                        currentScreen == NavigationScreen.users,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.users,
                        ),
                      ),
                      _buildNavItem(
                        context,
                        'الإعدادات',
                        Icons.settings,
                        currentScreen == NavigationScreen.settings,
                        isExpanded,
                        onTap: () => context.read<NavigationCubit>().setScreen(
                          NavigationScreen.settings,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // Logout Button
          const Divider(height: 1),
          _buildNavItem(
            context,
            'تسجيل الخروج',
            Icons.logout,
            false,
            isExpanded,
            onTap: () {
              context.read<AuthCubit>().logout();
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
    bool isExpanded, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0d6efd) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.w : 0),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.white70,
                size: 22.r,
              ),
              if (isExpanded) ...[
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubItem(
    String title,
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.r,
              color: isActive ? const Color(0xFF0d6efd) : Colors.white70,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
