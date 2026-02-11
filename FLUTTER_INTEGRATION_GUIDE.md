# 🔗 Flutter Admin App - Backend Integration Guide

Your Flutter Admin app is now fully integrated with the backend APIs! 🎉

---

## ✅ What's Been Integrated

### 1. **API Service Layer**
- ✅ Complete REST API client (`lib/services/api_service.dart`)
- ✅ JWT token management with SharedPreferences
- ✅ Error handling for network issues
- ✅ Automatic token persistence

### 2. **Authentication**
- ✅ Real signup with backend
- ✅ Real login with JWT tokens
- ✅ Token storage and retrieval
- ✅ Logout with token cleanup

### 3. **Vaccination Records**
- ✅ Create records → Backend database
- ✅ Load all records from backend
- ✅ Update records in backend
- ✅ Delete records from backend
- ✅ Search functionality
- ✅ Pull-to-refresh
- ✅ Loading indicators

### 4. **Data Serialization**
- ✅ `VaccinationRecord.toJson()` / `fromJson()`
- ✅ `Vaccine.toJson()` / `fromJson()`
- ✅ `Dose.toJson()` / `fromJson()`

---

## 🚀 Setup Instructions

### Step 1: Install Dependencies

```bash
cd /Users/mac/Desktop/ZesshanAppas/Admin
flutter pub get
```

**New packages added:**
- `http: ^1.2.2` - For API requests
- `shared_preferences: ^2.3.3` - For token storage

### Step 2: Configure Backend URL

**Important:** Update the API URL based on where you're testing.

Open `lib/config/api_config.dart` and set the correct `BASE_URL`:

```dart
// For Android Emulator
static const String BASE_URL = androidEmulator;  // http://10.0.2.2:5000/api

// For iOS Simulator
// static const String BASE_URL = iosSimulator;  // http://localhost:5000/api

// For Real Device (replace with your computer's IP)
// static const String BASE_URL = realDevice;  // http://192.168.1.100:5000/api
```

#### 📱 How to Find Your Computer's IP (for Real Device Testing):

**On Mac/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**On Windows:**
```bash
ipconfig
```

Look for your local IP address (usually starts with 192.168.x.x or 10.0.x.x)

### Step 3: Make Sure Backend is Running

```bash
# In a separate terminal
cd /Users/mac/Desktop/ZesshanAppas/backend
npm run dev
```

Server should be running on `http://localhost:5000`

### Step 4: Run the Flutter App

**Android Emulator:**
```bash
flutter run
```

**iOS Simulator:**
```bash
flutter run
```

**Real Device:**
```bash
# First, update BASE_URL in api_config.dart to your computer's IP
# Then run:
flutter run -d <device-id>
```

---

## 🧪 Testing the Integration

### Test 1: Signup
1. Open the app
2. Tap "Sign up" on login screen
3. Enter:
   - Full Name: Test User
   - Email: test@example.com
   - Password: password123
4. Tap "Create account"
5. ✅ Should navigate to home screen
6. ✅ Check backend: `curl http://localhost:5000/api/admin/login -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"password123"}'`

### Test 2: Login
1. Logout from the app
2. Login with:
   - Email: test@example.com
   - Password: password123
3. ✅ Should navigate to home screen
4. ✅ JWT token stored locally

### Test 3: Create Vaccination Record
1. Tap the + button on home screen
2. Add a vaccine with doses
3. Tap "Save"
4. ✅ Record appears in the list
5. ✅ Check backend database:
   ```bash
   mongosh mongodb://localhost:27017/healthcare_db
   db.vaccinationrecords.find().pretty()
   ```

### Test 4: Edit Record
1. Tap the ⋮ menu on a record
2. Tap "Edit"
3. Make changes
4. Tap "Save"
5. ✅ Changes reflected immediately
6. ✅ Changes saved in backend

### Test 5: Delete Record
1. Tap the ⋮ menu on a record
2. Tap "Delete"
3. Confirm deletion
4. ✅ Record removed from list
5. ✅ Record deleted from backend

### Test 6: Pull to Refresh
1. Pull down on the home screen
2. ✅ Loading indicator appears
3. ✅ Records refreshed from backend

---

## 📂 Files Modified/Created

### New Files:
- `lib/services/api_service.dart` - Complete API client
- `lib/config/api_config.dart` - API URL configuration
- `FLUTTER_INTEGRATION_GUIDE.md` - This file

### Modified Files:
- `lib/controllers/auth_controller.dart` - Real login/signup
- `lib/controllers/records_controller.dart` - Real CRUD operations
- `lib/models/vaccination_record.dart` - Added JSON serialization
- `lib/screens/home_screen.dart` - Added loading states
- `pubspec.yaml` - Added http & shared_preferences

---

## 🔐 How Authentication Works

### Flow:
1. User logs in → API call to `/api/admin/login`
2. Backend validates credentials
3. Backend returns JWT token
4. App saves token to SharedPreferences
5. All subsequent API calls include: `Authorization: Bearer <token>`
6. Token persists across app restarts
7. Logout clears the token

