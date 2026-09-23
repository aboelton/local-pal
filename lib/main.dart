import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LocalPalApp());
}

// ============================================================
// GLOBAL
// ============================================================

String appLanguage = 'ar';
bool darkMode = false;

final Set<String> favoriteIds = <String>{};

String tr(String ar, String en, String he) {
  if (appLanguage == 'en') return en;
  if (appLanguage == 'he') return he;
  return ar;
}

// ============================================================
// CATEGORY
// ============================================================

class Category {
  final String id;
  final String ar;
  final String en;
  final String he;
  final IconData icon;

  const Category({
    required this.id,
    required this.ar,
    required this.en,
    required this.he,
    required this.icon,
  });

  String get name => tr(ar, en, he);
}

const categories = <Category>[
  Category(
    id: 'restaurant',
    ar: 'مطاعم',
    en: 'Restaurants',
    he: 'מסעדות',
    icon: Icons.restaurant,
  ),
  Category(
    id: 'cafe',
    ar: 'كافيهات',
    en: 'Cafes',
    he: 'בתי קפה',
    icon: Icons.local_cafe,
  ),
  Category(
    id: 'fast_food',
    ar: 'وجبات سريعة',
    en: 'Fast Food',
    he: 'מזון מהיר',
    icon: Icons.fastfood,
  ),
  Category(
    id: 'bakery',
    ar: 'مخابز',
    en: 'Bakeries',
    he: 'מאפיות',
    icon: Icons.bakery_dining,
  ),
  Category(
    id: 'supermarket',
    ar: 'سوبرماركت',
    en: 'Supermarkets',
    he: 'סופרמרקטים',
    icon: Icons.shopping_cart,
  ),
  Category(
    id: 'shop',
    ar: 'محلات',
    en: 'Shops',
    he: 'חנויות',
    icon: Icons.store,
  ),
  Category(
    id: 'clothes',
    ar: 'ملابس',
    en: 'Clothing',
    he: 'בגדים',
    icon: Icons.checkroom,
  ),
  Category(
    id: 'electronics',
    ar: 'إلكترونيات',
    en: 'Electronics',
    he: 'אלקטרוניקה',
    icon: Icons.devices,
  ),
  Category(
    id: 'hotel',
    ar: 'فنادق',
    en: 'Hotels',
    he: 'מלונות',
    icon: Icons.hotel,
  ),
  Category(
    id: 'park',
    ar: 'حدائق',
    en: 'Parks',
    he: 'פארקים',
    icon: Icons.park,
  ),
  Category(
    id: 'cinema',
    ar: 'سينما',
    en: 'Cinema',
    he: 'קולנוע',
    icon: Icons.movie,
  ),
  Category(
    id: 'gym',
    ar: 'جيم',
    en: 'Gyms',
    he: 'חדרי כושר',
    icon: Icons.fitness_center,
  ),
  Category(
    id: 'hospital',
    ar: 'مستشفيات',
    en: 'Hospitals',
    he: 'בתי חולים',
    icon: Icons.local_hospital,
  ),
  Category(
    id: 'clinic',
    ar: 'عيادات',
    en: 'Clinics',
    he: 'מרפאות',
    icon: Icons.medical_services,
  ),
  Category(
    id: 'pharmacy',
    ar: 'صيدليات',
    en: 'Pharmacies',
    he: 'בתי מרקחת',
    icon: Icons.local_pharmacy,
  ),
  Category(
    id: 'dentist',
    ar: 'أطباء أسنان',
    en: 'Dentists',
    he: 'רופאי שיניים',
    icon: Icons.medical_information,
  ),
  Category(
    id: 'doctor',
    ar: 'أطباء',
    en: 'Doctors',
    he: 'רופאים',
    icon: Icons.person_search,
  ),
  Category(
    id: 'fuel',
    ar: 'محطات وقود',
    en: 'Gas Stations',
    he: 'תחנות דלק',
    icon: Icons.local_gas_station,
  ),
  Category(
    id: 'barber',
    ar: 'حلاقين',
    en: 'Barbers',
    he: 'ספרים',
    icon: Icons.content_cut,
  ),
  Category(
    id: 'bank',
    ar: 'بنوك',
    en: 'Banks',
    he: 'בנקים',
    icon: Icons.account_balance,
  ),
  Category(
    id: 'atm',
    ar: 'صراف آلي',
    en: 'ATMs',
    he: 'כספומטים',
    icon: Icons.atm,
  ),
  Category(
    id: 'mall',
    ar: 'مولات',
    en: 'Malls',
    he: 'קניונים',
    icon: Icons.local_mall,
  ),
  Category(
    id: 'mosque',
    ar: 'مساجد',
    en: 'Mosques',
    he: 'מסגדים',
    icon: Icons.mosque,
  ),
  Category(
    id: 'church',
    ar: 'كنائس',
    en: 'Churches',
    he: 'כנסיות',
    icon: Icons.church,
  ),
  Category(
    id: 'school',
    ar: 'مدارس',
    en: 'Schools',
    he: 'בתי ספר',
    icon: Icons.school,
  ),
  Category(
    id: 'university',
    ar: 'جامعات',
    en: 'Universities',
    he: 'אוניברסיטאות',
    icon: Icons.account_balance,
  ),
  Category(
    id: 'parking',
    ar: 'مواقف سيارات',
    en: 'Parking',
    he: 'חניונים',
    icon: Icons.local_parking,
  ),
];

