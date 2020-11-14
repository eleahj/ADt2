import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './cuisine.dart';

/*This abstract class defines the restaurant type, and manages some JSON to User
* conversions and visa versa. It also checks whether the restaurant is open
* based on locally stored times, and filters for fav restaurants and for those
* that are open*/
Future<String> _loadRestaurantAsset() async {
  return await rootBundle.loadString('assets/final_restaurants.json');
}

enum CovidClassification {
  Covid_Pending,
  Covid_Approved,
}

enum Affordability {
  Affordable,
  Pricey,
  Luxurious,
}

class Restaurant with ChangeNotifier {
  String id;
  List<CuisineTypes> cuisines;
  String name;
  String imageUrl;
  String websiteUrl;
  int phoneNumber;
  String address;
  String city;
  Affordability affordability;

  CovidClassification health;
  bool isGlutenFree;
  bool isVegetarian;
  bool hasPickup;
  bool hasEatIn;
  bool hasPatio;
  bool hasDelivery;

  LatLng latLng;
  double rating;
  SharedPreferences ptrToFavsList;

  bool isFavorite;
  int localPopularity;
  bool openNow;

  Restaurant({
    @required this.id,
    @required this.cuisines,
    @required this.name,
    @required this.imageUrl,
    @required this.websiteUrl,
    @required this.phoneNumber,
    @required this.address,
    @required this.latLng,
    @required this.city,
    this.rating,
    this.affordability = Affordability.Affordable,
    this.isGlutenFree = false,
    this.hasEatIn = true,
    this.hasDelivery = false,
    this.hasPatio = false,
    this.hasPickup = true,
    this.isVegetarian = false,
    this.isFavorite = false,
    this.localPopularity = 0,
    this.openNow = true,
    this.health = CovidClassification.Covid_Pending,
    this.ptrToFavsList,
  });

  Restaurant.fromJson(Map<String, dynamic> json, SharedPreferences pref) {
    id = json['id'].toString();
    cuisines = [
      CuisineTypes.values
          .firstWhere((c) => c.toString() == 'CuisineTypes.' + json['cuisine']),
    ];
    name = json['name'];
    imageUrl = json['imageUrl'];
    websiteUrl = json['website'];
    phoneNumber = json['phone'];
    address = json['address'];
    latLng = LatLng(json['lng'], json['lat']);
    rating = json['rating'];
    health = CovidClassification.Covid_Pending;
    hasPickup = json['pickup'] == 1;
    hasEatIn = json['sitInside'] == 1;
    hasPatio = json['sitPatio'] == 1;
    hasDelivery = json['delivery'] == 1;
    affordability = Affordability.values[json['affordability']];
    city = json['city'];
    isGlutenFree = json['gf'] == 1;
    isVegetarian = json['vege'] == 1;
    openNow = _isOpenNow(json);
    ptrToFavsList = pref;
  }

  void toggleFav() {
    isFavorite = !isFavorite;
    ptrToFavsList.setBool('fav$id', isFavorite);
    notifyListeners();
  }

  void iteratePop() {
    localPopularity != null ? localPopularity += 1 : localPopularity = 0;
    ptrToFavsList.setInt('${id}pop', localPopularity);
    notifyListeners();
  }

  bool _isOpenNow(Map<String, dynamic> json) {
    DateTime time = DateTime.now();
    int hour = time.hour;
    int min = time.minute;
    int hourMin = 100 * hour + min;
    switch (time.weekday) {
      case DateTime.monday:
        return _checkTimeIsBetween(
            json, 'Monday_Open_Time', 'Monday_Close_Time', hourMin);
        break;
      case DateTime.tuesday:
        return _checkTimeIsBetween(
            json, 'Tuesday_Open_Time', 'Tuesday_Close_Time', hourMin);
        break;
      case DateTime.wednesday:
        return _checkTimeIsBetween(
            json, 'Wednesday_Open_Time', 'Wednesday_Close_Time', hourMin);
        break;
      case DateTime.thursday:
        return _checkTimeIsBetween(
            json, 'Thursday_Open_Time', 'Thursday_Close_Time', hourMin);
        break;
      case DateTime.friday:
        return _checkTimeIsBetween(
            json, 'Friday_Open_Time', 'Friday_Close_Time', hourMin);
        break;
      case DateTime.saturday:
        return _checkTimeIsBetween(
            json, 'Saturday_Open_Time', 'Saturday_Close_Time', hourMin);
        break;
      case DateTime.sunday:
        return _checkTimeIsBetween(
            json, 'Sunday_Open_Time', 'Sunday_Close_Time', hourMin);
        break;
    }
    print('Missing time data for $name, id: $id');
    return false;
  }

  bool _checkTimeIsBetween(
      Map<String, dynamic> json, String start, String end, int hourMin) {
    if (json[end] == 2400 || json[start] == 2400) {
      return true;
    }
    return (json[start] <= hourMin && hourMin <= json[end]);
  }
}

class Restaurants with ChangeNotifier {
  List<Restaurant> _restaurants = [];

  Restaurants();

  List<Restaurant> get restaurants {
    return [..._restaurants];
  }

  List<Restaurant> get favRestaurants {
    return _restaurants.where((item) => item.isFavorite).toList();
  }

  List<Restaurant> get openRestaurants {
    return _restaurants.where((item) => item.openNow).toList();
  }

  List<Restaurant> get openAndFavRestaurants {
    return _restaurants
        .where((item) => item.openNow && item.isFavorite)
        .toList();
  }

  bool _readFav(SharedPreferences prefs, String restId) {
    bool isFav = prefs.getBool(restId);
    if (isFav == true || isFav == false) {
//      print ('favorite data on RAM: id:$restId  isFav:$isFav');
      return isFav;
    } else {
//      print('Fav data not set for restaurant id: $restId');
      prefs.setBool(restId, false);
      return false;
    }
  }

  Restaurant findById(String id) {
    return _restaurants.firstWhere((element) => element.id == id);
  }

  Restaurant findByName(String name) {
    return _restaurants.firstWhere((element) => element.name == name);
  }

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> fetchRestaurants({List<Restaurant> preloadedList = null}) async {
    if (_restaurants.length == 0) {
      if (preloadedList == null) {
        String jsonString = await _loadRestaurantAsset();
//        var i = 0;
        final prefs = await _getPrefs();
        (json.decode(jsonString) as List<dynamic>).forEach((json) {
//          print(i++);
          _restaurants.add(Restaurant.fromJson(json, prefs));
        });
        for (Restaurant restaurant in _restaurants) {
//      restaurant.openNow = await _setOpenNow(restaurant.address)??false;
//        restaurant.openNow = false;
          restaurant.isFavorite =
              _readFav(restaurant.ptrToFavsList, restaurant.id);
        }
      } else {
        _restaurants = preloadedList;
      }
      notifyListeners();
    }
  }
}
