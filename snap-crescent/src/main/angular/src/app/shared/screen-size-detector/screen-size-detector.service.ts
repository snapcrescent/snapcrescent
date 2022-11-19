import { Injectable} from '@angular/core';
import { Observable, BehaviorSubject } from 'rxjs';
import { distinctUntilChanged } from 'rxjs/operators';
import { ScreenSize } from './screen-size-detector.model';

@Injectable({
  providedIn: "root"
})
export class ScreenSizeDetectorService {
  
  get onResize$(): Observable<ScreenSize> {
    return this.resizeSubject.asObservable().pipe(distinctUntilChanged());
  }

  private resizeSubject: BehaviorSubject<ScreenSize>;

  constructor() {
    this.resizeSubject = new BehaviorSubject<ScreenSize>(ScreenSize.XS);
  }

  getCurrentSize() {
    return this.resizeSubject.getValue();
  }

  onResize(size: ScreenSize) {
    this.resizeSubject.next(size);
  }

}