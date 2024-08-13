import 'package:http/http.dart' as http;

class SearchService {
  static Future<String> searchDjangoApi(String query) async {
    Uri url =
        Uri.parse('https://mektebeti.pythonanywhere.com/api/livres/?q=$query');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
