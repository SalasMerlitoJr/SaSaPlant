import 'package:flutter/material.dart';
import 'package:SasaPlant/src/pages/plant_details_page.dart';
import 'package:SasaPlant/src/scoped-model/main_model.dart';
import 'package:SasaPlant/src/widgets/bought_plants.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/home_top_info.dart';
import '../widgets/plant_category.dart';
import '../widgets/search_file.dart';


// Model
import '../models/plant_model.dart';

class HomePage extends StatefulWidget {
  // final FoodModel foodModel;

  // HomePage(this.foodModel);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Food> _foods = foods;

  @override
  void initState() {
    // widget.foodModel.fetchFoods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        children: <Widget>[
          HomeTopInfo(),
          PlantCategory(),
          SizedBox(
            height: 20.0,
          ),
          SearchField(),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Frequently Bought",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("I' pressed");
                },
                child: Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return Column(
                children: model.plants.map(_buildPlantItems).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlantItems(Plant plant) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => PlantDetailsPage(
            plant: plant,
          ),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: BoughtPlants(
          id: plant.id,
          name: plant.name,
          imagePath:"assets/images/aloe.jpg",
          category: plant.category,
          discount: plant.discount,
          price: plant.price,
          ratings: plant.ratings,
        ),
      ),
    );
  }
}
