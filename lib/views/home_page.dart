import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    _permission();
    super.initState();
  }

  _permission() {}
  TextEditingController landmarkTextController = TextEditingController();
  TextEditingController longitudeTextController = TextEditingController();
  TextEditingController latitudeTextController = TextEditingController();

  String? pickedImage;
  DateTime? dateTime;

  _pickImage() async {
    final imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Image cropper',
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Image cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        pickedImage = croppedFile.path;
      });
    }
  }

  _pickDateTime() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime(2030));

    if (picked != null && picked != dateTime) {
      setState(() {
        dateTime = picked;
      });
    }
    _selectTime(context);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime!),
    );
    if (picked != null) {
      setState(() {
        dateTime = DateTime(
          dateTime!.year,
          dateTime!.month,
          dateTime!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  GlobalKey globalKey = GlobalKey();

  Future<void> saveStackContent() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(
        pixelRatio: 3.0); // Adjust the pixelRatio as needed
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      Uint8List bytes = byteData.buffer.asUint8List();

      // Save the image to the gallery
      final result = await ImageGallerySaver.saveImage(bytes);

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Image Saved'),
            content: Text('The image has been saved to the gallery.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Ionicons.logo_github),
          onPressed: () async {
            if (!await launchUrl(Uri.parse('https://github.com/'),mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("failed launch")));
            }
          },
        ),
        title: const Text("Edit gps"),
        actions: [
          pickedImage != null
              ? IconButton(
                  onPressed: () {
                    saveStackContent();
                  },
                  icon: const Icon(Icons.save_alt_rounded))
              : const SizedBox.shrink()
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: pickedImage == null
                  ? Center(
                      child: TextButton(
                          child: const Text("Pick image"),
                          onPressed: () {
                            _pickImage();
                          }),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          RepaintBoundary(
                            key: globalKey,
                            child: Stack(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      _pickImage();
                                    },
                                    child: Image.file(File(pickedImage!))),
                                if (pickedImage != null && dateTime != null)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration:
                                          BoxDecoration(color: Colors.black54),
                                      padding: const EdgeInsets.all(10),
                                      child: Expanded(
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                  'assets/location.png',
                                                  width: 80),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Landmark :" +
                                                            landmarkTextController
                                                                .text,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Longitude : " +
                                                                longitudeTextController
                                                                    .text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Text(
                                                            "Latitude : " +
                                                                latitudeTextController
                                                                    .text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .format(dateTime!),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        DateFormat.Hms()
                                                            .format(dateTime!),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox.shrink()
                              ],
                            ),
                          ),
                          Card(
                            child: TextField(
                                controller: landmarkTextController,
                                decoration: const InputDecoration(
                                  label: Text("Landmark"),
                                )),
                          ),
                          Card(
                            child: TextField(
                                controller: longitudeTextController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  label: Text("Longitude"),
                                )),
                          ),
                          Card(
                            child: TextField(
                                controller: latitudeTextController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  label: Text("Lantitude"),
                                )),
                          ),
                          ElevatedButton.icon(
                              onPressed: () {
                                _pickDateTime();
                              },
                              icon: const Icon(Icons.edit_calendar_outlined),
                              label: const Text("Date picker"))
                        ],
                      ),
                    ))
        ],
      ),
    );
  }
}
