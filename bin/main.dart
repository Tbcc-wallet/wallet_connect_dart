import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:wallet_connect/src/WCEncryptor.dart';
import 'package:wallet_connect/src/WCInteractor.dart';
import 'package:wallet_connect/src/WCSession.dart';
import 'package:wallet_connect/src/constants.dart';
import 'package:wallet_connect/src/models/WCSocetMessage.dart';
import 'package:wallet_connect/src/models/JSONRPCModels.dart';
import 'package:wallet_connect/src/models/WCPeerMeta.dart';
import 'package:web3dart/web3dart.dart';

import 'package:wallet_connect/src/models/WCSessionModels.dart';

main(List<String> args) async {
  var str = 'wc:219a6dea-7f22-471b-b452-a9ce5984dbb9@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=79075affd77a26eb32f5cec18876b46247b6d6f9d859ceb11915d2a3483d52de';
  var privateKey = EthPrivateKey.fromHex('ba005cd605d8a02e3d5dfd04234cef3a3ee4f76bfbad2722d1fb5af8e12e6764');
  
  var addr = await privateKey.extractAddress();
  var defaultChainId = 1;
  var session = WCSession.fromString(str);
  var interactor = WCInteractor(
      session: session,
      clientMeta: WCPeerMeta()
        ..name = 'WalletConnect SDK'
        ..url = 'https://github.com/TrustWallet/wallet-connect-swift'
        ..icons = []
        ..description = '',
      clientId: Uuid().v4());
  interactor..onSessionRequest = (_, __) {
    interactor.approveSession(defaultChainId, [addr.hex]);
  }..onEthSign = (id, params){
    

  };


  await interactor.connect();

  await Future.delayed(Duration(seconds: 20));
  return;

  // var iv = '7565e12b735feb336810abe823b72aad';
  // var result = WCApproveSessionResponse(
  //   accounts: ['0xD432C5910f626dD21bE918D782facB38BDaE3296'],
  //   approved: true,
  //   chainId: 1,
  //   peerId: 'b09ea1b5-9268-4692-9d2b-e94339e74e4e',
  //   peerMeta: WCPeerMeta(
  //     description: '',
  //     icons: [],
  //     name: 'WalletConnect SDK',
  //     url: 'https://github.com/TrustWallet/wallet-connect-swift',
  //   ),
  // );
  // var jsonrpc = JSONRPCResponse(
  //   id: 1601112093073921,
  //   result: result,
  // );

  // var wcwsmsg = WCSocketMessage(
  //   messageType: MessageType.pub,
  //   topic: '069bb8d4-95dc-4c4f-a838-0e7707a14184',
  //   payload: json.encode(WCEncryptor().encrypt(json.encode(jsonrpc), '4cac7c2a2c2f4e178ecef60ae2a3eedd82739c24c4f1b21710faa583cb7178e8')),
  // );

  // print(json.encode(wcwsmsg));
  // // '22113309f1e8ddd47cad35684a0344f689643f2989801bd4d20cdfc56b978842146567ff86705b5b6c5ceadb61e57f8dae076183aefce5b3fbe05e35a814e78c67c79d1e9886767eedb510b1a79f8236f92cf6a26f3d2776dc4b71c14d70b40e1a244c90986a3701ccb76024c2c2e7410332a577be12d646f8d272f99c34980b139e876446e245f30c70f3819f7ed44b6638d0f48b2a89bcb49f2fd494e95b8639eb21bf8a05158126e71eab917cfd2597daf9f145610176c7f2db6edb450d8983e86076e7d27c5d84784f7dff2027b0d440a871e7988073301bb59bec10abe5802b522ad0014340c5383dc1adf50e8150902c6b9f9d04d02af0d8352f19a8bcdb6bf44982475e2007e9bb4260caeda94fb5ed8204b2a56228d247d5abf026d376579255c9507af64cbdcaad5455ee4af5c339745e0576bce6ab141c84dc713c';
  // // '22113309f1e8ddd47cad35684a0344f689643f2989801bd4d20cdfc56b978842146567ff86705b5b6c5ceadb61e57f8d216785634335a5c7cbee1c4d491545d15b7ebc1a9949d30a215de50c5369805811832681c0ce55ab2eded5e9a46bb457e6d2def1e661901aca6b12c3cb0b9cafcc73cd038276a4a20be3840ff3fc03e21b710279304ece64aa37ae378674d0d10dfe059697db4d67d568f07996205d11730a2f075a056310df9c29274e2774fe0ed2385278f9a969b32a4ad21b1481d3055e49d31ce00e93b1f6eb3144094aed642d0bc8408f7156dcb7717f65e66bcf022f654d7704e4fd851913acb6ec20c6d3e5832083b071a574a9904cf8efb2ca219116829172aa151f8457aa8e31f2be1e53cac72f6126667f0456d2b7adba88e5487955b612e2a04608550f3ada4d82ba172066b8516c9cf746c3844c531c75';

  // var a = WCEncryptionPayload.fromJson(json.decode(
  //     '{"iv":"7565e12b735feb336810abe823b72aad","data":"22113309f1e8ddd47cad35684a0344f689643f2989801bd4d20cdfc56b978842146567ff86705b5b6c5ceadb61e57f8dae076183aefce5b3fbe05e35a814e78c67c79d1e9886767eedb510b1a79f8236f92cf6a26f3d2776dc4b71c14d70b40e1a244c90986a3701ccb76024c2c2e7410332a577be12d646f8d272f99c34980b139e876446e245f30c70f3819f7ed44b6638d0f48b2a89bcb49f2fd494e95b8639eb21bf8a05158126e71eab917cfd2597daf9f145610176c7f2db6edb450d8983e86076e7d27c5d84784f7dff2027b0d440a871e7988073301bb59bec10abe5802b522ad0014340c5383dc1adf50e8150902c6b9f9d04d02af0d8352f19a8bcdb6bf44982475e2007e9bb4260caeda94fb5ed8204b2a56228d247d5abf026d376579255c9507af64cbdcaad5455ee4af5c339745e0576bce6ab141c84dc713c","hmac":"d1be624b5d891d2e20e1e40f944445091f9d39076eaa943d79570b09a7c6d5c4"}'));

  // var decr = WCEncryptor().decrypt(a, '4cac7c2a2c2f4e178ecef60ae2a3eedd82739c24c4f1b21710faa583cb7178e8');
  // print(decr);
}

