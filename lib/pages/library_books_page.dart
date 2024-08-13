import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'BookDetailsPage.dart';
import '../services/search_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryBooksPage extends StatefulWidget {
  final int libraryId;
  final String libraryName;

  const LibraryBooksPage(
      {Key? key, required this.libraryId, required this.libraryName})
      : super(key: key);

  @override
  _LibraryBooksPageState createState() => _LibraryBooksPageState();
}

class _LibraryBooksPageState extends State<LibraryBooksPage> {
  List<dynamic> bookList = [];
  List<dynamic> searchResults = [];
  String selectedGenre = 'الكل';
  TextEditingController searchController = TextEditingController();
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  bool isSearching = false;
  bool isLoading = true;
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    getBooks();
    controller.addListener(() {
      if (_mounted) {
        setState(() {
          closeTopContainer = controller.offset > 50;
        });
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> getBooks() async {
    Uri url = Uri.parse(
        'https://mektebeti.pythonanywhere.com/api/libraries/${widget.libraryId}/books/');
    print('Fetching books from: $url');
    try {
      http.Response response =
          await http.get(url).timeout(Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        if (_mounted) {
          setState(() {
            bookList = jsonDecode(response.body) as List<dynamic>;
            isLoading = false;
          });
        }
        print('Fetched ${bookList.length} books');
      } else {
        throw Exception('فشل في تحميل الكتب: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ أثناء تحميل الكتب: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('فشل في تحميل الكتب. يرجى المحاولة مرة أخرى لاحقاً.');
      }
    }
  }

  Future<void> searchDjango(String value) async {
    if (value.isEmpty) {
      if (_mounted) {
        setState(() {
          isSearching = false;
          searchResults.clear();
        });
      }
      return;
    }

    if (_mounted) {
      setState(() {
        isSearching = true;
      });
    }

    try {
      String responseBody = await SearchService.searchDjangoApi(value);
      List<dynamic> data = jsonDecode(responseBody);
      if (_mounted) {
        setState(() {
          searchResults = data;
        });
      }
    } catch (e) {
      print('حدث خطأ أثناء البحث: $e');
      if (_mounted) {
        setState(() {
          searchResults = [];
        });
        _showErrorSnackBar('فشل البحث. يرجى المحاولة مرة أخرى.');
      }
    }
  }

  List<dynamic> get filteredBooks {
    if (isSearching) return searchResults;
    if (selectedGenre == 'الكل') return bookList;
    return bookList.where((book) => book['Genre'] == selectedGenre).toList();
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
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: controller,
                slivers: <Widget>[
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    expandedHeight: 200,
                    backgroundColor: Color(0xFF1E88E5),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E88E5), Color(0xFF26C6DA)],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildSearchBar(),
                            SizedBox(height: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: closeTopContainer ? 0 : 80,
                              child: CategoriesScroller(
                                selectedGenre: selectedGenre,
                                onCategorySelected: (String genre) {
                                  if (_mounted) {
                                    setState(() {
                                      selectedGenre = genre;
                                      isSearching = false;
                                      searchController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      widget.libraryName,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: isLoading
                        ? SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : filteredBooks.isEmpty
                            ? SliverFillRemaining(
                                child: Center(child: Text('لا توجد كتب')),
                              )
                            : SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      columnCount: 2,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: _buildBookItem(
                                              filteredBooks[index]),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: filteredBooks.length,
                                ),
                              ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60, // Adjust the height if needed
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          searchDjango(value);
        },
        decoration: InputDecoration(
          hintText: 'البحث عن الكتب...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF1E88E5)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildBookItem(dynamic book) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookDetailsPage(bookData: book)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: book['Image'] != null
                    ? Image.network(
                        book['Image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.book, color: Colors.grey[600]),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book['Name_book'] ?? 'غير معروف',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      book['Authour_name'] ?? 'غير معروف',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${book['Prix'] ?? 'غير متوفر'} MRU',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF26C6DA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (_mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class CategoriesScroller extends StatelessWidget {
  final String selectedGenre;
  final Function(String) onCategorySelected;

  const CategoriesScroller({
    Key? key,
    required this.selectedGenre,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'الكل', 'icon': Icons.category},
      {'name': 'الأدب', 'icon': Icons.book},
      {'name': 'رواية', 'icon': Icons.auto_stories},
      {'name': 'ديني', 'icon': Icons.mosque},
      {'name': 'تاريخي', 'icon': Icons.history_edu},
      {'name': 'سياسي', 'icon': Icons.gavel},
      {'name': 'علمي', 'icon': Icons.science},
      {'name': 'مال وأعمال', 'icon': Icons.business},
      {'name': 'علم النفس', 'icon': Icons.psychology},
      {'name': 'رومانسي', 'icon': Icons.favorite},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category['name'] == selectedGenre;
        return GestureDetector(
          onTap: () => onCategorySelected(category['name'] as String),
          child: Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category['icon'] as IconData,
                    size: 24, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
