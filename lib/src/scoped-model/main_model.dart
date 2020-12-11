import 'package:SasaPlant/src/scoped-model/plant_model.dart';
import 'package:SasaPlant/src/scoped-model/user_scoped_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with PlantModel, UserModel {
  void fetchAll() {
    fetchPlants();
    fetchUserInfos();
  }
}