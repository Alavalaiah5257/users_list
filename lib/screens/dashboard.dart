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
      appBar: AppBar(title: const Text('User List')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              controller.location,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          LocationMapWidget(),
          Expanded(
            child: ListView.builder(
              itemCount: controller.userListModel?.data?.length ?? 0,
              itemBuilder: (context, index) {
                final user = controller.userListModel!.data![index];
                final userId = user.id!;
                final imagePath = controller.uploadedImages[userId];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Column(
                    children: [
                      Divider(),
                      ListTile(
                        contentPadding: const EdgeInsets.all(2),
                        leading: InkWell(
                          onTap: (){
                            controller.pickImage(userId, context);
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: imagePath != null
                                ? FileImage(File(imagePath))
                                : NetworkImage(user.avatar!) as ImageProvider,
                          ),
                        ),
                        title: Text('${user.firstName} ${user.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.email ?? ''),
                      ),
                    ],
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
