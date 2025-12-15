import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:techbook/screens/components/constant.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddBookUrl extends StatefulWidget {
  const AddBookUrl({super.key});

  @override
  AddBookUrlState createState() => AddBookUrlState();
}

class AddBookUrlState extends State<AddBookUrl> {
  FirebaseStorage storage = FirebaseStorage.instance;
  String ?title;
  String ?description;
  final texEditingControllertitle = TextEditingController();
  final textEditingControllerdescription = TextEditingController();
  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    PickedFile? pickedImage;
    try {
      pickedImage = await picker.getImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage.ref('Library/$fileName').putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': title!,
              'description': description!
            }));

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        debugPrint(error.toString());
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  // Retriew the uploaded images
  // This function is called when the app launches for the first time or when an image is uploaded or deleted
  Future<List<Map<String, dynamic>>> _loadImages() async {
    // Skip Firebase Storage on web due to CORS issues
    if (kIsWeb) {
      return [];
    }
    
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref('Library/').list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'No title',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
         foregroundColor:Colors.black54 ,
        iconTheme: IconThemeData(color: Colors.black54),
        
       
        backgroundColor: Colors.white,
        title: Text('Add Resource',style: TextStyle(color: Colors.black87)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          children: [
                           TextField(
                             controller: texEditingControllertitle,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      title = value;
                      //Do something with the user input.
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        helperText: 'PDF Name'),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  TextField(
                    controller: textEditingControllerdescription,
                    textAlign: TextAlign.center,
                    
                    onChanged: (value) {
                      description = value;

                      //Do something with the user input.
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        
                        helperText: ' PDF URL'),
                  ),
            /////////////////////////////
      


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _upload('camera'),
                    icon: Icon(Icons.camera),
                    label: Text('camera')),
                ElevatedButton.icon(
                    onPressed: () {
                       _upload('gallery');
                      texEditingControllertitle.clear();
                      textEditingControllerdescription.clear();
                      //  setState(() {
                      //    title ='';
                      //    description ='';
                      //  });
                    } ,
                    icon: Icon(Icons.library_add),
                    label: Text('Gallery')),
              ],
            ),
            SizedBox(height: 16),
            // Add PDF Button
            ElevatedButton.icon(
              onPressed: () {
                if (title != null && title!.isNotEmpty && 
                    description != null && description!.isNotEmpty) {
                  // Save to local list or show success
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF "$title" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  texEditingControllertitle.clear();
                  textEditingControllerdescription.clear();
                  setState(() {
                    title = '';
                    description = '';
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter PDF Name and URL'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.add),
              label: Text('Add PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
            ),
            //////////////////////////////////
                  
            /////////////////////////////
            Expanded(
              child: FutureBuilder(
                future: _loadImages(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> image =
                            snapshot.data![index];

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            dense: false,
                            leading: Image.network(image['url']),
                            title: Text(image['uploaded_by'],style: TextStyle(color: Colors.white)),
                            subtitle: Text(image['description'],style: TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              onPressed: () => _delete(image['path']),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ImagePicker {
  Future<PickedFile?> getImage({required ImageSource source, required int maxWidth}) async {
    final XFile? image = await pickImage(source: source, maxWidth: maxWidth.toDouble());
    return image != null ? PickedFile(image.path) : null;
  }
}