import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { CanActivate } from '@angular/router';
import { ActivatedRouteSnapshot } from '@angular/router';
import { RouterStateSnapshot } from '@angular/router';
import { SessionService } from './session-service';


@Injectable({
  providedIn: "root"
})
export class AuthorizationGuard {

  constructor(private sessionService: SessionService) {

  }

};

@Injectable({
  providedIn: "root"
})
export class AuthenticationGuard implements CanActivate {

  constructor(private router: Router, private sessionService: SessionService, private authorizationGuard: AuthorizationGuard) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {

    let authenticated: boolean = false;
    let authorized: boolean = false;

    if (this.sessionService.getAuthInfo()) {
      authenticated = true;
      authorized = true;
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

};
