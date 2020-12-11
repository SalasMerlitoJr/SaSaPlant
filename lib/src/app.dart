import 'package:flutter/material.dart';
import 'package:SasaPlant/src/pages/signin_page.dart';
import 'package:SasaPlant/src/scoped-model/main_model.dart';
import 'package:SasaPlant/src/screens/main_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class App extends StatelessWidget {
  final MainModel mainModel = MainModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: mainModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "SaSa Plant Delivery App",
        theme: ThemeData(primaryColor: Colors.blueAccent),
        routes: {
          "/": (BuildContext context) => SignInPage(),
          "/mainscreen": (BuildContext context) => MainScreen(
                model: mainModel,
              ),
        },
      ),
    );
  }
}
