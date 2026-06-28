class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+?255|0)\d{9}$').hasMatch(clean)) {
      return 'Nambari ya simu si sahihi (mfano: 0712345678)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Barua pepe si sahihi (mfano: jina@barua.com)';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName inahitajika';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Jina linahitajika';
    if (value.trim().length < 2) return 'Jina lazima liwe na herufi 2 au zaidi';
    return null;
  }
}

class AppStrings {
  static const String appTitle = 'Mfumo wa Viongozi';
  static const String district = 'Wilaya';
  static const String division = 'Tarafa';
  static const String ward = 'Kata';
  static const String leaders = 'Viongozi';
  static const String addDivision = 'Ongeza Tarafa';
  static const String addWard = 'Ongeza Kata';
  static const String edit = 'Hariri';
  static const String delete = 'Futa';
  static const String save = 'Hifadhi';
  static const String search = 'Tafuta';
  static const String reports = 'Ripoti';
  static const String exportExcel = 'Hamisha Excel';
  static const String backup = 'Nakala Kumbukumbu';
  static const String restore = 'Rejesha Taarifa';
  static const String cancel = 'Ghairi';
  static const String confirm = 'Thibitisha';
  static const String dashboard = 'Dashibodi';
  static const String login = 'Ingia';
  static const String logout = 'Toka';
  static const String districtName = 'WILAYA YA MULEBA';
  static const String deleteConfirm = 'Una uhakika wa kufuta?';
  static const String deleteWarning = 'Hatua hii haiwezi kutenduliwa.';
  static const String savedSuccess = 'Imehifadhiwa kwa mafanikio!';
  static const String deletedSuccess = 'Imefutwa kwa mafanikio!';
  static const String errorOccurred = 'Hitilafu imetokea. Jaribu tena.';
  static const String backupSuccess = 'Nakala imehifadhiwa kwa mafanikio!';
  static const String restoreSuccess = 'Taarifa imerejeshwa kwa mafanikio!';
  static const String exportSuccess = 'Faili la Excel limehifadhiwa!';
  static const String invalidCredentials = 'Jina la mtumiaji au nywila si sahihi';
  static const String passwordChanged = 'Nywila imebadilishwa kwa mafanikio!';
  static const String noResults = 'Hakuna matokeo yaliyopatikana';
  static const String fullName = 'Jina Kamili';
  static const String phoneNumber = 'Nambari ya Simu';
  static const String emailAddress = 'Barua Pepe';
  static const String photo = 'Picha';
  static const String addPhoto = 'Ongeza Picha';
  static const String changePhoto = 'Badilisha Picha';
  static const String username = 'Jina la Mtumiaji';
  static const String password = 'Nywila';
  static const String newPassword = 'Nywila Mpya';
  static const String confirmPassword = 'Thibitisha Nywila';
  static const String oldPassword = 'Nywila ya Zamani';
  static const String divisionName = 'Jina la Tarafa';
  static const String wardName = 'Jina la Kata';
  static const String description = 'Maelezo (Hiari)';
  static const String workStation = 'Kituo cha Kazi';
  static const String forgotPassword = 'Nimesahau Nywila';
  static const String otpSent = 'Nambari ya uthibitisho imetumwa kwa barua pepe';
  static const String otpInvalid = 'Nambari ya uthibitisho si sahihi';
  static const String otpExpired = 'Nambari ya uthibitisho imeisha muda';
  static const String resetPasswordSuccess = 'Nywila imerejeshwa kwa mafanikio!';
}
