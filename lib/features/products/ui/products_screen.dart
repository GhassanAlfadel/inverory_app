import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/database/models.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../../../core/layout/cubit/navigation_cubit.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductsView();
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          return Container(
            color: const Color(0xFFF0F2F5),
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إدارة المنتجات',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    _buildAddProductMenu(context),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF0d6efd),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF0d6efd),
                    indicatorWeight: 3.h,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'هواتف'),
                      Tab(text: 'لاب توب / PC'),
                      Tab(text: 'ملحقات'),
                      Tab(text: 'عام'),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductTable(context, state, 'هواتف'),
                      _buildProductTable(context, state, 'لاب توب'),
                      _buildProductTable(context, state, 'ملحقات'),
                      _buildProductTable(context, state, 'عام'),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is ProductsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const Center(child: Text('لا توجد منتجات'));
      },
    );
  }

  Widget _buildProductTable(
    BuildContext context,
    ProductsLoaded state,
    String categoryFilter,
  ) {
    final filteredProducts = state.products.where((p) {
      final category = state.categories.firstWhere(
        (c) => c.id == p.categoryId,
        orElse: () => Category(id: -1, name: ''),
      );

      final matchesCategory =
          category.name.contains(categoryFilter) ||
          (categoryFilter == 'عام' &&
              ![
                'هواتف',
                'لاب توب',
                'ملحقات',
              ].any((s) => category.name.contains(s)));

      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(query) ||
          (p.processor?.toLowerCase().contains(query) ?? false) ||
          (p.model?.toLowerCase().contains(query) ?? false) ||
          (p.manufacturer?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();

    List<DataColumn> columns;
    if (categoryFilter == 'هواتف') {
      columns = const [
        DataColumn(label: Text('الاسم')),
        DataColumn(label: Text('الموديل')),
        DataColumn(label: Text('الرام')),
        DataColumn(label: Text('التخزين')),
        DataColumn(label: Text('اللون')),
        DataColumn(label: Text('السعر')),
        DataColumn(label: Text('المخزون')),
        DataColumn(label: Text('إجراءات')),
      ];
    } else if (categoryFilter == 'لاب توب') {
      columns = const [
        DataColumn(label: Text('الاسم')),
        DataColumn(label: Text('المعالج')),
        DataColumn(label: Text('الرام')),
        DataColumn(label: Text('التخزين')),
        DataColumn(label: Text('كرت الشاشة')),
        DataColumn(label: Text('لمس')),
        DataColumn(label: Text('السعر')),
        DataColumn(label: Text('المخزون')),
        DataColumn(label: Text('إجراءات')),
      ];
    } else if (categoryFilter == 'ملحقات') {
      columns = const [
        DataColumn(label: Text('اسم الملحق')),
        DataColumn(label: Text('الوصف')),
        DataColumn(label: Text('السعر')),
        DataColumn(label: Text('المخزون')),
        DataColumn(label: Text('إجراءات')),
      ];
    } else {
      columns = const [
        DataColumn(label: Text('اسم المنتج')),
        DataColumn(label: Text('التصنيف')),
        DataColumn(label: Text('السعر')),
        DataColumn(label: Text('المخزون')),
        DataColumn(label: Text('إجراءات')),
      ];
    }

    return AppPaginatedDataTable(
      minWidth: 1000,
      onSearch: (q) => setState(() => _searchQuery = q),
      header: Row(
        children: [
          Icon(Icons.list, color: Colors.blue, size: 24.r),
          SizedBox(width: 8.w),
          Text('قائمة $categoryFilter'),
        ],
      ),
      actions: [
        _buildDirectAddButton(context, _tabController.index, isCompact: true),
      ],
      columns: columns,
      source: ProductsTableSource(
        products: filteredProducts,
        categories: state.categories,
        type: categoryFilter,
        onEdit: (product) =>
            _navigateToEdit(context, product, state.categories),
        onDelete: (product) => _confirmDelete(context, product),
      ),
    );
  }

  void _navigateToEdit(
    BuildContext context,
    Product product,
    List<Category> categories,
  ) {
    final category = categories.firstWhere(
      (c) => c.id == product.categoryId,
      orElse: () => Category(id: -1, name: ''),
    );

    final name = category.name.trim().toLowerCase();

    // Check for Laptop categories
    if (name.contains('لاب') ||
        name.contains('توب') ||
        name.contains('كمبيوتر') ||
        name.contains('laptop') ||
        name.contains('pc') ||
        name.contains('computer')) {
      context.read<NavigationCubit>().setScreen(
        NavigationScreen.editLaptop,
        data: product,
      );
    }
    // Check for Phone categories
    else if (name.contains('هاتف') ||
        name.contains('هواتف') ||
        name.contains('جوال') ||
        name.contains('موبايل') ||
        name.contains('phone') ||
        name.contains('mobile')) {
      context.read<NavigationCubit>().setScreen(
        NavigationScreen.editPhone,
        data: product,
      );
    }
    // Check for Accessory categories
    else if (name.contains('ملحق') ||
        name.contains('إكسسوار') ||
        name.contains('اكسسوار') ||
        name.contains('accessory') ||
        name.contains('accessories')) {
      context.read<NavigationCubit>().setScreen(
        NavigationScreen.editAccessory,
        data: product,
      );
    }
    // Default to general product screen
    else {
      context.read<NavigationCubit>().setScreen(
        NavigationScreen.editProduct,
        data: product,
      );
    }
  }

  Widget _buildDirectAddButton(
    BuildContext context,
    int tabIndex, {
    bool isCompact = false,
  }) {
    final screen = _getAddScreen(tabIndex);
    final label = _getAddLabel(tabIndex);
    final icon = _getAddIcon(tabIndex);

    if (isCompact) {
      return InkWell(
        onTap: () => context.read<NavigationCubit>().setScreen(screen),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18.r, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => context.read<NavigationCubit>().setScreen(screen),
      icon: Icon(icon, size: 20.r),
      label: Text(label, style: TextStyle(fontSize: 14.sp)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  NavigationScreen _getAddScreen(int index) {
    switch (index) {
      case 0:
        return NavigationScreen.addPhone;
      case 1:
        return NavigationScreen.addLaptop;
      case 2:
        return NavigationScreen.addAccessory;
      case 3:
      default:
        return NavigationScreen.addProduct;
    }
  }

  String _getAddLabel(int index) {
    switch (index) {
      case 0:
        return 'إضافة هاتف جديد';
      case 1:
        return 'إضافة لاب توب جديد';
      case 2:
        return 'إضافة ملحق جديد';
      case 3:
      default:
        return 'إضافة منتج عام';
    }
  }

  IconData _getAddIcon(int index) {
    switch (index) {
      case 0:
        return Icons.phone_android;
      case 1:
        return Icons.laptop;
      case 2:
        return Icons.shutter_speed;
      case 3:
      default:
        return Icons.inventory;
    }
  }

  Widget _buildAddProductMenu(BuildContext context, {bool isCompact = false}) {
    return _buildDirectAddButton(
      context,
      _tabController.index,
      isCompact: isCompact,
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف ${product.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (product.id != null) {
                context.read<ProductsCubit>().deleteProduct(product.id!);
              }
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ProductsTableSource extends DataTableSource {
  final List<Product> products;
  final List<Category> categories;
  final String type;
  final Function(Product) onEdit;
  final Function(Product) onDelete;

  ProductsTableSource({
    required this.products,
    required this.categories,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];
    final category = categories.firstWhere(
      (c) => c.id == product.categoryId,
      orElse: () => Category(id: -1, name: 'غير محدد'),
    );

    List<DataCell> cells = [];
    if (type == 'هواتف') {
      cells = [
        DataCell(
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(product.model ?? '-')),
        DataCell(Text(product.ram ?? '-')),
        DataCell(Text(product.storage ?? '-')),
        DataCell(Text(product.color ?? '-')),
        DataCell(Text('${NumberFormat('#,##0').format(product.price)} SDG')),
        DataCell(Text('${product.stock}')),
      ];
    } else if (type == 'لاب توب') {
      cells = [
        DataCell(
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(product.processor ?? '-')),
        DataCell(Text(product.ram ?? '-')),
        DataCell(Text(product.storage ?? '-')),
        DataCell(Text(product.gpu ?? '-')),
        DataCell(Text((product.isTouchScreen ?? false) ? 'نعم' : 'لا')),
        DataCell(Text('${NumberFormat('#,##0').format(product.price)} SDG')),
        DataCell(Text('${product.stock}')),
      ];
    } else if (type == 'ملحقات') {
      cells = [
        DataCell(
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(product.description ?? '-')),
        DataCell(Text('${NumberFormat('#,##0').format(product.price)} SDG')),
        DataCell(Text('${product.stock}')),
      ];
    } else {
      cells = [
        DataCell(
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(category.name)),
        DataCell(Text('${NumberFormat('#,##0').format(product.price)} SDG')),
        DataCell(Text('${product.stock}')),
      ];
    }

    // Add Actions Cell
    cells.add(
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.edit,
              color: Colors.cyan,
              onPressed: () => onEdit(product),
            ),
            SizedBox(width: 8.w),
            _buildActionButton(
              icon: Icons.delete,
              color: Colors.red,
              onPressed: () => onDelete(product),
            ),
          ],
        ),
      ),
    );

    return DataRow(cells: cells);
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 18.r, color: Colors.white),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}
