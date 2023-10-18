
class AccountInfo {

  String serverUrl;
  String username;
  String password;

  AccountInfo(
      this.serverUrl,
      this.username,
      this.password
      );

  Map<String, dynamic> toJson() {
    return {
      "serverUrl" : serverUrl,
      "username" : username,
      "password" : password
    };
  }

  
}