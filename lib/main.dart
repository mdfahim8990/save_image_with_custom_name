import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            requestStoragePermission();
            String? imagePath = await pickAndSaveImage();
            if (imagePath != null) {
              saveImageToGallery(imagePath);
            }
          },
          child: const Text('Capture'),
        ),
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      // Handle permission denied case
      return false;
    }
  }

  Future<String?> pickAndSaveImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return null;
    }

    final fileName = '${DateTime.now()}fahim.jpg'; // Generate unique name
    final directory = await getApplicationDocumentsDirectory();
    final newPath = '${directory.path}/$fileName';

    // Read bytes from picked file
    final bytes = await pickedFile.readAsBytes();

    // Create a new file with custom name
    final newFile = File(newPath);

    // Write bytes to the new file
    await newFile.writeAsBytes(bytes);

    return newPath; // Return the path of the copied file
  }

  Future<void> saveImageToGallery(String imagePath) async {
    await ImageGallerySaver.saveFile(imagePath, name: 'Fahim.jpg');
  }
}
