import 'package:http/http.dart' as http;
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
      c.assignments = [];
      courses.add(c);

      var courseAssignmnetsUrl = Uri.parse(
          'https://$schoolTag.com/api/v1/courses/${c.id}/assignments');
      var assignmentsRes = await http.get(courseAssignmnetsUrl,
          headers: {"Authorization": "Bearer $canvasKey", "bucket": "future"});
      var assignmentData = jsonDecode(assignmentsRes.body);

      for (var assignment in assignmentData) {
        var a = Assignment.fromJson(assignment);
        if (a.name != Null) {
          c.assignments.add(a);
        }
      }
    }

    for (var course in courses) {
      print('Name: ${course.name}');

      var tempAs = course.assignments.map((assign) => assign.name).toList();

      print('Assinments$tempAs');
    }
    return courses;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load course');
  }
}

class Course {
  final String name;
  final int id;
  dynamic assignments;

  Course({required this.name, required this.id, this.assignments});

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
