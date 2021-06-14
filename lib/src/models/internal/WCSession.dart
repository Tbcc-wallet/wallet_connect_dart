import 'WCPeerMeta.dart';

class WCSessionRequestParam {
  String? peerId;
  WCPeerMeta? peerMeta;
  int? chainId;
  WCSessionRequestParam.fromJson(Map<String, dynamic> json) {
    peerId = json['peerId'];
    chainId = json['chainId'];
    peerMeta = json['peerMeta'] != null ? WCPeerMeta.fromJson(json['peerMeta']) : null;
  }
}

class WCSessionUpdateParam {
  bool? approved;
  int? chainId;
  List<String>? accounts;
  WCSessionUpdateParam.fromJson(Map<String, dynamic> json) {
    approved = json['approved'];
    chainId = json['chainId'];
    accounts = json['accounts']?.cast<String>();
  }
}

class WCApproveSessionResponse {
  bool? approved;
  int? chainId;
  List<String>? accounts;
  String? peerId;
  WCPeerMeta? peerMeta;

  WCApproveSessionResponse({
    this.approved,
    this.chainId,
    this.accounts,
    this.peerId,
    this.peerMeta,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'approved': approved,
        'chainId': chainId,
        'accounts': accounts,
        'peerId': peerId,
        'peerMeta': peerMeta?.toJson(),
      };
}
