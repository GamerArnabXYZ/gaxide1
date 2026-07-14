import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:gax_ide/utils/const.dart'; // Standardized project package reference
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_space/storage_space.dart'; // Modern up-to-date storage check integration

class FilesController extends GetxController {
  final FileManagerController controller = FileManagerController();

  // Made reactive using GetX observables (.obs) to match dynamic UI updates perfectly
  var deviceAvailableSize = 0.obs;
  var deviceTotalSize = 0.obs;

  var documentSize = 0.0;
  var videoSize = 0.0;
  var imageSize = 0.0;
  var soundSize = 0.0;

  @override
  void onInit() {
    super.onInit();
    _getSpace();
  }

  Future<void> _getSpace() async {
    try {
      // Fetching storage info via the new modern storage_space library
      StorageSpace space = await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024, // 2GB threshold safety check
      );
      
      // Setting exact integer values in GB directly
      int total = space.totalSpaceInGB.toInt();
      int free = space.freeSpaceInGB.toInt();
      int used = total - free;

      // Updating reactive variables
      deviceTotalSize.value = total;
      deviceAvailableSize.value = used; // UI displays "usedStorage", so feeding used space here
    } catch (e) {
      // Safe fallback if local system delays disk tracking
      deviceTotalSize.value = 32;
      deviceAvailableSize.value = 1;
    }
    update();
  }

  Future<void> selectStorage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                FileManager.basename(e),
                              ),
                              onTap: () {
                                controller.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return const Dialog(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: const Text("Name"),
                  onTap: () {
                    controller.sortBy(SortBy.name);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Size"),
                  onTap: () {
                    controller.sortBy(SortBy.size);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Date"),
                  onTap: () {
                    controller.sortBy(SortBy.date);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Type"),
                  onTap: () {
                    controller.sortBy(SortBy.type);
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  createFile(BuildContext context, String path) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController fileName = TextEditingController();
        TextEditingController fileSize = TextEditingController();
        TextEditingController fileExtension = TextEditingController();
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Name",
                    ),
                    controller: fileName,
                  ),
                ),
                ListTile(
                  trailing: const Text("Bytes"),
                  title: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "File Size",
                    ),
                    controller: fileSize,
                  ),
                ),
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Extension",
                    ),
                    controller: fileExtension,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: orage2,
                  ),
                  onPressed: () async {
                    if (fileName.text.isEmpty || fileExtension.text.isEmpty) return;
                    
                    String folderPath = path;
                    try {
                      Directory folder = Directory(folderPath);
                      if (!await folder.exists()) {
                        await folder.create(recursive: true);
                      }
                      File file = File(
                          '$folderPath/${fileName.text.trim()}.${fileExtension.text.trim()}');
                      if (!await file.exists()) {
                        await file.create();
                        int sizeInBytes = int.tryParse(fileSize.text) ?? 0;
                        if (sizeInBytes > 0) {
                          RandomAccessFile raf = await file.open(mode: FileMode.write);
                          for (int i = 0; i < sizeInBytes; i++) {
                            await raf.writeByte(0x00);
                          }
                          await raf.close();
                        }
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      alert(context, "Something went wrong");
                    }
                  },
                  child: const Text(
                    'Create File',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    update();
  }

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "Folder Name",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    controller: folderName,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: orage2,
                  ),
                  onPressed: () async {
                    if (folderName.text.isEmpty || folderName.text.trim() == "") {
                      return;
                    }

                    try {
                      await FileManager.createFolder(
                              controller.getCurrentPath, folderName.text.trim())
                          .then((value) {
                        Navigator.pop(context);
                        controller.setCurrentPath =
                            "${controller.getCurrentPath}/${folderName.text.trim()}";
                      });
                    } catch (e) {
                      alert(context, "Folder already exists");
                    }
                    update();
                  },
                  child: const Text(
                    'Create Folder',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> alert(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(message),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: orage2,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  calculateSize(List<FileSystemEntity> entities) {
    documentSize = 0;
    videoSize = 0;
    imageSize = 0;
    soundSize = 0;
    for (var i = 0; i < entities.length; i++) {
      String path = entities[i].path.toLowerCase();
      if (path.endsWith(".pdf") ||
          path.endsWith(".doc") ||
          path.endsWith(".txt") ||
          path.endsWith(".ppt") ||
          path.endsWith(".docx") ||
          path.endsWith(".pptx") ||
          path.endsWith(".xlsx") ||
          path.endsWith(".xls")) {
        documentSize += entities[i].statSync().size / 1000000;
      }
      if (path.endsWith(".mp4") ||
          path.endsWith(".mkv") ||
          path.endsWith(".avi") ||
          path.endsWith(".flv") ||
          path.endsWith(".wmv") ||
          path.endsWith(".mov") ||
          path.endsWith(".3gp") ||
          path.endsWith(".webm")) {
        videoSize += entities[i].statSync().size / 1000000;
      }
      if (path.endsWith(".jpg") ||
          path.endsWith(".jpeg") ||
          path.endsWith(".png") ||
          path.endsWith(".gif") ||
          path.endsWith(".bmp") ||
          path.endsWith(".webp")) {
        imageSize += (entities[i].statSync().size / 1000000);
      }
      if (path.endsWith(".mp3") ||
          path.endsWith(".wav") ||
          path.endsWith(".aac") ||
          path.endsWith(".ogg") ||
          path.endsWith(".wma") ||
          path.endsWith(".flac") ||
          path.endsWith(".m4a")) {
        soundSize += entities[i].statSync().size / 1000000;
      }
    }
    update();
  }
}
