import '../constants.dart';

class WCPeerMeta extends Jsonable {
  String name;
  String url;
  String description;
  List<String> icons;

  WCPeerMeta({this.description, this.url, this.icons, this.name});

  WCPeerMeta.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    url = json['url'];
    icons = json['icons'].cast<String>();
    name = json['name'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    data['url'] = url;
    data['icons'] = icons ?? [];
    data['name'] = name;
    return data;
  }
}
