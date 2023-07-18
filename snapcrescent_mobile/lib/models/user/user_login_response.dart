
class UserLoginResponse {
  String? token;

  UserLoginResponse(
      {
      this.token
      });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    
    return UserLoginResponse(
      token: json['token']
    );
  }
}