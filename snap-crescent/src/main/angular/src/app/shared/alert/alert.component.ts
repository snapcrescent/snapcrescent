import { Component, OnInit } from '@angular/core';
import { MatSnackBar, MatSnackBarDismiss, MatSnackBarRef, TextOnlySnackBar } from '@angular/material/snack-bar';
import { MatSnackBarHorizontalPosition } from '@angular/material/snack-bar';
import { MatSnackBarVerticalPosition } from '@angular/material/snack-bar';
import { Alert } from './alert.model';
import { AlertService } from './alert.service';

@Component({
    selector: 'app-alert',
    templateUrl: 'alert.component.html'

})
export class AlertComponent implements OnInit {
    
    durationInSeconds = 5;
    horizontalPosition: MatSnackBarHorizontalPosition = 'center';
    verticalPosition: MatSnackBarVerticalPosition = 'top';

    constructor(
        private alertService: AlertService,
        private _snackBar: MatSnackBar) { }

    ngOnInit() {
        this.registerListeners();
        }

    showAlert(alert: Alert) {

        
        const _snackBarRef: MatSnackBarRef<TextOnlySnackBar> = this._snackBar.open(alert.message, 'Ok', {
            duration: this.durationInSeconds * 1000,
            horizontalPosition: this.horizontalPosition,
            verticalPosition: this.verticalPosition,
            panelClass:`alert-` + alert.type
        });

        
        _snackBarRef.afterDismissed().subscribe((res:MatSnackBarDismiss) => {

            if(res.dismissedByAction) {
                if(!!alert.onClick) {
                    alert.onClick();
                }
            }
            
        });
        
        


    }

    registerListeners(): void {
        this.alertService.onCreateAlert.subscribe((alert:Alert) => {
            this.showAlert(alert);
        })
      }
}