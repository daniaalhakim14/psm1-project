import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/addexpense/addexpense_viewmodel.dart';


class CategoryPage extends StatefulWidget {
  //final int userid;
  //const CategoryPage({super.key, required this.userid});
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
      final viewModel = Provider.of<expenseCategoryViewModel>(context, listen: false);
      if (!viewModel.fetchingData && viewModel.category.isEmpty) {
        viewModel.fetchCategories();
        print('Fetched categories: ${viewModel.category.length}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white;
    final textColor = Colors.white;
    final appBarColor = const Color(0xFF65ADAD);
    final highlightColor = const Color(0xFF65ADAD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF65ADAD),
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
      body: Consumer<expenseCategoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.fetchingData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.category.isEmpty) {
            return const Center(child: Text('No Categories available'));
          }

          // Print debug information
          for (var category in viewModel.category) {
            print('Category: ${category.categoryid}, ${category.categoryname}, ${category.icondata}, ${category.iconcolor}');
          }

          // Precompute category icons and colors
          final Map<String, int> categoryId = {};
          final Map<String, IconData> categoryIcons = {};
          final Map<String, Color> categoryColors = {};

          for (var category in viewModel.category) {
            if (category.categoryname != null && category.categoryid != null) {
              if (!categoryIcons.containsKey(category.categoryname)) {
                categoryId[category.categoryname!] = category.categoryid!;
                categoryIcons[category.categoryname!] = category.icondata!;
                categoryColors[category.categoryname!] = category.iconcolor!;
              }
            }
          }

          return ListView.builder(
            itemCount: viewModel.category.length,
            itemBuilder: (context, index) {
              final category = viewModel.category[index];
              return GestureDetector(
                onTap: () {
                  final selectedCategory = {
                    'categoryid': category.categoryid,
                    'name': category.categoryname,
                    'icon': category.icondata,
                    'color': category.iconcolor,
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
                            color: category.iconcolor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              category.icondata,
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
                            category.categoryname.toString(),
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
