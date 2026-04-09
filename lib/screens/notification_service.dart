class NotificationService {
  
  // ඇප් එක පටන්ගද්දි මේක හිස්ව තියමු
  static Future<void> initialize() async {
    print("✅ Notifications Bypassed!");
  }

  // ෆෝන් එකට මැසේජ් එක එනවා වෙනුවට Terminal එකේ විතරක් පෙන්නමු
  static Future<void> showNotification({required String title, required String body}) async {
    print("🔔 NOTIFICATION: $title - $body");
  }
  
}