import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ViewModel/report/report_viewmodel.dart';
import '../../../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class ReportFilters extends StatefulWidget {
  const ReportFilters({super.key});

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportViewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Period Selection
              Row(
                children: [
                  Expanded(
                    child: _buildPeriodChip(
                      'This Month',
                      reportViewModel.filters.period == 'month' &&
                          reportViewModel.filters.year == DateTime.now().year &&
                          reportViewModel.filters.month == DateTime.now().month,
                      () => _setThisMonth(reportViewModel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPeriodChip(
                      'Last Month',
                      _isLastMonth(reportViewModel),
                      () => _setLastMonth(reportViewModel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPeriodChip(
                      'Year to Date',
                      reportViewModel.filters.period == 'year' &&
                          reportViewModel.filters.year == DateTime.now().year,
                      () => _setYearToDate(reportViewModel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Custom Period Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Type Toggle
                  Row(
                    children: [
                      Radio<String>(
                        value: 'month',
                        groupValue: reportViewModel.filters.period,
                        onChanged:
                            (value) => _setPeriod(reportViewModel, value!),
                        activeColor: const Color(0xFF5A7BE7),
                      ),
                      const Text('Month'),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'year',
                        groupValue: reportViewModel.filters.period,
                        onChanged:
                            (value) => _setPeriod(reportViewModel, value!),
                        activeColor: const Color(0xFF5A7BE7),
                      ),
                      const Text('Year'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date Pickers Row
                  Row(
                    children: [
                      // Month Picker (if period is month)
                      if (reportViewModel.filters.period == 'month')
                        Expanded(child: _buildMonthPicker(reportViewModel)),

                      if (reportViewModel.filters.period == 'month')
                        const SizedBox(width: 12),

                      // Year Picker
                      Expanded(child: _buildYearPicker(reportViewModel)),
                    ],
                  ),
                ],
              ),

              // Apply Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      reportViewModel.isLoading
                          ? null
                          : () => _applyFilters(reportViewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A7BE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      reportViewModel.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Apply Filters',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5A7BE7) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5A7BE7) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPicker(ReportViewModel reportViewModel) {
    return DropdownButtonFormField<int>(
      value: reportViewModel.filters.month,
      decoration: InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
      items: List.generate(12, (index) {
        final month = index + 1;
        return DropdownMenuItem(
          value: month,
          child: Text(
            _getMonthName(month),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          reportViewModel.setMonth(value);
        }
      },
    );
  }

  Widget _buildYearPicker(ReportViewModel reportViewModel) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return DropdownButtonFormField<int>(
      value: reportViewModel.filters.year,
      decoration: InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
      items:
          years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(
                year.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          reportViewModel.setYear(value);
        }
      },
    );
  }

  bool _isLastMonth(ReportViewModel reportViewModel) {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    return reportViewModel.filters.period == 'month' &&
        reportViewModel.filters.year == lastMonth.year &&
        reportViewModel.filters.month == lastMonth.month;
  }

  void _setThisMonth(ReportViewModel reportViewModel) {
    reportViewModel.setThisMonth();
    _applyFilters(reportViewModel);
  }

  void _setLastMonth(ReportViewModel reportViewModel) {
    reportViewModel.setLastMonth();
    _applyFilters(reportViewModel);
  }

  void _setYearToDate(ReportViewModel reportViewModel) {
    reportViewModel.setYearToDate();
    _applyFilters(reportViewModel);
  }

  void _setPeriod(ReportViewModel reportViewModel, String period) {
    reportViewModel.setPeriod(period);
  }

  void _applyFilters(ReportViewModel reportViewModel) {
    final authViewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );

    if (authViewModel.userInfo != null && authViewModel.authToken != null) {
      reportViewModel.fetchAllReports(
        authViewModel.userInfo!.id,
        authViewModel.authToken!,
      );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
