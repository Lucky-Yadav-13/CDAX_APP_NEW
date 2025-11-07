# Spring Boot Backend Integration for CDAX App

This document explains how to configure and use the Spring Boot backend integration for courses, modules, and videos.

## 🎯 Overview

The app now supports both **Spring Boot backend integration** and **mock data fallback**:
- If backend is available → Uses `RemoteCourseRepository` with automatic fallback to mock
- If backend is unavailable → Uses `MockCourseRepository`
- Automatic detection and extensive logging for debugging

## 🔧 Configuration

### 1. Backend URL Setup

Edit `lib/config/backend_config.dart`:

```dart
class BackendConfig {
  // TODO: Replace with your actual Spring Boot backend URL
  static const String baseUrl = 'http://your-domain.com'; // Update this!
  
  // Feature flags
  static const bool useRemoteRepository = true; // Set to true when backend is ready
}
```

### 2. Expected API Endpoints

Your Spring Boot backend should implement these endpoints:

```
GET    /api/courses              - Get all courses (with search & pagination)
GET    /api/courses/{courseId}   - Get course details with modules and videos
POST   /api/courses/{courseId}/enroll    - Enroll in course
DELETE /api/courses/{courseId}/unenroll  - Unenroll from course
POST   /api/courses/{courseId}/purchase  - Purchase course
```

### 3. Expected JSON Structure

#### Course List Response (`GET /api/courses`):
```json
{
  "data": [
    {
      "id": "course1",
      "title": "Flutter Development",
      "description": "Comprehensive Flutter course",
      "thumbnailUrl": "https://example.com/thumb.jpg",
      "progressPercent": 0.25,
      "isSubscribed": true,
      "isEnrolled": false,
      "instructor": "John Doe",
      "rating": 4.5,
      "studentsCount": 1250,
      "category": "Programming",
      "modules": [
        {
          "id": "module1",
          "title": "Introduction to Flutter",
          "description": "Learn Flutter basics",
          "durationSec": 3600,
          "isLocked": false,
          "orderIndex": 0,
          "videos": [
            {
              "id": "video1",
              "title": "What is Flutter?",
              "description": "Introduction video",
              "youtubeUrl": "https://youtu.be/VIDEO_ID_1",
              "durationSec": 600,
              "orderIndex": 0,
              "thumbnailUrl": "https://example.com/video-thumb.jpg",
              "isLocked": false,
              "isCompleted": false
            },
            {
              "id": "video2",
              "title": "Setting up Flutter",
              "description": "Installation guide",
              "youtubeUrl": "https://youtu.be/VIDEO_ID_2",
              "durationSec": 900,
              "orderIndex": 1,
              "isLocked": false,
              "isCompleted": false
            }
          ]
        }
      ]
    }
  ]
}
```

#### Course Details Response (`GET /api/courses/{courseId}`):
Same structure as individual course in the list above.

## 🚀 How It Works

### Automatic Repository Selection
The `CourseRepositoryFactory` automatically chooses the appropriate repository:

```dart
// Uses backend if configured and available, otherwise mock
final repo = CourseProviders.getCourseRepository();
```

### Fallback Mechanism
`RemoteCourseRepository` automatically falls back to mock data if:
- Backend is unreachable
- API returns error
- Network timeout
- Invalid JSON response

### Extensive Logging
Every operation logs detailed information:

```
🏭 CourseRepositoryFactory: Creating repository instance...
   ├─ Backend is configured and enabled
   ├─ Base URL: http://localhost:8080
   └─ Creating RemoteCourseRepository with fallback to mock

📡 Fetching courses from backend...
   ├─ Search: flutter
   ├─ Page: 1
   └─ URL: http://localhost:8080/api/courses

🎓 Parsing Course JSON: Flutter Development (ID: course1)
   ├─ Found 3 modules in course
   └─ Total videos across all modules: 8

🎬 VideoService: Getting video URL
   ├─ Course: course1
   ├─ Module: module1
   └─ Video: video1
```

## 🛠️ Testing Backend Integration

### 1. Enable Backend Mode
```dart
// In lib/config/backend_config.dart
static const bool useRemoteRepository = true;
static const String baseUrl = 'http://localhost:8080'; // Your backend URL
```

### 2. Check Logs
Run the app and watch console for detailed logs:
```bash
flutter run
```

Look for messages starting with:
- `🏭 CourseRepositoryFactory:`
- `📡 Fetching courses from backend:`
- `🎓 Parsing Course JSON:`
- `🚨 Error` (if backend fails)
- `🔄 Falling back to mock data`

### 3. Test Fallback
To test the fallback mechanism:
1. Set wrong backend URL
2. Watch logs show error + fallback
3. App continues working with mock data

## 📱 Current Features

### ✅ Implemented:
- **Multiple videos per module** (course → modules → videos structure)
- **Automatic backend/mock switching** based on configuration
- **Comprehensive error handling** with fallback
- **Detailed logging** for debugging
- **JSON serialization** for all models
- **Backward compatibility** with existing UI
- **YouTube video integration** for all video playback

### 🎯 Video Playback Flow:
1. User clicks on video
2. `VideoService` gets video URL from repository (backend or mock)
3. `AppVideoPlayer` detects YouTube URL
4. Plays embedded YouTube video using `youtube_player_flutter`
5. Videos stay in-app (no redirect to YouTube)

## 🔄 Migration Notes

### From Mock to Backend:
1. Update `backend_config.dart` with your backend URL
2. Ensure backend implements expected JSON structure
3. Test with logs enabled
4. Gradual rollout using `useRemoteRepository` flag

### Backward Compatibility:
- All existing screens continue working
- Mock repository still available as fallback
- No breaking changes to UI components
- Same video playback experience

## 🐛 Debugging Tips

### Common Issues:

1. **"Using repository type: Mock"**
   - Check `backend_config.dart` settings
   - Verify `useRemoteRepository = true`
   - Ensure `baseUrl` is not empty

2. **"Backend returned error: 404"**
   - Verify API endpoints exist
   - Check URL path matches expected routes
   - Ensure backend is running

3. **"Error parsing Course JSON"**
   - Verify JSON structure matches expected format
   - Check all required fields are present
   - Review detailed parsing logs

4. **"Falling back to mock data"**
   - Normal behavior when backend fails
   - Check network connectivity
   - Verify backend URL and endpoints

### Debug Commands:
```dart
// Force repository reset (useful for testing)
CourseRepositoryFactory.reset();

// Check current repository type
print(CourseRepositoryFactory.getRepositoryType());
```

## 🚀 Next Steps

When your Spring Boot backend is ready:
1. Update `baseUrl` in `backend_config.dart`
2. Set `useRemoteRepository = true`
3. Test with logs enabled
4. Monitor fallback behavior
5. Gradually migrate users

The app will automatically sync courses, modules, and videos from your backend while maintaining a smooth user experience with fallback support!