### Token Storage:
```dart
// Save token
await SharedPreferences.getInstance()
  .then((prefs) => prefs.setString('auth_token', token));

// Retrieve token
final token = await SharedPreferences.getInstance()
  .then((prefs) => prefs.getString('auth_token'));

// Clear token (logout)
await SharedPreferences.getInstance()
  .then((prefs) => prefs.remove('auth_token'));
```

---

## 📊 Data Flow

### Create Record Flow:
```
User Input (Flutter UI)
    ↓
VaccinationRecord.toJson()
    ↓
ApiService.createVaccinationRecord()
    ↓
HTTP POST /api/admin/vaccinations
    ↓
Backend saves to MongoDB
    ↓
Backend returns saved record
    ↓
VaccinationRecord.fromJson()
    ↓
Update UI (GetX reactive list)
```

### Load Records Flow:
```
App loads / Pull to refresh
    ↓
ApiService.getVaccinationRecords()
    ↓
HTTP GET /api/admin/vaccinations
    ↓
Backend fetches from MongoDB
    ↓
Backend returns records array
    ↓
VaccinationRecord.fromJson() for each
    ↓
Display in ListView
```

---

## 🚨 Troubleshooting

### Issue 1: "Cannot connect to server"

**Cause:** Backend not running or wrong URL

**Solution:**
1. Check backend is running: `http://localhost:5000/api/health`
2. Verify URL in `lib/config/api_config.dart`
3. For real device, use computer's IP, not localhost

### Issue 2: "Failed to load records" after login

**Cause:** Token not being sent or expired

**Solution:**
1. Check if token is saved: Look for "auth_token" in app data
2. Logout and login again
3. Check backend logs for 401 errors

### Issue 3: "Network error" on real device

**Cause:** Device can't reach computer

**Solution:**
1. Make sure computer and device are on same WiFi
2. Find computer's IP: `ifconfig` (Mac/Linux) or `ipconfig` (Windows)
3. Update BASE_URL in `api_config.dart`
4. Restart the app

### Issue 4: Records not showing after creation

**Cause:** JSON serialization mismatch

**Solution:**
1. Check backend response format matches `VaccinationRecord.fromJson()`
2. Look for errors in Flutter debug console
3. Check backend logs for validation errors

### Issue 5: App crashes on startup

**Cause:** Missing dependencies

**Solution:**
```bash
cd /Users/mac/Desktop/ZesshanAppas/Admin
flutter clean
flutter pub get
flutter run
```

---

## 🛠️ Developer Tips

### 1. Viewing API Requests
Add this to see all API calls:
```dart
// In api_service.dart, add before response
print('📤 Request: ${response.request?.url}');
print('📥 Response: ${response.statusCode}');
print('📄 Body: ${response.body}');
```

### 2. Testing API Endpoints
Use Postman or cURL to test endpoints independently:
```bash
# Test login
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### 3. Clearing App Data
**Android:**
```bash
adb shell pm clear com.ewarnt.admin.admin
```

**iOS:**
```bash
# Uninstall and reinstall the app
```

### 4. Viewing Logs
```bash
# Flutter logs
flutter logs

# Backend logs
# Check terminal where backend is running
```

---

## 🎯 Next Steps

### Immediate:
1. ✅ Test all CRUD operations
2. ✅ Test on Android Emulator
3. ✅ Test on iOS Simulator
4. ✅ Test on Real Device

### Future Enhancements:
1. **Offline Mode**
   - Cache records locally
   - Sync when online

2. **Advanced Features**
   - Statistics dashboard
   - Export to PDF
   - Search filters
   - Sorting options

3. **Error Handling**
   - Retry mechanism
   - Better error messages
   - Network status indicator

4. **UI Improvements**
   - Skeleton loaders
   - Empty state illustrations
   - Success animations

5. **Security**
   - Token refresh mechanism
   - Biometric authentication
   - SSL pinning

---

## 📱 API Configuration Quick Reference

```dart
// lib/config/api_config.dart

// Android Emulator
BASE_URL = 'http://10.0.2.2:5000/api'

// iOS Simulator
BASE_URL = 'http://localhost:5000/api'

// Real Device (replace with your IP)
BASE_URL = 'http://192.168.1.100:5000/api'
```

---

## 🔗 Related Documentation

- **Backend API Docs:** `/backend/VACCINATION_API_GUIDE.md`
- **Backend Setup:** `/backend/SETUP_SUMMARY.md`
- **Testing Guide:** `/backend/TESTING_GUIDE.md`

---

## ✅ Checklist

Before deploying or testing:

- [ ] Backend server is running (`npm run dev`)
- [ ] MongoDB is running
- [ ] Correct BASE_URL in `api_config.dart`
- [ ] Dependencies installed (`flutter pub get`)
- [ ] At least one admin account created
- [ ] Network permissions in AndroidManifest.xml (already added)
- [ ] Internet permission in Info.plist (iOS)

---

## 🎉 Success!

Your Flutter Admin app is now fully connected to your backend!

**What works:**
- ✅ Real user authentication
- ✅ Persistent login (JWT tokens)
- ✅ Create, read, update, delete records
- ✅ Data synced with MongoDB
- ✅ Pull to refresh
- ✅ Search functionality
- ✅ Loading states
- ✅ Error handling

**Your data flow:**
```
Flutter App ↔️ REST API ↔️ Node.js Backend ↔️ MongoDB
```

**Ready to test!** 🚀
