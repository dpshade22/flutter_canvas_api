import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<List<Course>> fetchCanvas(schoolTag, canvasKey) async {
  var canvasCourseUrl = Uri.parse('https://$schoolTag.com/api/v1/courses/');
  var r = await http
      .get(canvasCourseUrl, headers: {"Authorization": "Bearer $canvasKey"});

  // var r =
  //     await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/2'));

  if (r.statusCode == 200) {
    List<Course> courses = [];

    var jsonData = jsonDecode(r.body);
    for (var course in jsonData) {
      var c = Course.fromJson(course);
      courses.add(c);

      var courseAssignmnetsUrl = Uri.parse(
          'https://$schoolTag.com/api/v1/courses/${c.id}/assignments');
      var assignmentsRes = await http.get(courseAssignmnetsUrl,
          headers: {"Authorization": "Bearer $canvasKey"});
      var assignmentData = jsonDecode(assignmentsRes.body);
      print(assignmentData);

      for (var assignment in assignmentData) {
        if (assignment != Null) {
          var a = Assignment.fromJson(assignment);
          c.assignments.add(a);
        }
      }
    }

    for (var course in courses) {
      print('Name: ${course.name}');
      print('Assinments${course.assignments}');
    }
    return courses;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Course {
  final String name;
  final int id;
  final dynamic assignments;

  const Course({required this.name, required this.id, this.assignments});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(name: json['name'], id: json['id']);
  }
}

class Assignment {
  final String name;
  final int id;
  final dynamic dueDate;

  const Assignment({required this.name, required this.id, this.dueDate});

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
        name: json['name'], id: json['id'], dueDate: json['due_at']);
  }
}

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
  void initState() {
    super.initState();
    fetchCanvas("uk.instructure",
        "1139~9rTRlkNDlPabGNTZsEWK1oMndqFjCJzJzKnq2x6VRAu3qE72HZcpdtZZKcR4FUgC");
  }

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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
