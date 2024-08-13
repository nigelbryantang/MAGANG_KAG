import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart'; // Use open_filex package

class CSVExporter {
  static const String baseUrl = 'http://nbtserver.my.id/help';

  static Future<void> downloadCSV(BuildContext context) async {
    final url = Uri.parse('$baseUrl/export');

    try {
      // Request storage permissions
      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          PermissionStatus status = await Permission.storage.request();
          if (!status.isGranted) {
            _showErrorSnackBar(context, 'Storage permission not granted');
            return;
          }
        }

        // For Android 11+, request Manage External Storage permission
        if (Platform.isAndroid && !await Permission.manageExternalStorage.isGranted) {
          PermissionStatus status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            _showErrorSnackBar(context, 'Manage External Storage permission not granted');
            return;
          }
        }
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Use public Downloads directory
        String downloadsPath = '/storage/emulated/0/Download';

        // Ensure the directory exists
        Directory downloadsDir = Directory(downloadsPath);
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }

        final filePath = '${downloadsDir.path}/Monitoring_log.xlsx';

        // Write the file to the device
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Show a SnackBar with the file path
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File saved to: $filePath')),
          );
        }

        // Open the file using native app handlers
        var result = await OpenFilex.open(filePath);
        if (result.type == ResultType.error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error opening file: ${result.message}')),
            );
          }
        }
      } else {
        _showErrorSnackBar(context, 'Failed to download file: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_filex/open_filex.dart'; // Use open_filex package
//
// class CSVExporter {
//   static const String baseUrl = 'http://nbtserver.my.id/help';
//
//   static Future<void> downloadCSV(BuildContext context) async {
//     final url = Uri.parse('$baseUrl/export');
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         // Use public Downloads directory
//         String downloadsPath = '/storage/emulated/0/Download';
//
//         // Ensure the directory exists
//         Directory downloadsDir = Directory(downloadsPath);
//         if (!downloadsDir.existsSync()) {
//           downloadsDir.createSync(recursive: true);
//         }
//
//         final filePath = '${downloadsDir.path}/Monitoring_log.xlsx';
//
//         // Write the file to the device
//         final file = File(filePath);
//         await file.writeAsBytes(response.bodyBytes);
//
//         // Show a SnackBar with the file path
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('File saved to: $filePath')),
//           );
//         }
//
//         // Open the file using native app handlers
//         var result = await OpenFilex.open(filePath);
//         if (result.type == ResultType.error) {
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error opening file: ${result.message}')),
//             );
//           }
//         }
//       } else {
//         _showErrorSnackBar(context, 'Failed to download file: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error downloading file: $e');
//       _showErrorSnackBar(context, 'Error: $e');
//     }
//   }
//
//   static void _showErrorSnackBar(BuildContext context, String message) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
// }
