import { Injectable} from '@angular/core';
import { Observable ,  Subject } from "rxjs";

@Injectable({
    providedIn: "root"
  })
export class LoaderService {

  static instance: LoaderService;
  total = 0;
  private subject = new Subject<number>();
  isOverrideSpinner = false;

  lastServerCommunicationTimeStamp: Date;

  constructor() {
    return (LoaderService.instance = LoaderService.instance || this);
  }

  get total$(): Observable<number> {
    return this.subject.asObservable();
  }

  get overrideSpinner(): boolean {
    return this.isOverrideSpinner;
  }

  set overrideSpinner(isOverrideSpinner: boolean) {
    this.isOverrideSpinner = isOverrideSpinner;
  }

  add(num: number = 1) {
    if (this.overrideSpinner) {
      this.total += 0;
    } else {
      this.total += num;
    }
    this.subject.next(this.total);
  }

  subtract(num: number = 1) {
    this.total -= num;
    if (this.total < 0) {
      this.total = 0;
    }
    this.lastServerCommunicationTimeStamp = new Date();
    this.subject.next(this.total);
  }

  clear() {
    this.subject.next(0);
  }
  
}
