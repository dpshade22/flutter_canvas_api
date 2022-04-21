import 'package:http/http.dart' as http;

import 'dart:convert';

Future<List<Course>> fetchCanvas({schoolTag = "", canvasKey = ""}) async {
  if (schoolTag == "" && canvasKey == "") {
    return [];
  }

  var params = {
    "per_page": '200',
    "include": ["concluded"],
    "enrollment_state": ["active"],
  };

  var header = {
    "Authorization": "Bearer $canvasKey",
  };

  var canvasCourseUrl = Uri.https('$schoolTag.com', '/api/v1/courses/', params);
  var r = await http.get(canvasCourseUrl, headers: header);

  // var r =
  //     await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/2'));

  if (r.statusCode == 200) {
    List<Course> courses = [];

    var jsonData = jsonDecode(r.body);
    for (var course in jsonData) {
      var c = Course.fromJson(course);
      var diff = DateTime.parse(c.startAt).difference(DateTime.now());
      if (diff.inDays < -240) {
        continue;
      }

      courses.add(c);

      await addAssignments(schoolTag, c, canvasKey);
    }

    for (var course in courses) {
      print('Name: ${course.name}, ID: ${course.id}');

      for (var assign in course.assignments) {
        print('Assignment Name: ${assign.name}');
      }
      // var tempAs = course.assignments.map((assign) => assign.name).toList();
    }
    return courses;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.

    throw Exception('Failed to load course');
  }
}

Future<void> addAssignments(schoolTag, Course c, canvasKey) async {
  c.assignments = [];

  var params = {
    "bucket": ['future'],
  };

  var courseAssignmnetsUrl = Uri.https(
      '$schoolTag.com', '/api/v1/courses/${c.id}/assignments', params);
  var assignmentsRes = await http.get(courseAssignmnetsUrl,
      headers: {"Authorization": "Bearer $canvasKey", "bucket": "future"});
  var assignmentData = jsonDecode(assignmentsRes.body);

  for (var assignment in assignmentData) {
    var a = Assignment.fromJson(assignment);
    if (a.name != null) {
      c.assignments.add(a);
    }
  }
}

class Course {
  final String name;
  final int id;
  dynamic startAt;
  dynamic assignments;
  dynamic enrollState;

  Course({
    required this.name,
    required this.id,
    this.startAt,
    this.assignments,
    this.enrollState,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        name: json['name'],
        id: json['id'],
        startAt: json['start_at'],
        enrollState: json['enrollment_state']);
  }
}

class Assignment {
  final String name;
  final int id;
  final dynamic dueDate;

  const Assignment({required this.name, required this.id, this.dueDate});

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      name: json['name'],
      id: json['id'],
      dueDate: json['due_at'],
    );
  }
}
