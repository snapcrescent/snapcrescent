import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';
import { Observable } from "rxjs";
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Album, AlbumType } from './album.model';

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
}
