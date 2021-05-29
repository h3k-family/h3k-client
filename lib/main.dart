import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H3k Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'h3k'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Child {
  final int id;
  final String url;
  final String updatedAt;

  Child({
    required this.id,
    required this.url,
    required this.updatedAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json["id"],
      url: json["url"],
      updatedAt: json["updated_at"],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Child>> fetchChildren() async {
    final response = await http.get(Uri.parse(
        'https://h3k-parent-app-de.a0ijasjbbe5.eu-gb.codeengine.appdomain.cloud/children/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Child> children = body
          .map(
            (dynamic item) => Child.fromJson(item),
          )
          .toList();

      return children;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchChildren(),
          builder: (BuildContext context, AsyncSnapshot<List<Child>> snapshot) {
            if (snapshot.hasData) {
              List<Child> children = snapshot.data!;
              return ListView(
                children: children
                    .map(
                      (Child child) => ListTile(
                        title: Text(child.url),
                        subtitle: Text("${child.updatedAt}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(child: child),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class SensorData {
  final int id;
  final int sensorId;
  final double value;
  final String updatedAt;
  final String sensorName;
  final String username;
  final String unitsShort;
  final String unitsLong;
  final double latitude;
  final double longitude;

  SensorData({
    required this.id,
    required this.sensorId,
    required this.value,
    required this.updatedAt,
    required this.sensorName,
    required this.username,
    required this.unitsShort,
    required this.unitsLong,
    required this.latitude,
    required this.longitude,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json["id"],
      sensorId: json["sensor_id"],
      value: json["value"],
      updatedAt: json["updated_at"],
      sensorName: json["sensor_name"],
      username: json["username"],
      unitsShort: json["units_short"],
      unitsLong: json["units_long"],
      latitude: json["latitude"],
      longitude: json["longitude"],
    );
  }
}

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Child
  final Child child;

  Future<List<SensorData>> fetchSensorData() async {
    final response = await http.get(Uri.parse("${child.url}/sensors/data/"));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<SensorData> sensors = body
          .map(
            (dynamic item) => SensorData.fromJson(item),
          )
          .toList();

      return sensors;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  // In the constructor, require a Child
  DetailScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text("${child.id}"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchSensorData(),
          builder:
              (BuildContext context, AsyncSnapshot<List<SensorData>> snapshot) {
            if (snapshot.hasData) {
              List<SensorData> children = snapshot.data!;
              return ListView(
                children: children
                    .map(
                      (SensorData child) => ListTile(
                        title: Row(
                          children: <Widget>[
                            Text("${child.sensorName}"),
                            Expanded(child: Container()),
                            Text(
                              "location(${child.longitude}, ${child.latitude})",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: <Widget>[
                            Text("${child.value} ${child.unitsShort}"),
                            Expanded(child: Container()),
                            Text("${child.username} - ${child.updatedAt}"),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
