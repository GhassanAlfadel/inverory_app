import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/suppliers_cubit.dart';
import '../cubit/suppliers_state.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SuppliersCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadSuppliers(),
      child: const SuppliersView(),
    );
  }
}

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  Supplier? _editingSupplier;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _editingSupplier = null;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
    });
  }

  void _editSupplier(Supplier supplier) {
    setState(() {
      _editingSupplier = supplier;
      _nameController.text = supplier.name;
      _phoneController.text = supplier.phone ?? '';
      _emailController.text = supplier.email ?? '';
      _addressController.text = supplier.address ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuppliersCubit, SuppliersState>(
      listener: (context, state) {
        if (state is SupplierActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: GoogleFonts.cairo())),
          );
          _resetForm();
        } else if (state is SuppliersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(24.0.r),
        color: const Color(0xFFF8F9FC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة الموردين',
              style: GoogleFonts.cairo(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right Column: Form
                  Expanded(flex: 2, child: _buildFormCard()),
                  SizedBox(width: 24.w),
                  // Left Column: List
                  Expanded(flex: 6, child: _buildListCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _editingSupplier == null
                        ? Icons.person_add_outlined
                        : Icons.edit_note_outlined,
                    color: const Color(0xFF0D6EFD),
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _editingSupplier == null
                        ? 'إضافة مورد جديد'
                        : 'تعديل بيانات مورد',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildLabel('اسم المورد/الشركة *'),
              _buildTextField(
                _nameController,
                'أدخل اسم المورد',
                validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              SizedBox(height: 16.h),
              _buildLabel('رقم الهاتف'),
              _buildTextField(
                _phoneController,
                '0123456789',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              _buildLabel('البريد الإلكتروني'),
              _buildTextField(
                _emailController,
                'example@mail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              _buildLabel('العنوان'),
              _buildTextField(
                _addressController,
                'العنوان الكامل',
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final supplier = Supplier(
                            id: _editingSupplier?.id,
                            name: _nameController.text,
                            phone: _phoneController.text,
                            email: _emailController.text,
                            address: _addressController.text,
                          );
                          if (_editingSupplier == null) {
                            context.read<SuppliersCubit>().addSupplier(
                              supplier,
                            );
                          } else {
                            context.read<SuppliersCubit>().updateSupplier(
                              supplier,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _editingSupplier == null
                            ? 'حفظ المورد'
                            : 'تحديث البيانات',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  if (_editingSupplier != null) ...[
                    SizedBox(width: 12.w),
                    OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 16.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF64748B),
                        size: 20.r,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return BlocBuilder<SuppliersCubit, SuppliersState>(
      builder: (context, state) {
        if (state is SuppliersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SuppliersLoaded) {
          return AppPaginatedDataTable(
            minWidth: 800,
            onSearch: (v) =>
                context.read<SuppliersCubit>().loadSuppliers(query: v),
            header: Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: const Color(0xFF0D6EFD),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'قائمة الموردين',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            columns: [
              DataColumn(label: _buildTableHeader('اسم المورد')),
              DataColumn(label: _buildTableHeader('الهاتف')),
              DataColumn(label: _buildTableHeader('البريد الإلكتروني')),
              DataColumn(label: _buildTableHeader('العنوان')),
              DataColumn(label: _buildTableHeader('إجراءات')),
            ],
            source: SuppliersTableSource(
              suppliers: state.suppliers,
              onEdit: _editSupplier,
              onDelete: _showDeleteDialog,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTableHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        fontSize: 13.sp,
        color: const Color(0xFF475569),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
        ),
      ),
    );
  }

  void _showDeleteDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'حذف مورد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف المورد "${supplier.name}"؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<SuppliersCubit>().deleteSupplier(supplier.id!);
              Navigator.pop(dialogContext);
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuppliersTableSource extends DataTableSource {
  final List<Supplier> suppliers;
  final Function(Supplier) onEdit;
  final Function(Supplier) onDelete;

  SuppliersTableSource({
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= suppliers.length) return null;
    final s = suppliers[index];

    return DataRow(
      cells: [
        DataCell(
          Text(
            s.name,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
        DataCell(
          Text(s.phone ?? '---', style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Text(s.email ?? '---', style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Text(s.address ?? '---', style: GoogleFonts.cairo(fontSize: 13.sp)),
        ),
        DataCell(
          Row(
            children: [
              _buildActionIcon(
                Icons.edit_outlined,
                const Color(0xFF0D6EFD),
                () => onEdit(s),
              ),
              SizedBox(width: 8.w),
              _buildActionIcon(Icons.delete_outline, Colors.red, () {
                onDelete(s);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, color: color, size: 18.r),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => suppliers.length;

  @override
  int get selectedRowCount => 0;
}
