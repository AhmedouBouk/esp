import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookDetailsPage extends StatelessWidget {
  final Map bookData;

  const BookDetailsPage({Key? key, required this.bookData}) : super(key: key);

  Future<void> addToFavorites(Map<dynamic, dynamic> book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesString = prefs.getString('favorite_books');
    List<Map<String, dynamic>> favoriteBooks = favoritesString != null
        ? List<Map<String, dynamic>>.from(jsonDecode(favoritesString))
        : [];

    Map<String, dynamic> bookAsStringMap = Map<String, dynamic>.from(book);

    bool isAlreadyFavorite =
        favoriteBooks.any((element) => element['id'] == bookAsStringMap['id']);
    if (!isAlreadyFavorite) {
      favoriteBooks.add(bookAsStringMap);
      await prefs.setString('favorite_books', jsonEncode(favoriteBooks));
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = bookData['Name_book']?.toString() ?? 'غير متوفر';
    String author = bookData['Authour_name']?.toString() ?? 'غير متوفر';
    String genre = bookData['Genre']?.toString() ?? 'غير متوفر';
    String description = bookData['Description']?.toString() ?? 'غير متوفر';
    String price = bookData['Prix']?.toString() ?? 'غير متوفر';
    String libraryName = bookData['library_name']?.toString() ?? 'غير متوفر';
    String libraryphone =
        bookData['library_PHONE_NUMBER']?.toString() ?? 'غير متوفر';
    String imageUrl = bookData['Image'] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'bookImage${bookData['id']}',
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1E88E5).withOpacity(0.3),
                          Color(0xFF26C6DA).withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                name,
                style: GoogleFonts.cairo(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorAndGenre(author, genre),
                  SizedBox(height: 20),
                  _buildPriceSection(price),
                  SizedBox(height: 20),
                  _buildDescriptionSection(description),
                  SizedBox(height: 20),
                  _buildLibrarySection(context, libraryName, libraryphone),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorAndGenre(String author, String genre) {
    return Row(
      children: [
        Expanded(child: _buildInfoChip(Icons.person, 'المؤلف', author)),
        SizedBox(width: 10),
        Expanded(child: _buildInfoChip(Icons.category, 'النوع', genre)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E88E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Color(0xFF1E88E5)),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  textStyle: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(String price) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF26C6DA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'السعر',
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26C6DA),
              ),
            ),
          ),
          Text(
            '$price MRU',
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26C6DA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف',
          style: GoogleFonts.cairo(
            textStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          description,
          style: GoogleFonts.cairo(
            textStyle: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarySection(
      BuildContext context, String libraryName, String libraryphone) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متوفر في',
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            libraryName,
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () => _launchWhatsApp(context, libraryphone),
            icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
            label: Text(
              'التواصل عبر WhatsApp',
              style: GoogleFonts.cairo(
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber == 'غير متوفر') {
      _showErrorSnackBar(context, 'رقم الهاتف غير متوفر');
      return;
    }
    final formattedPhoneNumber =
        '222${phoneNumber.replaceAll(RegExp(r'\D'), '')}';
    final whatsappUrl = Uri.parse('https://wa.me/$formattedPhoneNumber');
    final whatsappUrlScheme =
        Uri.parse('whatsapp://send?phone=$formattedPhoneNumber');

    try {
      bool launched = await launchUrl(whatsappUrlScheme,
          mode: LaunchMode.externalApplication);
      if (!launched) {
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch WhatsApp';
        }
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      _showErrorSnackBar(context, 'Error launching WhatsApp: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
