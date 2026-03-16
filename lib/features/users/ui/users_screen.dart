import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../../../core/widgets/app_paginated_data_table.dart';
import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UsersCubit(RepositoryProvider.of<AppDatabase>(context))..loadUsers(),
      child: const UsersView(),
    );
  }
}

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _branchController = TextEditingController();
  String _role = 'seller';
  bool _isActive = true;
  User? _editingUser;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = User(
        id: _editingUser?.id,
        name: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        role: _role,
        branch: _branchController.text,
        isActive: _isActive,
      );

      if (_editingUser == null) {
        context.read<UsersCubit>().addUser(user);
      } else {
        context.read<UsersCubit>().updateUser(user);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _editingUser = null;
      _nameController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _branchController.clear();
      _role = 'seller';
      _isActive = true;
    });
  }

  void _onEdit(User user) {
    setState(() {
      _editingUser = user;
      _nameController.text = user.name ?? '';
      _usernameController.text = user.username;
      _passwordController.text = user.password;
      _role = user.role;
      _branchController.text = user.branch ?? '';
      _isActive = user.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersCubit, UsersState>(
      listener: (context, state) {
        if (state is UserActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        } else if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<User> users = state is UsersLoaded ? state.users : [];
          final filteredUsers = users.where((user) {
            final query = _searchQuery.toLowerCase();
            return (user.name?.toLowerCase().contains(query) ?? false) ||
                user.username.toLowerCase().contains(query) ||
                (user.branch?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Container(
            color: const Color(0xFFF0F2F5),
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المستخدمين',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right: Add/Edit Form
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(20.0.r),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _editingUser == null
                                              ? Icons.person_add_alt_outlined
                                              : Icons.person_outline,
                                          color: Colors.blue,
                                          size: 24.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _editingUser == null
                                              ? 'إضافة مستخدم جديد'
                                              : 'تعديل بيانات المستخدم',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: _inputDecoration(
                                        'الاسم الكامل',
                                      ),
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    SizedBox(height: 16.h),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: _inputDecoration(
                                        'اسم المستخدم',
                                      ),
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    SizedBox(height: 16.h),
                                    TextFormField(
                                      controller: _passwordController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: _inputDecoration(
                                        'كلمة المرور',
                                      ),
                                      obscureText: true,
                                      validator: (v) =>
                                          v!.isEmpty ? 'مطلوب' : null,
                                    ),
                                    SizedBox(height: 16.h),
                                    TextFormField(
                                      controller: _branchController,
                                      style: TextStyle(fontSize: 14.sp),
                                      decoration: _inputDecoration('الفرع'),
                                    ),
                                    SizedBox(height: 16.h),
                                    DropdownButtonFormField<String>(
                                      value: _role,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                      ),
                                      decoration: _inputDecoration('الصلاحية'),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'admin',
                                          child: Text('مدير'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'seller',
                                          child: Text('بائع'),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _role = v!),
                                    ),
                                    SizedBox(height: 16.h),
                                    SwitchListTile(
                                      title: Text(
                                        'الحساب نشط',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      value: _isActive,
                                      onChanged: (v) =>
                                          setState(() => _isActive = v),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    SizedBox(height: 20.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45.h,
                                      child: ElevatedButton.icon(
                                        onPressed: _onSave,
                                        icon: Icon(
                                          _editingUser == null
                                              ? Icons.add
                                              : Icons.save,
                                          size: 18.r,
                                        ),
                                        label: Text(
                                          _editingUser == null
                                              ? 'إضافة مستخدم'
                                              : 'حفظ التعديلات',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_editingUser != null) ...[
                                      SizedBox(height: 8.h),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: _resetForm,
                                          child: Text(
                                            'إلغاء التعديل',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24.w),
                      // Left: Users Table
                      Expanded(
                        flex: 2,
                        child: AppPaginatedDataTable(
                          minWidth: 800,
                          onSearch: (q) => setState(() => _searchQuery = q),
                          searchPlaceholder: 'مثال بحث (اسم، مستخدم، فرع)...',
                          header: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.blue,
                                size: 24.r,
                              ),
                              SizedBox(width: 8.w),
                              const Text('قائمة المستخدمين'),
                            ],
                          ),
                          columns: const [
                            DataColumn(label: Text('الاسم الكامل')),
                            DataColumn(label: Text('اسم المستخدم')),
                            DataColumn(label: Text('الفرع')),
                            DataColumn(label: Text('الصلاحية')),
                            DataColumn(label: Text('الحالة')),
                            DataColumn(label: Text('إجراءات')),
                          ],
                          source: UsersTableSource(
                            users: filteredUsers,
                            onEdit: _onEdit,
                            onDelete: (user) => _confirmDelete(context, user),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14.sp),
      border: const OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف المستخدم',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف المستخدم ${user.username}؟',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (user.id != null)
                context.read<UsersCubit>().deleteUser(user.id!);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class UsersTableSource extends DataTableSource {
  final List<User> users;
  final Function(User) onEdit;
  final Function(User) onDelete;

  UsersTableSource({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(
      cells: [
        DataCell(Text(user.name ?? '-')),
        DataCell(
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(user.branch ?? '-')),
        DataCell(Text(user.role == 'admin' ? 'مدير' : 'بائع')),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: user.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              user.isActive ? 'نشط' : 'غير نشط',
              style: TextStyle(
                color: user.isActive ? Colors.green : Colors.red,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.cyan,
                onPressed: () => onEdit(user),
              ),
              SizedBox(width: 8.w),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: () => onDelete(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 18.r, color: color),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}
