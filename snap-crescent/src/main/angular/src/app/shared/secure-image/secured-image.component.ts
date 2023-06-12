import { Component, Input, OnChanges } from '@angular/core';
import {HttpClient, HttpHeaders} from '@angular/common/http';
import {Observable, BehaviorSubject, switchMap, map} from 'rxjs';
import { DomSanitizer } from '@angular/platform-browser';

@Component({
  selector: 'secured-image',
  template: `<img class="asset img-fluid" alt="Asset" [src]="dataUrl$|async"/>
  `
})
export class SecuredImageComponent implements OnChanges  {
    
  @Input() src: string = '';

  private src$ = new BehaviorSubject(this.src);

  ngOnChanges(): void {
    this.src$.next(this.src);
  }

  dataUrl$ = this.src$.pipe(switchMap((url:string) => this.loadImage(url)))
  
  // we need HttpClient to load the image and DomSanitizer to trust the url
  constructor(private httpClient: HttpClient, private domSanitizer: DomSanitizer) {
  }

  private loadImage(url: string): Observable<any> {
    let headers: HttpHeaders = new HttpHeaders({
      'loading':'false'
    });
    

    return this.httpClient
      .get(url, {responseType: 'blob', headers}).pipe(
        map((e:any) => this.domSanitizer.bypassSecurityTrustUrl(URL.createObjectURL(e)))
      );
  }
}
