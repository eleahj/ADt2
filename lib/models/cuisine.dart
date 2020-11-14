import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './finalCategories.dart';
/*This abstract class defines the Cuisine/Category type, and manages filtering
* by fav cuisine functions*/

enum CuisineTypes {
  All,
  African,
  American,
  Arabic,
  Asian,
  Bakery,
  Beer,
  Beverages,
  Breakfast,
  Canadian,
  Chinese,
  Cafe,
  Comfort,
  Cuban,
  Dessert,
  Drinks,
  EastEurope,
  FastFood,
  Filipino,
  French,
  German,
  Greek,
  Indian,
  Italian,
  Japanese,
  Korean,
  Latin,
  Lebanese,
  Malaysian,
  Mediterranean,
  Mexican,
  Modern,
  Persian,
  Pizza,
  Seafood,
  Singaporean,
  Steak,
  Thai,
  Vegan,
  Vietnamese
}

class Cuisine with ChangeNotifier {
  final String id;
  final String title;
  final String imageUrl;
  bool isFavCuisine;

  Cuisine({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
    this.isFavCuisine = false,
  });

  Future<void> toggleFav() async {
    isFavCuisine = !isFavCuisine;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(id, !isFavCuisine);
    notifyListeners();
  }
}

class Cuisines with ChangeNotifier {
  List<Cuisine> _cuisines = [];

  Cuisines();

  List<Cuisine> get cuisines {
    return [..._cuisines];
  }

  List<Cuisine> get favCuisines {
    return _cuisines.where((item) => item.isFavCuisine).toList();
  }

  Cuisine findById(String id) {
    return _cuisines.firstWhere((element) => element.id == id);
  }

  Future<bool> _readFav(cuisId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(cuisId) ?? false;
  }

  Future<void> fetchAndSetCuisines([bool filterByUser = false]) async {
    final List<Cuisine> loadedCuisines = [];
    for (Cuisine cuisine in categories) {
      cuisine.isFavCuisine = await _readFav(cuisine.id);
      loadedCuisines.insert(0, cuisine);
    }
    _cuisines = loadedCuisines;
    notifyListeners();
  }
}
