/// Support for doing something awesome.
///
/// More dartdocs go here.
library zipcode_jp;

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';

export 'src/zipcode_jp_base.dart';

// TODO: Export any libraries intended for clients of this package.

/// https://www.post.japanpost.jp/zipcode/dl/readme.html
enum ZipCol {
  localGovCode, // 全国地方公共団体コード（JIS X0401、X0402）
  oldZipCode, //（旧）郵便番号（5桁）
  zipCode, // 郵便番号（7桁）
  prefNameKana, // 都道府県名
  cityNameKana, // 市区町村名
  townNameKana, // 町域名
  prefNameKanji, // 都道府県名
  cityNameKanji, // 市区町村名
  townNameKanji, // 町域名
  dupCode, // 一町域が二以上の郵便番号で表される場合の表示
  oazaHasSomeKoazas, // 小字毎に番地が起番されている町域の表示
  cityBlock, // 丁目を有する町域の場合の表示
  oneZipForTwoTowns, // 一つの郵便番号で二以上の町域を表す場合の表示
  updated, // 更新の表示
  updateReason // 変更理由
}

///
class ConvToAddressByJpZip {
  // zip code file for each prefs
  final pref = [
    '01HOKKAI.CSV',
    '02AOMORI.CSV',
    '03IWATE.CSV',
    '04MIYAGI.CSV',
    '05AKITA.CSV',
    '06YAMAGA.CSV',
    '07FUKUSH.CSV',
    '08IBARAK.CSV',
    '09TOCHIG.CSV',
    '10GUMMA.CSV',
    '11SAITAM.CSV',
    '12CHIBA.CSV',
    '13TOKYO.CSV',
    '14KANAGA.CSV',
    '15NIIGAT.CSV',
    '16TOYAMA.CSV',
    '17ISHIKA.CSV',
    '18FUKUI.CSV',
    '19YAMANA.CSV',
    '20NAGANO.CSV',
    '21GIFU.CSV',
    '22SHIZUO.CSV',
    '23AICHI.CSV',
    '24MIE.CSV',
    '25SHIGA.CSV',
    '26KYOUTO.CSV',
    '27OSAKA.CSV',
    '28HYOGO.CSV',
    '29NARA.CSV',
    '30WAKAYA.CSV',
    '31TOTTOR.CSV',
    '32SHIMAN.CSV',
    '33OKAYAM.CSV',
    '34HIROSH.CSV',
    '35YAMAGU.CSV',
    '36TOKUSH.CSV',
    '37KAGAWA.CSV',
    '38EHIME.CSV',
    '39KOCHI.CSV',
    '40FUKUOK.CSV',
    '41SAGA.CSV',
    '42NAGASA.CSV',
    '43KUMAMO.CSV',
    '44OITA.CSV',
    '45MIYAZA.CSV',
    '46KAGOSH.CSV',
    '47OKINAW.CSV',
  ];

  /// giving 7 digits zip code then returns address
  Future<String> getAddressByZipCode(String zipCode) async {
    var result;
    var pref;
    var zipCodeList = getDuplicatePrefCodes(zipCode);
    if (zipCodeList.isEmpty) {
      pref = getPrefCode(zipCode);
      zipCodeList.add(pref);
    }

    for (var i in zipCodeList) {
      var fileName = this.pref[i - 1];
      extractZipFile(Directory.current.path + '/csv/' + fileName + '.zip');

      var file = File(Directory.current.path + '/out/' + fileName);
      if (file == null) {
        continue;
      }
      var fields = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

      for (var col in fields) {
        if (col[ZipCol.zipCode.index] == zipCode) {
          result = col[ZipCol.prefNameKanji.index] +
              col[ZipCol.cityNameKanji.index] +
              col[ZipCol.townNameKanji.index];
          break;
        }
      }
      fields.clear();
      Directory('out/' + fileName)..deleteSync(recursive: true);
    }
    return result;
  }

