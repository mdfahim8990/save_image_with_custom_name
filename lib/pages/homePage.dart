import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as d;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imagePath;
  var pickedFile;
  bool permission = false;
  var images;
  final picker = ImagePicker();

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  FocusNode idFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
 /* @override
  void initState() {
    // TODO: implement initState
    super.initState();
    images =  Image.asset(
      "assets/images/person.jpg",
      fit: BoxFit.cover,
    );
  }*/

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    width: width / 2,
                    height: height / 4,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            15) // Adjust the radius as needed
                        ),
                    child: images == null
                        ? Image.asset(
                      "assets/images/empty_image.jpg",
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                            images!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const Text(
                    "Profile Image",
                    style: TextStyle(fontSize: 25),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 45,
                      width: width / 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5, // Add elevation here
                          //padding: EdgeInsets.all(20),
                          backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                        ),
                        onPressed: () async {
                          try {
                            await requestStoragePermission();

                              imagePath = await pickAndSaveImage();

                            setState(() {});
                          } catch (e) {
                            d.log("Error[Request Permission and Camera Open]:",
                                error: e);
                          }
                        },
                        child:   const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Camera"),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.camera_alt)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    children: [
                      Text(
                        'Id',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: idController,
                    keyboardType: TextInputType.name,
                    focusNode: idFocusNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Id';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add Id',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      //  border bottom
                    ),
                    onTap: () {},
                    onEditingComplete: () {
                      setState(() {
                        /*firstNameFocusNode.unfocus();
                        lastNameFocusNode.requestFocus();*/
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children: [
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    focusNode: nameFocusNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add full Name',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      //  border bottom
                    ),
                    onTap: () {},
                    onEditingComplete: () {
                      setState(() {
                        /*firstNameFocusNode.unfocus();
                        lastNameFocusNode.requestFocus();*/
                      });
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      height: 45,
                      width: width / 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 8, // Add elevation here
                          //padding: EdgeInsets.all(20),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (imagePath != null) {
                              saveImageToGallery(imagePath!, idController.text,
                                  nameController.text);
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                backgroundColor: Colors.deepOrangeAccent,
                                content: Text("Pick Image Please"),
                              ));
                            }
                          }
                        },
                        child: const Text('Save Image'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.photos.request();
  }

  Future<String?> pickAndSaveImage() async {
    try {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 5);
      if (pickedFile == null) {
        return null;
      } else {
        images = File(pickedFile.path);
      }

      final fileName = '${DateTime.now()}.jpg'; // Generate unique name
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/$fileName';

      // Read bytes from picked file
      final bytes = await pickedFile.readAsBytes();

      // Create a new file with custom name
      final newFile = File(newPath);

      // Write bytes to the new file
      await newFile.writeAsBytes(bytes);

      return newPath; // Return the path of the copied file
    } catch (e) {
      d.log("Error: [Camera Open And Image Pick] :$e");
    }
  }
/*  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }*/
  Future<void> pickAndDeleteImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Perform deletion
      await deleteImage(pickedFile.path);
      print('Image deleted successfully!');
    } else {
      print('No image selected.');
    }
  }
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }
  Future<void> saveImageToGallery(
      String imagePath, String id, String name) async {

      await ImageGallerySaver.saveFile(imagePath, name: '$id-$name');
     if(mounted){
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
         backgroundColor: Colors.indigoAccent,
         content: Center(child: Text("Save Successfully")),
       ));
     }

        idController.clear();
        nameController.clear();
        imagePath = '';
        images = null;
        idFocusNode.unfocus();
        nameFocusNode.unfocus();
        setState(() {
        });

  }
}
