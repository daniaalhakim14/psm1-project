import 'package:flutter/cupertino.dart';

class Category {
  final int categoryId;
  final String categoryName;
  final String description;
  final IconData? iconData; // Combines `codepoint` and `fontfamily`
  final Color? iconColor;
  //final int? userid;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.iconData,
    required this.iconColor,
    // required this.userid
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryId:
        json['categoryId'] is int
            ? json['categoryId']
            : int.tryParse(json['categoryId'].toString()) ??
                0, // Safely parse categoryid

    categoryName: json['categoryName'] ?? 'Unknown', // fallback for safety

    description: json['categoryDesc'] ?? '',

    iconData:
        (json['iconCodePoint'] != null && json['iconFontFamily'] != null)
            ? IconData(
              // Safely parse codepoint: supports both int and string
              json['iconCodePoint'] is int
                  ? json['iconCodePoint']
                  : int.tryParse(json['iconCodePoint'].toString()) ?? 0,
              fontFamily: json['iconFontFamily'],
            )
            : null, // fallback to null if incomplete icon data

    iconColor:
        json['iconColor'] != null
            ? Color(
              // Safely parse color from int or string
              json['iconColor'] is int
                  ? json['iconColor']
                  : int.tryParse(json['iconColor'].toString()) ?? 0,
            )
            : null,
  );
  /* to print data
  @override
  String toString() {
    return 'Category(categoryid: $categoryid, categoryname: $categoryname, '
        'description: $description, icondata: ${icondata?.codePoint}, '
        'iconcolor: $iconcolor)';
  }

   */
}
