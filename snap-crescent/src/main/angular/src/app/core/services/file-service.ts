import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { BaseService } from './base.service';

@Injectable({
  providedIn: "root"
})
export class FileService extends BaseService {

  constructor(private httpClient: HttpClient) {
    super();
  }

  private entityUrl = '/file';

  getImageRetrievalURL(fileName:string) {
    return environment.backendUrl + this.entityUrl + "/" + fileName;
  }

  save(file:any) {
    const formData = new FormData();
    formData.append('file', file);
    return this.httpClient.post<any>(this.entityUrl, formData);
  }




}
