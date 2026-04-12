import 'package:flutter_dotenv/flutter_dotenv.dart';

String get newsAPIBaseURL => dotenv.env['NEWS_API_BASE_URL']!;
String get newsAPIKey => dotenv.env['NEWS_API_KEY']!;
String get countryQuery => dotenv.env['COUNTRY_QUERY']!;
String get categoryQuery => dotenv.env['CATEGORY_QUERY']!;
String get kDefaultImage => dotenv.env['DEFAULT_IMAGE']!;
const String kDefaultAuthorName = 'Anonymous';

bool get isTestingEnv => dotenv.env['USE_EMULATOR'] == 'true';
String get emulatorHost => dotenv.env['EMULATOR_HOST'] ?? '10.0.2.2';
