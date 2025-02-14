  static Future<StudentModel> fetchStudentById(int studentId) async {
    final response = await http.get(Uri.parse('https://your-api-url.com/students/$studentId'));

    if (response.statusCode == 200) {
      return StudentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load student details');
    }
  }