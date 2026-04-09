class NotificationService {
  
  
  static Future<void> initialize() async {
    print("✅ Notifications Bypassed!");
  }

  
  static Future<void> showNotification({required String title, required String body}) async {
    print("🔔 NOTIFICATION: $title - $body");
  }
  
}