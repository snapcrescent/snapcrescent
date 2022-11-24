import { Injectable } from "@angular/core";
import {
  HttpRequest,
  HttpHandler,
  HttpInterceptor
} from "@angular/common/http";
import { Observable, throwError } from "rxjs";
import { Router } from "@angular/router";

import { catchError } from "rxjs/operators";
import { AlertService } from "src/app/shared/alert/alert.service";
import { SessionService } from "../session.service";

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(
    private alertService: AlertService,
    private router: Router,
    private sessionService: SessionService
  ) {}

  intercept(req: HttpRequest<any>, next: HttpHandler) {
    return next.handle(req).pipe(
      catchError(
        (res): Observable<any> => {
          if (res.status === 401) {
            this.sessionService.logout();
            this.router.navigate(["/login"]);
            
            return throwError(() => new Error(res.error.message))
          } else {
            if (res.status > 0) {
              let message = "Error occurred, please try again later.";
              if (res.error) {
                if (typeof res.error === "string") {
                  res.message = res.error.replace("[RPM Exception]", "");
                } else if (res.error.message) {
                  res.message = res.error.message;
                }
                message = res.message;
              }
              this.alertService.showError(message);
            } else {
                this.alertService.showError("Unable to connect to server");
            }

            return throwError(() => new Error(res))
          }
        }
      )
    );
  }
}
