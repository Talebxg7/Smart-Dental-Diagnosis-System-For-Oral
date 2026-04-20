import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    if (locale.languageCode == 'ar') {
      _strings = _ar;
    } else if (locale.languageCode == 'tr') {
      _strings = _tr;
    } else {
      _strings = _en;
    }
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get(String key) => _strings[key] ?? key;

  // App
  String get appTitle => get('appTitle');
  String get guest => get('guest');

  // Auth
  String get signIn => get('signIn');
  String get signUp => get('signUp');
  String get email => get('email');
  String get password => get('password');
  String get confirmPassword => get('confirmPassword');
  String get forgotPassword => get('forgotPassword');
  String get noAccount => get('noAccount');
  String get haveAccount => get('haveAccount');
  String get firstName => get('firstName');
  String get lastName => get('lastName');
  String get phone => get('phone');
  String get register => get('register');
  String get createAccount => get('createAccount');
  String get useAccountToContinue => get('useAccountToContinue');
  String get demoViewWithoutSignIn => get('demoViewWithoutSignIn');
  String get noAccountRegister => get('noAccountRegister');

  // Home
  String get welcome => get('welcome');
  String get newScan => get('newScan');
  String get takePhoto => get('takePhoto');
  String get chooseGallery => get('chooseGallery');
  String get recentScans => get('recentScans');
  String get viewAll => get('viewAll');
  String get noScansYet => get('noScansYet');
  String get caries => get('caries');
  String get tartar => get('tartar');
  String get gingivitis => get('gingivitis');
  String get cariesDescription => get('cariesDescription');
  String get tartarDescription => get('tartarDescription');
  String get gingivitisDescription => get('gingivitisDescription');
  String get detectableConditions => get('detectableConditions');
  String get hello => get('hello');
  String get scanTagline => get('scanTagline');
  String get uploadDentalImage => get('uploadDentalImage');
  String get scanTeeth => get('scanTeeth');
  String get takeNewPhoto => get('takeNewPhoto');
  String get startFirstScan => get('startFirstScan');
  String get dentalTip => get('dentalTip');
  String get dailyDentalTip => get('dailyDentalTip');
  String get lastScanResult => get('lastScanResult');
  String diseaseDetected(String disease) =>
      (get('diseaseDetected')).replaceAll('{disease}', disease);
  /// 1-based index 1..15
  String getDailyTip(int index) => get('dailyTip$index');
  String get scanHistory => get('scanHistory');
  String get reports => get('reports');
  String get profile => get('profile');

  // Scan
  String get scanResult => get('scanResult');
  String get condition => get('condition');
  String get severity => get('severity');
  String get confidence => get('confidence');
  String get recommendation => get('recommendation');
  String get backToHome => get('backToHome');

  // History
  String get searchScans => get('searchScans');
  String get all => get('all');
  String get newestFirst => get('newestFirst');
  String get oldestFirst => get('oldestFirst');
  String get sort => get('sort');
  String get noScansMatch => get('noScansMatch');
  String get viewDetails => get('viewDetails');
  String diagnosisDetected(String disease) =>
      (get('diagnosisDetected')).replaceAll('{disease}', disease);
  String get date => get('date');
  String get deleteScan => get('deleteScan');
  String get deleteScanConfirm => get('deleteScanConfirm');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get scanResultDetails => get('scanResultDetails');
  String get scanDate => get('scanDate');

  // Reports
  String get reportDetails => get('reportDetails');
  String get patientInfo => get('patientInfo');
  String get reportResults => get('reportResults');
  String get notesRecommendations => get('notesRecommendations');
  String get latestFirst => get('latestFirst');
  String get allSeverity => get('allSeverity');
  String get mild => get('mild');
  String get moderate => get('moderate');
  String get severe => get('severe');
  String get noReportsYet => get('noReportsYet');
  String get noReportsMatch => get('noReportsMatch');

  // Profile
  String get tapToChangePhoto => get('tapToChangePhoto');
  String get editProfile => get('editProfile');
  String get save => get('save');
  String get accountSettings => get('accountSettings');
  String get changePassword => get('changePassword');
  String get changePasswordSubtitle => get('changePasswordSubtitle');
  String get currentPassword => get('currentPassword');
  String get newPassword => get('newPassword');
  String get confirmNewPassword => get('confirmNewPassword');
  String get atLeast6Chars => get('atLeast6Chars');
  String get updatePassword => get('updatePassword');
  String get enterCurrentPassword => get('enterCurrentPassword');
  String get passwordsDoNotMatch => get('passwordsDoNotMatch');
  String get newPasswordMinLength => get('newPasswordMinLength');
  String get passwordUpdated => get('passwordUpdated');
  String get pleaseSignInToChangePassword => get('pleaseSignInToChangePassword');
  String get changePasswordDescription => get('changePasswordDescription');
  String get notifications => get('notifications');
  String get notificationsSubtitle => get('notificationsSubtitle');
  String get scanVisibility => get('scanVisibility');
  String get scanVisibilitySubtitle => get('scanVisibilitySubtitle');
  String get activitySummary => get('activitySummary');
  String get scans => get('scans');
  String get quickAccessLatestScans => get('quickAccessLatestScans');
  String get viewYourReports => get('viewYourReports');
  String get logOut => get('logOut');
  String get deleteAccount => get('deleteAccount');
  String get deleteAccountConfirm => get('deleteAccountConfirm');
  String get camera => get('camera');
  String get gallery => get('gallery');

  // App preferences
  String get appPreferences => get('appPreferences');
  String get theme => get('theme');
  String get light => get('light');
  String get dark => get('dark');
  String get language => get('language');
  String get english => get('english');
  String get arabic => get('arabic');
  String get turkish => get('turkish');

  // Common
  String get retry => get('retry');
  String get unknown => get('unknown');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar' || locale.languageCode == 'tr';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      Future<AppLocalizations>.value(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

