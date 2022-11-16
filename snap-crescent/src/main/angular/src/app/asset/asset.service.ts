import { HttpClient, HttpEvent, HttpRequest } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Asset } from './asset.model';

@Injectable({
    providedIn: "root"
  })
export class AssetService extends BaseService {

  sortMapping:any = {
    creationDate: "asset.metadata.creationDatetime"
  };

  constructor(
    private httpClient: HttpClient
  ) { 
    super();
  }

  private entityUrl = '/asset';

  search(params:any): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.get(this.entityUrl, super.getSearchParameters(params));
  }

  read(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.get(this.entityUrl + '/' + id);
  }

  readLite(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.get(this.entityUrl + '/' + id + '/lite');
  }

  save(assetType:number,  files:any): Observable<HttpEvent<unknown>> {
    const formData = new FormData();
    formData.append('assetType',''+assetType);
    formData.append('files', files);

    const request = new HttpRequest('POST', this.entityUrl + '/upload', formData, {
      reportProgress: true,
      responseType: 'json'
    });

    return this.httpClient.request(request);
  }

  update(id: number,entity: Asset): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(this.entityUrl + '/' + id,this.preparePayload(entity));
  }

  delete(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.delete(this.entityUrl + '/' + id);
  }

  preparePayload(entity: Asset) {
        return entity;
  }

 
}
