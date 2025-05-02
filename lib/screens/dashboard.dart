import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';
import 'location_map_widget.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A6EFF), // Primary blue
        title: const Text('User List', style: TextStyle(color: Colors.white)),
        elevation: 2,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFFEAF1FB), // Soft light blue

             ),

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF0A6EFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.location,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
            child: Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: LocationMapWidget()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.userListModel?.data?.length ?? 0,
              itemBuilder: (context, index) {
                final user = controller.userListModel!.data![index];
                final userId = user.id!;
                final imagePath = controller.uploadedImages[userId];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(2),
                    leading: InkWell(
                      onTap: () {
                        controller.pickImage(userId, context);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath))
                            : NetworkImage(user.avatar!) as ImageProvider,
                        backgroundColor: const Color(0xFFDFE6F1),
                      ),
                    ),
                    title: Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      user.email ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
