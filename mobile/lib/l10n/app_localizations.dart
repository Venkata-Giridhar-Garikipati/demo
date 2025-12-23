import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Title
      'app_title': 'PM Internship Scheme',
      
      // Profile Input Screen
      'fill_details': 'Fill Your Details',
      'education': 'Education',
      'education_icon': '📚',
      'select_education': 'Select Education Level',
      'sector': 'Sector',
      'sector_icon': '💼',
      'select_sector': 'Select Sector',
      'location': 'Location',
      'location_icon': '📍',
      'select_location': 'Select Location',
      'skills': 'Skills',
      'skills_icon': '🎯',
      'select_skills': 'Select 2-5 skills',
      'find_internships': 'Find Internships',
      'select_at_least_one_skill': 'Please select at least one skill',
      'please_select_option': 'Please select an option',
      'searching_recommendations': 'Searching recommendations...',
      
      // Education Levels
      '10th_pass': '10th Pass',
      '12th_pass': '12th Pass',
      'diploma': 'Diploma',
      'bachelors': "Bachelor's Degree",
      'masters': "Master's Degree",
      
      // Sectors
      'it_software': 'IT & Software',
      'manufacturing': 'Manufacturing',
      'marketing_sales': 'Marketing & Sales',
      'finance_banking': 'Finance & Banking',
      'healthcare': 'Healthcare',
      'education_sector': 'Education',
      'agriculture': 'Agriculture',
      'retail': 'Retail',
      'hospitality': 'Hospitality',
      'government': 'Government',
      
      // Locations
      'delhi': 'Delhi',
      'mumbai': 'Mumbai',
      'bangalore': 'Bangalore',
      'hyderabad': 'Hyderabad',
      'chennai': 'Chennai',
      'kolkata': 'Kolkata',
      'pune': 'Pune',
      'goa': 'Goa',
      'madhya_pradesh': 'Madhya Pradesh',
      'remote': 'Remote',
      
      // Skills
      'communication': 'Communication',
      'ms_office': 'MS Office',
      'english': 'English',
      'hindi': 'Hindi',
      'python': 'Python',
      'java': 'Java',
      'sales': 'Sales',
      'customer_service': 'Customer Service',
      'data_entry': 'Data Entry',
      'social_media': 'Social Media',
      'accounting': 'Accounting',
      'teaching': 'Teaching',
      'manual_work': 'Manual Work',
      
      // Recommendation Screen
      'recommendations_for_you': 'Recommendations for You',
      'no_internships_found': 'No Internships Found',
      'try_different_options': 'Please try different options',
      'top_internships': 'Top Internships for You',
      'internships_found': 'Great Internships Found!',
      'match': 'MATCH',
      'required_skills': 'Required Skills:',
      'apply_now': 'Apply Now',
      'details': 'Details',
      'apply': 'Apply',
      'apply_for': 'You want to apply for',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'application_submitted': 'Application submitted!',
      'close': 'Close',
      'score_breakdown': 'Score Breakdown:',
      'skills_match': 'Skills',
      'sector_match': 'Sector',
      'location_match': 'Location',
      'education_match': 'Education',
      
      // Language
      'language': 'Language',
      'change_language': 'Change Language',
    },
    'hi': {
      // App Title
      'app_title': 'पीएम इंटर्नशिप योजना',
      
      // Profile Input Screen
      'fill_details': 'अपना विवरण भरें',
      'education': 'शिक्षा',
      'education_icon': '📚',
      'select_education': 'शिक्षा स्तर चुनें',
      'sector': 'क्षेत्र',
      'sector_icon': '💼',
      'select_sector': 'क्षेत्र चुनें',
      'location': 'स्थान',
      'location_icon': '📍',
      'select_location': 'स्थान चुनें',
      'skills': 'कौशल',
      'skills_icon': '🎯',
      'select_skills': '2-5 कौशल चुनें',
      'find_internships': 'इंटर्नशिप खोजें',
      'select_at_least_one_skill': 'कृपया कम से कम एक कौशल चुनें',
      'please_select_option': 'कृपया एक विकल्प चुनें',
      'searching_recommendations': 'सिफारिशें खोज रहे हैं...',
      
      // Education Levels
      '10th_pass': '10वीं पास',
      '12th_pass': '12वीं पास',
      'diploma': 'डिप्लोमा',
      'bachelors': 'स्नातक की डिग्री',
      'masters': 'स्नातकोत्तर की डिग्री',
      
      // Sectors
      'it_software': 'आईटी और सॉफ्टवेयर',
      'manufacturing': 'विनिर्माण',
      'marketing_sales': 'विपणन और बिक्री',
      'finance_banking': 'वित्त और बैंकिंग',
      'healthcare': 'स्वास्थ्य सेवा',
      'education_sector': 'शिक्षा',
      'agriculture': 'कृषि',
      'retail': 'खुदरा',
      'hospitality': 'आतिथ्य',
      'government': 'सरकार',
      
      // Locations
      'delhi': 'दिल्ली',
      'mumbai': 'मुंबई',
      'bangalore': 'बेंगलुरु',
      'hyderabad': 'हैदराबाद',
      'chennai': 'चेन्नई',
      'kolkata': 'कोलकाता',
      'pune': 'पुणे',
      'goa': 'गोवा',
      'madhya_pradesh': 'मध्य प्रदेश',
      'remote': 'रिमोट',
      
      // Skills
      'communication': 'संचार',
      'ms_office': 'एमएस ऑफिस',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'python': 'पायथन',
      'java': 'जावा',
      'sales': 'बिक्री',
      'customer_service': 'ग्राहक सेवा',
      'data_entry': 'डेटा एंट्री',
      'social_media': 'सोशल मीडिया',
      'accounting': 'लेखांकन',
      'teaching': 'शिक्षण',
      'manual_work': 'शारीरिक कार्य',
      
      // Recommendation Screen
      'recommendations_for_you': 'आपके लिए सिफारिशें',
      'no_internships_found': 'कोई इंटर्नशिप नहीं मिली',
      'try_different_options': 'कृपया अलग विकल्प चुनें',
      'top_internships': 'आपके लिए शीर्ष इंटर्नशिप',
      'internships_found': 'बेहतरीन इंटर्नशिप मिली!',
      'match': 'मैच',
      'required_skills': 'आवश्यक कौशल:',
      'apply_now': 'अभी आवेदन करें',
      'details': 'विवरण',
      'apply': 'आवेदन करें',
      'apply_for': 'आप इसके लिए आवेदन करना चाहते हैं',
      'cancel': 'रद्द करें',
      'yes': 'हां',
      'application_submitted': 'आवेदन सबमिट हुआ!',
      'close': 'बंद करें',
      'score_breakdown': 'स्कोर विवरण:',
      'skills_match': 'कौशल',
      'sector_match': 'क्षेत्र',
      'location_match': 'स्थान',
      'education_match': 'शिक्षा',
      
      // Language
      'language': 'भाषा',
      'change_language': 'भाषा बदलें',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for easy access
  String get appTitle => translate('app_title');
  String get fillDetails => translate('fill_details');
  String get education => translate('education');
  String get educationIcon => translate('education_icon');
  String get selectEducation => translate('select_education');
  String get sector => translate('sector');
  String get sectorIcon => translate('sector_icon');
  String get selectSector => translate('select_sector');
  String get location => translate('location');
  String get locationIcon => translate('location_icon');
  String get selectLocation => translate('select_location');
  String get skills => translate('skills');
  String get skillsIcon => translate('skills_icon');
  String get selectSkills => translate('select_skills');
  String get findInternships => translate('find_internships');
  String get selectAtLeastOneSkill => translate('select_at_least_one_skill');
  String get pleaseSelectOption => translate('please_select_option');
  String get searchingRecommendations => translate('searching_recommendations');
  String get recommendationsForYou => translate('recommendations_for_you');
  String get noInternshipsFound => translate('no_internships_found');
  String get tryDifferentOptions => translate('try_different_options');
  String get topInternships => translate('top_internships');
  String get internshipsFound => translate('internships_found');
  String get match => translate('match');
  String get requiredSkills => translate('required_skills');
  String get applyNow => translate('apply_now');
  String get details => translate('details');
  String get apply => translate('apply');
  String get applyFor => translate('apply_for');
  String get cancel => translate('cancel');
  String get yes => translate('yes');
  String get applicationSubmitted => translate('application_submitted');
  String get close => translate('close');
  String get scoreBreakdown => translate('score_breakdown');
  String get language => translate('language');
  String get changeLanguage => translate('change_language');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
