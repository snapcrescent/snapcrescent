import { HttpClient, HttpEvent, HttpRequest } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { of, Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Asset, AssetType } from './asset.model';
import { Option } from '../core/models/option.model';

@Injectable({
    providedIn: "root"
  })
export class AssetService extends BaseService {

  sortMapping:any = {
    creationDate: "asset.metadata.creationDateTime"
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

  stream(id: number) {
    return this.httpClient.get(`${this.entityUrl}/${id}/stream`, {responseType: "blob"});
  }

  readLite(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.get(this.entityUrl + '/' + id + '/lite');
  }

  save(file:File): Observable<HttpEvent<unknown>> {
    const formData = new FormData();
    formData.append('files', file);

    const request = new HttpRequest('POST', this.entityUrl + '/upload', formData, {
      reportProgress: true,
      responseType: 'json'
    });

    return this.httpClient.request(request);
  }

  updateMetadata(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(this.entityUrl + '/' + id + "/metadata",{});
  }

  update(id: number,entity: Asset): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(this.entityUrl + '/' + id,this.preparePayload(entity));
  }

  restore(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(`${this.entityUrl}/restore?ids=${ids.join(',')}`, {});
  }

  delete(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.delete(`${this.entityUrl}?ids=${ids.join(',')}`);
  }

  deletePermanently(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.delete(`${this.entityUrl}/permanent?ids=${ids.join(',')}`);
  }

  preparePayload(entity: Asset) {
        return entity;
  }


  getAssetTypesAsOptions(): Observable<Option[]> {
    const assetTypeOptions: Option[] = [];

    for (const [key, value] of Object.entries(AssetType)) {
      assetTypeOptions.push({
        value:value.id,
        label:value.label,
        rawValue:value
      });

  }

    return of(assetTypeOptions);
}

 
}
