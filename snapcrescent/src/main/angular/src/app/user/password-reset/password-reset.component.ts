import { Component, OnInit, AfterViewInit, Input, OnDestroy, Inject } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute } from '@angular/router';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable, of } from 'rxjs';
import { AbstractControl, FormBuilder, ValidatorFn, Validators } from '@angular/forms';
import { User } from '../user.model';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { UserService } from '../user.service';

@Component({
  selector: 'app-password-reset',
  templateUrl: './password-reset.component.html',
  styleUrls: ['./password-reset.component.scss']
})
export class PasswordResetComponent extends BaseComponent implements OnInit, AfterViewInit, OnDestroy {

  entityFormGroup = this.formBuilder.group(new User());
  
  id: number;
  user:User;

  constructor(
    public dialogRef: MatDialogRef<PasswordResetComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    public activatedRoute: ActivatedRoute,
    private formBuilder: FormBuilder,
    private alertService: AlertService,
    private userService: UserService
  ) {
      super();
      dialogRef.disableClose = true;
      this.id = data.id;
      this.user = data.user;

  }

  ngOnInit() {
    this.user.password = '';
    this.entityFormGroup.patchValue(this.user);
  }

  ngAfterViewInit() {
  
  }

  get entity(): User {
    return this.entityFormGroup.getRawValue() as unknown as User;
  }

  ngOnDestroy(): void {
   
  }

  resetPassword() {

    this.validate()
      .subscribe(valid => {
        if (valid === true) {
          const payload = this.entity;

          
            this.userService.resetPassword(this.id, payload).subscribe(response => {
              this.saveCallback(response);
            });
          
        } else {
          this.alertService.showError("Please fix the errors");
        }

      });


  }

  saveCallback(response: any) {
    if (response.success === true) {
      this.alertService.showSuccess("Password updated successfully");
      this.dialogRef.close();
    } else {
      this.alertService.showError("Error while saving user");
    }
  }

  validate(): Observable<Boolean> {
    const formValidationMap = this.getFormValidations();
    const formControlNames = Array.from(formValidationMap.keys());

    const controls: AbstractControl[] = [];

    formControlNames.map(name => {
      const control = this.entityFormGroup.get(name);

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
    formValidationMap.set('password', [Validators.required]);
    return formValidationMap;
  }

  override getErrorMessage(id: string) {
    return super.getErrorMessage(id, this.entityFormGroup);
  }

}
