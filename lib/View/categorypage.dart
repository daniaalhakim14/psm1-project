import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/expense/expense_viewmodel.dart';

class categoryPage extends StatefulWidget {
  //final int userid;
  //const CategoryPage({super.key, required this.userid});
  const categoryPage({super.key});

  @override
  State<categoryPage> createState() => _categoryPageState();
}

class _categoryPageState extends State<categoryPage> {
  NavigatorState? _navigatorState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigatorState = Navigator.of(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final viewModel = Provider.of<expenseViewModel>(context, listen: false);
      if (!viewModel.fetchingData && viewModel.categoryList.isEmpty) {
        viewModel.fetchCategories();
        //print('Fetched categories: ${viewModel.category.length}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Category Name',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<expenseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.fetchingData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.categoryList.isEmpty) {
            return const Center(child: Text('No Categories available'));
          }

          // Print debug information
          /*
          for (var category in viewModel.category) {
            print('Category: ${category.categoryId}, ${category.categoryName}, ${category.iconData}, ${category.iconColor}');
          }

           */

          // Precompute category icons and colors
          final Map<String, int> categoryId = {};
          final Map<String, IconData> categoryIcons = {};
          final Map<String, Color> categoryColors = {};

          for (var category in viewModel.categoryList) {
            if (category.categoryName != null && category.categoryId != null) {
              if (!categoryIcons.containsKey(category.categoryName)) {
                categoryId[category.categoryName!] = category.categoryId!;
                categoryIcons[category.categoryName!] = category.iconData!;
                categoryColors[category.categoryName!] = category.iconColor!;
              }
            }
          }

          return ListView.builder(
            itemCount: viewModel.categoryList.length,
            itemBuilder: (context, index) {
              final category = viewModel.categoryList[index];
              return GestureDetector(
                onTap: () {
                  final selectedCategory = {
                    'categoryId': category.categoryId,
                    'name': category.categoryName,
                    'icon': category.iconData,
                    'color': category.iconColor,
                  };
                  _navigatorState?.pop(selectedCategory);
                },
                child: Container(
                  width: 330,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: 47,
                          height: 47,
                          decoration: BoxDecoration(
                            color: category.iconColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              category.iconData,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            category.categoryName.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
