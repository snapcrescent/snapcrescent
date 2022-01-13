import { Injectable} from '@angular/core';
import { ReplaySubject } from 'rxjs';

@Injectable({
    providedIn: "root"
  })
export class SessionService {

  constructor() {
    this.loggedIn.next(false);
   }

  private loggedIn = new ReplaySubject<boolean>(1);
  public onloggedInStateChange = this.loggedIn.asObservable();

  private updateLoginState(value: boolean):void {
    this.loggedIn.next(value)
  };
  
  login() {
    this.updateLoginState(true);
  }

  logout() {
    this.updateLoginState(false);
  }

  

  

  

}
