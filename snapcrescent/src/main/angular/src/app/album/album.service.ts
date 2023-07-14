import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Album, CreateAlbumAssetAssnRequest } from './album.model';
import { UserLoginResponse } from '../login/login.model';

@Injectable({
    providedIn: "root"
  })
export class AlbumService extends BaseService {

  override sortMapping:any = {
    creationDate: "album.creationDateTime"
  };

  constructor(
    private httpClient: HttpClient
  ) { 
    super();
  }

  private entityUrl = '/album';

  search(params:any): Observable<BaseResponseBean<number, Album>> {
    return this.httpClient.get(this.entityUrl, super.getSearchParameters(params));
  }

  read(id: number): Observable<BaseResponseBean<number, Album>> {
    return this.httpClient.get(this.entityUrl + '/' + id);
  }

  readLite(id: number): Observable<BaseResponseBean<number, Album>> {
    return this.httpClient.get(this.entityUrl + '/' + id + '/lite');
  }

  update(id: number,entity: Album): Observable<BaseResponseBean<number, Album>> {
    return this.httpClient.put(this.entityUrl + '/' + id,this.preparePayload(entity));
  }

  verifyPasswordForAlbum(id: number,entity: Album): Observable<any> {
    return this.httpClient.post(this.entityUrl + '/' + id + '/login',this.preparePayload(entity));
  }

  delete(id: number): Observable<BaseResponseBean<number, Album>> {
    return this.httpClient.delete(`${this.entityUrl}/${id}`);
  }

  preparePayload(entity: Album) {
    return entity;
}

  createAlbumAssetAssociation(payload:CreateAlbumAssetAssnRequest) {
    return this.httpClient.post(this.entityUrl + '/asset/assn',payload);
  }
}
