import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  @override
  void initState() {
    searchController.addListener(() {
      onChange();
    });
    super.initState();
  }

  onChange() {
    placeSuggestion(searchController.text);
  }

  void placeSuggestion(String input) async {
    const String apiKey = "AIzaSyDkXPe5r85J05Nc_MNCz--b91QMmjaAQyQ";
    try {
      String basseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = '$basseUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }

      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['prediction'];
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.arrow_left_circle),
        ),
        title: Text(
          'Location',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(hintText: "Enter Place..."),
              onChanged: (value) {
                setState(() {});
              },
            ),
            Visibility(
              visible: searchController.text.isNotEmpty,
              child: Expanded(
                child: ListView.builder(
                  itemCount: listOfLocation.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: ListTile(
                        title: Text(listOfLocation[index]["description"]),
                      ),
                    );
                  },
                ),
              ),
            ),
            Visibility(
              visible: searchController.text.isEmpty,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
