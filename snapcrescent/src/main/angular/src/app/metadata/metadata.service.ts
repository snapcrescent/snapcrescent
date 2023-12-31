import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseService } from '../core/services/base.service';

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


}
