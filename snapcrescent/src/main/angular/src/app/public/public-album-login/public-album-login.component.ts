import { Component , OnInit} from '@angular/core';
import { FormBuilder } from '@angular/forms';
import { AbstractControl, ValidatorFn, Validators } from '@angular/forms';
import { Observable, of } from 'rxjs';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { UserLoginRequest, UserLoginResponse } from 'src/app/login/login.model';
import { SessionService } from 'src/app/core/services/session.service';
import { LoginService } from 'src/app/login/login.service';
import { browserRefresh } from 'src/app/app.component';
import { ActivatedRoute, Router } from '@angular/router';
import { AlbumService } from 'src/app/album/album.service';
import { BaseComponent } from 'src/app/core/components/base.component';
import { Album } from 'src/app/album/album.model';

@Component({
  selector: 'app-public-album-login',
  templateUrl: './public-album-login.component.html',
  styleUrls:['./public-album-login.component.scss']
})
export class PublicAlbumLoginComponent extends BaseComponent implements OnInit{

  redirectingToHome: boolean = false;
  browserRefreshed: boolean;

  albumId: number;
  album?:Album;

  form = this.formBuilder.group(new UserLoginRequest());

  constructor(
    private formBuilder: FormBuilder,
    private sessionService: SessionService,
    private loginService: LoginService,
    private alertService: AlertService,
    private router: Router,
    private albumService : AlbumService,
    private activatedRoute: ActivatedRoute,
  ) {
    super();
    this.albumId = this.activatedRoute.snapshot.params['albumId']
  }

  ngOnInit() {
    this.browserRefreshed = browserRefresh;
    this.sessionService.logout();
    this.getAlbumDetails();
  }

  get userLoginRequest() {
    return this.form.getRawValue() as UserLoginRequest;
  }

  getAlbumDetails() {
    this.albumService.readLite(this.albumId).subscribe(response => {
        this.album = response.object!;

        let userLoginRequest: UserLoginRequest = new UserLoginRequest();
        userLoginRequest.username = this.album.publicAccessUserObject!.username;

        this.form.patchValue(userLoginRequest);
    });
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

                    this.router.navigate(['/album/view', this.album?.id]);
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

  override getErrorMessage(id: string) {
    return super.getErrorMessage(id, this.form);
  }
}
