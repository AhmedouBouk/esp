import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'library_books_page.dart';

class AllLibraryPage extends StatefulWidget {
  const AllLibraryPage({Key? key}) : super(key: key);

  @override
  _AllLibraryPageState createState() => _AllLibraryPageState();
}

class _AllLibraryPageState extends State<AllLibraryPage> {
  List<dynamic> libraries = [];
  bool isLoading = true;
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    fetchLibraries();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchLibraries() async {
    Uri url = Uri.parse('https://mektebeti.pythonanywhere.com/api/libraries/');
    try {
      http.Response response =
          await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (_mounted) {
          setState(() {
            libraries = jsonDecode(response.body) as List<dynamic>;
            isLoading = false;
          });
        }
      } else {
        throw Exception('فشل في تحميل المكتبات: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ أثناء جلب المكتبات: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('فشل في تحميل المكتبات. يرجى المحاولة مرة أخرى لاحقاً.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFF1E88E5),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF26C6DA)),
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 80.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'المكتبات',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E88E5), Color(0xFF26C6DA)],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.0),
              sliver: isLoading
                  ? SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : libraries.isEmpty
                      ? SliverFillRemaining(
                          child: Center(child: Text('لم يتم العثور على مكتبات')),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildLibraryItem(libraries[index]),
                                  ),
                                ),
                              );
                            },
                            childCount: libraries.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(dynamic library) {
    // Affichez l'URL de l'image pour débogage
    print('URL الصورة: ${library['image']}');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LibraryBooksPage(
                  libraryId: library['id'], libraryName: library['name_lib']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'library_${library['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: library['image'] != null
                          ? Image.network(
                              'https://mektebeti.pythonanywhere.com${library['image']}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('حدث خطأ أثناء تحميل الصورة: $error');
                                return _buildPlaceholder(library);
                              },
                            )
                          : _buildPlaceholder(library),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          library['name_lib'] ?? 'غير معروف',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          library['email'] ?? 'لا يوجد بريد إلكتروني',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                    label: 'واتساب',
                    onPressed: () => _launchWhatsApp(library['phone_number']),
                  ),
                  _buildActionButton(
                    icon: Icons.location_on,
                    color: Color(0xFF1E88E5),
                    label: 'الموقع',
                    onPressed: () => _launchGoogleMaps(
                        library['latitude'], library['longitude']),
                  ),
                  _buildActionButton(
                    icon: Icons.call,
                    color: Color(0xFF26C6DA),
                    label: 'اتصال',
                    onPressed: () => _launchPhone(library['phone_number']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic library) {
    return Container(
      width: 100,
      height: 100,
      color: Color(0xFF1E88E5),
      child: Center(
        child: Text(
          library['name_lib'].isNotEmpty
              ? library['name_lib'][0].toUpperCase()
              : '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  void _launchWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null) {
      _showErrorSnackBar('رقم الهاتف غير متاح');
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
          throw 'لم أتمكن من فتح واتساب';
        }
      }
    } catch (e) {
      print('خطأ في فتح واتساب: $e');
      _showErrorSnackBar('خطأ في فتح واتساب: $e');
    }
  }

  void _launchGoogleMaps(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      _showErrorSnackBar('الموقع غير متاح');
      return;
    }

    final query = Uri.encodeComponent('$latitude,$longitude');
    final googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final googleMapsAppUrl = Uri.parse('geo:$latitude,$longitude');

    try {
      // First, try to launch the map app using the geo URI
      bool launched = await launchUrl(googleMapsAppUrl,
          mode: LaunchMode.externalApplication);

      if (!launched) {
        // If that fails, try opening Google Maps in the browser
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          // If both attempts fail, throw an exception
          throw 'لم أتمكن من فتح خرائط جوجل';
        }
      }
    } catch (e) {
      print('خطأ في فتح خرائط جوجل: $e');
      // Show a more user-friendly error message
      _showErrorSnackBar(
          'تعذر فتح الخرائط. يرجى التأكد من وجود تطبيق خرائط مثبت.');

      // Optionally, you could offer to open the coordinates in the default browser
      if (await canLaunchUrl(googleMapsUrl)) {
        bool userWantsToOpenInBrowser = await _showConfirmationDialog(
            'هل ترغب في عرض الموقع في متصفح الويب الخاص بك؟');
        if (userWantsToOpenInBrowser) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('فتح في المتصفح'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text('إلغاء'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text('فتح'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            }) ??
        false;
  }

  void _launchPhone(String? phoneNumber) async {
    if (phoneNumber == null) {
      _showErrorSnackBar('رقم الهاتف غير متاح');
      return;
    }
    final phoneUrl = Uri.parse('tel:$phoneNumber');
    final phoneIntent = Uri.parse(
        'intent://call/$phoneNumber#Intent;scheme=tel;action=android.intent.action.CALL;package=com.android.server.telecom;end');

    try {
      bool launched =
          await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (await canLaunchUrl(phoneIntent)) {
          await launchUrl(phoneIntent, mode: LaunchMode.externalApplication);
        } else {
          throw 'لم أتمكن من فتح تطبيق الهاتف';
        }
      }
    } catch (e) {
      print('خطأ في فتح تطبيق الهاتف: $e');
      _showErrorSnackBar('خطأ في فتح تطبيق الهاتف: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
