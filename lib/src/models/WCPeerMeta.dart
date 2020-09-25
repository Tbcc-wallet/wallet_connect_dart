class WCPeerMeta {
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['url'] = this.url;
    data['icons'] = this.icons;
    data['name'] = this.name;
    return data;
  }
}
