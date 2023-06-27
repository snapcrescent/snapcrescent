import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import {  Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { AppConfig } from './app-config.model';

@Injectable({
    providedIn: "root"
  })
export class AppConfigService extends BaseService {

  constructor(
    private httpClient: HttpClient
  ) { 
    super();
  }

  private entityUrl = '/app-config';

  search(): Observable<BaseResponseBean<number, AppConfig>> {
    return this.httpClient.get(this.entityUrl);
  }
}