// ============================================================
// CITY
// ============================================================

class City {
  final String name;
  final String displayName;
  final double lat;
  final double lon;

  const City({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

const popularCities = <City>[
  City(
    name: 'Jerusalem',
    displayName: 'Jerusalem',
    lat: 31.7683,
    lon: 35.2137,
  ),
  City(
    name: 'Tel Aviv',
    displayName: 'Tel Aviv',
    lat: 32.0853,
    lon: 34.7818,
  ),
  City(
    name: 'Haifa',
    displayName: 'Haifa',
    lat: 32.7940,
    lon: 34.9896,
  ),
  City(
    name: 'Nazareth',
    displayName: 'Nazareth',
    lat: 32.6996,
    lon: 35.3035,
  ),
  City(
    name: 'Bethlehem',
    displayName: 'Bethlehem',
    lat: 31.7054,
    lon: 35.2024,
  ),
  City(
    name: 'Amman',
    displayName: 'Amman',
    lat: 31.9539,
    lon: 35.9106,
  ),
];

// ============================================================
// PLACE
// ============================================================

class Place {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lon;
  final String address;
  final String phone;
  final String website;
  final String hours;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lon,
    this.address = '',
    this.phone = '',
    this.website = '',
    this.hours = '',
    this.imageUrl = '',
    this.rating = 0,
    this.ratingCount = 0,
  });

  bool get isFavorite => favoriteIds.contains(id);
}

// ============================================================
// APP
// ============================================================

class LocalPalApp extends StatefulWidget {
  const LocalPalApp({super.key});

  @override
  State<LocalPalApp> createState() => _LocalPalAppState();
}

class _LocalPalAppState extends State<LocalPalApp> {
  void refreshApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Pal',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  City selectedCity = popularCities[0];

