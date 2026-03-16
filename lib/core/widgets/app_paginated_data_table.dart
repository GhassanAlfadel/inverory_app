import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';

class AppPaginatedDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  final Widget? header;
  final List<Widget>? actions;
  final int initialRowsPerPage;
  final bool showCheckboxColumn;
  final double? columnSpacing;
  final double? horizontalMargin;
  final void Function(int?)? onRowsPerPageChanged;
  final int? initialFirstRowIndex;
  final void Function(int)? onPageChanged;
  final double? minWidth;

  final void Function(String)? onSearch;
  final String? searchPlaceholder;

  const AppPaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.header,
    this.actions,
    this.initialRowsPerPage = 10,
    this.showCheckboxColumn = false,
    this.columnSpacing,
    this.horizontalMargin,
    this.onRowsPerPageChanged,
    this.initialFirstRowIndex,
    this.onPageChanged,
    this.minWidth,
    this.onSearch,
    this.searchPlaceholder,
  });

  @override
  State<AppPaginatedDataTable> createState() => _AppPaginatedDataTableState();
}

class _AppPaginatedDataTableState extends State<AppPaginatedDataTable> {
  late int _rowsPerPage;
  final List<int> _availableRowsPerPage = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.initialRowsPerPage;
    // Ensure initial value is in the available list to prevent dropdown issues
    if (!_availableRowsPerPage.contains(_rowsPerPage)) {
      _availableRowsPerPage.add(_rowsPerPage);
      _availableRowsPerPage.sort();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          color: Colors.white,
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyMedium: GoogleFonts.cairo(
            fontSize: 13.sp,
            color: const Color(0xFF475569),
          ),
          bodySmall: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.black),
        ),
        dataTableTheme: DataTableThemeData(
          dividerThickness: 1.0,
          headingTextStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: const Color(0xFF334155),
          ),
          dataTextStyle: GoogleFonts.cairo(
            fontSize: 13.sp,
            color: const Color(0xFF475569),
          ),
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        ),
      ),
      child: PaginatedDataTable2(
        border: TableBorder(
          top: const BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
          right: BorderSide(color: Colors.grey[300]!),
          verticalInside: BorderSide(color: Colors.grey[300]!),
          horizontalInside: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        header: widget.header,
        actions: [
          if (widget.onSearch != null)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: SizedBox(
                width: 250.w,
                child: TextField(
                  onChanged: widget.onSearch,
                  style: GoogleFonts.cairo(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: widget.searchPlaceholder ?? 'بحث...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.r,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12.w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
            ),
          ...?widget.actions,
        ],
        columns: widget.columns,
        source: widget.source,
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: _availableRowsPerPage,
        showCheckboxColumn: widget.showCheckboxColumn,
        columnSpacing: widget.columnSpacing ?? 30.w,
        horizontalMargin: widget.horizontalMargin ?? 16.w,
        minWidth: widget.minWidth ?? 600,
        fit: FlexFit.tight,
        renderEmptyRowsInTheEnd: false,
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _rowsPerPage = value;
            });
            if (widget.onRowsPerPageChanged != null) {
              widget.onRowsPerPageChanged!(value);
            }
          }
        },
        initialFirstRowIndex: widget.initialFirstRowIndex,
        onPageChanged: widget.onPageChanged,
        showFirstLastButtons: true,
      ),
    );
  }
}
