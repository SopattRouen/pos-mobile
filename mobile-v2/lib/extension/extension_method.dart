
// ignore_for_file: curly_braces_in_flow_control_structures 
import 'package:intl/intl.dart' as format; 

final dollarFormat = format.NumberFormat("#,##0.00", "en_US");
final numberFormat = format.NumberFormat("#,###", "en_US");
final percentFormat = format.NumberFormat.percentPattern('en');
final khmerFormat = format.NumberFormat("###,### ####", "en_US");

var engKhMonth = [
  {
    "en": "January",
    "kh": "មករា",
  },
  {
    "en": "February",
    "kh": "កុម្ភៈ",
  },
  {
    "en": "March",
    "kh": "មិនា",
  },
  {
    "en": "April",
    "kh": "មេសា",
  },
  {
    "en": "May",
    "kh": "ឧសភា",
  },
  {
    "en": "June",
    "kh": "មិថុនា",
  },
  {
    "en": "July",
    "kh": "កក្កដា",
  },
  {
    "en": "August",
    "kh": "សីហា",
  },
  {
    "en": "September",
    "kh": "កញ្ញា",
  },
  {
    "en": "October",
    "kh": "តុលា",
  },
  {
    "en": "November",
    "kh": "វិច្ឆិកា",
  },
  {
    "en": "December",
    "kh": "ធ្នូ",
  },
];

extension NumberParsing on double {
  String toDollarCurrency({symbol = true}) {
    return (symbol ? "\$ " : "") + dollarFormat.format(this);
  }

  String toKhmerCurrency({symbol = true}) {
    return  khmerFormat.format(this) + (symbol ? "៛ " : "");
  }

  String toPercentFormat() {
    return percentFormat.format(this);
  }
}

extension NumberQtyParsing on int {
  String toNumberFormat() {
    return numberFormat.format(this);
  }
}

extension GetMonth on String {
  int getMonthNo() {
    for (int i = 0; i < engKhMonth.length; i++) {
      if (engKhMonth[i].containsValue(this)) {
        return (i + 1);
      }
    }
    return 0;
  }

  bool isNumeric() {
    try {
      var data = double.parse(this);
      if (data < 0 || data > 0) {
        return true;
      } else
        return false;
    } on FormatException {
      return false;
    }
  }
}

extension DateParsing on String {
  DateTime getDateByMonth() {
    return DateTime.parse(
        "0000-${getMonthNo().toString().padLeft(2, '0')}-01");
  }

  String getKhmerMonth() {
    for (int i = 0; i < engKhMonth.length; i++) {
      if (engKhMonth[i].containsValue(this)) {
        return engKhMonth[i].values.toList()[1].toString();
      }
    }
    return "";
  }

  String toDateDMY() {
    return format.DateFormat('dd/MM/yyyy').format(
      DateTime.parse(this),
    );
  }

  String toDateStandardMPWT() {
    return format.DateFormat('yyyy-MM-dd HH:mm:ss').format(
      DateTime.parse(this),
    );
  }

  String toDateDividerStandardMPWT() {
    return format.DateFormat('yyyy-MM-dd | HH:mm:ss')
        .format(DateTime.parse(this));
  }

  String toDateYYYYMMDD() {
    return format.DateFormat('yyyy-MM-dd').format(
      DateTime.parse(this),
    );
  }

  String toDateYYYYMMDDNoDash() {
    return format.DateFormat('yyyyMMdd').format(
      DateTime.parse(this),
    );
  }

  String toDateYYYYMM() {
    return format.DateFormat('yyyy-MM').format(
      DateTime.parse(this),
    );
  }

  String toDateYYYY() {
    return format.DateFormat('yyyy').format(
      DateTime.parse(this),
    );
  } 
}

extension DateCustomFormat on DateTime {
  String toYYYYMM() {
    return format.DateFormat('yyyy-MM').format(this);
  }

  String toYYYYMMDD() {
    return format.DateFormat('yyyy-MM-dd').format(this);
  }

  String toStandardMPWT() {
    return format.DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  String toYYYYMMDDNoDash() {
    return format.DateFormat('yyyyMMdd').format(this);
  }

  // String toDateKhmerMonthYear() {
  //   return DateFormat('MMMM', Singleton.instance.localLanguage()).format(this) +
  //       " " +
  //       DateFormat('yyyy').format(this);
  // }

  // String toYear() {
  //   return DateFormat('yyyy').format(this);
  // }
  
}