//{"payload":"{\"iv\":\"7565e12b735feb336810abe823b72aad\",\"data\":\"22113309f1e8ddd47cad35684a0344f689643f2989801bd4d20cdfc56b978842146567ff86705b5b6c5ceadb61e57f8dae076183aefce5b3fbe05e35a814e78c67c79d1e9886767eedb510b1a79f8236f92cf6a26f3d2776dc4b71c14d70b40e1a244c90986a3701ccb76024c2c2e7410332a577be12d646f8d272f99c34980b139e876446e245f30c70f3819f7ed44b6638d0f48b2a89bcb49f2fd494e95b8639eb21bf8a05158126e71eab917cfd2597daf9f145610176c7f2db6edb450d8983e86076e7d27c5d84784f7dff2027b0d440a871e7988073301bb59bec10abe5802b522ad0014340c5383dc1adf50e8150902c6b9f9d04d02af0d8352f19a8bcdb6bf44982475e2007e9bb4260caeda94fb5ed8204b2a56228d247d5abf026d376579255c9507af64cbdcaad5455ee4af5c339745e0576bce6ab141c84dc713c\",\"hmac\":\"d1be624b5d891d2e20e1e40f944445091f9d39076eaa943d79570b09a7c6d5c4\"}","topic":"069bb8d4-95dc-4c4f-a838-0e7707a14184","type":"pub"}
