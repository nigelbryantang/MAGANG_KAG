import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://<YOUR_FLASK_SERVER_IP>:5000';

  Future<String> exportExcel() async {
    final url = Uri.parse('$baseUrl/export_excel');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['file_path']; // Assuming your API returns a file path
      } else {
        throw Exception('Failed to export Excel: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error exporting Excel: $e');
      return '';
    }
  }
}