final Map<String, String> _en = {
  'appTitle': 'Smart Dental Diagnosis',
  'guest': 'Guest',
  'signIn': 'Sign in',
  'signUp': 'Sign up',
  'email': 'Email',
  'password': 'Password',
  'confirmPassword': 'Confirm password',
  'forgotPassword': 'Forgot password?',
  'noAccount': "Don't have an account?",
  'haveAccount': 'Already have an account?',
  'firstName': 'First name',
  'lastName': 'Last name',
  'phone': 'Phone',
  'register': 'Register',
  'createAccount': 'Create account',
  'useAccountToContinue': 'Use your account to continue',
  'demoViewWithoutSignIn': 'Demo – view app without signing in',
  'noAccountRegister': "Don't have an account? Register",
  'welcome': 'Welcome',
  'newScan': 'New Scan',
  'takePhoto': 'Take photo',
  'chooseGallery': 'Choose from gallery',
  'recentScans': 'Recent scans',
  'viewAll': 'View all',
  'noScansYet': 'No scans yet',
  'caries': 'Caries',
  'tartar': 'Tartar',
  'gingivitis': 'Gingivitis',
  'cariesDescription': 'Tooth decay caused by bacteria.',
  'tartarDescription': 'Hardened plaque on teeth.',
  'gingivitisDescription': 'Early stage gum inflammation.',
  'detectableConditions': 'Detectable Conditions',
  'hello': 'Hello',
  'scanTagline': 'Scan your teeth and detect oral diseases instantly.',
  'uploadDentalImage': 'Upload Dental Image',
  'scanTeeth': 'Scan Teeth',
  'takeNewPhoto': 'Take a new photo',
  'startFirstScan': 'Start your first scan.',
  'diseaseDetected': '{disease} detected',
  'dailyDentalTip': 'Daily Dental Tip',
  'scanHistory': 'Scan History',
  'dailyTip1': 'Brush your teeth twice a day for at least 2 minutes.',
  'dailyTip2': 'Use a fluoride toothpaste to help protect against cavities.',
  'dailyTip3': 'Floss daily to remove food and plaque between teeth.',
  'dailyTip4': 'Replace your toothbrush every 3–4 months.',
  'dailyTip5': 'Avoid too many sugary snacks and drinks.',
  'dailyTip6': 'Drink plenty of water to wash away bacteria.',
  'dailyTip7': 'Use mouthwash to reduce bacteria and freshen breath.',
  'dailyTip8': 'Clean your tongue when brushing to prevent bad breath.',
  'dailyTip9': 'Eat crunchy fruits and vegetables like apples and carrots.',
  'dailyTip10': 'Limit soda and acidic drinks that damage enamel.',
  'dailyTip11': 'Do not brush too hard to avoid damaging gums.',
  'dailyTip12': 'Wait 30 minutes after eating before brushing your teeth.',
  'dailyTip13': 'Chew sugar-free gum to increase saliva and protect teeth.',
  'dailyTip14': 'Visit your dentist every 6 months for checkups.',
  'dailyTip15': 'Stop smoking or tobacco use to protect gums and teeth.',
  'reports': 'Reports',
  'profile': 'Profile',
  'dentalTip': 'Dental tip',
  'lastScanResult': 'Last scan result',
  'scanResult': 'Scan Result',
  'condition': 'Condition',
  'severity': 'Severity',
  'confidence': 'Confidence',
  'recommendation': 'Recommendation',
  'backToHome': 'Back to Home',
  'searchScans': 'Search scans...',
  'all': 'All',
  'newestFirst': 'Newest First',
  'oldestFirst': 'Oldest First',
  'sort': 'Sort:',
  'noScansMatch': 'No scans match your search',
  'viewDetails': 'View Details',
  'diagnosisDetected': 'Diagnosis: {disease} detected',
  'date': 'Date',
  'deleteScan': 'Delete scan?',
  'deleteScanConfirm': 'Are you sure you want to delete this scan?',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'scanResultDetails': 'Scan Result Details',
  'scanDate': 'Scan Date',
  'reportDetails': 'Report details',
  'patientInfo': 'Patient information',
  'reportResults': 'Report results',
  'notesRecommendations': 'Notes / Recommendations',
  'latestFirst': 'Latest first',
  'allSeverity': 'All severity',
  'mild': 'Mild',
  'moderate': 'Moderate',
  'severe': 'Severe',
  'noReportsYet': 'No reports yet',
  'noReportsMatch': 'No reports match your search',
  'tapToChangePhoto': 'Tap to change photo',
  'editProfile': 'Edit profile',
  'save': 'Save',
  'accountSettings': 'Account settings',
  'changePassword': 'Change password',
  'changePasswordSubtitle': 'Update your account password',
  'currentPassword': 'Current password',
  'newPassword': 'New password',
  'confirmNewPassword': 'Confirm new password',
  'atLeast6Chars': 'At least 6 characters',
  'updatePassword': 'Update password',
  'enterCurrentPassword': 'Enter your current password',
  'passwordsDoNotMatch': 'New passwords do not match',
  'newPasswordMinLength': 'New password must be at least 6 characters',
  'passwordUpdated': 'Password updated',
  'pleaseSignInToChangePassword': 'Please sign in to change your password',
  'changePasswordDescription': 'Enter your current password and choose a new one.',
  'notifications': 'Notifications',
  'notificationsSubtitle': 'Receive reminders and updates',
  'scanVisibility': 'Scan visibility',
  'scanVisibilitySubtitle': 'Allow your scans to be used for research (anonymous)',
  'activitySummary': 'Activity summary',
  'scans': 'Scans',
  'quickAccessLatestScans': 'Quick access to your latest scans',
  'viewYourReports': 'View your reports',
  'logOut': 'Log out',
  'deleteAccount': 'Delete account',
  'deleteAccountConfirm': 'This will permanently delete your account and all your scan history. This cannot be undone.',
  'camera': 'Camera',
  'gallery': 'Gallery',
  'appPreferences': 'App preferences',
  'theme': 'Theme',
  'light': 'Light',
  'dark': 'Dark',
  'language': 'Language',
  'english': 'English',
  'arabic': 'العربية',
  'turkish': 'Türkçe',
  'retry': 'Retry',
  'unknown': 'Unknown',
};

