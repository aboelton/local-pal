import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final String? image;

  const Category({
    required this.id,
    required this.ar,
    required this.en,
    required this.he,
    required this.icon,
    this.image,
  });

  String get name => tr(ar, en, he);
}

const categories = <Category>[
  Category(
    id: 'restaurant',
    image: 'assests/categories/restaurant.jpg',
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
  id: 'veterinary',
  ar: 'دكتور بيطري',
  en: 'Veterinarians',
  he: 'וטרינרים',
  icon: Icons.pets,
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
        scaffoldBackgroundColor: const Color(0xFF263A27),
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

class HomeContent extends StatefulWidget {
  final ValueChanged<City> onCityChanged;
  final City city;
  const HomeContent({
    super.key,
    required this.city,
    required this.onCityChanged,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Place> _nearbyPlaces = [];
bool _loadingNearby = false;
bool _nearbyLoaded = false;
City? _nearbyCity;

Future<void> _loadNearbyPlaces() async {
  if (_loadingNearby) return;

  setState(() {
    _loadingNearby = true;
  });

  try {
    final position =
        await CurrentLocationService.getCurrentLocation();

    if (position == null) {
      if (!mounted) return;

      setState(() {
        _loadingNearby = false;
        _nearbyLoaded = true;
      });
      return;
    }

    final nearbyCity = City(
      name: 'Current Location',
      displayName: tr(
        'موقعي الحالي',
        'My current location',
        'המיקום הנוכחי שלי',
      ),
      lat: position.latitude,
      lon: position.longitude,
    );
    _nearbyCity = nearbyCity;
    final nearbyCategoryIds = <String>[
      'restaurant',
      'cafe',
      'supermarket',
      'pharmacy',
    ];

    final selectedCategories = categories
        .where(
          (category) =>
              nearbyCategoryIds.contains(category.id),
        )
        .toList();

    final results = await Future.wait(
      selectedCategories.map(
        (category) => PlacesService.getPlaces(
          city: nearbyCity,
          category: category,
        ),
      ),
    );

    final places =
        results.expand((list) => list).toList();

    places.sort((a, b) {
      final distanceA = calculateDistance(
        nearbyCity.lat,
        nearbyCity.lon,
        a.lat,
        a.lon,
      );

      final distanceB = calculateDistance(
        nearbyCity.lat,
        nearbyCity.lon,
        b.lat,
        b.lon,
      );

      return distanceA.compareTo(distanceB);
    });

    if (!mounted) return;

    setState(() {
      _nearbyCity = nearbyCity;
      _nearbyPlaces = places.take(10).toList();
      _loadingNearby = false;
      _nearbyLoaded = true;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _loadingNearby = false;
      _nearbyLoaded = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ==================================================
          // APP BAR
          // ==================================================
          SliverAppBar(
  pinned: true,
  expandedHeight: 120,
  backgroundColor: const Color(0xFF1F302D),
  surfaceTintColor: Colors.transparent,
  flexibleSpace: FlexibleSpaceBar(
    background: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF172522),
            Color(0xFF2B403A),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Local ',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'Pal',
                      style: TextStyle(
                        color: Color(0xFF7ED68B),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),

          // ==================================================
          // MAIN CONTENT
          // ==================================================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // CITY SELECTOR
                CitySelector(
                  city: widget.city,
                  onChanged: widget.onCityChanged,
                ),

const SizedBox(height: 14),

ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Stack(
    children: [
      FutureBuilder<String?>(
  future: getCityImage(widget.city.name),
  builder: (context, snapshot) {
    final imageUrl = snapshot.data;

    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return Container(
        width: double.infinity,
        height: 180,
        alignment: Alignment.center,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        child: const CircularProgressIndicator(),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 180,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
        );
      },
    );
  },
),

      Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.65),
            ],
          ),
        ),
      ),

      Positioned(
        left: 18,
        right: 18,
        bottom: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(
                'اكتشف مدينتك',
                'Discover your city',
                'גלה את העיר שלך',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.city.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 18),

                const SizedBox(height: 18),

                // SEARCH TITLE
Text(
  tr(
    'ماذا تبحث اليوم؟',
    'What are you looking for?',
    'מה אתה מחפש היום?',
  ),
  style: Theme.of(context)
      .textTheme
      .headlineSmall
      ?.copyWith(
        fontWeight: FontWeight.bold,
      ),
),

const SizedBox(height: 12),

                // SEARCH BUTTON
                SearchButton(city: widget.city),

                const SizedBox(height: 12),

                // CURRENT LOCATION
                CurrentLocationButton(
                  onLocationFound: (position) {
                    widget.onCityChanged(
                      City(
                        name: 'Current Location',
                        displayName: tr(
                          'موقعي الحالي',
                          'My current location',
                          'המיקום הנוכחי שלי',
                        ),
                        lat: position.latitude,
                        lon: position.longitude,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

// ==================================================
// NEARBY PLACES
// ==================================================
Row(
  children: [
    Expanded(
      child: Text(
        tr(
          'قريب منك',
          'Nearby',
          'קרוב אליך',
        ),
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    ),
    TextButton.icon(
      onPressed:
          _loadingNearby ? null : _loadNearbyPlaces,
      icon: const Icon(Icons.near_me_outlined),
      label: Text(
        _nearbyLoaded
            ? tr(
                'تحديث',
                'Refresh',
                'רענון',
              )
            : tr(
                'اعرض',
                'Show',
                'הצג',
              ),
      ),
    ),
  ],
),

const SizedBox(height: 12),

if (_loadingNearby)
  const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
  )
else if (_nearbyLoaded && _nearbyPlaces.isEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),
    child: Text(
      tr(
        'لم نجد أماكن قريبة حالياً',
        'No nearby places found',
        'לא נמצאו מקומות קרובים',
      ),
    ),
  )
else if (_nearbyPlaces.isNotEmpty &&
    _nearbyCity != null)
  ..._nearbyPlaces.map(
    (place) => PlaceCard(
      place: place,
      city: _nearbyCity!,
    ),
  ),

const SizedBox(height: 28),

                // ==================================================
                // SERVICES
                // ==================================================
                Text(
                  tr(
                    'الخدمات',
                    'Services',
                    'שירותים',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

               Row(
  children: [
    // ================= CURRENCY =================
    Expanded(
      child: SizedBox(
        height: 155,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CurrencyPage(),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/categories/currency.png',
                  ),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.currency_exchange,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tr(
                        'العملات',
                        'Currency',
                        'מטבע',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr(
                        'تحويل العملات',
                        'Convert currency',
                        'המרת מטבע',
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),

    // ================= ASSISTANT =================
    Expanded(
      child: SizedBox(
        height: 155,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AssistantPage(),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/categories/assistant.png',
                  ),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.68),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tr(
                        'المساعد',
                        'Assistant',
                        'עוזר',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr(
                        'مساعدك الذكي',
                        'Your smart assistant',
                        'העוזר החכם שלך',
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 10),

    // ================= TAXI =================
    Expanded(
      child: SizedBox(
        height: 155,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxiPage(),
                ),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/categories/taxi.png',
                  ),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_taxi_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tr(
                        'تاكسي',
                        'Taxi',
                        'מונית',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr(
                        'اطلب تاكسي الآن',
                        'Book a taxi now',
                        'הזמן מונית עכשיו',
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),

                // ==================================================
                // CATEGORIES TITLE
                // ==================================================
                Text(
                  tr(
                    'التصنيفات',
                    'Categories',
                    'קטגוריות',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),
              ]),
            ),
          ),

          // ==================================================
          // CATEGORIES GRID
          // ==================================================
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              24,
            ),
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
                            city: widget.city,
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
      
          // ==================================================
          // STAYS
          // ==================================================
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(
                      'وين بدك تسكن؟',
                      'Where to stay?',
                      'איפה תרצו להתארח?',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                          onTap: () {
  final hotelCategory =
      categories.firstWhere((c) => c.id == 'hotel');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PlacesPage(
        city: widget.city,
        category: hotelCategory,
      ),
    ),
  );
},

                            child: Container(
  height: 185,
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(
        'assets/categories/hotels.png',
      ),
      fit: BoxFit.cover,
    ),
  ),
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.75),
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF4285F4),
          child: Icon(
            Icons.hotel,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr(
            'فنادق',
            'Hotels',
            'מלונות',
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
),
    ),
  ),
      const SizedBox(width: 12),

Expanded(
  child: Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LocalStaysPage(
        city: widget.city,
      ),
    ),
  );
},
      child: Container(
  height: 185,
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(
        'assets/categories/local_stay.png',
      ),
      fit: BoxFit.cover,
    ),
  ),
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.75),
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF21966B),
          child: Icon(
            Icons.home_work_outlined,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr(
            'سكن محلي',
            'Local Stay',
            'אירוח מקומי',
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
      ),
    ),
  ),
                    ],                    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalStaysPage extends StatefulWidget {
  final City city;

  const LocalStaysPage({
    super.key,
    required this.city,
  });

  @override
  State<LocalStaysPage> createState() => _LocalStaysPageState();
}

class _LocalStaysPageState extends State<LocalStaysPage> {
  List<Place> stays = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStays();
  }

  Future<void> _loadStays() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      const localStayCategory = Category(
        id: 'local_stay',
        ar: 'سكن محلي',
        en: 'Local Stay',
        he: 'אירוח מקומי',
        icon: Icons.home_work_outlined,
      );

      final result = await PlacesService.getPlaces(
        city: widget.city,
        category: localStayCategory,
      );

      if (!mounted) return;

      setState(() {
        stays = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'سكن محلي',
            'Local Stays',
            'אירוח מקומי',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStays,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              tr(
                'اكتشف سكن محلي في ${widget.city.displayName}',
                'Discover local stays in ${widget.city.displayName}',
                'גלו אירוח מקומי ב-${widget.city.displayName}',
              ),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              tr(
                'اكتشف شقق وبيوت ضيافة وأماكن إقامة قريبة.',
                'Discover apartments, guest houses and nearby stays.',
                'גלו דירות, בתי הארחה ומקומות אירוח קרובים.',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr(
                          'إضافة السكن قريبًا',
                          'Listing your place is coming soon',
                          'הוספת מקום אירוח תהיה זמינה בקרוב',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_home_outlined),
                label: Text(
                  tr(
                    'أضف سكنك',
                    'List your place',
                    'הוספת מקום אירוח',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              tr(
                'أماكن متاحة',
                'Available stays',
                'מקומות זמינים',
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          'تعذر تحميل أماكن السكن',
                          'Could not load stays',
                          'לא ניתן לטעון מקומות אירוח',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: _loadStays,
                        child: Text(
                          tr(
                            'حاول مرة ثانية',
                            'Try again',
                            'נסה שוב',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (stays.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.home_work_outlined,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          'ما لقينا أماكن سكن قريبة حاليًا',
                          'No nearby stays found',
                          'לא נמצאו מקומות אירוח קרובים',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...stays.map(
                (place) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: PlaceCard(
                    place: place,
                    city: widget.city,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<String?> getCityImage(String cityName) async {
  try {
    final uri = Uri.https(
      'en.wikipedia.org',
      '/w/api.php',
      {
        'action': 'query',
        'format': 'json',
        'generator': 'search',
        'gsrsearch': '$cityName city',
        'gsrlimit': '1',
        'prop': 'pageimages',
        'piprop': 'thumbnail',
        'pithumbsize': '1200',
        'origin': '*',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    final pages = data['query']?['pages'];

    if (pages == null || pages.isEmpty) {
      return null;
    }

    final firstPage = pages.values.first;

    return firstPage['thumbnail']?['source']?.toString();
  } catch (_) {
    return null;
  }
}


// ============================================================
// CITY SELECTOR
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
    final isCurrentLocation =
        city.name == 'Current Location';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push<City>(
            context,
            MaterialPageRoute(
              builder: (_) => CitySearchPage(currentCity:city),
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
              CircleAvatar(
                child: Icon(
                  isCurrentLocation
                      ? Icons.my_location
                      : Icons.location_on,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        'الموقع',
                        'Location',
                        'מיקום',
                      ),
                      style:
                          Theme.of(context).textTheme.bodySmall,
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
// ==================================================
class SearchButton extends StatelessWidget {
  final City city;

  const SearchButton({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchPage(city: city),
            ),
          );
        },
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF40514B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Colors.white70,
                size: 25,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  tr(
                    'ابحث عن مكان...',
                    'Search for a place...',
                    'חפש מקום...',
                  ),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 20,
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

  String? get categoryImage {
    switch (category.id) {
      case 'restaurant':
        return 'restaurant.png';
      case 'cafe':
        return 'cafe.png';
      case 'fast_food':
        return 'fast_food.png';
      case 'bakery':
        return 'bakery.png';
      case 'supermarket':
        return 'supermarket.png';
      case 'shop':
        return 'shop.png';
      case 'clothes':
        return 'Clothes.png';
      case 'electronics':
        return 'electronic.png';
      case 'hotel':
        return 'hotel.png';
      case 'park':
        return 'park.png';
      case 'cinema':
        return 'cinema.png';
      case 'gym':
        return 'gym.png';
      case 'hospital':
        return 'hospital.png';
      case 'clinic':
        return 'Clinic.png';
      case 'pharmacy':
        return 'pharmacy.png';
      case 'dentist':
        return 'Dental Clinic.png';
      case 'doctor':
        return 'doctor.png';
      case 'veterinary':
        return 'veterinary.png';
      case 'fuel':
        return 'fuel.png';
      case 'barber':
        return 'barber.png';
      case 'bank':
        return 'bank.png';
      case 'atm':
        return 'atm.png';
      case 'mall':
        return 'mall.png';
      case 'mosque':
        return 'mosque.png';
      case 'church':
        return 'church.png';
      case 'school':
        return 'school.png';
      case 'university':
        return 'university.png';
      case 'parking':
        return 'parking.png';
      default:
        return null;
    }
  }

  Color get categoryColor {
    switch (category.id) {
      case 'restaurant':
        return Colors.red;
      case 'cafe':
        return Colors.brown;
      case 'fast_food':
        return Colors.orange;
      case 'supermarket':
        return Colors.green;
      case 'pharmacy':
        return Colors.teal;
      case 'fuel':
        return Colors.red;
      case 'hotel':
        return Colors.blue;
      default:
        return const Color(0xFF66765E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = categoryImage;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // CATEGORY BACKGROUND IMAGE
            if (image != null)
              Image.asset(
                'assets/categories/$image',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF66765E),
                  );
                },
              )
            else
              Container(
                color: const Color(0xFF66765E),
              ),

            // DARK GRADIENT
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),

            // CATEGORY ICON + NAME
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                        ),
                      ],
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('اختيار المدينة', 'Choose city', 'בחר עיר'),
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

  static Future<List<Place>> getPlaces({
    required City city,
    required Category category,
  }) async {
    

    final geoCategory =
        _geoCategory(category.id);

    final radius =
        _radiusForCategory(category.id);

    final uri = Uri.https(
      'local-pal-api.tonytabri12.workers.dev',
      '/places',
      {
        'categories': geoCategory,

        'filter':
            'circle:${city.lon},${city.lat},$radius',

        // بخلي الأقرب يطلع أول
        'bias':
            'proximity:${city.lon},${city.lat}',

        'limit': '100',

        'lang': _geoLanguage(),
      },
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Geoapify HTTP ${response.statusCode}: '
          '${response.body}',
        );
      }

      final data =
          jsonDecode(response.body);

      if (data is! Map ||
          data['features'] is! List) {
        throw Exception(
          'Invalid Geoapify response',
        );
      }

      final result = <Place>[];

      final features =
          data['features'] as List;

      for (final feature in features) {
        if (feature is! Map) {
          continue;
        }

        final rawProperties =
            feature['properties'];

        if (rawProperties is! Map) {
          continue;
        }

        final properties =
            Map<String, dynamic>.from(
          rawProperties,
        );

        final geometryRaw =
            feature['geometry'];

        if (geometryRaw is! Map) {
          continue;
        }

        final geometry =
            Map<String, dynamic>.from(
          geometryRaw,
        );

        final coordinates =
            geometry['coordinates'];

        if (coordinates is! List ||
            coordinates.length < 2) {
          continue;
        }

        final lon = double.tryParse(
          '${coordinates[0]}',
        );

        final lat = double.tryParse(
          '${coordinates[1]}',
        );

        if (lat == null || lon == null) {
          continue;
        }

        final name = _placeName(
          properties,
          fallback: category.name,
        );

        final datasource =
            properties['datasource'];

        Map<String, dynamic> raw =
            <String, dynamic>{};

        if (datasource is Map &&
            datasource['raw'] is Map) {
          raw =
              Map<String, dynamic>.from(
            datasource['raw'],
          );
        }

        final contactRaw =
            properties['contact'];

        Map<String, dynamic> contact =
            <String, dynamic>{};

        if (contactRaw is Map) {
          contact =
              Map<String, dynamic>.from(
            contactRaw,
          );
        }

        final phone = _firstNonEmpty(
          [
            properties['phone'],
            contact['phone'],
            raw['phone'],
            raw['contact:phone'],
          ],
        );

        final website = _firstNonEmpty(
          [
            properties['website'],
            contact['website'],
            raw['website'],
            raw['contact:website'],
          ],
        );

        final hours = _firstNonEmpty(
          [
            properties['opening_hours'],
            raw['opening_hours'],
          ],
        );

        final address = _firstNonEmpty(
          [
            properties['formatted'],
            properties['address_line2'],
            properties['address_line1'],
          ],
        );

        final id = _firstNonEmpty(
          [
            properties['place_id'],
            raw['osm_id'],
          ],
        );

        result.add(
          Place(
            id: id.isNotEmpty
                ? 'geo_$id'
                : 'geo_${category.id}_${lat}_$lon',

            name: name,

            category: category.id,

            lat: lat,

            lon: lon,

            address: address,

            phone: phone,

            website: website,

            hours: hours,

            // نخليه فاضي عشان PlaceImage
            // يجيب Mapillary زي قبل
            imageUrl: '',

            rating: double.tryParse(
                  '${properties['rating'] ?? 0}',
                ) ??
                0,

            ratingCount: int.tryParse(
                  '${properties['rating_count'] ?? 0}',
                ) ??
                0,
          ),
        );
      }

      // زيادة تأكيد إن الأقرب يطلع أول
      result.sort(
        (a, b) {
          final da =
              calculateDistance(
            city.lat,
            city.lon,
            a.lat,
            a.lon,
          );

          final db =
              calculateDistance(
            city.lat,
            city.lon,
            b.lat,
            b.lon,
          );

          return da.compareTo(db);
        },
      );

      return result;
    } catch (e) {
      throw Exception(
        '${tr(
          'تعذر تحميل الأماكن',
          'Could not load places',
          'לא ניתן לטעון מקומות',
        )}: $e',
      );
    }
  }

  // =========================================================
  // GEOAPIFY CATEGORY
  // =========================================================
  static String _geoCategory(
    String id,
  ) {
    switch (id) {
      case 'restaurant':
        return 'catering.restaurant';

      case 'cafe':
        return 'catering.cafe';

      case 'fast_food':
        return 'catering.fast_food';

      case 'bakery':
        return 'commercial.food_and_drink.bakery';

      case 'supermarket':
        return 'commercial.supermarket';

      case 'shop':
        return 'commercial';

      case 'clothes':
        return 'commercial.clothing';

      case 'electronics':
        // مكتوبة هيك رسميًا عند Geoapify
        return 'commercial.elektronics';

      case 'hotel':
        return 'accommodation.hotel';

      case 'local_stay':
       return 'accommodation.apartment,accommodation.guest_house,accommodation.hostel';

      case 'park':
        return 'leisure.park';

      case 'cinema':
        return 'entertainment.cinema';

      case 'gym':
        return 'sport.fitness.gym';

      case 'hospital':
        return 'healthcare.hospital';

      case 'clinic':
        return 'healthcare.clinic_or_praxis';

      case 'pharmacy':
        return 'healthcare.pharmacy';

      case 'dentist':
        return 'healthcare.dentist';

      case 'doctor':
        return 'healthcare.clinic_or_praxis.general';

         case'veterinary':
           return 'pet.veterinary';

      case 'fuel':
        return 'service.vehicle.fuel';

      case 'barber':
        return 'service.beauty.hairdresser';

      case 'bank':
        return 'service.financial.bank';

      case 'atm':
        return 'service.financial.atm';

      case 'mall':
        return 'commercial.shopping_mall';

      case 'mosque':
        return 'religion.place_of_worship.islam';

      case 'church':
        return 'religion.place_of_worship.christianity';

      case 'school':
        return 'education.school';

      case 'university':
        return 'education.university';

      case 'parking':
        return 'parking';

      default:
        return 'commercial';
    }
  }

  // =========================================================
  // RADIUS
  // =========================================================
  static int _radiusForCategory(
    String id,
  ) {
    if ([
      'restaurant',
      'cafe',
      'fast_food',
      'bakery',
      'supermarket',
      'shop',
      'clothes',
      'electronics',
      'pharmacy',
      'atm',
      'barber',
    ].contains(id)) {
      return 1500;
    }

    if ([
      'fuel',
      'hospital',
      'hotel',
      'local_stay',
      'mall',
      'university',
    ].contains(id)) {
      return 5000;
    }

    return 3000;
  }

  // =========================================================
  // LANGUAGE
  // =========================================================
  static String _geoLanguage() {
    if (appLanguage == 'he') {
      return 'he';
    }

    if (appLanguage == 'en') {
      return 'en';
    }

    return 'ar';
  }

  // =========================================================
  // PLACE NAME
  // =========================================================
  static String _placeName(
    Map<String, dynamic> properties, {
    required String fallback,
  }) {
    final international =
        properties['name_international'];

    if (international is Map) {
      final translated =
          '${international[appLanguage] ?? ''}'
              .trim();

      if (translated.isNotEmpty) {
        return translated;
      }
    }

    final name =
        '${properties['name'] ?? ''}'
            .trim();

    if (name.isNotEmpty) {
      return name;
    }

    final addressName =
        '${properties['address_line1'] ?? ''}'
            .trim();

    if (addressName.isNotEmpty) {
      return addressName;
    }

    return fallback;
  }

  // =========================================================
  // FIRST NON EMPTY VALUE
  // =========================================================
  static String _firstNonEmpty(
    List<dynamic> values,
  ) {
    for (final value in values) {
      final text =
          '${value ?? ''}'.trim();

      if (text.isNotEmpty &&
          text != 'null') {
        return text;
      }
    }

    return '';
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
  String formatDistance(double distance) {
    if (distance < 1) {
      final meters = (distance * 1000).round();
      return '$meters ${tr('م', 'm', 'מ׳')}';
    }

    return '${distance.toStringAsFixed(1)} ${tr('كم', 'km', 'ק״מ')}';
  }

  String openingStatus(String hours) {
    if (hours.trim().isEmpty) {
      return '';
    }

    if (hours.trim() == '24/7') {
      return tr(
        'مفتوح الآن',
        'Open now',
        'פתוח עכשיו',
      );
    }

    final now = DateTime.now();

    final dayNames = <int, String>{
      DateTime.monday: 'Mo',
      DateTime.tuesday: 'Tu',
      DateTime.wednesday: 'We',
      DateTime.thursday: 'Th',
      DateTime.friday: 'Fr',
      DateTime.saturday: 'Sa',
      DateTime.sunday: 'Su',
    };

    final today = dayNames[now.weekday];

    if (today == null) {
      return '';
    }

    try {
      final parts = hours.split(';');

      for (final part in parts) {
        final trimmed = part.trim();

        if (trimmed.isEmpty) {
          continue;
        }

        final firstSpace = trimmed.indexOf(' ');

        if (firstSpace == -1) {
          continue;
        }

        final days = trimmed
            .substring(0, firstSpace)
            .trim();

        final times = trimmed
            .substring(firstSpace + 1)
            .trim();

        if (!_dayMatches(days, today)) {
          continue;
        }

        if (times.toLowerCase() == 'off') {
          return tr(
            'مسكر الآن',
            'Closed now',
            'סגור עכשיו',
          );
        }

        final ranges = times.split(',');

        for (final range in ranges) {
          if (_timeRangeIsOpen(range.trim(), now)) {
            return tr(
              'مفتوح الآن',
              'Open now',
              'פתוח עכשיו',
            );
          }
        }

        return tr(
          'مسكر الآن',
          'Closed now',
          'סגור עכשיו',
        );
      }
    } catch (_) {
      return '';
    }

    return '';
  }

  bool _dayMatches(
    String days,
    String today,
  ) {
    if (days == today) {
      return true;
    }

    if (!days.contains('-')) {
      return false;
    }

    final parts = days.split('-');

    if (parts.length != 2) {
      return false;
    }

    const order = <String>[
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa',
      'Su',
    ];

    final start = order.indexOf(parts[0].trim());
    final end = order.indexOf(parts[1].trim());
    final current = order.indexOf(today);

    if (start == -1 || end == -1 || current == -1) {
      return false;
    }

    if (start <= end) {
      return current >= start && current <= end;
    }

    return current >= start || current <= end;
  }

  bool _timeRangeIsOpen(
    String range,
    DateTime now,
  ) {
    final parts = range.split('-');

    if (parts.length != 2) {
      return false;
    }

    final start = _minutesFromTime(parts[0]);
    final end = _minutesFromTime(parts[1]);

    if (start == null || end == null) {
      return false;
    }

    final current = now.hour * 60 + now.minute;

    if (end >= start) {
      return current >= start && current < end;
    }

    return current >= start || current < end;
  }

  int? _minutesFromTime(String time) {
    final cleaned = time.trim();
    final parts = cleaned.split(':');

    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 24 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    if (hour == 24 && minute != 0) {
      return null;
    }

    return hour * 60 + minute;
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance(
      widget.city.lat,
      widget.city.lon,
      widget.place.lat,
      widget.place.lon,
    );

    final category = getCategory(
      widget.place.category,
    );

    final status = openingStatus(
      widget.place.hours,
    );

    final isOpen = status ==
        tr(
          'مفتوح الآن',
          'Open now',
          'פתוח עכשיו',
        );

      return Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 0,
  color: const Color(0xFF8f9d82),
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: BorderSide(
      color: Colors.white.withValues(alpha: 0.22),
      width: 1,
    ),
  ),

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
            if (mounted) {
              setState(() {});
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
             ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: PlaceImage(
    place: widget.place,
    size: 90,
  ),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            category.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    if (status.isNotEmpty) ...[
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (
                            isOpen
                                ? Colors.green
                                : Colors.red
                          ).withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 15,
                        ),
                        const SizedBox(width: 3),

                        Text(
                          formatDistance(distance),
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
                    if (widget.place.isFavorite) {
                      favoriteIds.remove(
                        widget.place.id,
                      );
                    } else {
                      favoriteIds.add(
                        widget.place.id,
                      );
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

class PlaceImage extends StatefulWidget {
  final Place place;
  final double size;

  const PlaceImage({
    super.key,
    required this.place,
    this.size = 100,
  });

  @override
  State<PlaceImage> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<PlaceImage> {
  String imageUrl = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();

    if (widget.place.imageUrl.isNotEmpty) {
      imageUrl = widget.place.imageUrl;
      loading = false;
    } else {
      loadImage();
    }
  }

  Future<void> loadImage() async {
    try {
      final uri = Uri.parse(
        'https://local-pal-api.tonytabri12.workers.dev/place-image'
        '?lat=${widget.place.lat}'
        '&lon=${widget.place.lon}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final url = data['imageUrl']?.toString() ?? '';

        if (mounted) {
          setState(() {
            imageUrl = url;
            loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: widget.size,
          height: widget.size,
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
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        getCategoryIcon(widget.place.category),
        size: widget.size * 0.4,
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

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
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

    final phone = widget.place.phone.replaceAll(' ', '');

    await launchUrl(
      Uri.parse('tel:$phone'),
    );
  }

  Future<void> openWebsite() async {
    if (widget.place.website.isEmpty) {
      return;
    }

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
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String formatDistance(double distance) {
    if (distance < 1) {
      final meters = (distance * 1000).round();

      return '$meters ${tr('م', 'm', 'מ׳')}';
    }

    return '${distance.toStringAsFixed(1)} '
        '${tr('كم', 'km', 'ק״מ')}';
  }

  @override
  Widget build(BuildContext context) {
    final category = getCategory(
      widget.place.category,
    );

    final distance = calculateDistance(
      widget.city.lat,
      widget.city.lon,
      widget.place.lat,
      widget.place.lon,
    );

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
            tooltip: tr(
              'المفضلة',
              'Favorite',
              'מועדפים',
            ),
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
                if (widget.place.isFavorite) {
                  favoriteIds.remove(
                    widget.place.id,
                  );
                } else {
                  favoriteIds.add(
                    widget.place.id,
                  );
                }
              });
            },
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),
            children: [
              // =========================
              // HERO IMAGE
              // =========================
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: PlaceImage(
                      place: widget.place,
                      size: 280,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // NAME
              // =========================
              Text(
                widget.place.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 12),

              // =========================
              // QUICK INFO
              // =========================
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: category.icon,
                    text: category.name,
                  ),

                  _InfoChip(
                    icon: Icons.near_me_outlined,
                    text: formatDistance(
                      distance,
                    ),
                  ),

                  if (widget.place.rating > 0)
                    _InfoChip(
                      icon: Icons.star_rounded,
                      text: widget.place.rating
                          .toStringAsFixed(1),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // =========================
              // DETAILS CARD
              // =========================
              if (widget.place.address.isNotEmpty ||
                  widget.place.phone.isNotEmpty ||
                  widget.place.hours.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.place.address.isNotEmpty)
                        _ModernDetailRow(
                          icon: Icons.location_on_outlined,
                          title: tr(
                            'العنوان',
                            'Address',
                            'כתובת',
                          ),
                          value: widget.place.address,
                        ),

                      if (widget.place.address.isNotEmpty &&
                          (widget.place.phone.isNotEmpty ||
                              widget.place.hours.isNotEmpty))
                        const Divider(height: 28),

                      if (widget.place.phone.isNotEmpty)
                        _ModernDetailRow(
                          icon: Icons.phone_outlined,
                          title: tr(
                            'الهاتف',
                            'Phone',
                            'טלפון',
                          ),
                          value: widget.place.phone,
                        ),

                      if (widget.place.phone.isNotEmpty &&
                          widget.place.hours.isNotEmpty)
                        const Divider(height: 28),

                      if (widget.place.hours.isNotEmpty)
                        _ModernDetailRow(
                          icon: Icons.schedule_rounded,
                          title: tr(
                            'ساعات العمل',
                            'Opening hours',
                            'שעות פתיחה',
                          ),
                          value: widget.place.hours,
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 22),

              // =========================
              // MAIN MAP BUTTON
              // =========================
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    openGoogleMaps(
                      widget.place,
                    );
                  },
                  icon: const Icon(
                    Icons.directions_rounded,
                  ),
                  label: Text(
                    tr(
                      'الاتجاهات',
                      'Directions',
                      'ניווט',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =========================
              // CALL + WEBSITE
              // =========================
              if (widget.place.phone.isNotEmpty ||
                  widget.place.website.isNotEmpty)
                Row(
                  children: [
                    if (widget.place.phone.isNotEmpty)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: callPlace,
                            icon: const Icon(
                              Icons.phone_rounded,
                            ),
                            label: Text(
                              tr(
                                'اتصال',
                                'Call',
                                'התקשר',
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (widget.place.phone.isNotEmpty &&
                        widget.place.website.isNotEmpty)
                      const SizedBox(width: 10),

                    if (widget.place.website.isNotEmpty)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: openWebsite,
                            icon: const Icon(
                              Icons.language_rounded,
                            ),
                            label: Text(
                              tr(
                                'الموقع',
                                'Website',
                                'אתר',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ModernDetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 21,
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer,
          ),
        ),

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
                    .labelMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
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
          tr('الخريطة', 'Map', 'מפה'),
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

class OSMMapView extends StatefulWidget {
  final City city;
  final List<Place> places;

  const OSMMapView({
    super.key,
    required this.city,
    required this.places,
  });

  @override
  State<OSMMapView> createState() => _OSMMapViewState();
}

class _OSMMapViewState extends State<OSMMapView> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation({
    bool moveMap = false,
  }) async {
    if (_loadingLocation) {
      return;
    }

    setState(() {
      _loadingLocation = true;
    });

    final position =
        await CurrentLocationService.getCurrentLocation();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentPosition = position;
      _loadingLocation = false;
    });

    if (moveMap && position != null) {
      _mapController.move(
        LatLng(
          position.latitude,
          position.longitude,
        ),
        16,
      );
    }
  }

  void _goToMyLocation() {
    final position = _currentPosition;

    if (position != null) {
      _mapController.move(
        LatLng(
          position.latitude,
          position.longitude,
        ),
        16,
      );
      return;
    }

    _loadCurrentLocation(
      moveMap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              widget.city.lat,
              widget.city.lon,
            ),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.localpal.app',
            ),

            MarkerLayer(
              markers: [
                ...widget.places.map(
                  (place) => Marker(
                    point: LatLng(
                      place.lat,
                      place.lon,
                    ),
                    width: 46,
                    height: 46,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (sheetContext) {
                            final category =
                                getCategory(
                              place.category,
                            );

                            return SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  20,
                                  4,
                                  20,
                                  20,
                                ),
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration:
                                              BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            category.icon,
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                place.name,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                category.name,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (place
                                        .address
                                        .isNotEmpty) ...[
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .location_on_outlined,
                                            size: 19,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Expanded(
                                            child: Text(
                                              place.address,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(
                                      height: 18,
                                    ),

                                    SizedBox(
                                      width:
                                          double.infinity,
                                      height: 50,
                                      child:
                                          FilledButton.icon(
                                        onPressed: () {
                                          Navigator.pop(
                                            sheetContext,
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PlaceDetailsPage(
                                                place: place,
                                                city:
                                                    widget.city,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .arrow_forward_rounded,
                                        ),
                                        label: Text(
                                          tr(
                                            'عرض المكان',
                                            'View place',
                                            'הצג מקום',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              offset: Offset(0, 2),
                              color: Color(
                                0x33000000,
                              ),
                            ),
                          ],
                        ),
                        child: Icon(
                          getCategory(
                            place.category,
                          ).icon,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                ),

                if (_currentPosition != null)
                  Marker(
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    width: 34,
                    height: 34,
                    child: Container(
                      padding:
                          const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Color(
                              0x44000000,
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration:
                            const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            RichAttributionWidget(
              attributions: const [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                ),
              ],
            ),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 28,
          child: FloatingActionButton.small(
            heroTag: 'my_location_map',
            onPressed: _loadingLocation
                ? null
                : _goToMyLocation,
            tooltip: tr(
              'موقعي',
              'My location',
              'המיקום שלי',
            ),
            child: _loadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.my_location_rounded,
                  ),
          ),
        ),
      ],
    );
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
              name:
                  '${item['display_name'] ?? query}',
              category: 'shop',
              lat: lat,
              lon: lon,
              address:
                  '${item['display_name'] ?? ''}',
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
          tr('البحث', 'Search', 'חיפוש'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                textInputAction:
                    TextInputAction.search,
                onSubmitted: (_) => search(),
                decoration: InputDecoration(
                  hintText: tr(
                    'ابحث عن مكان...',
                    'Search for a place...',
                    'חפש מקום...',
                  ),
                  prefixIcon:
                      const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    onPressed: search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
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
                      padding:
                          const EdgeInsets.all(12),
                      itemCount: results.length,
                      itemBuilder:
                          (context, index) {
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
// CURRENT LOCATION
// ============================================================

class CurrentLocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

// ============================================================
// CURRENT LOCATION BUTTON
// ============================================================

class CurrentLocationButton extends StatefulWidget {
  final ValueChanged<Position> onLocationFound;

  const CurrentLocationButton({
    super.key,
    required this.onLocationFound,
  });

  @override
  State<CurrentLocationButton> createState() =>
      _CurrentLocationButtonState();
}

class _CurrentLocationButtonState
    extends State<CurrentLocationButton> {
  bool loading = false;

  Future<void> getLocation() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    final position =
        await CurrentLocationService.getCurrentLocation();

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'تعذر الحصول على موقعك. تأكد من تشغيل الموقع والسماح للتطبيق باستخدامه.',
              'Could not get your location. Make sure location is enabled and permission is allowed.',
              'לא ניתן לקבל את המיקום שלך. ודא שהמיקום מופעל ואושר.',
            ),
          ),
        ),
      );
      return;
    }

    widget.onLocationFound(position);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'تم تحديد موقعك الحالي 📍',
            'Your current location was found 📍',
            'המיקום הנוכחי שלך נמצא 📍',
          ),
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: FilledButton(
      onPressed: loading ? null : getLocation,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4F7A58),
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            const Color(0xFF4F7A58).withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            const Icon(
              Icons.my_location_rounded,
              size: 22,
            ),

          const SizedBox(width: 10),

          Text(
            loading
                ? tr(
                    'جاري تحديد الموقع...',
                    'Finding location...',
                    'מאתר מיקום...',
                  )
                : tr(
                    'استخدم موقعي الحالي',
                    'Use my current location',
                    'השתמש במיקום הנוכחי שלי',
                  ),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
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

  final c = 2 *
      atan2(
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
// ============================================================
// CURRENCY PAGE
// ============================================================

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController amountController =
      TextEditingController(text: '1');

  final List<String> currencies = [
    'ILS',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'AED',
  ];

  String fromCurrency = 'ILS';
  String toCurrency = 'USD';

  double? rate;
  String? rateDate;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadRate();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadRate() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (fromCurrency == toCurrency) {
        setState(() {
          rate = 1;
          rateDate = DateTime.now().toString().substring(0, 10);
          loading = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/'
        '${fromCurrency.toLowerCase()}/'
        '${toCurrency.toLowerCase()}?providers=ecb',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load exchange rate');
      }

      final data = jsonDecode(response.body);

      setState(() {
        rate = (data['rate'] as num).toDouble();
        rateDate = data['date']?.toString();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = tr(
          'تعذر تحميل سعر الصرف. تأكد من الإنترنت وحاول مرة أخرى.',
          'Could not load the exchange rate. Check your internet and try again.',
          'לא ניתן לטעון את שער החליפין. בדוק את האינטרנט ונסה שוב.',
        );
      });
    }
  }

  double get convertedAmount {
    final amount = double.tryParse(
          amountController.text.replaceAll(',', '.'),
        ) ??
        0;

    return amount * (rate ?? 0);
  }

  void swapCurrencies() {
    setState(() {
      final oldFrom = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = oldFrom;
    });

    loadRate();
  }

  String currencyName(String code) {
    switch (code) {
      case 'ILS':
        return tr('شيكل إسرائيلي', 'Israeli Shekel', 'שקל ישראלי');
      case 'USD':
        return tr('دولار أمريكي', 'US Dollar', 'דולר אמריקאי');
      case 'EUR':
        return tr('يورو', 'Euro', 'אירו');
      case 'GBP':
        return tr('جنيه إسترليني', 'British Pound', 'לירה שטרלינג');
      case 'JPY':
        return tr('ين ياباني', 'Japanese Yen', 'ין יפני');
      case 'CHF':
        return tr('فرنك سويسري', 'Swiss Franc', 'פרנק שווייצרי');
      case 'CAD':
        return tr('دولار كندي', 'Canadian Dollar', 'דולר קנדי');
      case 'AUD':
        return tr('دولار أسترالي', 'Australian Dollar', 'דולר אוסטרלי');
      case 'CNY':
        return tr('يوان صيني', 'Chinese Yuan', 'יואן סיני');
      case 'AED':
        return tr('درهم إماراتي', 'UAE Dirham', 'דירהם אמירתי');
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = convertedAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'تحويل العملات',
            'Currency Converter',
            'ממיר מטבעות',
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : loadRate,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRate,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      tr(
                        'تحويل العملات',
                        'Currency Converter',
                        'ממיר מטבעות',
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: tr(
                          'المبلغ',
                          'Amount',
                          'סכום',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: fromCurrency,
                      decoration: InputDecoration(
                        labelText: tr(
                          'من',
                          'From',
                          'מ',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(
                            '$currency — ${currencyName(currency)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          fromCurrency = value;
                        });

                        loadRate();
                      },
                    ),

                    const SizedBox(height: 12),

                    IconButton(
                      onPressed: loading
                          ? null
                          : swapCurrencies,
                      icon: const Icon(
                        Icons.swap_vert,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: toCurrency,
                      decoration: InputDecoration(
                        labelText: tr(
                          'إلى',
                          'To',
                          'אל',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(
                            '$currency — ${currencyName(currency)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          toCurrency = value;
                        });

                        loadRate();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: loadRate,
                        icon: const Icon(Icons.refresh),
                        label: Text(
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
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${amountController.text} $fromCurrency',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),

                      const SizedBox(height: 10),

                      const Icon(
                        Icons.arrow_downward,
                        size: 28,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '${result.toStringAsFixed(2)} $toCurrency',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '1 $fromCurrency = '
                        '${rate!.toStringAsFixed(6)} $toCurrency',
                        textAlign: TextAlign.center,
                      ),

                      if (rateDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          tr(
                            'تاريخ السعر: $rateDate',
                            'Rate date: $rateDate',
                            'תאריך השער: $rateDate',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              tr(
                'الأسعار مرجعية وليست أسعار بيع وشراء للبنوك أو محلات الصرافة.',
                'Reference rates are not bank or exchange-office buy/sell rates.',
                'השערים הם שערי ייחוס ולא שערי קנייה/מכירה של בנקים או חלפנים.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// TAXI PAGE
// ============================================================

class TaxiPage extends StatelessWidget {
  const TaxiPage({super.key});

  Future<void> openGett() async {
    final uri = Uri.parse('https://www.gett.com/il/');

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'تاكسي',
            'Taxi',
            'מונית',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_taxi,
                    size: 70,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    tr(
                      'احجز تاكسي',
                      'Book a Taxi',
                      'הזמן מונית',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    tr(
                      'اطلب تاكسي بسهولة من خلال Gett.',
                      'Request a taxi easily through Gett.',
                      'הזמן מונית בקלות דרך Gett.',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: openGett,
                      icon: const Icon(
                        Icons.local_taxi,
                      ),
                      label: Text(
                        tr(
                          'فتح Gett',
                          'Open Gett',
                          'פתח Gett',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.location_on,
              ),
              title: Text(
                tr(
                  'استخدم موقعك',
                  'Use your location',
                  'השתמש במיקום שלך',
                ),
              ),
              subtitle: Text(
                tr(
                  'يمكنك تحديد موقعك داخل Gett عند طلب الرحلة.',
                  'You can set your pickup location inside Gett.',
                  'ניתן לבחור את מיקום האיסוף בתוך Gett.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
// ============================================================
// ASSISTANT PAGE
// ============================================================
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  bool _loading = false;

  Future<void> sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _loading) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });
      _loading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('/.netlify/functions/ai-chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': data['reply'] ?? 'No response.',
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': data['error'] ?? 'حدث خطأ أثناء الاتصال بالمساعد.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'حدث خطأ أثناء الاتصال بالمساعد.',
        });
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(
            'المساعد',
            'Assistant',
            'עוזר',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      tr(
                        'اكتب سؤالك للمساعد 🤖',
                        'Ask the assistant a question 🤖',
                        'שאל את העוזר שאלה 🤖',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(
                            maxWidth: 320,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: tr(
                          'اكتب سؤالك...',
                          'Type your question...',
                          'כתוב את השאלה שלך...',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loading ? null : sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}  
