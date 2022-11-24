import { Component, OnInit } from '@angular/core';
import { AbstractControl, FormBuilder, ValidatorFn, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import {  UserLoginRequest, UserLoginResponse } from './login.model';
import { LoginService } from './login.service';
import { SessionService } from '../core/services/session.service';
import { AlertService } from '../shared/alert/alert.service';
import { Observable, of } from 'rxjs';
import { BaseComponent } from '../core/components/base.component';
import { browserRefresh } from '../app.component';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent extends BaseComponent implements OnInit {

  redirectingToHome: boolean = false;

  browserRefreshed: boolean;

  form = this.formBuilder.group(new UserLoginRequest());

  constructor(
    private formBuilder: FormBuilder,
    private sessionService: SessionService,
    private loginService: LoginService,
    private router: Router,
    private alertService: AlertService
  ) {
    super();
  }

  ngOnInit() {
    this.browserRefreshed = browserRefresh;
    this.sessionService.logout();
  }

  get userLoginRequest() {
    return this.form.getRawValue() as UserLoginRequest;
  }

  login() {

    this.validate()
      .subscribe(valid => {
        if (valid === true) {
          this.loginService.login(this.userLoginRequest).subscribe(
            {
              next: (response: UserLoginResponse) => {

                if (response.token) {
                  this.redirectingToHome = true;

                  setTimeout(() => {
                    this.sessionService.login(response);

                    this.router.navigate(['/asset']);
                  }, 800);
                } else {
                  this.alertService.showError(response.message!);
                }
              },
              error: (error) => {
                this.alertService.showError(error.message);
              }
            }
          );
        }
      });


  }

  validate(): Observable<Boolean> {
    const formValidationMap = this.getFormValidations();
    const formControlNames = Array.from(formValidationMap.keys());

    const controls: AbstractControl[] = [];

    formControlNames.map(name => {
      const control = this.form.get(name);

      if (control) {
        control.setValidators(formValidationMap.get(name)!);
        control.markAsTouched();
        control.updateValueAndValidity({ emitEvent: false });
        controls.push(control);
      }
    });


    if (controls.reduce((acc, val: AbstractControl) => acc && !val.invalid, true)) {
      return of(true);
    } else {
      return of(false);
    }
  }

  private getFormValidations(): Map<string, ValidatorFn | ValidatorFn[] | null> {

    const formValidationMap = new Map<string, ValidatorFn | ValidatorFn[] | null>();

    formValidationMap.set('username', [Validators.required]);
    formValidationMap.set('password', [Validators.required]);

    return formValidationMap;
  }

  getErrorMessage(id: string) {
    return super.getErrorMessage(id, this.form);
  }
}
