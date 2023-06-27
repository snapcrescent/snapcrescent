import { Injectable} from '@angular/core';
import { UserLoginResponse } from 'src/app/login/login.model';
import { StorageService } from './storage.service';

@Injectable({
    providedIn: "root"
  })
export class SessionService extends StorageService{

  constructor(
  ) {
    super();
   }

  login(response: UserLoginResponse) {
    this.setItem('authInfo', JSON.stringify(response));
  }

  logout() {
    this.removeAll();
  }

  getAuthInfo():UserLoginResponse|null {
    let authInfoString :string = this.getItem('authInfo')!;

    if(authInfoString) {
      return JSON.parse(authInfoString);
    } else{
      return null;
    }
  }
}