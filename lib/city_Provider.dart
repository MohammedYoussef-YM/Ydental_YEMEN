import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ydental_application/constant.dart';
import '../Model/city_model.dart';

class ProfileProvider with ChangeNotifier {
  String? selectedCity;
  University? selectedUniversity;
  List<City> cities = [];
  List<University> universities = [];


  /// **جلب المحافظات من الـ API**
  Future<void> fetchCities() async {
    try {
      final response = await http.get(Uri.parse("$api_local/cities/select"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse["data"];

        cities = data.map((cityJson) => City(
          id: cityJson["id"].toString(),
          name: cityJson["name"],
        )).toList();

        notifyListeners();
      } else {
      }
    } catch (error) {
    }
  }

  /// **تحديث المحافظة المحددة وجلب الجامعات المرتبطة بها**
  void updateCity(String? cityId) {
    if (selectedCity == cityId) return; // تجنب إعادة تحميل نفس البيانات
    selectedCity = cityId;
    selectedUniversity = null;
    universities.clear();
    if (cityId != null) {
      print("cityId : $cityId");
      fetchUniversities(cityId);
    }
    notifyListeners();
  }

  /// **جلب الجامعات بناءً على `city_id`**
  Future<void> fetchUniversities(String cityId) async {
    print("cityId 2 : $cityId");

    try {
      print("cityId 3: $cityId");

      final response = await http.get(Uri.parse("$api_local/universities/select?city_id=$cityId"));
      if (response.statusCode == 200) {
        print("cityId 4: $cityId");
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse["data"];

        universities = data.map((universityJson) => University(
          id: universityJson["id"].toString(),
          name: universityJson["name"], cityId: universityJson["city_id"].toString(),
        )).toList();
        print("universities id : ${universities[0]}");
        print("universities id : ${universities[0].id}");
        print("universities name : ${universities[0].name}");
        print("universities city id: ${universities[0].cityId}");

        notifyListeners();
      } else {
        print("خطأ في جلب الجامعات: ${response.statusCode}");
      }
    } catch (error) {
      print("خطأ في الاتصال بالـ API: $error");
    }
  }

  /// **تحديث الجامعة المحددة**
  void updateUniversity(University? university) {
    selectedUniversity = university;
    notifyListeners();
  }
  // void updateUniversity(University? university) {
  //   selectedUniversity = university;
  //   notifyListeners();
  // }
}