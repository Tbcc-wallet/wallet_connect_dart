import '../constants.dart';

class WCEncryptionPayload {
  String data;
  String hmac;
  String iv;
  WCEncryptionPayload({this.data, this.hmac, this.iv});

  WCEncryptionPayload.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    hmac = json['hmac'];
    iv = json['iv'];
  }

  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    res['data'] = data;
    res['hmac'] = hmac;
    res['iv'] = iv;
    return res;
  }
}

class WCSocketMessage<T> {
  String topic;
  MessageType messageType;
  T payload;

  WCSocketMessage({this.topic, this.messageType, this.payload});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'topic': topic,
      'type': messageType.toString().split('.').sublist(1).join(),
      'payload': payload.toString(),
    };
  }
}
