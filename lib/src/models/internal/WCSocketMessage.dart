import '../../constants.dart';

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data,
        'hmac': hmac,
        'iv': iv,
      };
}

class WCSocketMessage<T> {
  String topic;
  MessageType messageType;
  T payload;

  WCSocketMessage({this.topic, this.messageType, this.payload});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'topic': topic,
        'type': '$messageType'.split('.').sublist(1).join(),
        'payload': '$payload',
      };
}
