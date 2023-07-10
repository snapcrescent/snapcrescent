import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Album, AlbumType, CreateAlbumAssetAssnRequest, CreateAlbumUserAssnRequest } from './album.model';

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

  createAlbumAssetAssociation(payload:CreateAlbumAssetAssnRequest) {
    return this.httpClient.post(this.entityUrl + '/asset/assn',payload);
  }

  createAlbumUserAssociation(payload:CreateAlbumUserAssnRequest) {
    return this.httpClient.post(this.entityUrl + '/user/assn',payload);
  }
}
