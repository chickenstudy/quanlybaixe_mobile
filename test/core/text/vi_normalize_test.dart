import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/text/vi_normalize.dart';

void main() {
  group('viFold', () {
    test('gấp dấu họ tên tiếng Việt', () {
      expect(viFold('Nguyễn Văn Đức'), 'nguyen van duc');
      expect(viFold('Trần Thị Hồng Ánh'), 'tran thi hong anh');
      expect(viFold('Lê Quốc Cường'), 'le quoc cuong');
    });

    test('chữ đ và Đ về d — trường hợp Unicode NFD sẽ bỏ sót', () {
      expect(viFold('Đặng'), 'dang');
      expect(viFold('đường'), 'duong');
      expect(viFold('ĐỖ ĐÌNH ĐỨC'), 'do dinh duc');
    });

    test('phủ hết các nguyên âm có dấu', () {
      expect(viFold('àáạảãâầấậẩẫăằắặẳẵ'), 'a' * 17);
      expect(viFold('èéẹẻẽêềếệểễ'), 'e' * 11);
      expect(viFold('òóọỏõôồốộổỗơờớợởỡ'), 'o' * 17);
      expect(viFold('ùúụủũưừứựửữ'), 'u' * 11);
      expect(viFold('ìíịỉĩ'), 'i' * 5);
      expect(viFold('ỳýỵỷỹ'), 'y' * 5);
    });

    test('gom khoảng trắng thừa và cắt hai đầu', () {
      expect(viFold('  Nguyễn   Văn  An  '), 'nguyen van an');
    });

    test('tìm "nguyen" khớp được "Nguyễn" — mục đích của cả hàm này', () {
      expect(viFold('Nguyễn Thị Mai').contains('nguyen'), isTrue);
      expect(viFold('Nguyễn Thị Mai').contains('thi mai'), isTrue);
    });

    test('chuỗi không dấu giữ nguyên', () {
      expect(viFold('Honda Wave'), 'honda wave');
    });
  });

  group('normalizePlate', () {
    test('bỏ mọi dấu phân cách, viết hoa', () {
      expect(normalizePlate('59-A1 234.56'), '59A123456');
      expect(normalizePlate('59a1-234.56'), '59A123456');
      expect(normalizePlate('59A123456'), '59A123456');
    });

    test('các cách gõ khác nhau của cùng một biển số cho ra một kết quả', () {
      const variants = ['30F-123.45', '30F 123 45', '30f12345', '30-F1.2345'];
      final normalized = variants.map(normalizePlate).toSet();
      expect(normalized.length, 1, reason: 'phải quy về đúng một dạng chuẩn');
    });

    test('biển số xe máy và ô tô', () {
      expect(normalizePlate('29-B1 567.89'), '29B156789');
      expect(normalizePlate('51G-999.99'), '51G99999');
    });
  });

  group('normalizePhone', () {
    test('bỏ khoảng trắng và dấu phân cách', () {
      expect(normalizePhone('0912 345 678'), '0912345678');
      expect(normalizePhone('0912.345.678'), '0912345678');
      expect(normalizePhone('(091) 234-5678'), '0912345678');
    });

    test('giữ dấu cộng của số quốc tế', () {
      expect(normalizePhone('+84 912 345 678'), '+84912345678');
    });

    test('dấu cộng ở giữa không được giữ', () {
      expect(normalizePhone('091+2345678'), '0912345678');
    });

    test('chuỗi rỗng', () {
      expect(normalizePhone(''), '');
      expect(normalizePhone('   '), '');
    });
  });
}
