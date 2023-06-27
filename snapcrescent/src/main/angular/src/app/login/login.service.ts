import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { Observable } from 'rxjs';
import { UserLoginRequest } from './login.model';

@Injectable({
    providedIn: "root"
  })
export class LoginService {

  constructor(private httpClient: HttpClient) {
    
   }

  login(userLoginRequest:UserLoginRequest): Observable<any> {
    return this.httpClient.post("/login",userLoginRequest);
  }

  logout() {
    return this.httpClient.post("/logout",{});
  }

}
