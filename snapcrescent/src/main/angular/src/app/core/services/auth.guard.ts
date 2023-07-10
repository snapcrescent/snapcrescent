import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

import { ActivatedRouteSnapshot } from '@angular/router';
import { RouterStateSnapshot } from '@angular/router';
import { SessionService } from './session.service';
import { UserType } from 'src/app/user/user.model';


@Injectable({
  providedIn: "root"
})
export class AuthorizationGuard {

  constructor(private sessionService: SessionService) {

  }

  hasCorrectUserType(requiredUserTypes: Array<string>): boolean {

    const requiredUserType = requiredUserTypes[0];

    let hasPermission = false;

    if(requiredUserType.toLowerCase() === UserType.ADMIN.label.toLocaleLowerCase()) {
        hasPermission = this.sessionService.isAdminUser();
    } else{
        hasPermission = !this.sessionService.isAdminUser();
    }
    
    return hasPermission;
  }

};

@Injectable({
  providedIn: "root"
})
export class AuthenticationGuard  {

  constructor(private router: Router, private sessionService: SessionService, private authorizationGuard: AuthorizationGuard) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {

    let authenticated: boolean = false;
    let authorized: boolean = false;

    if (this.sessionService.getAuthInfo()) {
      authenticated = true;

      if (this.checkUserType(route)) {
        authorized = true;
      }
    }

    if (authenticated == false) {
      this.router.navigate(['/login']);
      return false;
    }
    else if (authorized == false) {
      this.router.navigate(['/authorization-error']);
      return false;
    }
    else {
      return true;
    }

  }

  checkUserType(route: ActivatedRouteSnapshot): boolean {
    let accessAllowed: boolean = false;

    let requiredUserTypesArray = route.data["userType"] as Array<string>;

    if (requiredUserTypesArray != null) {
      let requiredUserTypes = requiredUserTypesArray[0].split(',');
      accessAllowed = this.authorizationGuard.hasCorrectUserType(requiredUserTypes);
    }
    else {
      accessAllowed = true;
    }

    return accessAllowed;
  }

};
