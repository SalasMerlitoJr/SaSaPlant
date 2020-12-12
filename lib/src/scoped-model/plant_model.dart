import 'dart:convert';
import 'package:SasaPlant/src/models/plant_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class PlantModel extends Model {
  List<Plant> _plants = [];
  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }

  List<Plant> get plants {
    return List.from(_plants);
  }

  int get plantLength {
    return _plants.length;
  }

  Future<bool> addPlant(Plant plant) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> plantData = {
        "title": plant.name,
        "description": plant.description,
        "category": plant.category,
        "price": plant.price,
        "discount": plant.discount,
      };
      final http.Response response = await http.post(
          "https://sasaplant-69216-default-rtdb.firebaseio.com/plants.json",
          body: json.encode(plantData));

      final Map<String, dynamic> responeData = json.decode(response.body);

      Plant plantWithID = Plant(
        id: responeData["name"],
        name: plant.name,
        description: plant.description,
        category: plant.category,
        discount: plant.discount,
        price: plant.price,
      );

      _plants.add(plantWithID);
      _isLoading = false;
      notifyListeners();
 
      return Future.value(true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return Future.value(false);

    }
  }

  Future<bool> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await http
          .get("https://sasaplant-69216-default-rtdb.firebaseio.com/plants.json");


      final Map<String, dynamic> fetchedData = json.decode(response.body);
      print(fetchedData);

      final List<Plant> plantItems = [];

      fetchedData.forEach((String id, dynamic plantData) {
        Plant plantItem = Plant(
          id: id,
          name: plantData["title"],
          description: plantData["description"],
          category: plantData["category"],
          price: double.parse(plantData["price"].toString()),
          discount: double.parse(plantData["discount"].toString()),
        );

        plantItems.add(plantItem);
      });

      _plants = plantItems;
      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (error) {
      print("The errror: $error");
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  Future<bool> updatePlant(Map<String, dynamic> plantData, String plantId) async {
    _isLoading = true;
    notifyListeners();

    Plant thePlant = getPlantItemById(plantId);


    int plantIndex = _plants.indexOf(thePlant);
    try {
      await http.put(
    // ignore: unnecessary_brace_in_string_interps
    'https://sasaplant-69216-default-rtdb.firebaseio.com/plants/${plantId}.json',
          body: json.encode(plantData));

     Plant updatePlantItem = Plant(
        id: plantId,
        name: plantData["title"],
        category: plantData["category"],
        discount: plantData['discount'],
        price: plantData['price'],
        description: plantData['description'],
      );

      _plants[plantIndex] = updatePlantItem;

      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  Future<bool> deletePlant(String plantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await http.delete(
          "https://sasaplant-69216-default-rtdb.firebaseio.com/${plantId}.json");

      _plants.removeWhere((Plant plant) => plant.id == plantId);

      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
    }
  }

  Plant getPlantItemById(String plantId) {
    Plant plant;
    for (int i = 0; i < _plants.length; i++) {
      if (_plants[i].id == plantId) {
        plant = _plants[i];
        break;
      }
    }
    return plant;
  }
}
