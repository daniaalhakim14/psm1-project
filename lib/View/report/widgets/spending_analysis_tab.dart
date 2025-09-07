import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../Model/signupLoginpage.dart';
import '../../../Model/report.dart';
import '../../../ViewModel/report/report_viewmodel.dart';

class SpendingAnalysisTab extends StatefulWidget {
  final UserInfoModule userInfo;

  const SpendingAnalysisTab({super.key, required this.userInfo});

  @override
  State<SpendingAnalysisTab> createState() => _SpendingAnalysisTabState();
}

class _SpendingAnalysisTabState extends State<SpendingAnalysisTab> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ms_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );

  bool _showActiveDays = true; // Toggle between active days and calendar days

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, reportViewModel, child) {
        if (reportViewModel.isLoadingExpenseSummary) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading spending analysis...'),
              ],
            ),
          );
        }

        if (reportViewModel.expenseSummary == null) {
          return _buildEmptyState();
        }

        final summary = reportViewModel.expenseSummary!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // KPI Cards
              _buildKpiCards(summary),
              const SizedBox(height: 20),

              // Daily Spending Chart
              _buildDailySpendingChart(summary),
              const SizedBox(height: 20),

              // Category Breakdown Chart
              _buildCategoryBreakdownChart(summary),
              const SizedBox(height: 20),

              // Platform Breakdown Chart
              _buildPlatformBreakdownChart(summary),
              const SizedBox(height: 20),

              // Top 5 Expenses List
              _buildTop5ExpensesList(summary),
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
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No spending data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see your spending analysis.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCards(ExpenseSummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Total Spent',
                _currencyFormat.format(summary.totals.sum),
                Icons.account_balance_wallet,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showActiveDays = !_showActiveDays;
                  });
                },
                child: _buildKpiCard(
                  _showActiveDays
                      ? 'Daily Avg (Active)'
                      : 'Daily Avg (Calendar)',
                  _currencyFormat.format(
                    _showActiveDays
                        ? summary.dailyAverageSpending.activeDays
                        : summary.dailyAverageSpending.calendarDays,
                  ),
                  Icons.today,
                  Colors.blue,
                  showTooltip: true,
                  tooltipMessage:
                      'Tap to toggle between active days and calendar days',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Monthly Average',
                _currencyFormat.format(summary.monthlyAverageSpending),
                Icons.calendar_month,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                'Biggest Category',
                '${summary.biggestExpenseCategory.name}\n${_currencyFormat.format(summary.biggestExpenseCategory.sum)}',
                Icons.category,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Most Used (Count)',
                '${summary.mostUsedFinancialPlatform.byCount.name}\n${summary.mostUsedFinancialPlatform.byCount.count} transactions',
                Icons.payment,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                'Most Used (Amount)',
                '${summary.mostUsedFinancialPlatform.byAmount.name}\n${_currencyFormat.format(summary.mostUsedFinancialPlatform.byAmount.sum)}',
                Icons.credit_card,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool showTooltip = false,
    String? tooltipMessage,
  }) {
    Widget card = Container(
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

    if (showTooltip && tooltipMessage != null) {
      return Tooltip(message: tooltipMessage, child: card);
    }

    return card;
  }

  Widget _buildDailySpendingChart(ExpenseSummary summary) {
    if (summary.timeSeriesDaily.isEmpty) {
      return _buildChartContainer(
        title: 'Daily Spending Trend',
        child: const Center(
          child: Text(
            'No daily spending data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final spots =
        summary.timeSeriesDaily.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.sum);
        }).toList();

    return _buildChartContainer(
      title: 'Daily Spending Trend',
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _currencyFormat.format(value).replaceAll('RM', 'RM'),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < summary.timeSeriesDaily.length) {
                      final date = DateTime.parse(
                        summary.timeSeriesDaily[value.toInt()].date,
                      );
                      return Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF5A7BE7),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF5A7BE7).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart(ExpenseSummary summary) {
    if (summary.breakdownByCategory.isEmpty) {
      return _buildChartContainer(
        title: 'Category Breakdown',
        child: const Center(
          child: Text(
            'No category data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final sections =
        summary.breakdownByCategory.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.pink,
            Colors.indigo,
          ];

          return PieChartSectionData(
            value: category.sum,
            title:
                '${((category.sum / summary.totals.sum) * 100).toStringAsFixed(1)}%',
            color: colors[index % colors.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return _buildChartContainer(
      title: 'Category Breakdown',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(summary.breakdownByCategory),
        ],
      ),
    );
  }

  Widget _buildPlatformBreakdownChart(ExpenseSummary summary) {
    if (summary.breakdownByPlatform.isEmpty) {
      return _buildChartContainer(
        title: 'Platform Breakdown',
        child: const Center(
          child: Text(
            'No platform data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxValue = summary.breakdownByPlatform
        .map((p) => p.sum)
        .reduce((a, b) => a > b ? a : b);

    return _buildChartContainer(
      title: 'Platform Breakdown',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            summary.breakdownByPlatform.asMap().entries.map((entry) {
              final index = entry.key;
              final platform = entry.value;
              final percentage = (platform.sum / maxValue) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        platform.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                          ][index % 5],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currencyFormat.format(platform.sum),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTop5ExpensesList(ExpenseSummary summary) {
    if (summary.top5Expenses.isEmpty) {
      return _buildChartContainer(
        title: 'Top 5 Expenses',
        child: const Center(
          child: Text(
            'No expense data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return _buildChartContainer(
      title: 'Top 5 Expenses',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            summary.top5Expenses.map((expense) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF5A7BE7),
                    child: Text(
                      expense.name.isNotEmpty
                          ? expense.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    expense.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    expense.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text(
                    _currencyFormat.format(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A7BE7),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLegend(List<CategoryBreakdown> categories) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(category.name, style: const TextStyle(fontSize: 11)),
              ],
            );
          }).toList(),
    );
  }
}
