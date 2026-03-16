import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/layout_cubit.dart';
import '../../../features/dashboard/ui/dashboard_screen.dart';
import '../../../features/products/ui/products_screen.dart';
import '../../../features/products/ui/categories_screen.dart';
import '../../../features/products/ui/add_product_screen.dart';
import '../../../features/expenses/ui/expenses_screen.dart';
import '../../../features/purchases/ui/add_purchase_screen.dart';
import '../../../features/purchases/ui/purchases_screen.dart';
import '../../../features/purchases/ui/view_purchase_screen.dart';
import '../../../features/suppliers/ui/suppliers_screen.dart';
import '../../../features/reports/ui/reports_screen.dart';
import '../../../features/users/ui/users_screen.dart';
import '../../../features/settings/ui/settings_screen.dart';
import '../../../features/pos/ui/pos_screen.dart';
import '../../../features/products/ui/add_laptop_screen.dart';
import '../../../features/products/ui/add_phone_screen.dart';
import '../../../features/products/ui/add_accessory_screen.dart';
import '../../../features/invoices/ui/invoices_screen.dart';
import '../../../features/invoices/ui/invoice_details_screen.dart';
import 'side_menu.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, layoutState) {
        final isExpanded = layoutState.isSidebarExpanded;
        // Check for desktop/tablet vs mobile using ScreenUtil
        final isDesktop = 1.sw >= 1100;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: Row(
            children: [
              if (isDesktop) SideMenu(isExpanded: isExpanded),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, isDesktop),
                    Expanded(
                      child: BlocBuilder<NavigationCubit, NavigationState>(
                        builder: (context, navState) {
                          switch (navState.screen) {
                            case NavigationScreen.dashboard:
                              return const DashboardContent();
                            case NavigationScreen.medicines:
                              return const ProductsView();
                            case NavigationScreen.categories:
                              return const CategoriesView();
                            case NavigationScreen.purchases:
                              return const PurchasesScreen();
                            case NavigationScreen.viewPurchase:
                              return ViewPurchaseScreen(
                                purchaseId: navState.data,
                              );
                            case NavigationScreen.addProduct:
                              return const AddProductScreen();
                            case NavigationScreen.editProduct:
                              return AddProductScreen(product: navState.data);
                            case NavigationScreen.expenses:
                              return const ExpensesScreen();
                            case NavigationScreen.addPurchase:
                              return const AddPurchaseScreen();
                            case NavigationScreen.suppliers:
                              return const SuppliersScreen();
                            case NavigationScreen.reports:
                              return const ReportsScreen();
                            case NavigationScreen.users:
                              return const UsersScreen();
                            case NavigationScreen.settings:
                              return const SettingsScreen();
                            case NavigationScreen.pos:
                              return const POSScreen();
                            case NavigationScreen.addLaptop:
                              return const AddLaptopScreen();
                            case NavigationScreen.editLaptop:
                              return AddLaptopScreen(product: navState.data);
                            case NavigationScreen.addPhone:
                              return const AddPhoneScreen();
                            case NavigationScreen.editPhone:
                              return AddPhoneScreen(product: navState.data);
                            case NavigationScreen.addAccessory:
                              return const AddAccessoryScreen();
                            case NavigationScreen.editAccessory:
                              return AddAccessoryScreen(product: navState.data);
                            case NavigationScreen.invoices:
                              return const InvoicesScreen();
                            case NavigationScreen.invoiceDetails:
                              return InvoiceDetailsScreen(
                                saleId: navState.data,
                              );
                            default:
                              return Center(
                                child: Text(
                                  'Screen for ${navState.screen} coming soon',
                                ),
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          drawer: !isDesktop
              ? const Drawer(child: SideMenu(isExpanded: true))
              : null,
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Builder(
        builder: (topBarContext) {
          return Row(
            children: [
              IconButton(
                onPressed: () {
                  if (isDesktop) {
                    context.read<LayoutCubit>().toggleSidebar();
                  } else {
                    Scaffold.of(topBarContext).openDrawer();
                  }
                },
                icon: Icon(Icons.menu, color: Colors.grey.shade700, size: 24.r),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: const Color(0xFF0d6efd),
                radius: 18.r,
                child: Icon(Icons.person, color: Colors.white, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Text(
                'أهلاً، المدير العام',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24.r),
            ],
          );
        },
      ),
    );
  }
}
