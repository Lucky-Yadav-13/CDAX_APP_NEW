class MockVideoService {
  static Future<String> getCourseIntroUrl(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Free demo MP4 (samplelib). Replace with backend API later.
    return 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';
  }

  static Future<String> getModuleVideoUrl({required String courseId, required String moduleId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Alternate demo MP4
    return 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';
  }
}


