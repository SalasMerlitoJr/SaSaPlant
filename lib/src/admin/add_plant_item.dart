import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../scoped-model/main_model.dart';
import '../widgets/button.dart';
import '../widgets/show_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class AddPlantItem extends StatefulWidget {
  final Plant plant;

  AddPlantItem({this.plant});

  @override
  _AddPlantItemState createState() => _AddPlantItemState();
}

class _AddPlantItemState extends State<AddPlantItem> {
  String title;
  String category;
  String description;
  String price;
  String discount;

  GlobalKey<FormState> _plantItemFormKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop(false);
          return Future.value(false);
        },
        child: Scaffold(
          key: _scaffoldStateKey,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            title: Text(
              widget.plant != null ? "Update Item" : "Add Item",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _plantItemFormKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15.0),
                      width: MediaQuery.of(context).size.width,
                      height: 170.0,
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage("assets/images/noimage.png"),
                        ),
                      ),
                    ),
                    _buildTextFormField("Plant Title"),
                    _buildTextFormField("Category"),
                    _buildTextFormField("Description", maxLine: 5),
                    _buildTextFormField("Price"),
                    _buildTextFormField("Discount"),
                    SizedBox(
                      height: 70.0,
                    ),
                    ScopedModelDescendant(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return GestureDetector(
                          onTap: () {
                            onSubmit(model.addPlant, model.updatePlant);
                            if (model.isLoading) {
                              showLoadingIndicator(
                                  context,
                                  widget.plant != null
                                      ? "Updating..."
                                      : "Adding...");
                            }
                          },
                          child: Button(
                              btnText: widget.plant != null
                                  ? "Update Item"
                                  : "Add Item"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSubmit(Function addPlant, Function updatePlant) async {
    if (_plantItemFormKey.currentState.validate()) {
      _plantItemFormKey.currentState.save();

      if (widget.plant != null) {
        Map<String, dynamic> updatedPlantItem = {
          "title": title,
          "category": category,
          "description": description,
          "price": double.parse(price),
          "discount": discount != null ? double.parse(discount) : 0.0,
        };

        final bool response = await updatePlant(updatedPlantItem, widget.plant.id);
        if (response) {
          Navigator.of(context).pop(); 
          Navigator.of(context).pop(response); 
          Navigator.of(context).pop();
          SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            content: Text(
              "Failed to update",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          );
          _scaffoldStateKey.currentState.showSnackBar(snackBar);
        }
      } else if (widget.plant == null) {
        final Plant plant = Plant(
          name: title,
          category: category,
          description: description,
          price: double.parse(price),
          discount: double.parse(discount),
        );
        bool value = await addPlant(plant);
        if (value) {
          Navigator.of(context).pop();
          SnackBar snackBar =
              SnackBar(content: Text("Item successfully added."));
          _scaffoldStateKey.currentState.showSnackBar(snackBar);
        } else if (!value) {
          Navigator.of(context).pop();
          SnackBar snackBar =
              SnackBar(content: Text("Failed to add"));
          _scaffoldStateKey.currentState.showSnackBar(snackBar);
        }
      }
    }
  }

  Widget _buildTextFormField(String hint, {int maxLine = 1}) {
    return TextFormField(
      initialValue: widget.plant != null && hint == "Plant Title"
          ? widget.plant.name
          : widget.plant != null && hint == "Description"
              ? widget.plant.description
              : widget.plant != null && hint == "Category"
                  ? widget.plant.category
                  : widget.plant != null && hint == "Price"
                      ? widget.plant.price.toString()
                      : widget.plant != null && hint == "Discount"
                          ? widget.plant.discount.toString()
                          : "",
      decoration: InputDecoration(hintText: "$hint"),
      maxLines: maxLine,
      keyboardType: hint == "Price" || hint == "Discount"
          ? TextInputType.number
          : TextInputType.text,
      validator: (String value) {
        if (value.isEmpty && hint == "Plant Title") {
          return "The title is required";
        }
        if (value.isEmpty && hint == "Description") {
          return "The description is required";
        }

        if (value.isEmpty && hint == "Category") {
          return "The category is required";
        }

        if (value.isEmpty && hint == "Price") {
          return "The price is required";
        }
        // return "";
      },
      onSaved: (String value) {
        if (hint == "Title") {
          title = value;
        }
        if (hint == "Category") {
          category = value;
        }
        if (hint == "Description") {
          description = value;
        }
        if (hint == "Price") {
          price = value;
        }
        if (hint == "Discount") {
          discount = value;
        }
      },
    );
  }

  Widget _buildCategoryTextFormField() {
    return TextFormField();
  }
}
