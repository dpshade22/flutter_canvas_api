import 'package:flutter/material.dart';
import 'dart:async';
import 'canvasObjs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CanvasResponse(
          schoolTag: "uk",
          canvasKey:
              "1139~9rTRlkNDlPabGNTZsEWK1oMndqFjCJzJzKnq2x6VRAu3qE72HZcpdtZZKcR4FUgC"),
    );
  }
}

class CanvasResponse extends StatefulWidget {
  const CanvasResponse(
      {Key? key, required this.canvasKey, required this.schoolTag})
      : super(key: key);

  @override
  State<CanvasResponse> createState() => _CanvasResponseState();

  final String canvasKey;
  final String schoolTag;
}

class _CanvasResponseState extends State<CanvasResponse> {
  late Future<List<Course>> _courses;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _courses = fetchCanvas("uk.instructure",
        "1139~9rTRlkNDlPabGNTZsEWK1oMndqFjCJzJzKnq2x6VRAu3qE72HZcpdtZZKcR4FUgC");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Canvas API")),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term',
                  ),
                  controller: myController,
                  onSubmitted: (String str) {
                    setState(() {
                      _courses =
                          fetchCanvas("uk.instructure", myController.text);
                    });
                  }),
            ),
            showCourses()
          ],
        ));
  }

  FutureBuilder<List<Course>> showCourses() {
    return FutureBuilder(
        future: _courses,
        builder: (context, AsyncSnapshot<List<Course>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Text('Loading....');
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(snapshot.data?[index].name ?? "Error"),
                          trailing: Text(
                              snapshot.data?[index].id.toString() ?? "Error"),
                        ),
                      );
                    },
                  ),
                );
              }
          }
        });
  }
}