  void selectCity(City city) {
    setState(() {
      selectedCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeContent(
        city: selectedCity,
        onCityChanged: selectCity,
      ),
      SearchPage(city: selectedCity),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: tr('الرئيسية', 'Home', 'בית'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: tr('بحث', 'Search', 'חיפוש'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: tr('المفضلة', 'Favorites', 'מועדפים'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: tr('حسابي', 'Profile', 'פרופיל'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME CONTENT
// ============================================================

class HomeContent extends StatelessWidget {
  final City city;
  final ValueChanged<City> onCityChanged;

  const HomeContent({
    super.key,
    required this.city,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(
              'Local Pal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr(
                          'لا توجد إشعارات جديدة',
                          'No new notifications',
                          'אין התראות חדשות',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CitySelector(
                  city: city,
                  onChanged: onCityChanged,
                ),
                const SizedBox(height: 18),
                Text(
                  tr(
                    'ماذا تبحث اليوم؟',
                    'What are you looking for?',
                    'מה אתה מחפש היום?',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SearchButton(city: city),
                const SizedBox(height: 24),
                Text(
                  tr(
                    'التصنيفات',
                    'Categories',
                    'קטגוריות',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];

                  return CategoryCard(
                    category: category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlacesPage(
                            city: city,
                            category: category,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: categories.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CITY SELECTOR
// ============================================================

class CitySelector extends StatelessWidget {
  final City city;
  final ValueChanged<City> onChanged;

  const CitySelector({
    super.key,
    required this.city,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push<City>(
            context,
            MaterialPageRoute(
              builder: (_) => CitySearchPage(currentCity: city),
            ),
          );

          if (result != null) {
            onChanged(result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.location_on),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        'الموقع الحالي',
                        'Current location',
                        'מיקום נוכחי',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH BUTTON
// ============================================================

class SearchButton extends StatelessWidget {
  final City city;

  const SearchButton({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchPage(city: city),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr(
                  'ابحث عن مكان...',
                  'Search for a place...',
                  'חפש מקום...',
                ),
              ),
            ),
            const Icon(Icons.tune),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY CARD
// ============================================================

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CITY SEARCH
// ============================================================

class CitySearchPage extends StatefulWidget {
  final City currentCity;

  const CitySearchPage({
    super.key,
    required this.currentCity,
  });

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final controller = TextEditingController();

  List<City> results = <City>[];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    results = List<City>.from(popularCities);
  }

  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        results = List<City>.from(popularCities);
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'limit': '10',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'LocalPal/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      final found = <City>[];

      if (data is List) {
        for (final item in data) {
          final lat = double.tryParse('${item['lat']}');
          final lon = double.tryParse('${item['lon']}');

          if (lat == null || lon == null) continue;

          found.add(
            City(
              name: '${item['name'] ?? query}',
              displayName:
                  '${item['display_name'] ?? query}',
              lat: lat,
              lon: lon,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        results = found;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'تعذر البحث. تحقق من الإنترنت.',
              'Search failed. Check your internet.',
              'החיפוש נכשל. בדוק את האינטרנט.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'اختيار المدينة',
            'Choose city',
            'בחר עיר',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              onSubmitted: searchCities,
              decoration: InputDecoration(
                hintText: tr(
                  'ابحث عن مدينة...',
                  'Search city...',
                  'חפש עיר...',
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    searchCities('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final city = results[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.location_city),
                  ),
                  title: Text(
                    city.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    city.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context, city);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PLACES PAGE
// ============================================================

class PlacesPage extends StatefulWidget {
  final City city;
  final Category category;

  const PlacesPage({
    super.key,
    required this.city,
    required this.category,
  });

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  List<Place> places = <Place>[];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await PlacesService.getPlaces(
        city: widget.city,
        category: widget.category,
      );

      if (!mounted) return;

      setState(() {
        places = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPage(
                    city: widget.city,
                    places: places,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPlaces,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? ErrorView(
                  message: error!,
                  onRetry: loadPlaces,
                )
              : places.isEmpty
                  ? EmptyView(
                      message: tr(
                        'لم نجد أماكن لهذه الفئة.',
                        'No places found.',
                        'לא נמצאו מקומות.',
                      ),
                      onRetry: loadPlaces,
                    )
                  : RefreshIndicator(
                      onRefresh: loadPlaces,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          return PlaceCard(
                            place: places[index],
                            city: widget.city,
                          );
                        },
                      ),
                    ),
    );
  }
}

// ============================================================
// PLACES SERVICE
// ============================================================

class PlacesService {
  static const servers = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.system/api/interpreter',
  ];

  static Future<List<Place>> getPlaces({
    required City city,
    required Category category,
  }) async {
    final filter = _categoryFilter(category.id);

    final query = '''
[out:json][timeout:25];
(
  node(around:10000,${city.lat},${city.lon})$filter;
  way(around:10000,${city.lat},${city.lon})$filter;
  relation(around:10000,${city.lat},${city.lon})$filter;
);
out center tags;
''';

    Object? lastError;

    for (final server in servers) {
      try {
        final response = await http
            .post(
              Uri.parse(server),
              headers: {
                'User-Agent': 'LocalPal/1.0',
                'Content-Type':
                    'application/x-www-form-urlencoded',
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 35));

        if (response.statusCode != 200) {
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }

        final data = jsonDecode(response.body);

        if (data is! Map || data['elements'] is! List) {
          lastError = 'Invalid response';
          continue;
        }

        final result = <Place>[];

        for (final element in data['elements']) {
          final rawTags = element['tags'];

          final tags = rawTags is Map
              ? Map<String, dynamic>.from(rawTags)
              : <String, dynamic>{};

          final name = '${tags['name'] ?? ''}'.trim();

          if (name.isEmpty) continue;

          double? lat;
          double? lon;

          if (element['lat'] != null &&
              element['lon'] != null) {
            lat = double.tryParse('${element['lat']}');
            lon = double.tryParse('${element['lon']}');
          } else if (element['center'] is Map) {
            lat = double.tryParse(
              '${element['center']['lat']}',
            );
            lon = double.tryParse(
              '${element['center']['lon']}',
            );
          }

          if (lat == null || lon == null) continue;

          result.add(
            Place(
              id: '${element['type']}_${element['id']}',
              name: name,
              category: category.id,
              lat: lat,
              lon: lon,
              address: _addressFromTags(tags),
              phone:
                  '${tags['phone'] ?? tags['contact:phone'] ?? ''}',
              website:
                  '${tags['website'] ?? tags['contact:website'] ?? ''}',
              hours: '${tags['opening_hours'] ?? ''}',
              imageUrl: '${tags['image'] ?? ''}',
              rating:
                  double.tryParse('${tags['rating'] ?? 0}') ?? 0,
              ratingCount: int.tryParse(
                    '${tags['rating:count'] ?? 0}',
                  ) ??
                  0,
            ),
          );
        }

        result.sort((a, b) {
          final da = calculateDistance(
            city.lat,
            city.lon,
            a.lat,
            a.lon,
          );

          final db = calculateDistance(
            city.lat,
            city.lon,
            b.lat,
            b.lon,
          );

          return da.compareTo(db);
        });

        return result.take(100).toList();
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception(
      lastError?.toString() ??
          tr(
            'تعذر تحميل الأماكن',
            'Could not load places',
            'לא ניתן לטעון מקומות',
          ),
    );
  }

  static String _addressFromTags(
    Map<String, dynamic> tags,
  ) {
    final parts = <String>[];

    final street =
        '${tags['addr:street'] ?? ''}'.trim();
    final house =
        '${tags['addr:housenumber'] ?? ''}'.trim();
    final city =
        '${tags['addr:city'] ?? ''}'.trim();

    if (street.isNotEmpty) {
      parts.add(
        house.isNotEmpty ? '$street $house' : street,
      );
    }

    if (city.isNotEmpty) {
      parts.add(city);
    }

    return parts.join(', ');
  }

  static String _categoryFilter(String id) {
    switch (id) {
      case 'restaurant':
        return '[amenity=restaurant]';
      case 'cafe':
        return '[amenity=cafe]';
      case 'fast_food':
        return '[amenity=fast_food]';
      case 'bakery':
        return '[shop=bakery]';
      case 'supermarket':
        return '[shop=supermarket]';
      case 'shop':
        return '[shop]';
      case 'clothes':
        return '[shop=clothes]';
      case 'electronics':
        return '[shop=electronics]';
      case 'hotel':
        return '[tourism=hotel]';
      case 'park':
        return '[leisure=park]';
      case 'cinema':
        return '[amenity=cinema]';
      case 'gym':
        return '[leisure=fitness_centre]';
      case 'hospital':
        return '[amenity=hospital]';
      case 'clinic':
        return '[amenity=clinic]';
      case 'pharmacy':
        return '[amenity=pharmacy]';
      case 'dentist':
        return '[amenity=dentist]';
      case 'doctor':
        return '[amenity=doctors]';
      case 'fuel':
        return '[amenity=fuel]';
      case 'barber':
        return '[shop=hairdresser]';
      case 'bank':
        return '[amenity=bank]';
      case 'atm':
        return '[amenity=atm]';
      case 'mall':
        return '[shop=mall]';
      case 'mosque':
        return '[amenity=place_of_worship][religion=muslim]';
      case 'church':
        return '[amenity=place_of_worship][religion=christian]';
      case 'school':
        return '[amenity=school]';
      case 'university':
        return '[amenity=university]';
      case 'parking':
        return '[amenity=parking]';
      default:
        return '[name]';
    }
  }
}

// ============================================================
// PLACE CARD
// ============================================================

class PlaceCard extends StatefulWidget {
  final Place place;
  final City city;

  const PlaceCard({
    super.key,
    required this.place,
    required this.city,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance(
      widget.city.lat,
      widget.city.lon,
      widget.place.lat,
      widget.place.lon,
    );

    final category = getCategory(widget.place.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailsPage(
                place: widget.place,
                city: widget.city,
              ),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PlaceImage(
                place: widget.place,
                size: 85,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(category.icon, size: 16),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                        ),
                        if (widget.place.rating > 0) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.star,
                            size: 15,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.place.rating
                                .toStringAsFixed(1),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.place.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.place.isFavorite
                      ? Colors.red
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    if (favoriteIds
                        .contains(widget.place.id)) {
                      favoriteIds.remove(widget.place.id);
                    } else {
                      favoriteIds.add(widget.place.id);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// IMAGE
// ============================================================

class PlaceImage extends StatelessWidget {
  final Place place;
  final double size;

  const PlaceImage({
    super.key,
    required this.place,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (place.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          place.imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return placeholder(context);
          },
        ),
      );
    }

    return placeholder(context);
  }

  Widget placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        getCategoryIcon(place.category),
        size: size * 0.4,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// ============================================================
// DETAILS
// ============================================================

class PlaceDetailsPage extends StatefulWidget {
  final Place place;
  final City city;

  const PlaceDetailsPage({
    super.key,
    required this.place,
    required this.city,
  });

  @override
  State<PlaceDetailsPage> createState() =>
      _PlaceDetailsPageState();
}

class _PlaceDetailsPageState
    extends State<PlaceDetailsPage> {
  Future<void> callPlace() async {
    if (widget.place.phone.isEmpty) {
      showMessage(
        tr(
          'رقم الهاتف غير متوفر',
          'Phone number is not available',
          'מספר הטלפון אינו זמין',
        ),
      );
      return;
    }

    final phone =
        widget.place.phone.replaceAll(' ', '');

    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> openWebsite() async {
    if (widget.place.website.isEmpty) return;

    var url = widget.place.website.trim();

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category =
        getCategory(widget.place.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'تفاصيل المكان',
            'Place Details',
            'פרטי המקום',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.place.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.place.isFavorite
                  ? Colors.red
                  : null,
            ),
            onPressed: () {
              setState(() {
                if (favoriteIds
                    .contains(widget.place.id)) {
                  favoriteIds.remove(widget.place.id);
                } else {
                  favoriteIds.add(widget.place.id);
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlaceImage(
            place: widget.place,
            size: 180,
          ),
          const SizedBox(height: 18),
          Text(
            widget.place.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(category.icon),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
          if (widget.place.rating > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.place.rating
                      .toStringAsFixed(1),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          if (widget.place.address.isNotEmpty)
            DetailRow(
              icon: Icons.location_on,
              title: tr(
                'العنوان',
                'Address',
                'כתובת',
              ),
              value: widget.place.address,
            ),
          if (widget.place.phone.isNotEmpty)
            DetailRow(
              icon: Icons.phone,
              title: tr(
                'الهاتف',
                'Phone',
                'טלפון',
              ),
              value: widget.place.phone,
            ),
          if (widget.place.hours.isNotEmpty)
            DetailRow(
              icon: Icons.access_time,
              title: tr(
                'ساعات العمل',
                'Opening hours',
                'שעות פתיחה',
              ),
              value: widget.place.hours,
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              openGoogleMaps(widget.place);
            },
            icon: const Icon(Icons.map),
            label: Text(
              tr(
                'فتح في Google Maps',
                'Open in Google Maps',
                'פתח ב-Google Maps',
              ),
            ),
          ),
          if (widget.place.phone.isNotEmpty)
            OutlinedButton.icon(
              onPressed: callPlace,
              icon: const Icon(Icons.phone),
              label: Text(
                tr(
                  'اتصال',
                  'Call',
                  'התקשר',
                ),
              ),
            ),
          if (widget.place.website.isNotEmpty)
            OutlinedButton.icon(
              onPressed: openWebsite,
              icon: const Icon(Icons.language),
              label: Text(
                tr(
                  'الموقع الإلكتروني',
                  'Website',
                  'אתר',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
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
}

// ============================================================
// MAP
// ============================================================

class MapPage extends StatelessWidget {
  final City city;
  final List<Place> places;

  const MapPage({
    super.key,
    required this.city,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'الخريطة',
            'Map',
            'מפה',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              openCityInGoogleMaps(city);
            },
          ),
        ],
      ),
      body: OSMMapView(
        city: city,
        places: places,
      ),
    );
  }
}

class OSMMapView extends StatelessWidget {
  final City city;
  final List<Place> places;

  const OSMMapView({
    super.key,
    required this.city,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://tile.openstreetmap.org/12/'
            '${_tileX(city.lon, 12)}/'
            '${_tileY(city.lat, 12)}.png',
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Center(
                child: Text(
                  tr(
                    'تعذر تحميل الخريطة',
                    'Could not load map',
                    'לא ניתן לטעון את המפה',
                  ),
                ),
              );
            },
          ),
        ),
        const Center(
          child: Icon(
            Icons.location_on,
            size: 48,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  int _tileX(double lon, int zoom) {
    final n = pow(2, zoom).toDouble();
    return ((lon + 180) / 360 * n).floor();
  }

  int _tileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    final n = pow(2, zoom).toDouble();

    final y = (1 -
            log(tan(latRad) + 1 / cos(latRad)) /
                pi) /
        2 *
        n;

    return y.floor();
  }
}

// ============================================================
// SEARCH
// ============================================================

class SearchPage extends StatefulWidget {
  final City city;

  const SearchPage({
    super.key,
    required this.city,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  List<Place> results = <Place>[];
  bool loading = false;

  Future<void> search() async {
    final query = controller.text.trim();

    if (query.isEmpty) return;

    setState(() {
      loading = true;
      results = <Place>[];
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': '$query ${widget.city.name}',
          'format': 'json',
          'limit': '20',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'LocalPal/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      final found = <Place>[];

      if (data is List) {
        for (final item in data) {
          final lat =
              double.tryParse('${item['lat']}');
          final lon =
              double.tryParse('${item['lon']}');

          if (lat == null || lon == null) continue;

          found.add(
            Place(
              id: 'search_${item['place_id']}',
              name: '${item['display_name'] ?? query}',
              category: 'shop',
              lat: lat,
              lon: lon,
              address: '${item['display_name'] ?? ''}',
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        results = found;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'حدث خطأ أثناء البحث.',
              'Search error.',
              'אירעה שגיאה בחיפוש.',
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'البحث',
            'Search',
            'חיפוש',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => search(),
                decoration: InputDecoration(
                  hintText: tr(
                    'ابحث عن مكان...',
                    'Search for a place...',
                    'חפש מקום...',
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            if (loading)
              const LinearProgressIndicator(),
            Expanded(
              child: results.isEmpty && !loading
                  ? Center(
                      child: Text(
                        tr(
                          'اكتب اسم المكان للبحث',
                          'Enter a place to search',
                          'הקלד שם מקום לחיפוש',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return PlaceCard(
                          place: results[index],
                          city: widget.city,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// FAVORITES
// ============================================================

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() =>
      _FavoritesPageState();
}

class _FavoritesPageState
    extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              tr(
                'المفضلة',
                'Favorites',
                'מועדפים',
              ),
            ),
          ),
          Expanded(
            child: EmptyView(
              message: favoriteIds.isEmpty
                  ? tr(
                      'لم تضف أي أماكن للمفضلة بعد.',
                      'You have no favorite places yet.',
                      'עדיין אין מקומות במועדפים.',
                    )
                  : '${favoriteIds.length} ${tr(
                      'أماكن محفوظة',
                      'saved places',
                      'מקומות שמורים',
                    )}',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  void changeLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text(
                  '🇸🇦',
                  style: TextStyle(fontSize: 24),
                ),
                title: const Text('العربية'),
                onTap: () {
                  setState(() {
                    appLanguage = 'ar';
                  });
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Text(
                  '🇬🇧',
                  style: TextStyle(fontSize: 24),
                ),
                title: const Text('English'),
                onTap: () {
                  setState(() {
                    appLanguage = 'en';
                  });
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Text(
                  '🇮🇱',
                  style: TextStyle(fontSize: 24),
                ),
                title: const Text('עברית'),
                onTap: () {
                  setState(() {
                    appLanguage = 'he';
                  });
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    child: Icon(
                      Icons.person,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      'ملفي الشخصي',
                      'My Profile',
                      'הפרופיל שלי',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  const Text('Local Pal'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.language),
              title: Text(
                tr(
                  'اللغة',
                  'Language',
                  'שפה',
                ),
              ),
              subtitle: Text(
                appLanguage == 'ar'
                    ? 'العربية'
                    : appLanguage == 'en'
                        ? 'English'
                        : 'עברית',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: changeLanguage,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              secondary:
                  const Icon(Icons.dark_mode),
              title: Text(
                tr(
                  'الوضع الداكن',
                  'Dark Mode',
                  'מצב כהה',
                ),
              ),
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });

                final appState = context
                    .findAncestorStateOfType<
                        _LocalPalAppState>();

                appState?.refreshApp();
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.favorite),
              title: Text(
                tr(
                  'المفضلة',
                  'Favorites',
                  'מועדפים',
                ),
              ),
              subtitle: Text(
                '${favoriteIds.length} ${tr(
                  'مكان محفوظ',
                  'saved places',
                  'מקומות שמורים',
                )}',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Local Pal',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY / ERROR
// ============================================================

class EmptyView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const EmptyView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(
                  tr(
                    'إعادة المحاولة',
                    'Try again',
                    'נסה שוב',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              tr(
                'حدث خطأ أثناء تحميل البيانات.',
                'Something went wrong.',
                'אירעה שגיאה.',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: Text(
                tr(
                  'إعادة المحاولة',
                  'Try again',
                  'נסה שוב',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

Category getCategory(String id) {
  for (final category in categories) {
    if (category.id == id) {
      return category;
    }
  }

  return categories[0];
}

String getCategoryName(String id) {
  return getCategory(id).name;
}

IconData getCategoryIcon(String id) {
  return getCategory(id).icon;
}

double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadius = 6371.0;

  final dLat =
      _degreesToRadians(lat2 - lat1);
  final dLon =
      _degreesToRadians(lon2 - lon1);

  final a = pow(sin(dLat / 2), 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          pow(sin(dLon / 2), 2);

  final c = 2 * atan2(
    sqrt(a),
    sqrt(1 - a),
  );

  return earthRadius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

// ============================================================
// GOOGLE MAPS
// ============================================================

Future<void> openGoogleMaps(
  Place place,
) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/'
    '?api=1&query=${place.lat},${place.lon}',
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

Future<void> openCityInGoogleMaps(
  City city,
) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/'
    '?api=1&query=${city.lat},${city.lon}',
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
