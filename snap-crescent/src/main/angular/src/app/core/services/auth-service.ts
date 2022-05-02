import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { UserLoginRequest } from '../models/user-login-request';

@Injectable({
    providedIn: "root"
  })
export class AuthService {

  constructor(private httpClient: HttpClient) {
    
   }

  login(userLoginRequest:UserLoginRequest) {
    return this.httpClient.post("/login",userLoginRequest);
  }

  logout() {
    return this.httpClient.post("/logout",{});
  }

  

  

  

}
