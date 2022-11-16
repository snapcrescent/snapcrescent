import { Injectable} from '@angular/core';
import { ReplaySubject } from 'rxjs';
import { UserLoginResponse } from 'src/app/login/login.model';

@Injectable({
    providedIn: "root"
  })
export class SessionService {

  constructor() {
    
   }

  private loggedIn = new ReplaySubject<Boolean>(1);
  public onLoggedInStateChange = this.loggedIn.asObservable();

  private updateLoginState(value: Boolean):void {
    this.loggedIn.next(value)
  };

  private setLocalStorageValue(loggedIn: Boolean,authInfo?: UserLoginResponse ) {
    localStorage.setItem('loggedIn', loggedIn.toString());

    if(authInfo) {
      localStorage.setItem('authInfo', JSON.stringify(authInfo));
    } else{
      localStorage.removeItem('authInfo');
    }
  }
  
  login(response: UserLoginResponse) {
    this.updateLoginState(true);
    this.setLocalStorageValue(true,response);
  }

  logout() {
    this.updateLoginState(false);
    this.setLocalStorageValue(false);
  }

  getLoginState() {
    let loggedIn = localStorage.getItem('loggedIn');

    if(loggedIn && loggedIn === 'true') {
      this.updateLoginState(true);
    } else{
      this.updateLoginState(false);
    }
  }

  getAuthInfo():UserLoginResponse|null {
    let authInfoString :string = localStorage.getItem('authInfo')!;

    if(authInfoString) {
      return JSON.parse(authInfoString);
    } else{
      return null;
    }
  }
  

  isAuthenticated() {
    return this.getAuthInfo() !== null;
  }

  

  

}
