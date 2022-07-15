import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Weather Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  late TextEditingController lattitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();
    lattitudeController = TextEditingController();
    longitudeController = TextEditingController();
  }


 // Api call getting temperature data for wednesday night
  Future<String> fetchTemperatureFromGovtApi(double lattitude, double longitude) async {
    final response = await http.get(Uri.parse("https://api.weather.gov/points/$lattitude,$longitude" ));
    late String temperature;

    if (response.statusCode == 200) {
      Map<String, dynamic> response_from_first_url =  jsonDecode(response.body);
      String url = response_from_first_url["properties"]["forecast"];
      final response_from_second_url = await http.get(Uri.parse(url));
      if (response_from_second_url.statusCode == 200){
        Map<String, dynamic> finalResponse = jsonDecode(response_from_second_url.body);
        List<dynamic> listOfTemp = finalResponse["properties"]["periods"];

        for (Map<String, dynamic> value in listOfTemp) {
          if (value["name"].toString().toLowerCase() == "Wednesday Night".toLowerCase()) {
            temperature = value["temperature"].toString();
          }
        }
        //"Wednesday Night"
        print(listOfTemp);
      }
    }
    else {
      throw Exception('Failed to load album');
    }
    return temperature.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 400,
          padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),

          child: Column(
            children: [

              TextFormField(
                controller: lattitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Please enter lattitute",
                  focusedBorder:OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: longitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder:OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Please enter longitude",

                ),
              ),
              SizedBox(height: 40,),

              SizedBox(

                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    var fetchedTemperature;
                    //fetchDataFromGovtApi(39.7456, -97.0892);
                    try {
                       fetchedTemperature = (await fetchTemperatureFromGovtApi(
                          double.parse(lattitudeController.text), double.parse(
                          longitudeController.text))) as String;
                    }
                    catch (e){
                      fetchedTemperature = "Some Error is coming please try again";
                    }

                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        if (fetchedTemperature.runtimeType == Future )
                          {
                            return CircularProgressIndicator();
                          }


                        return Container(
                          height: 200,
                          color: Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[

                                Text("Wednesday night temperature for the given location", style: TextStyle(fontSize: 26),),
                                SizedBox(height: 20,),
                                 Text('$fetchedTemperature' + " ºF", style: TextStyle(fontSize: 20),),
                                SizedBox(height: 20,),
                                TextButton(
                                  child: const Text('close', style: TextStyle(fontSize: 20, color: Colors.red),),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );


                  },
                  child: Text("Submit"),
                  style: ButtonStyle(

                    // backgroundColor: Colors.cyan.shade50,
                  ),


                ),
              ),

            ],
          ),
        ),

      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
