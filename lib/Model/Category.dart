import 'package:flutter/cupertino.dart';

class Category {
  final int categoryid;
  final String categoryname;
  final String description;
  final IconData? icondata; // Combines `codepoint` and `fontfamily`
  final Color? iconcolor;
  //final int? userid;

  Category({
    required this.categoryid,
    required this.categoryname,
    required this.description,
    required this.icondata,
    required this.iconcolor,
    // required this.userid
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryid:
        json['categoryid'] is int
            ? json['categoryid']
            : int.tryParse(json['categoryid'].toString()) ??
                0, // Safely parse categoryid

    categoryname: json['name'] ?? 'Unknown', // fallback for safety

    description: json['description'] ?? '',

    icondata:
        (json['codepoint'] != null && json['fontfamily'] != null)
            ? IconData(
              // Safely parse codepoint: supports both int and string
              json['codepoint'] is int
                  ? json['codepoint']
                  : int.tryParse(json['codepoint'].toString()) ?? 0,
              fontFamily: json['fontfamily'],
            )
            : null, // fallback to null if incomplete icon data

    iconcolor:
        json['color'] != null
            ? Color(
              // Safely parse color from int or string
              json['color'] is int
                  ? json['color']
                  : int.tryParse(json['color'].toString()) ?? 0,
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