final Map<String, String> _tr = {
  'appTitle': 'Akıllı Diş Teşhisi',
  'guest': 'Misafir',
  'signIn': 'Giriş yap',
  'signUp': 'Kayıt ol',
  'email': 'E-posta',
  'password': 'Şifre',
  'confirmPassword': 'Şifreyi onayla',
  'forgotPassword': 'Şifremi unuttum',
  'noAccount': 'Hesabınız yok mu?',
  'haveAccount': 'Zaten hesabınız var mı?',
  'firstName': 'Ad',
  'lastName': 'Soyad',
  'phone': 'Telefon',
  'register': 'Kayıt ol',
  'createAccount': 'Hesap oluştur',
  'useAccountToContinue': 'Devam etmek için hesabınızı kullanın',
  'demoViewWithoutSignIn': 'Demo – giriş yapmadan uygulamayı görüntüle',
  'noAccountRegister': 'Hesabınız yok mu? Kayıt olun',
  'welcome': 'Hoş geldiniz',
  'newScan': 'Yeni tarama',
  'takePhoto': 'Fotoğraf çek',
  'chooseGallery': 'Galeriden seç',
  'recentScans': 'Son taramalar',
  'viewAll': 'Tümünü gör',
  'noScansYet': 'Henüz tarama yok',
  'caries': 'Çürük',
  'tartar': 'Diş taşı',
  'gingivitis': 'Diş eti iltihabı',
  'cariesDescription': 'Bakterilerin neden olduğu diş çürüğü.',
  'tartarDescription': 'Dişlerde sertleşen plak.',
  'gingivitisDescription': 'Diş eti iltihabının erken aşaması.',
  'detectableConditions': 'Tespit Edilebilir Durumlar',
  'hello': 'Merhaba',
  'scanTagline': 'Dişlerinizi tarayın ve ağız hastalıklarını anında tespit edin.',
  'uploadDentalImage': 'Diş Görüntüsü Yükle',
  'scanTeeth': 'Diş Tara',
  'takeNewPhoto': 'Yeni fotoğraf çek',
  'startFirstScan': 'İlk taramanıza başlayın.',
  'diseaseDetected': '{disease} tespit edildi',
  'dailyDentalTip': 'Günlük Diş İpucu',
  'scanHistory': 'Tarama geçmişi',
  'dailyTip1': 'Günde en az 2 dakika dişlerinizi iki kez fırçalayın.',
  'dailyTip2': 'Çürüklere karşı koruma için florürlü diş macunu kullanın.',
  'dailyTip3': 'Dişler arasındaki yiyecek ve plağı çıkarmak için günlük diş ipi kullanın.',
  'dailyTip4': 'Diş fırçanızı her 3–4 ayda bir değiştirin.',
  'dailyTip5': 'Çok fazla şekerli atıştırmalık ve içeceklerden kaçının.',
  'dailyTip6': 'Bakterileri temizlemek için bol su için.',
  'dailyTip7': 'Bakterileri azaltmak ve nefesi tazelemek için ağız gargarası kullanın.',
  'dailyTip8': 'Ağız kokusunu önlemek için fırçalarken dilinizi temizleyin.',
  'dailyTip9': 'Elma ve havuç gibi çıtır meyve ve sebzeler yiyin.',
  'dailyTip10': 'Mineye zarar veren gazlı ve asitli içecekleri sınırlayın.',
  'dailyTip11': 'Diş etlerine zarar vermemek için çok sert fırçalamayın.',
  'dailyTip12': 'Dişlerinizi fırçalamadan önce yemekten sonra 30 dakika bekleyin.',
  'dailyTip13': 'Tükürüğü artırmak ve dişleri korumak için şekersiz sakız çiğneyin.',
  'dailyTip14': 'Kontroller için her 6 ayda bir diş hekiminizi ziyaret edin.',
  'dailyTip15': 'Diş etlerini ve dişleri korumak için sigara veya tütün kullanımını bırakın.',
  'reports': 'Raporlar',
  'profile': 'Profil',
  'dentalTip': 'Diş ipucu',
  'lastScanResult': 'Son tarama sonucu',
  'scanResult': 'Tarama sonucu',
  'condition': 'Durum',
  'severity': 'Şiddet',
  'confidence': 'Güven',
  'recommendation': 'Öneri',
  'backToHome': 'Ana sayfaya dön',
  'searchScans': 'Taramalarda ara...',
  'all': 'Tümü',
  'newestFirst': 'En yeni önce',
  'oldestFirst': 'En eski önce',
  'sort': 'Sırala:',
  'noScansMatch': 'Aramanızla eşleşen tarama yok',
  'viewDetails': 'Detayları gör',
  'diagnosisDetected': 'Teşhis: {disease} tespit edildi',
  'date': 'Tarih',
  'deleteScan': 'Tarama silinsin mi?',
  'deleteScanConfirm': 'Bu taramayı silmek istediğinizden emin misiniz?',
  'cancel': 'İptal',
  'delete': 'Sil',
  'scanResultDetails': 'Tarama sonucu detayları',
  'scanDate': 'Tarama tarihi',
  'reportDetails': 'Rapor detayları',
  'patientInfo': 'Hasta bilgisi',
  'reportResults': 'Rapor sonuçları',
  'notesRecommendations': 'Notlar / Öneriler',
  'latestFirst': 'En yeni önce',
  'allSeverity': 'Tüm şiddetler',
  'mild': 'Hafif',
  'moderate': 'Orta',
  'severe': 'Şiddetli',
  'noReportsYet': 'Henüz rapor yok',
  'noReportsMatch': 'Aramanızla eşleşen rapor yok',
  'tapToChangePhoto': 'Fotoğrafı değiştirmek için dokunun',
  'editProfile': 'Profili düzenle',
  'save': 'Kaydet',
  'accountSettings': 'Hesap ayarları',
  'changePassword': 'Şifre değiştir',
  'changePasswordSubtitle': 'Hesap şifrenizi güncelleyin',
  'currentPassword': 'Mevcut şifre',
  'newPassword': 'Yeni şifre',
  'confirmNewPassword': 'Yeni şifreyi onayla',
  'atLeast6Chars': 'En az 6 karakter',
  'updatePassword': 'Şifreyi güncelle',
  'enterCurrentPassword': 'Mevcut şifrenizi girin',
  'passwordsDoNotMatch': 'Yeni şifreler eşleşmiyor',
  'newPasswordMinLength': 'Yeni şifre en az 6 karakter olmalı',
  'passwordUpdated': 'Şifre güncellendi',
  'pleaseSignInToChangePassword': 'Şifrenizi değiştirmek için giriş yapın',
  'changePasswordDescription': 'Mevcut şifrenizi girin ve yeni bir şifre seçin.',
  'notifications': 'Bildirimler',
  'notificationsSubtitle': 'Hatırlatıcı ve güncellemeleri alın',
  'scanVisibility': 'Tarama görünürlüğü',
  'scanVisibilitySubtitle': 'Taramalarınızın araştırmada kullanılmasına izin verin (anonim)',
  'activitySummary': 'Aktivite özeti',
  'scans': 'Taramalar',
  'quickAccessLatestScans': 'Son taramalara hızlı erişim',
  'viewYourReports': 'Raporlarınızı görüntüleyin',
  'logOut': 'Çıkış yap',
  'deleteAccount': 'Hesabı sil',
  'deleteAccountConfirm': 'Bu işlem hesabınızı ve tüm tarama geçmişinizi kalıcı olarak silecektir. Bu işlem geri alınamaz.',
  'camera': 'Kamera',
  'gallery': 'Galeri',
  'appPreferences': 'Uygulama tercihleri',
  'theme': 'Tema',
  'light': 'Açık',
  'dark': 'Koyu',
  'language': 'Dil',
  'english': 'English',
  'arabic': 'العربية',
  'turkish': 'Türkçe',
  'retry': 'Tekrar dene',
  'unknown': 'Bilinmiyor',
};

