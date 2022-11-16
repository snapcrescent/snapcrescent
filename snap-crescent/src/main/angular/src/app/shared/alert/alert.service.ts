import { Injectable} from '@angular/core';
import { ReplaySubject } from 'rxjs';
import { Alert } from './alert.model';

@Injectable({
    providedIn: "root"
  })
export class AlertService {

  constructor(
  ) { 

  }

  private alert = new ReplaySubject<Alert>(1);
  public onCreateAlert = this.alert.asObservable();

  showError(message:string, onClick? :Function) {
    this.create({
      type : "error",
      message:message,
      onClick: onClick
    });
  }

  showSuccess(message:string, onClick? :Function) {
    this.create({
      type : "success",
      message:message,
      onClick: onClick
    });
  }

  private create(message:Alert) {
    this.alert.next(message);
  }
  
}
