import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(CategoryModel(
      name: 'Diluent', //water
      iconPath: 'assets/icons/Diluent.svg',
      boxColor: const Color.fromARGB(255, 59, 199, 230),
    ));

    categories.add(CategoryModel(
      name: 'Salt Mixer',
      iconPath: 'assets/icons/saltmixer.svg',
      boxColor: const Color.fromARGB(255, 249, 129, 54),
    ));

    categories.add(CategoryModel(
      name: 'Second Mixer',
      iconPath: 'assets/icons/secondmixer.svg',
      boxColor: const Color.fromARGB(255, 59, 199, 230),
    ));

    categories.add(CategoryModel(
      name: 'Waste',
      iconPath: 'assets/icons/waste.svg',
      boxColor: const Color.fromARGB(255, 249, 129, 54),
    ));

    categories.add(CategoryModel(
      name: 'Water Supply',
      iconPath: 'assets/icons/watersupply.svg',
      boxColor: const Color.fromARGB(255, 59, 199, 230),
    ));
    return categories;
  }
}
