import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import {  Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { MetadataTimeline } from './metadata.model';

@Injectable({
    providedIn: "root"
  })
export class MetadataService extends BaseService {

  constructor(
    private httpClient: HttpClient
  ) { 
    super();
  }

  private entityUrl = '/metadata';

  getMetadataTimeline(): Observable<BaseResponseBean<number, MetadataTimeline>> {
    return this.httpClient.get(this.entityUrl + '/timeline');
  }
}
