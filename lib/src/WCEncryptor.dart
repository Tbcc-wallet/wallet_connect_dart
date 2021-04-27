import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:wallet_connect/src/models/internal/WCSocketMessage.dart';

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
    final keyBytes = hex.decode(key);
    final dataBytes = utf8.encode(data);
    final iv = _secureRandom.nextBytes(16);

    final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESFastEngine()));
    paddedCipher.init(
        true,
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ParametersWithIV<KeyParameter>(KeyParameter(keyBytes), iv),
          null,
        ));

    final encrypted = paddedCipher.process(dataBytes);
    final hmac = computeHMAC(encrypted, iv, keyBytes);

    final payload = WCEncryptionPayload(data: hex.encode(encrypted), iv: hex.encode(iv), hmac: hmac);

    return payload;
  }

  String decrypt(WCEncryptionPayload payload, String key) {
    final ivBytes = hex.decode(payload.iv);

    final dataBytes = hex.decode(payload.data);
    final keyBytes = hex.decode(key);
    final computedHMAC = computeHMAC(dataBytes, ivBytes, keyBytes);

    if (computedHMAC != payload.hmac) {
      throw ArgumentError('invalid HMAC.');
    }

    final cipher = CBCBlockCipher(AESFastEngine());
    cipher
      ..reset()
      ..init(
        false,
        ParametersWithIV(
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
    final data = Uint8List(payload.length + iv.length)..setRange(0, payload.length, payload)..setRange(payload.length, payload.length + iv.length, iv);
    final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
    return hex.encode(hmac.process(data));
  }
}
