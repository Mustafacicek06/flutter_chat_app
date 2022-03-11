class MyExceptions {
  static String showError(String errorCode) {
    switch (errorCode) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return 'Bu mail adresi zaten kullanımda.';

      default:
        return 'Bir hata Olustu : MyExceptions';
    }
  }
}
