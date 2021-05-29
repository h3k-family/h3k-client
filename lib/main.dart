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
              return Text("Something is good");
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
