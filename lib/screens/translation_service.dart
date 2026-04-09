import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static String currentLang = 'en'; 
  
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString('app_language') ?? 'en';
  }

 
  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode);
    currentLang = langCode;
  }


  static const Map<String, Map<String, String>> _dictionary = {
    'en': {
      
      'welcome': 'Welcome Back',
      'subtitle': 'Official Utility Billing Portal',
      'email': 'Email Address',
      'password': 'Password',
      'login_btn': 'Login',
      'forgot': 'Forgot Password?',
      'admin_note': 'Admins: Use your @ceb.lk or @waterboard.lk email',
      'admin_portal': 'Utility Admin Portal',
      'welcome_billmate': 'Welcome to BillMate,',
      'managed_accounts': 'Managed Utility Accounts',
      'linked_accounts': 'My Linked Accounts',
      'no_bills': 'No active bills found.',
      'issue_bill': 'Issue Official Bill',
      'link_account': 'Link My Account',
      'estimate_title': 'Monthly Consumption Estimate',
      'view_history': 'View Payment History',
      'pay_all': 'Pay All Unpaid Bills',
     
      'my_profile': 'My Profile',
      'set_budget': 'Set Monthly Budget',
      'security': 'Security & Password',
      'help': 'Help & Support',
      'about': 'About BillMate SL',
      'history_title': 'History',
      'search_hint': 'Search account number or type...',
      'paid': 'Paid',
      'link_title': 'Link Utility Account',
      'utility_type': 'Utility Type',
      'acc_number': 'Account Number',
      'electricity': 'Electricity',
      'water': 'Water'
    },
    'si': {
      'welcome': 'ආපසු සාදරයෙන් පිළිගනිමු',
      'subtitle': 'නිල උපයෝගිතා බිල්පත් ද්වාරය',
      'email': 'විද්‍යුත් තැපෑල',
      'password': 'මුරපදය',
      'login_btn': 'පිවිසෙන්න',
      'forgot': 'මුරපදය අමතකද?',
      'admin_note': 'පරිපාලකයින්: @ceb.lk හෝ @waterboard.lk භාවිතා කරන්න',
      'admin_portal': 'උපයෝගිතා පරිපාලක ද්වාරය',
      'welcome_billmate': 'BillMate වෙත සාදරයෙන් පිළිගනිමු,',
      'managed_accounts': 'කළමනාකරණය කළ උපයෝගිතා ගිණුම්',
      'linked_accounts': 'මගේ සම්බන්ධිත ගිණුම්',
      'no_bills': 'ක්‍රියාකාරී බිල්පත් හමු නොවීය.',
      'issue_bill': 'නිල බිල්පත නිකුත් කරන්න',
      'link_account': 'මගේ ගිණුම සම්බන්ධ කරන්න',
      'estimate_title': 'මාසික පරිභෝජන ඇස්තමේන්තුව',
      'view_history': 'ගෙවීම් ඉතිහාසය බලන්න',
      'pay_all': 'සියලුම බිල්පත් ගෙවන්න',
      'my_profile': 'මගේ පැතිකඩ',
      'set_budget': 'මාසික අයවැය සකසන්න',
      'security': 'ආරක්ෂාව සහ මුරපදය',
      'help': 'උදවු සහ සහාය',
      'about': 'BillMate SL ගැන',
      'history_title': 'ඉතිහාසය',
      'search_hint': 'ගිණුම් අංකය සොයන්න...',
      'paid': 'ගෙවා ඇත',
      'link_title': 'ගිණුම සම්බන්ධ කරන්න',
      'utility_type': 'උපයෝගිතා වර්ගය',
      'acc_number': 'ගිණුම් අංකය',
      'electricity': 'විදුලිය',
      'water': 'ජලය'
    },
    'ta': {
      'welcome': 'மீண்டும் வருக',
      'subtitle': 'அதிகாரப்பூர்வ பயன்பாட்டு பில்லிங் போர்டல்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'login_btn': 'உள்நுழைக',
      'forgot': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'admin_note': 'நிர்வாகிகள்: @ceb.lk அல்லது @waterboard.lk ஐப் பயன்படுத்தவும்',
      'admin_portal': 'பயன்பாட்டு நிர்வாக போர்டல்',
      'welcome_billmate': 'BillMate க்கு வரவேற்கிறோம்,',
      'managed_accounts': 'நிர்வகிக்கப்பட்ட பயன்பாட்டு கணக்குகள்',
      'linked_accounts': 'எனது இணைக்கப்பட்ட கணக்குகள்',
      'no_bills': 'செயலில் உள்ள பில்கள் இல்லை.',
      'issue_bill': 'அதிகாரப்பூர்வ மசோதாவை வழங்கு',
      'link_account': 'என் கணக்கை இணைக்கவும்',
      'estimate_title': 'மாதாந்திர நுகர்வு மதிப்பீடு',
      'view_history': 'கட்டண வரலாற்றைக் காண்க',
      'pay_all': 'அனைத்து பில்களையும் செலுத்துங்கள்',
      'my_profile': 'எனது சுயவிவரம்',
      'set_budget': 'பட்ஜெட்டை அமைக்கவும்',
      'security': 'பாதுகாப்பு & கடவுச்சொல்',
      'help': 'உதவி மற்றும் ஆதரவு',
      'about': 'BillMate SL பற்றி',
      'history_title': 'வரலாறு',
      'search_hint': 'கணக்கு எண்ணைத் தேடுக...',
      'paid': 'செலுத்தப்பட்டது',
      'link_title': 'கணக்கை இணைக்கவும்',
      'utility_type': 'பயன்பாட்டு வகை',
      'acc_number': 'கணக்கு எண்',
      'electricity': 'மின்சாரம்',
      'water': 'நீர்'
    }
  };

  // Text eka ganna function eka
  static String getText(String key) {
    return _dictionary[currentLang]?[key] ?? _dictionary['en']![key] ?? key;
  }
}
