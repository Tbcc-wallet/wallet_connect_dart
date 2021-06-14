class WCSession {
  String? topic;
  String? version;
  String? bridgeUrl;
  late String key;
  WCSession.fromString(String str) {
    if (!str.startsWith('wc:')) throw 'invalid string';
    str = str.replaceAll('wc:', '');
    str = str.replaceAll('https%3A%2F%2F', 'wss://');
    var split = str.split('@');
    topic = split.first;
    split = split[1].split('?');
    version = split.first;
    split = split[1].split('bridge=')[1].split('&key=');
    bridgeUrl = split.first;
    key = split[1];
  }
}