final Map<String, String> _ar = {
  'appTitle': 'تشخيص الأسنان الذكي',
  'guest': 'زائر',
  'signIn': 'تسجيل الدخول',
  'signUp': 'إنشاء حساب',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'forgotPassword': 'نسيت كلمة المرور؟',
  'noAccount': 'ليس لديك حساب؟',
  'haveAccount': 'لديك حساب بالفعل؟',
  'firstName': 'الاسم الأول',
  'lastName': 'اسم العائلة',
  'phone': 'الهاتف',
  'register': 'التسجيل',
  'createAccount': 'إنشاء حساب',
  'useAccountToContinue': 'استخدم حسابك للمتابعة',
  'demoViewWithoutSignIn': 'عرض التجريبي – بدون تسجيل دخول',
  'noAccountRegister': 'ليس لديك حساب؟ سجّل',
  'welcome': 'مرحباً',
  'newScan': 'مسح جديد',
  'takePhoto': 'التقاط صورة',
  'chooseGallery': 'اختيار من المعرض',
  'recentScans': 'المسوح الأخيرة',
  'viewAll': 'عرض الكل',
  'noScansYet': 'لا توجد مسوح بعد',
  'caries': 'تسوس',
  'tartar': 'جير',
  'gingivitis': 'التهاب اللثة',
  'cariesDescription': 'تسوس الأسنان الناجم عن البكتيريا.',
  'tartarDescription': 'اللويحة المتصلبة على الأسنان.',
  'gingivitisDescription': 'المرحلة المبكرة من التهاب اللثة.',
  'detectableConditions': 'الحالات القابلة للكشف',
  'hello': 'مرحباً',
  'scanTagline': 'امسح أسنانك واكتشف أمراض الفم فوراً.',
  'uploadDentalImage': 'رفع صورة سنية',
  'scanTeeth': 'مسح الأسنان',
  'takeNewPhoto': 'التقاط صورة جديدة',
  'startFirstScan': 'ابدأ أول مسح لك.',
  'diseaseDetected': 'تم اكتشاف {disease}',
  'dailyDentalTip': 'نصيحة سنية يومية',
  'scanHistory': 'سجل المسوح',
  'dailyTip1': 'اغسل أسنانك مرتين يومياً لمدة دقيقتين على الأقل.',
  'dailyTip2': 'استخدم معجون أسنان بالفلورايد لحماية من التسوس.',
  'dailyTip3': 'استخدم الخيط يومياً لإزالة الطعام واللويحة بين الأسنان.',
  'dailyTip4': 'استبدل فرشاة أسنانك كل 3–4 أشهر.',
  'dailyTip5': 'تجنب الإكثار من الوجبات الخفيفة والمشروبات السكرية.',
  'dailyTip6': 'اشرب الكثير من الماء لطرد البكتيريا.',
  'dailyTip7': 'استخدم غسول الفم لتقليل البكتيريا وانتعاش النفس.',
  'dailyTip8': 'نظف لسانك عند تنظيف الأسنان لمنع رائحة الفم.',
  'dailyTip9': 'تناول فواكه وخضروات مقرمشة مثل التفاح والجزر.',
  'dailyTip10': 'قلل المشروبات الغازية والحامضية التي تضر المينا.',
  'dailyTip11': 'لا تنظف أسنانك بقوة لتجنب إيذاء اللثة.',
  'dailyTip12': 'انتظر 30 دقيقة بعد الأكل قبل تنظيف الأسنان.',
  'dailyTip13': 'امضغ علكة خالية من السكر لزيادة اللعاب وحماية الأسنان.',
  'dailyTip14': 'زر طبيب الأسنان كل 6 أشهر للفحوصات.',
  'dailyTip15': 'أقلع عن التدخين أو التبغ لحماية اللثة والأسنان.',
  'reports': 'التقارير',
  'profile': 'الملف الشخصي',
  'dentalTip': 'نصيحة سنية',
  'lastScanResult': 'نتيجة آخر مسح',
  'scanResult': 'نتيجة المسح',
  'condition': 'الحالة',
  'severity': 'الشدة',
  'confidence': 'الثقة',
  'recommendation': 'التوصية',
  'backToHome': 'العودة للرئيسية',
  'searchScans': 'البحث في المسوح...',
  'all': 'الكل',
  'newestFirst': 'الأحدث أولاً',
  'oldestFirst': 'الأقدم أولاً',
  'sort': 'ترتيب:',
  'noScansMatch': 'لا توجد مسوح تطابق البحث',
  'viewDetails': 'عرض التفاصيل',
  'diagnosisDetected': 'التشخيص: تم اكتشاف {disease}',
  'date': 'التاريخ',
  'deleteScan': 'حذف المسح؟',
  'deleteScanConfirm': 'هل أنت متأكد أنك تريد حذف هذا المسح؟',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'scanResultDetails': 'تفاصيل نتيجة المسح',
  'scanDate': 'تاريخ المسح',
  'reportDetails': 'تفاصيل التقرير',
  'patientInfo': 'معلومات المريض',
  'reportResults': 'نتائج التقرير',
  'notesRecommendations': 'ملاحظات / التوصيات',
  'latestFirst': 'الأحدث أولاً',
  'allSeverity': 'كل الدرجات',
  'mild': 'خفيف',
  'moderate': 'متوسط',
  'severe': 'شديد',
  'noReportsYet': 'لا توجد تقارير بعد',
  'noReportsMatch': 'لا توجد تقارير تطابق البحث',
  'tapToChangePhoto': 'انقر لتغيير الصورة',
  'editProfile': 'تعديل الملف الشخصي',
  'save': 'حفظ',
  'accountSettings': 'إعدادات الحساب',
  'changePassword': 'تغيير كلمة المرور',
  'changePasswordSubtitle': 'تحديث كلمة مرور حسابك',
  'currentPassword': 'كلمة المرور الحالية',
  'newPassword': 'كلمة المرور الجديدة',
  'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
  'atLeast6Chars': '6 أحرف على الأقل',
  'updatePassword': 'تحديث كلمة المرور',
  'enterCurrentPassword': 'أدخل كلمة المرور الحالية',
  'passwordsDoNotMatch': 'كلمتا المرور الجديدتان غير متطابقتين',
  'newPasswordMinLength': 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل',
  'passwordUpdated': 'تم تحديث كلمة المرور',
  'pleaseSignInToChangePassword': 'يرجى تسجيل الدخول لتغيير كلمة المرور',
  'changePasswordDescription': 'أدخل كلمة المرور الحالية واختر كلمة جديدة.',
  'notifications': 'الإشعارات',
  'notificationsSubtitle': 'استلام التذكيرات والتحديثات',
  'scanVisibility': 'ظهور المسوح',
  'scanVisibilitySubtitle': 'السماح باستخدام مسوحك للبحث (بدون هوية)',
  'activitySummary': 'ملخص النشاط',
  'scans': 'المسوح',
  'quickAccessLatestScans': 'وصول سريع لأحدث المسوح',
  'viewYourReports': 'عرض تقاريرك',
  'logOut': 'تسجيل الخروج',
  'deleteAccount': 'حذف الحساب',
  'deleteAccountConfirm': 'سيؤدي هذا إلى حذف حسابك وسجل المسوح نهائياً. لا يمكن التراجع عن ذلك.',
  'camera': 'الكاميرا',
  'gallery': 'المعرض',
  'appPreferences': 'تفضيلات التطبيق',
  'theme': 'المظهر',
  'light': 'فاتح',
  'dark': 'داكن',
  'language': 'اللغة',
  'english': 'English',
  'arabic': 'العربية',
  'turkish': 'Türkçe',
  'retry': 'إعادة المحاولة',
  'unknown': 'غير معروف',
};
