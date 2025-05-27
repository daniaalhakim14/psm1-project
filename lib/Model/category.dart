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
        json['categoryid'] is int
            ? json['categoryid']
            : int.tryParse(json['categoryid'].toString()) ??
                0, // Safely parse categoryid

    categoryName: json['categoryname'] ?? 'Unknown', // fallback for safety

    description: json['categorydesc'] ?? '',

    iconData:
        (json['iconcodepoint'] != null && json['iconfontfamily'] != null)
            ? IconData(
              // Safely parse codepoint: supports both int and string
              json['iconcodepoint'] is int
                  ? json['iconcodepoint']
                  : int.tryParse(json['iconcodepoint'].toString()) ?? 0,
              fontFamily: json['iconfontfamily'],
            )
            : null, // fallback to null if incomplete icon data

    iconColor:
        json['iconcolor'] != null
            ? Color(
              // Safely parse color from int or string
              json['iconcolor'] is int
                  ? json['iconcolor']
                  : int.tryParse(json['iconcolor'].toString()) ?? 0,
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
