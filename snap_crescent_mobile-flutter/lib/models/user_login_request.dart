
class UserLoginRequest {

  String? username;
  String? password;

  UserLoginRequest(
      {
      this.username,
      this.password
      });

  Map<String, dynamic> toJson() {
    return {
      "username" : username,
      "password" : password
    };
  }

  
}