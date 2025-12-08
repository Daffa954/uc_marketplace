part of 'shared.dart';

class Const {
  // static String baseUrl = "rajaongkir.komerce.id";
  // static String subUrl = "/api/v1/";
  // // static String apiKey = dotenv.env['API_KEY_1'] ?? "";
  // // static String apiKey = dotenv.env['API_KEY_2'] ?? "";
  // static String apiKey = dotenv.env['API_KEY'] ?? "";
  static String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? "";
  static String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? "";
  static String get restUrl => "$supabaseUrl/rest/v1/";
}
