import 'dart:convert';

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'account_number': accountNumber,
        'chain_id': chainId,
        'data': data,
        'memo': memo,
        'msgs': msgsJson,
        'sequence': sequence,
        'source': source,
      };
}

class WCBinanceSignResult {
  String signature;
  String publicKey;

  WCBinanceSignResult({this.signature, this.publicKey});

  String toJson() => json.encode(<String, dynamic>{
        'signature': signature,
        'publicKey': publicKey,
      });
}
