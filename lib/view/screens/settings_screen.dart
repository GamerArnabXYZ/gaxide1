import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../controller/files_controller.dart';
import '../../utils/const.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Shifting our active controller reference
    final FilesController myController = Get.find<FilesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Storage",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Reactive Storage Card Layout
            Obx(() {
              final int total = myController.deviceTotalSize.value.toInt();
              final int used = myController.deviceAvailableSize.value.toInt();
              
              // Safe progress percentage logic
              final double progress = total > 0 ? (used / total) : 0.0;

              return Container(
                width: 100.w,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text Specs Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$used GB / $total GB",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Used Device Space",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Responsive Circular Progress Ring
                    SizedBox(
                      height: 8.h,
                      width: 8.h,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(orange),
                        strokeWidth: 5,
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 30),
            Text(
              "IDE Preferences",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Placeholder option just for professional layout feel
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.code, color: orange),
              title: const Text("Editor Configurations"),
              subtitle: const Text("Font size, tab spacing, auto-save"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Future IDE settings space
              },
            ),
          ],
        ),
      ),
    );
  }
}
