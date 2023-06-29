import { HttpClient, HttpEvent, HttpRequest } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { of, Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Asset, AssetTimeline, AssetType } from './asset.model';
import { Option } from '../core/models/option.model';

@Injectable({
    providedIn: "root"
  })
export class AssetService extends BaseService {

  override sortMapping:any = {
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

  readLite(id: number): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.get(this.entityUrl + '/' + id + '/lite');
  }

  save(files:File[]): Observable<HttpEvent<unknown>> {
    const formData = new FormData();

    for (const file of files) { 
      formData.append('files', file);
    }
    
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

  popFromInactive(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(`${this.entityUrl}/pop/trash?ids=${ids.join(',')}`, {});
  }

  pushToInactive(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.delete(`${this.entityUrl}/trash?ids=${ids.join(',')}`);
  }

  deletePermanently(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.delete(`${this.entityUrl}/permanent?ids=${ids.join(',')}`);
  }

  pushToFavorite(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(`${this.entityUrl}/push/favorite?ids=${ids.join(',')}`, {});
  }

  popFromFavorite(ids: number[]): Observable<BaseResponseBean<number, Asset>> {
    return this.httpClient.put(`${this.entityUrl}/pop/favorite?ids=${ids.join(',')}`, {});
  }

  getAssetTimeline(params:any): Observable<BaseResponseBean<number, AssetTimeline>> {
    return this.httpClient.get(this.entityUrl + '/timeline', super.getSearchParameters(params));
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
