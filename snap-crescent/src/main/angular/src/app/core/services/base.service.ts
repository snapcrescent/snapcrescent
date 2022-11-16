import { HttpParams } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { Option } from '../models/option.model';

@Injectable({
    providedIn: "root"
  })
export class BaseService {

  constructor() { }

  sortMapping:any = {};

  protected getSearchParameters(params:any) {
    Object.keys(params).forEach(key => {
      if(Array.isArray(params[key])) {
        params[key] = params[key].join(',');
      }

      if(key === 'sortBy') {
        if(this.sortMapping[params[key]]) {
          params[key] = this.sortMapping[params[key]];
        }
      }
    });
    return {params:params};
  }

  getYesAndNoOptions() {
    return [
      new Option(true,"Yes"),
      new Option(false,"No"),
    ]
  }

}
