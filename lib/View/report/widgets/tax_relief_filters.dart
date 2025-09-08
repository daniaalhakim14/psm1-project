import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ViewModel/report/report_viewmodel.dart';
import '../../../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class TaxReliefFilters extends StatefulWidget {
  const TaxReliefFilters({super.key});

  @override
  State<TaxReliefFilters> createState() => _TaxReliefFiltersState();
}

class _TaxReliefFiltersState extends State<TaxReliefFilters> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportViewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Year Selection Chips
              Row(
                children: [
                  Expanded(
                    child: _buildYearChip(
                      'This Year',
                      reportViewModel.filters.year == DateTime.now().year,
                      () => _setThisYear(reportViewModel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildYearChip(
                      'Last Year',
                      reportViewModel.filters.year == DateTime.now().year - 1,
                      () => _setLastYear(reportViewModel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildYearChip(
                      '2 Years Ago',
                      reportViewModel.filters.year == DateTime.now().year - 2,
                      () => _setTwoYearsAgo(reportViewModel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Custom Year Selection
              Row(
                children: [
                  const Text(
                    'Or select a specific year:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildYearPicker(reportViewModel)),
                ],
              ),

              // Apply Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      reportViewModel.isLoadingTaxRelief
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
                      reportViewModel.isLoadingTaxRelief
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
                            'Apply Filter',
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

  Widget _buildYearChip(String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildYearPicker(ReportViewModel reportViewModel) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - index);

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
          // Force to year period when year is changed
          reportViewModel.setPeriod('year');
        }
      },
    );
  }

  void _setThisYear(ReportViewModel reportViewModel) {
    reportViewModel.setYear(DateTime.now().year);
    reportViewModel.setPeriod('year');
    _applyFilters(reportViewModel);
  }

  void _setLastYear(ReportViewModel reportViewModel) {
    reportViewModel.setYear(DateTime.now().year - 1);
    reportViewModel.setPeriod('year');
    _applyFilters(reportViewModel);
  }

  void _setTwoYearsAgo(ReportViewModel reportViewModel) {
    reportViewModel.setYear(DateTime.now().year - 2);
    reportViewModel.setPeriod('year');
    _applyFilters(reportViewModel);
  }

  void _applyFilters(ReportViewModel reportViewModel) {
    final authViewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );

    if (authViewModel.userInfo != null && authViewModel.authToken != null) {
      // Only fetch tax relief data since this is tax relief specific filter
      reportViewModel.fetchTaxReliefEligible(
        authViewModel.userInfo!.id,
        authViewModel.authToken!,
      );
    }
  }
}
