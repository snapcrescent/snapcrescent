import { Injectable} from '@angular/core';
import { UserLoginResponse } from 'src/app/login/login.model';
import { StorageService } from './storage.service';
import { UserType } from 'src/app/user/user.model';
import { ReplaySubject } from 'rxjs';

@Injectable({
    providedIn: "root"
  })
export class SessionService extends StorageService{

  constructor(
  ) {
    super();
   }

   private loggedIn = new ReplaySubject<Boolean>(1);
   public onLoggedInStateChange = this.loggedIn.asObservable();

  private updateLoginState(value: Boolean):void {
    this.loggedIn.next(value)
  };

  apiLogin(response: UserLoginResponse) {
    this.setItem('loggedIn', 'false');
    this.setItem('authInfo', JSON.stringify(response));
    this.updateLoginState(true);
  }

  login(response: UserLoginResponse) {
    this.setItem('loggedIn', 'true');
    this.setItem('authInfo', JSON.stringify(response));
    this.updateLoginState(true);
  }

  logout() {
    this.removeAll();
    this.updateLoginState(false);
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
    let authInfoString :string = this.getItem('authInfo')!;

    if(authInfoString) {
      return JSON.parse(authInfoString);
    } else{
      return null;
    }
  }

  isAdminUser() {
    return this.getAuthInfo()?.user?.userType === UserType.ADMIN.id;
  }

  isUser() {
    return this.getAuthInfo()?.user?.userType === UserType.ADMIN.id;
  }

  isPublicAccessUser() {
    return this.getAuthInfo()?.user?.userType === UserType.PUBLIC_ACCESS.id;
  }
}