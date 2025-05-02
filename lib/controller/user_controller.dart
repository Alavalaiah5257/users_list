import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_list_model.dart';
import '../provider/api_service.dart';
import '../provider/location_service.dart';


class UserController extends ChangeNotifier {
  UserListModel? userListModel;
  String location = 'Fetching location...';
  double? latitude;
  double? longitude;
  final _apiService = ApiService();
  final _locationService = LocationService();
  final _imageBox = Hive.box<String>('user_images');
  bool isLoading = true;

  Map<int, String> uploadedImages = {};

  Future<void> initialize() async {
    await fetchLocation();
    await fetchUsers();
    loadStoredImages();
  }

  Future<void> fetchLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      final address = await _locationService.getAddressFromLatLng(position);
      location = 'Lat: $latitude, Lng: $longitude\n$address';
    } catch (e) {
      location = 'Failed to get location';
    }
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      userListModel = await _apiService.fetchUsers();
    } catch (e) {
      print('Error fetching users: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage(int userId, BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      uploadedImages[userId] = pickedFile.path;
      _imageBox.put(userId.toString(), pickedFile.path);
      notifyListeners();
    }
  }


  void loadStoredImages() {
    for (var key in _imageBox.keys) {
      uploadedImages[int.parse(key)] = _imageBox.get(key)!;
    }
    notifyListeners();
  }

}
