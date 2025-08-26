import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/financialplatform/paltform_viewmodel.dart';
import 'package:provider/provider.dart';
class financialPlatformCategory extends StatefulWidget {
  const financialPlatformCategory({super.key});

  @override
  State<financialPlatformCategory> createState() => _financialPlatformCategoryState();
}

class _financialPlatformCategoryState extends State<financialPlatformCategory> {
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
      final viewModel = Provider.of<platformViewModel>(context, listen: false);
      if (!viewModel.fetchingData && viewModel.FPcategory.isEmpty) {
        viewModel.fetchFPCategories();
        //print('Fetched Financial platform categories: ${viewModel.FPcategory.length}');
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
          'Financial Platform Name',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<platformViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.fetchingData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.FPcategory.isEmpty) {
            return const Center(child: Text('No Financial Platform Categories available'));
          }
          /*
          // Print debug information
          for (var FPcategory in viewModel.FPcategory) {
            print('Category: ${FPcategory.platfromid}, ${FPcategory.name}, ${FPcategory.iconimage}, ${FPcategory.iconColorExpense}');
          }

           */

          // Precompute category icons and colors
          final Map<String, int> PlatformId = {};
          final Map<String, Uint8List> FPimageicon = {};
          final Map<String, Color> categoryColors = {};

          for (var FPcategory in viewModel.FPcategory) {
            if (FPcategory.name != null && FPcategory.platfromid != null) {
              if (!FPimageicon.containsKey(FPcategory.name)) {
                PlatformId[FPcategory.name!] = FPcategory.platfromid!;
                FPimageicon[FPcategory.name!] = FPcategory.iconimage!;
                categoryColors[FPcategory.name!] = FPcategory.iconColorExpense!;
              }
            }
          }

          return ListView.builder(
            itemCount: viewModel.FPcategory.length,
            itemBuilder: (context, index) {
              final fp = viewModel.FPcategory[index];
              return GestureDetector(
                onTap: () {
                  final selectedFPcategory = {
                    'platformid': fp.platfromid,
                    'fpname': fp.name,
                    'iconimage': fp.iconimage,
                    'color': fp.iconColorExpense,
                  };
                  _navigatorState?.pop(selectedFPcategory);
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
                            color: fp.iconColorExpense,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: fp.iconimage != null
                                ? Image.memory(fp.iconimage!)
                                : const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            fp.name.toString(),
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


