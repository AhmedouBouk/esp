import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  List<String> _favoriteBooks = [];
  List<dynamic> _bookDetails = [];

  List<String> get favoriteBooks => _favoriteBooks;
  List<dynamic> get bookDetails => _bookDetails;

  FavoritesProvider() {
    loadFavorites();
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteBooks = prefs.getStringList('favoriteBooks') ?? [];
    await fetchFavoriteBooks();
  }

  void toggleFavorite(String bookName) async {
    if (_favoriteBooks.contains(bookName)) {
      _favoriteBooks.remove(bookName);
    } else {
      _favoriteBooks.add(bookName);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoriteBooks', _favoriteBooks);
    await fetchFavoriteBooks();
  }

  bool isFavorite(String bookName) {
    return _favoriteBooks.contains(bookName);
  }

  Future<void> fetchFavoriteBooks() async {
    List<dynamic> tempBookDetails = [];
    for (String bookName in _favoriteBooks) {
      final book = await fetchBookByName(bookName);
      if (book != null) {
        tempBookDetails.add(book);
      }
    }
    _bookDetails = tempBookDetails;
    notifyListeners();
  }

  Future<dynamic> fetchBookByName(String bookName) async {
    Uri url = Uri.parse('https://mektebeti.pythonanywhere.com/api/livres/$bookName/');
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load book');
      }
    } catch (e) {
      return null;
    }
  }
}
