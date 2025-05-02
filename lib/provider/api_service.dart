import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_list_model.dart';

class ApiService {
  Future<UserListModel?> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));

    if (response.statusCode == 200) {
      return UserListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load users');
    }
  }
}
