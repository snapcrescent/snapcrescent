
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpInterceptor
} from '@angular/common/http';
import { SessionService } from '../session.service';
import { UserLoginResponse } from 'src/app/login/login.model';

@Injectable()
export class HeaderInterceptor implements HttpInterceptor {

  constructor(private sessionService: SessionService) { }

  intercept(req: HttpRequest<any>, next: HttpHandler) {

    const authInfo:UserLoginResponse = this.sessionService.getAuthInfo()!;

    let token = '';
    if (authInfo) {
      token = authInfo.token;
    }


    return next.handle(
      req.clone({
        headers: req.headers
          .append("Authorization", `Bearer ${token}`)
          .append("Access-Control-Allow-Origin", "*")
      })
    );
  }
}