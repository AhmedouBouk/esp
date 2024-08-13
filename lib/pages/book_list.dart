import 'package:esp/pages/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'BookDetailsPage.dart';
import '../services/search_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart'; // Import the favorites provider

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<dynamic> bookList = [];
  List<dynamic> searchResults = [];
  String selectedGenre = 'الكل';
  TextEditingController searchController = TextEditingController();
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  bool isSearching = false;
  bool isLoading = true; // Ajoutez cette ligne

  @override
  void initState() {
    super.initState();
    getBooks();
    controller.addListener(() {
      setState(() {
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  Future<void> getBooks() async {
    setState(() {
      isLoading = true; // Définir isLoading à true avant de commencer à charger
    });
    Uri url = Uri.parse('https://mektebeti.pythonanywhere.com/api/livres/');
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          bookList = jsonDecode(response.body) as List<dynamic>;
          isLoading = false; // Définir isLoading à false une fois les données chargées
        });
      } else {
        throw Exception('فشل في تحميل الكتب');
      }
    } catch (e) {
      print('حدث خطأ: $e');
      setState(() {
        isLoading = false; // Définir isLoading à false en cas d'erreur
      });
    }
  }

  Future<void> searchDjango(String value) async {
    if (value.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      String responseBody = await SearchService.searchDjangoApi(value);
      List<dynamic> data = jsonDecode(responseBody);
      setState(() {
        searchResults = data;
      });
    } catch (e) {
      print('حدث خطأ أثناء البحث: $e');
      setState(() {
        searchResults = [];
      });
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
                                  setState(() {
                                    selectedGenre = genre;
                                    isSearching = false;
                                    searchController.clear();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      'مكتبتي',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.favorite),
                        color: Color(0xFFFF0000),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoritesPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 80), // Ajoutez du padding en bas
                    sliver: isLoading // Vérifiez si isLoading est vrai
                        ? SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7, // Adjusted aspect ratio
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: _buildBookItem(filteredBooks[index]),
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
    final String bookName = book['Name_book'];

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(bookName);

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsPage(bookData: book),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                    child: Stack(
                      children: [
                        Image.network(
                          book['Image'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              favoritesProvider.toggleFavorite(bookName);
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ],
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
                            book['Name_book'],
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          book['Authour_name'] ?? 'غير معروف',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      },
    );
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
