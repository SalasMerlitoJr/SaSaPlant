import 'package:flutter/material.dart';
import 'package:SasaPlant/src/admin/add_plant_item.dart';
import 'package:SasaPlant/src/widgets/plant_item_card.dart';
import 'package:SasaPlant/src/scoped-model/main_model.dart';
import 'package:SasaPlant/src/widgets/show_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoritePage extends StatefulWidget {
  final MainModel model;

  FavoritePage({this.model});
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  // the scaffold global key
  GlobalKey<ScaffoldState> _explorePageScaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.model.fetchPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _explorePageScaffoldKey,
      backgroundColor: Colors.white,
      body: ScopedModelDescendant<MainModel>(
        builder: (BuildContext sctx, Widget child, MainModel model) {
          //model.fetchFoods(); // this will fetch and notifylisteners()
          // List<Food> foods = model.foods;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: RefreshIndicator(
              onRefresh: model.fetchPlants,
              child: ListView.builder(
                itemCount: model.plantLength,
                itemBuilder: (BuildContext lctx, int index) {
                  return GestureDetector(
                    onTap: () async {
                      final bool response =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => AddPlantItem(
                                    plant: model.plants[index],
                                  )));

                      if (response) {
                        SnackBar snackBar = SnackBar(
                          duration: Duration(seconds: 2),
                          backgroundColor: Theme.of(context).primaryColor,
                          content: Text(
                            "Item successfully updated.",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        );
                        _explorePageScaffoldKey.currentState.showSnackBar(snackBar);
                      }
                    },
                    onDoubleTap: (){
                      // delete food item
                      showLoadingIndicator(context, "Deleting item...");
                      model.deletePlant(model.plants[index].id).then((bool response){
                        Navigator.of(context).pop();
                      });
                    },
                    child: PlantItemCard(
                      model.plants[index].name,
                      model.plants[index].description,
                      model.plants[index].price.toString(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Container(
//         color: Colors.white,
//         padding: EdgeInsets.symmetric(horizontal: 16.0),
//         child: ScopedModelDescendant<MainModel>(
//           builder: (BuildContext context, Widget child, MainModel model) {
//             model.fetchFoods();
//             List<Food> foods = model.foods;
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: foods.map((Food food){
//                 return FoodItemCard(
//                   food.name,
//                   food.description,
//                   food.price.toString(),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       )
