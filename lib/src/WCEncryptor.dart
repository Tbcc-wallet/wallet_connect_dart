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
    var keyBytes = hex.decode(key);
    var dataBytes = utf8.encode(data);
    var iv = _secureRandom.nextBytes(16);
    //var iv = hex.decode('7565e12b735feb336810abe823b72aad');
    var cipher = CBCBlockCipher(AESFastEngine());

    cipher
      ..reset()
      ..init(
        true,
        ParametersWithIV(
          KeyParameter(keyBytes),
          iv,
        ),
      );
    var paddedData = _padIfRequired(dataBytes, cipher.blockSize);
    final encrypted = Uint8List(paddedData.length);

    var offset = 0;
    while (offset < paddedData.length) {
      offset += cipher.processBlock(paddedData, offset, encrypted, offset);
    }
    var hmac = computeHMAC(encrypted, iv, keyBytes);
    var payload = WCEncryptionPayload(data: hex.encode(encrypted), iv: hex.encode(iv), hmac: hmac);

    return payload;
  }

  Uint8List _padIfRequired(Uint8List origdata, int blockSize) {
    var result = origdata;
    var origDataSize = origdata.length;
    var remainder = origDataSize % blockSize;
    if (remainder != 0) {
      var padded_data = List<int>.from(origdata);
      padded_data.addAll(utf8.encode(('' * (blockSize - remainder))));
      result = Uint8List.fromList(padded_data);
    }
    return result;
  }

  String decrypt(WCEncryptionPayload payload, String key) {
    var ivBytes = hex.decode(payload.iv);

    var dataBytes = hex.decode(payload.data);
    var keyBytes = hex.decode(key);
    var computedHMAC = computeHMAC(dataBytes, ivBytes, keyBytes);

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
