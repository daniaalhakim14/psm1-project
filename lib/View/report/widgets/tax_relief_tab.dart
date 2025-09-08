import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Model/signupLoginpage.dart';
import '../../../Model/report.dart';
import '../../../ViewModel/report/report_viewmodel.dart';

class TaxReliefTab extends StatefulWidget {
  final UserInfoModule userInfo;

  const TaxReliefTab({super.key, required this.userInfo});

  @override
  State<TaxReliefTab> createState() => _TaxReliefTabState();
}

class _TaxReliefTabState extends State<TaxReliefTab> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ms_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportViewModel, child) {
        if (reportViewModel.isLoadingTaxRelief) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading tax relief data...'),
              ],
            ),
          );
        }

        if (reportViewModel.taxReliefReport == null) {
          return _buildEmptyState();
        }

        final report = reportViewModel.taxReliefReport!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummaryCards(reportViewModel),
              const SizedBox(height: 20),

              // Tax Relief Categories
              if (report.categories.isNotEmpty)
                ...report.categories.map(
                  (category) => _buildTaxReliefCategory(category),
                )
              else
                _buildNoDataMessage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tax relief data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add eligible expenses to see your tax relief breakdown.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ReportViewModel reportViewModel) {
    return Column(
      children: [
        // Top row: Total Limit and Remaining
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Limit',
                _currencyFormat.format(reportViewModel.totalTaxReliefLimit),
                Icons.account_balance,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Remaining',
                _currencyFormat.format(reportViewModel.totalTaxReliefRemaining),
                Icons.savings,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Total Eligible (centered and wider)
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(), // Left spacer
            ),
            Expanded(
              flex: 2,
              child: _buildSummaryCard(
                'Total Eligible',
                _currencyFormat.format(reportViewModel.totalTaxReliefEligible),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(), // Right spacer
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxReliefCategory(TaxReliefCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF5A7BE7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.category, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.reliefcategory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${category.items.length} item${category.items.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Category Items
          if (category.items.isNotEmpty)
            ...category.items.map((item) => _buildTaxReliefItem(item))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No items in this category',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaxReliefItem(TaxReliefItem item) {
    final utilizationPercentage =
        item.itemClaimLimit > 0
            ? (item.itemTotalEligible / item.itemClaimLimit) * 100
            : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Header
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getUtilizationColor(
                    utilizationPercentage,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${utilizationPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getUtilizationColor(utilizationPercentage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amount Information
          Row(
            children: [
              Expanded(
                child: _buildAmountInfo(
                  'Eligible',
                  _currencyFormat.format(item.itemTotalEligible),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildAmountInfo(
                  'Limit',
                  _currencyFormat.format(item.itemClaimLimit),
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildAmountInfo(
                  'Remaining',
                  _currencyFormat.format(item.itemRemaining),
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value:
                item.itemClaimLimit > 0
                    ? item.itemTotalEligible / item.itemClaimLimit
                    : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getUtilizationColor(utilizationPercentage),
            ),
          ),
          const SizedBox(height: 16),

          // Expenses List
          if (item.expenses.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.receipt, color: Color(0xFF5A7BE7), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Eligible Expenses (${item.expenses.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A7BE7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...item.expenses.map((expense) => _buildExpenseItem(expense)),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'No eligible expenses found for this item',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(TaxReliefExpense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Receipt indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: expense.hasReceipt ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Expense details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Amount details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(expense.eligibleamount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (expense.amount != expense.eligibleamount)
                Text(
                  'of ${_currencyFormat.format(expense.amount)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Tax Relief Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tax relief categories found for the selected year.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getUtilizationColor(double percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 75) return Colors.orange;
    if (percentage >= 50) return Colors.yellow.shade700;
    return Colors.green;
  }
}
