import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsCubit(RepositoryProvider.of<AppDatabase>(context))
            ..loadSettings(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _generalFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  final _currencyController = TextEditingController();
  final _lowStockController = TextEditingController();

  final _paymentMethodController = TextEditingController();
  bool _pmActive = true;

  bool _showPrice = true;
  bool _showImage = true;

  AppSettings? _originalSettings;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    _currencyController.dispose();
    _lowStockController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _initFields(AppSettings settings) {
    if (_originalSettings == settings) return;
    _originalSettings = settings;
    _nameController.text = settings.pharmacyName;
    _phoneController.text = settings.phone ?? '';
    _addressController.text = settings.address ?? '';
    _emailController.text = settings.email ?? '';
    _hoursController.text = settings.workingHours ?? '';
    _currencyController.text = settings.currency;
    _lowStockController.text = settings.lowStockLimit.toString();
    _showPrice = settings.showPrice;
    _showImage = settings.showImage;
  }

  void _saveGeneral() {
    if (_generalFormKey.currentState?.validate() ?? false) {
      final updated = AppSettings(
        id: _originalSettings?.id,
        pharmacyName: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        email: _emailController.text,
        workingHours: _hoursController.text,
        currency: _currencyController.text,
        lowStockLimit: int.tryParse(_lowStockController.text) ?? 10,
        showPrice: _showPrice,
        showImage: _showImage,
        logoPath: _originalSettings?.logoPath, // For now keep it
      );
      context.read<SettingsCubit>().updateSettings(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsLoaded) {
            _initFields(state.settings);
            return _buildContent(state);
          }
          return const Center(child: Text('جاري التحميل...'));
        },
      ),
    );
  }

  Widget _buildContent(SettingsLoaded state) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right Column: General & Interface
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildGeneralSettingsCard(),
                      SizedBox(height: 24.h),
                      _buildInterfaceSettingsCard(),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                // Left Column: Payment Methods & Danger Zone
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildPaymentMethodsCard(state.paymentMethods),
                      SizedBox(height: 24.h),
                      _buildDangerZoneCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFFEE2E2)),
      ),
      color: const Color(0xFFFEF2F2),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'منطقة الخطورة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'هذا الإجراء سيقوم بمسح كافة البيانات (المنتجات، المبيعات، المشتريات، الخ) ولن تتمكن من التراجع عن ذلك. سيتم الإبقاء على حسابات المستخدمين فقط.',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showResetConfirmation,
                icon: const Icon(Icons.delete_forever),
                label: const Text('تصفير كافة البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تأكيد مسح البيانات', style: GoogleFonts.cairo()),
        content: Text(
          'هل أنت متأكد من رغبتك في مسح كافة البيانات؟ سيتم فقدان جميع المنتجات والعمليات المخزنة.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SettingsCubit>().resetDatabase();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'نعم، امسح كل شيء',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات النظام',
          style: GoogleFonts.cairo(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'تخصيص معلومات الصيدلية وإعدادات الواجهة والمشتريات',
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettingsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _generalFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                Icons.business_rounded,
                'معلومات الصيدلية العامة',
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  _buildLogoUpload(),
                  SizedBox(width: 32.w),
                  Expanded(
                    child: Column(
                      children: [
                        _buildInputField(
                          'اسم الصيدلية *',
                          _nameController,
                          Icons.store,
                        ),
                        SizedBox(height: 16.h),
                        _buildInputField(
                          'رقم الهاتف',
                          _phoneController,
                          Icons.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      'العنوان',
                      _addressController,
                      Icons.location_on,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildInputField(
                      'البريد الإلكتروني',
                      _emailController,
                      Icons.email,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInputField(
                'ساعات العمل',
                _hoursController,
                Icons.access_time_filled,
              ),
              SizedBox(height: 32.h),
              Align(
                alignment: Alignment.centerLeft,
                child: _buildPrimaryButton(
                  'حفظ الإعدادات العامة',
                  _saveGeneral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterfaceSettingsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              Icons.settings_suggest_rounded,
              'إعدادات الواجهة والمخزون',
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'العملة المستخدمة',
                    _currencyController,
                    Icons.monetization_on,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildInputField(
                    'تنبيه نقص المخزون (أقل من)',
                    _lowStockController,
                    Icons.warning_rounded,
                    isNumeric: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            const Divider(color: Color(0xFFF1F5F9)),
            SizedBox(height: 16.h),
            _buildToggleItem(
              'إظهار الأسعار في واجهة البحث',
              _showPrice,
              (v) => setState(() => _showPrice = v),
            ),
            _buildToggleItem(
              'إظهار صور الأدوية في واجهة البحث',
              _showImage,
              (v) => setState(() => _showImage = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(List<PaymentMethod> methods) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.payments_rounded, 'إدارة طرق الدفع'),
            SizedBox(height: 24.h),
            _buildInputField(
              'اسم وسيلة الدفع',
              _paymentMethodController,
              Icons.payment,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                const Text('نشطة؟'),
                const Spacer(),
                Switch(
                  value: _pmActive,
                  onChanged: (v) => setState(() => _pmActive = v),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: _buildPrimaryButton('إضافة وسيلة دفع', () {
                if (_paymentMethodController.text.isNotEmpty) {
                  context.read<SettingsCubit>().addPaymentMethod(
                    _paymentMethodController.text,
                  );
                  _paymentMethodController.clear();
                }
              }),
            ),
            SizedBox(height: 24.h),
            const Divider(color: Color(0xFFF1F5F9)),
            SizedBox(height: 16.h),
            ...methods.map((m) => _buildPaymentMethodItem(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: const Color(0xFF0D6EFD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: const Color(0xFF0D6EFD), size: 20.r),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.cairo(fontSize: 14.sp),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18.r, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Color(0xFF0D6EFD),
                width: 1.5,
              ),
            ),
          ),
          validator: (v) =>
              v!.isEmpty && label.contains('*') ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildLogoUpload() {
    return Column(
      children: [
        Container(
          width: 120.r,
          height: 120.r,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Icon(
              Icons.image,
              size: 48.r,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.upload_file, size: 16.r),
          label: Text(
            'تغيير الشعار',
            style: GoogleFonts.cairo(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: const Color(0xFF475569),
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D6EFD),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod m) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  m.isActive ? 'نشطة' : 'معطلة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: m.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildSmallActionBtn(Icons.edit, Colors.cyan, () {
              // Edit logic
            }),
            SizedBox(width: 8.w),
            _buildSmallActionBtn(Icons.delete, Colors.red, () {
              context.read<SettingsCubit>().deletePaymentMethod(m.id!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, size: 16.r, color: color),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
    );
  }
}
