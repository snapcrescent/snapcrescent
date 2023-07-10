import { Component, ViewChild, OnInit, AfterViewInit } from '@angular/core';
import { AbstractControl, FormBuilder, ValidationErrors, ValidatorFn, Validators } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { ActivatedRoute, Router } from '@angular/router';
import { BaseComponent } from 'src/app/core/components/base.component';
import { Action } from 'src/app/core/models/action.model';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { User } from '../user.model';
import { UserService } from '../user.service';
import { Observable, of } from 'rxjs';
import { map } from 'rxjs/operators';
import { Option } from 'src/app/core/models/option.model';
import { PasswordResetComponent } from '../password-reset/password-reset.component';

@Component({
  selector: 'app-user-create-edit',
  templateUrl: './user-create-edit.component.html',
})
export class UserCreateEditComponent extends BaseComponent implements OnInit, AfterViewInit {

  id: number;
  actions: Action[] = [];
  entityFormGroup = this.formBuilder.group(new User());

  userTypes: Option[] = []
 
  override errorMessage: any = {
    username: {
      usernameAlreadyUsed: "Username is already associated with another user",
    },
    default: {
      required: "Required field",
      min: "Required field"
    }
  };

  constructor(
    private userService: UserService,
    private activatedRoute: ActivatedRoute,
    private router: Router,
    private formBuilder: FormBuilder,
    private alertService: AlertService,
    private dialog: MatDialog
  ) {
    super();
    this.id = this.activatedRoute.snapshot.params['id']
  }

  get entity(): User {
    return this.entityFormGroup.getRawValue() as unknown as User;
  }

  ngOnInit() {
    this.populateBreadCrumbs()
    this.populatePageMetaData();
  }

  private populateBreadCrumbs() {
    this.breadCrumbs.length = 0;
    this.breadCrumbs.push({
      label: "Search Users",
      onClick: () => {
        this.router.navigate([`/admin/user/list`]);
      }
    })

    this.breadCrumbs.push({
      label: (this.id ? "Manage " + this.entity.fullName : "Create User"),
      onClick: () => {

      }
    })
  }

  private populatePageMetaData() {

    this.userService.getUserTypesAsOptions().subscribe(userTypes => {
      this.userTypes = userTypes;
    });

    this.actions.push({
      id: "save",
      icon: "save",
      tooltip: "Save User",
      onClick: () => {
        this.save();
      }
    })

    if (this.id) {
      this.actions.push({
        id: "resetPassword",
        icon: "lock_reset",
        tooltip: "Reset Password",
        styleClass: "orange",
        onClick: () => {
          this.dialog.open(PasswordResetComponent, {
            width: "50vw",
            data: {
              id : this.id,
              user: this.entity
            }
          })
        }
      });


      this.actions.push({
        id: "delete",
        icon: "delete",
        tooltip: "Delete User",
        styleClass: "red",
        onClick: () => {
          this.dialog.open(DialogComponent, {
            data: {
              title: "Are you sure?",
              message: "This will permanently delete the user",
              actions: [
                { label: "CANCEL" },
                {
                  label: "OK",
                  type: "flat",
                  onClick: () => {
                    this.userService.delete(this.id).subscribe(response => {
                      this.alertService.showSuccess("User deleted successfully");
                      this.router.navigate(["/admin/user/list"]);
                    });
                  }
                }
              ]
            }
          });
        }
      });


    }
  }

  ngAfterViewInit() {
    if (this.id) {
      this.getById();
    }
  }

  getById() {
    this.userService.read(this.id).subscribe((response) => {
        const user: User = response.object!;
        this.entityFormGroup.patchValue(user);
        this.populateBreadCrumbs();
    });
  }

  save() {

    this.validate()
      .subscribe(valid => {
        if (valid === true) {
          const payload = this.entity;

          if (this.id) {
            this.userService.update(this.id, payload).subscribe(response => {
              this.saveCallback(response);
            });
          } else {
            this.userService.save(payload).subscribe(response => {
              this.saveCallback(response);
            });
          }
        } else {
          this.alertService.showError("Please fix the errors");
        }

      });


  }

  saveCallback(response: any) {
    if (response.success === true) {
      this.alertService.showSuccess("User saved successfully");

      if (this.id) {
        this.getById()
      } else {
        this.id = response.objectId;
        this.router.navigate(["/admin/user/manage", this.id]);
      }
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
      return this.performBackendValidation();
    } else {
      return of(false);
    }
  }

  performBackendValidation() : Observable<boolean> {
    const payload = this.entity;

    if (this.id) {
      payload.id = this.id;
    }

    return this.userService.validate(payload).pipe(
      map(response => {

        if(response.success) {
          return true;
        } else {

          response.objects?.forEach(object => {
            const errors :ValidationErrors = {};
            errors[object.code] = true;
            this.entityFormGroup.get(object.field)!.setErrors(errors);
          });
          

          return false;
        }

       }));
  }

  private getFormValidations(): Map<string, ValidatorFn | ValidatorFn[] | null> {

    const formValidationMap = new Map<string, ValidatorFn | ValidatorFn[] | null>();

    formValidationMap.set('firstName', [Validators.required]);
    formValidationMap.set('lastName', [Validators.required]);
    formValidationMap.set('username', [Validators.required]);

    if(!this.id) {
      formValidationMap.set('password', [Validators.required]);
    }
    

    return formValidationMap;
  }

  override getErrorMessage(id: string) {
    return super.getErrorMessage(id, this.entityFormGroup);
  }
}
