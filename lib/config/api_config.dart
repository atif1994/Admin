/// API Configuration for different environments
/// Change BASE_URL based on where you're running the app
class ApiConfig {
  // ============ IMPORTANT: Choose the right URL for your environment ============
  
  // For Android Emulator (use 10.0.2.2 to access localhost)
  static const String androidEmulator = 'http://10.0.2.2:5000/api';
  
  // For iOS Simulator (can use localhost)
  static const String iosSimulator = 'http://localhost:5000/api';
  
  // For Real Device (use your computer's local IP address)
  // Find your IP: On Mac/Linux run: ifconfig | grep "inet " | grep -v 127.0.0.1
  //               On Windows run: ipconfig
  // Your computer's IP: 192.168.4.170
  static const String realDevice = 'http://192.168.4.170:5000/api';
  
  // ============ SET YOUR BASE URL HERE ============
  // Uncomment the one you need:
  
  // static const String BASE_URL = androidEmulator;  // ← For Android Emulator
  // static const String BASE_URL = iosSimulator;     // ← For iOS Simulator
  static const String BASE_URL = realDevice;          // ← For Real Device (ACTIVE)
  
  // ===============================================
  
  // API Endpoints
  static const String adminSignup = '/admin/signup';
  static const String adminLogin = '/admin/login';
  static const String adminProfile = '/admin/profile';
  static const String vaccinations = '/admin/vaccinations';
  static const String vaccinationStats = '/admin/vaccinations/stats/summary';
  static const String vaccinationSearch = '/admin/vaccinations/search';
}
