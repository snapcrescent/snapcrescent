import { Pipe, PipeTransform } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';
import { map,Observable } from 'rxjs';

@Pipe({
    name: 'secure'
})
export class SecurePipe implements PipeTransform {

    constructor(private http: HttpClient, private sanitizer: DomSanitizer) { }

    transform(url:string): Observable<SafeUrl> {

        let headers: HttpHeaders = new HttpHeaders({
            'loading':'false'
          });

        return this.http
            .get(url, { responseType: 'blob',headers }).pipe(
                map((val) => this.sanitizer.bypassSecurityTrustUrl(URL.createObjectURL(val)))
            );
    }

}