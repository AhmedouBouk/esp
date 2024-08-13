import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حول التطبيق',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'نبذة عن التطبيق',
                    content:
                        'هذا التطبيق يساعدك في البحث  عن الكتب والمكتبات بسهولة. يمكنك البحث عن الكتب، تصفح الفئات المختلفة، و تصفح المكتبات المتاحة. كما يمكنك الاطلاع على تفاصيل الكتاب والمؤلف.',
                  ),
                  SizedBox(height: 24),
                  _buildFeatures(),
                  SizedBox(height: 24),
                  _buildDevelopers(context),
                  SizedBox(height: 24),
                  _buildContact(context),
                  SizedBox(height: 24),
                  _buildSocialMedia(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {'icon': Icons.search, 'text': 'البحث عن الكتب'},
      {'icon': Icons.book, 'text': 'تفاصيل الكتب'},
      {'icon': Icons.library_books, 'text': 'تصفح المكتبات'},
      {'icon': Icons.phone_android, 'text': 'واجهة سهلة'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المميزات',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: features
              .map((feature) => _buildFeatureItem(
                    feature['icon'] as IconData,
                    feature['text'] as String,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String feature) {
    return Container(
      width: 150,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blue.shade800, size: 24),
              SizedBox(height: 4),
              Text(
                feature,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevelopers(BuildContext context) {
    final developers = [
      {
        'name': ' مريم أجيون',
        'linkedin': 'https://www.linkedin.com/in/mouna-ejiwen-2a72bb29b?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app'
      },
      {
        'name': ' محمدو محمد الأمين ابوك',
        'linkedin':
            'http://www.linkedin.com/in/mohamedou-mohamed-lemine-a7886b314/'
      },
      {
        'name': ' محمد الأمين نيانج',
        'linkedin': 'https://www.linkedin.com/in/developer3'
      },
      {
        'name': ' سيدي محمد الصبار',
        'linkedin': 'https://www.linkedin.com/in/sidi-mohamed-sabar-02486a30a?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المطورون',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        ...developers.map((dev) => _buildDeveloperItem(
            context, dev['name'] as String, dev['linkedin'] as String)),
      ],
    );
  }

  Widget _buildDeveloperItem(
      BuildContext context, String name, String linkedinUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: InkWell(
          onTap: () => _launchURL(context, linkedinUrl),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0077B5), Color(0xFF0E6795)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.linkedin,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildContact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'للتواصل',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        _buildContactItem(Icons.email, 'البريد الإلكتروني', 'irt77696@esp.mr'),
        SizedBox(height: 8),
        _buildContactItem(Icons.phone, 'الهاتف', '47348999',
            onTap: () => _launchURL(context, 'https://wa.me/22247348999')),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String info,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade800),
        title: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          info,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تابعنا على',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialMediaIcon(context, FontAwesomeIcons.facebook,
                'https://www.facebook.com/share/JJHcZqpXy3n2dwZm/?mibextid=LQQJ4d', Colors.blue),
            _buildSocialMediaIcon(context, FontAwesomeIcons.whatsapp,
                'https://wa.me/22247348999', Color.fromARGB(255, 54, 177, 70)),
          
          ],
        ),
      ],
    );
  }

  Widget _buildSocialMediaIcon(
      BuildContext context, IconData icon, String url, Color color) {
    return InkWell(
      onTap: () => _launchURL(context, url),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, size: 24, color: Colors.white),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not open the link. Please try again later.')),
      );
    }
  }
}
