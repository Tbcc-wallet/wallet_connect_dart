import 'dart:convert' as conv;

import 'package:wallet_connect/src/constants.dart';

class WCBinanceSign {
  String accountNumber;
  String chainId;
  dynamic data;
  String memo;
  List<dynamic> msgsJson;

  /// need to provide before toJsonString
  String sequence;
  String source = '1';

  WCBinanceSign.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    chainId = json['chain_id'];
    data = json['data'];
    memo = json['memo'];
    msgsJson = json['msgs'];
  }

  String toJsonString() {
    return conv.json.encode({
      'account_number': accountNumber,
      'chain_id': chainId,
      'data': data,
      'memo': memo,
      'msgs': msgsJson,
      'sequence': sequence,
      'source': source,
    });
  }
}

class WCBinanceSignResult extends Jsonable {
  String signature;
  String publicKey;

  WCBinanceSignResult({this.signature, this.publicKey});

  @override
  String toJson() {
    return conv.json.encode({
      'signature': signature,
      'publicKey': publicKey,
    });
  }
}
