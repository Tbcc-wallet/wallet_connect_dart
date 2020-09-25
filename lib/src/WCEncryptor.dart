import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:wallet_connect/src/models/WCSocetMessage.dart';

class WCEncryptor {
  static final _instance = WCEncryptor._();
  Random _sGen;
  SecureRandom _secureRandom;

  WCEncryptor._() {
    if (_secureRandom == null) {
      _sGen = Random.secure();
      _secureRandom = SecureRandom('Fortuna')..seed(KeyParameter(Uint8List.fromList(List.generate(32, (n) => _sGen.nextInt(255)))));
    }
  }

  factory WCEncryptor() {
    return _instance;
  }

  WCEncryptionPayload encrypt(String data, String key) {
    var iv = _secureRandom.nextBytes(16);
    var cipher = StreamCipher('AES/CBC');
    cipher
      ..reset()
      ..init(
        true,
        ParametersWithIV(
          //KeyParameter(hex.decode(key)),
          KeyParameter(utf8.encode(key)),
          iv,
        ),
      );
    var encrypted = cipher.process(utf8.encode(data));

    var hmac = computeHMAC(encrypted, iv, utf8.encode(key));
    return WCEncryptionPayload(data: hex.encode(encrypted), iv: hex.encode(iv), hmac: hmac);
  }

  String decrypt(WCEncryptionPayload payload, String key) {
    var ivBytes = hex.decode(payload.iv);
    print(payload.data);

    var dataBytes = hex.decode(payload.data);
    print(dataBytes.length);
    var keyBytes = hex.decode(key);
    var computedHMAC = computeHMAC(dataBytes, ivBytes, keyBytes);
    print(computedHMAC);
    print(payload.hmac);
    if (computedHMAC != payload.hmac) {
      throw ArgumentError('invalid HMAC.');
    }

    var cipher = CBCBlockCipher(AESFastEngine());
    cipher
      ..reset()
      ..init(
        false,
        ParametersWithIV(
          //KeyParameter(hex.decode(key)),
          KeyParameter(keyBytes),
          ivBytes,
        ),
      );
    final destination = Uint8List(dataBytes.length); // allocate space

    var offset = 0;
    while (offset < dataBytes.length) {
      offset += cipher.processBlock(dataBytes, offset, destination, offset);
    }
    var str = utf8.decode(destination);
    str = str.substring(0, str.lastIndexOf('}') + 1);
    return str;
  }

  String computeHMAC(Uint8List payload, Uint8List iv, Uint8List key) {
    var data = Uint8List(payload.length + iv.length)..setRange(0, payload.length, payload)..setRange(payload.length, payload.length + iv.length, iv);
    var hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
    return hex.encode(hmac.process(data));
  }
}
