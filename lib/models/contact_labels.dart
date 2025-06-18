enum PhoneLabel { mobile, home, work, pager, other, custom }

extension PhoneLabelX on PhoneLabel {
  String get label {
    switch (this) {
      case PhoneLabel.mobile:
        return 'mobile';
      case PhoneLabel.home:
        return 'home';
      case PhoneLabel.work:
        return 'work';
      case PhoneLabel.pager:
        return 'pager';
      case PhoneLabel.other:
        return 'other';
      case PhoneLabel.custom:
        return 'custom';
    }
  }

  static PhoneLabel fromString(String? label) {
    switch (label) {
      case 'mobile':
        return PhoneLabel.mobile;
      case 'home':
        return PhoneLabel.home;
      case 'work':
        return PhoneLabel.work;
      case 'pager':
        return PhoneLabel.pager;
      case 'other':
        return PhoneLabel.other;
      case 'custom':
        return PhoneLabel.custom;
      default:
        return PhoneLabel.other;
    }
  }
}

enum EmailLabel { home, work, other, custom }

extension EmailLabelX on EmailLabel {
  String get label {
    switch (this) {
      case EmailLabel.home:
        return 'home';
      case EmailLabel.work:
        return 'work';
      case EmailLabel.other:
        return 'other';
      case EmailLabel.custom:
        return 'custom';
    }
  }

  static EmailLabel fromString(String? label) {
    switch (label) {
      case 'home':
        return EmailLabel.home;
      case 'work':
        return EmailLabel.work;
      case 'other':
        return EmailLabel.other;
      case 'custom':
        return EmailLabel.custom;
      default:
        return EmailLabel.other;
    }
  }
}

enum AddressLabel { home, work, other, custom }

extension AddressLabelX on AddressLabel {
  String get label {
    switch (this) {
      case AddressLabel.home:
        return 'home';
      case AddressLabel.work:
        return 'work';
      case AddressLabel.other:
        return 'other';
      case AddressLabel.custom:
        return 'custom';
    }
  }

  static AddressLabel fromString(String? label) {
    switch (label) {
      case 'home':
        return AddressLabel.home;
      case 'work':
        return AddressLabel.work;
      case 'other':
        return AddressLabel.other;
      case 'custom':
        return AddressLabel.custom;
      default:
        return AddressLabel.other;
    }
  }
}