  /// 引数pathのzipファイルをout以下に展開する
  void extractZipFile(String path) {
    var bytes = File(path).readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      String fileName = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        File('out/' + fileName)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('out/' + fileName)..create(recursive: true);
      }
    }
  }

  /// 郵便番号先頭2桁で判別できる県（例外あり。getDuplicatePrefCodes()も併用すべし）
  int getPrefCode(String zipCode) {
    var pref;

    if (RegExp('^(00|0[4-9])').hasMatch(zipCode)) {
      pref = 1; // 北海道
    } else if (RegExp('^03').hasMatch(zipCode)) {
      pref = 2; // 青森県
    } else if (RegExp('^02').hasMatch(zipCode)) {
      pref = 3; // 岩手県
    } else if (RegExp('^98').hasMatch(zipCode)) {
      pref = 4; // 宮城県
    } else if (RegExp('^01').hasMatch(zipCode)) {
      pref = 5; // 秋田県
    } else if (RegExp('^99').hasMatch(zipCode)) {
      pref = 6; // 山形県
    } else if (RegExp('^9[6-7]').hasMatch(zipCode)) {
      pref = 7; // 福島県
    } else if (RegExp('^3[0-1]').hasMatch(zipCode)) {
      pref = 8; // 茨城県
    } else if (RegExp('^32').hasMatch(zipCode)) {
      pref = 9; // 栃木県
    } else if (RegExp('^37').hasMatch(zipCode)) {
      pref = 10; // 群馬県
    } else if (RegExp('^3[3-6]').hasMatch(zipCode)) {
      pref = 11; // 埼玉県
    } else if (RegExp('^2[6-9]').hasMatch(zipCode)) {
      pref = 12; // 千葉県
    } else if (RegExp('^(1[0-9]|20)').hasMatch(zipCode)) {
      pref = 13; // 東京都
    } else if (RegExp('^2[1-5]').hasMatch(zipCode)) {
      pref = 14; // 神奈川県
    } else if (RegExp('^9[4-5]').hasMatch(zipCode)) {
      pref = 15; // 新潟県
    } else if (RegExp('^93').hasMatch(zipCode)) {
      pref = 16; // 富山県
    } else if (RegExp('^92').hasMatch(zipCode)) {
      pref = 17; // 石川県
    } else if (RegExp('^91').hasMatch(zipCode)) {
      pref = 18; // 福井県
    } else if (RegExp('^40').hasMatch(zipCode)) {
      pref = 19; // 山梨県
    } else if (RegExp('^3[8-9]').hasMatch(zipCode)) {
      pref = 20; // 長野県
    } else if (RegExp('^50').hasMatch(zipCode)) {
      pref = 21; // 岐阜県
    } else if (RegExp('^4[1-3]').hasMatch(zipCode)) {
      pref = 22; // 静岡県
    } else if (RegExp('^4[4-9]').hasMatch(zipCode)) {
      pref = 23; // 愛知県
    } else if (RegExp('^51').hasMatch(zipCode)) {
      pref = 24; // 三重県
    } else if (RegExp('^52').hasMatch(zipCode)) {
      pref = 25; // 滋賀県
    } else if (RegExp('^6[0-2]').hasMatch(zipCode)) {
      pref = 26; // 京都府
    } else if (RegExp('^5[3-9]').hasMatch(zipCode)) {
      pref = 27; // 大阪府
    } else if (RegExp('^6[5-7]').hasMatch(zipCode)) {
      pref = 28; // 兵庫県
    } else if (RegExp('^63').hasMatch(zipCode)) {
      pref = 29; // 奈良県
    } else if (RegExp('^64').hasMatch(zipCode)) {
      pref = 30; // 和歌山県
    } else if (RegExp('^68').hasMatch(zipCode)) {
      pref = 31; // 鳥取県
    } else if (RegExp('^69').hasMatch(zipCode)) {
      pref = 32; // 島根県
    } else if (RegExp('^7[0-1]').hasMatch(zipCode)) {
      pref = 33; // 岡山県
    } else if (RegExp('^7[2-3]').hasMatch(zipCode)) {
      pref = 34; // 広島県
    } else if (RegExp('^7[4-5]').hasMatch(zipCode)) {
      pref = 35; // 山口県
    } else if (RegExp('^77').hasMatch(zipCode)) {
      pref = 36; // 徳島県
    } else if (RegExp('^76').hasMatch(zipCode)) {
      pref = 37; // 香川県
    } else if (RegExp('^79').hasMatch(zipCode)) {
      pref = 38; // 愛媛県
    } else if (RegExp('^78').hasMatch(zipCode)) {
      pref = 39; // 高知県
    } else if (RegExp('^8[0-3]').hasMatch(zipCode)) {
      pref = 40; // 福岡県
    } else if (RegExp('^84').hasMatch(zipCode)) {
      pref = 41; // 佐賀県
    } else if (RegExp('^85').hasMatch(zipCode)) {
      pref = 42; // 長崎県
    } else if (RegExp('^86').hasMatch(zipCode)) {
      pref = 43; // 熊本県
    } else if (RegExp('^87').hasMatch(zipCode)) {
      pref = 44; // 大分県
    } else if (RegExp('^88').hasMatch(zipCode)) {
      pref = 45; // 宮崎県
    } else if (RegExp('^89').hasMatch(zipCode)) {
      pref = 46; // 鹿児島県
    } else if (RegExp('^90').hasMatch(zipCode)) {
      pref = 47; // 沖縄県
    }
    return pref;
  }

  /// 郵便番号の先頭2桁で複数の県にまたがる場合
  List<int> getDuplicatePrefCodes(String zipCode) {
    var prefs = List<int>();
    if (RegExp('^01').hasMatch(zipCode)) {
      prefs = [2, 5]; // 青森県、秋田県
    } else if (RegExp('^31').hasMatch(zipCode)) {
      prefs = [8, 9]; // 茨城県、栃木県
    } else if (RegExp('^34').hasMatch(zipCode)) {
      prefs = [9, 11]; // 栃木県、埼玉県
    } else if (RegExp('^38').hasMatch(zipCode)) {
      prefs = [15, 10, 11]; // 新潟県、群馬県、埼玉県
    } else if (RegExp('^43').hasMatch(zipCode)) {
      prefs = [23, 22]; // 愛知県、静岡県
    } else if (RegExp('^49').hasMatch(zipCode)) {
      prefs = [23, 24]; // 愛知県、三重県
    } else if (RegExp('^52').hasMatch(zipCode)) {
      prefs = [25, 26]; // 滋賀県、京都府
    } else if (RegExp('^56').hasMatch(zipCode)) {
      prefs = [27, 29]; // 大阪府、奈良県
    } else if (RegExp('^64').hasMatch(zipCode)) {
      prefs = [24, 29, 30]; // 三重県、奈良県、和歌山県
    } else if (RegExp('^68').hasMatch(zipCode)) {
      prefs = [32, 31]; // 島根県、鳥取県
    } else if (RegExp('^81').hasMatch(zipCode)) {
      prefs = [40, 42]; // 福岡県、長崎県
    } else if (RegExp('^83').hasMatch(zipCode)) {
      prefs = [40, 44]; // 福岡県、大分県
    } else if (RegExp('^84').hasMatch(zipCode)) {
      prefs = [41, 42]; // 佐賀県、長崎県
    } else if (RegExp('^87').hasMatch(zipCode)) {
      prefs = [40, 44]; // 福岡県、大分県
    } else if (RegExp('^92').hasMatch(zipCode)) {
      prefs = [17, 18]; // 石川県、福井県
    } else if (RegExp('^93').hasMatch(zipCode)) {
      prefs = [16, 17]; // 富山県、石川県
    } else if (RegExp('^94').hasMatch(zipCode)) {
      prefs = [15, 20]; // 新潟県、長野県
    }
    return prefs;
  }
}
