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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'description': description,
        'url': url,
        'icons': icons ?? [],
        'name': name,
      };
}
