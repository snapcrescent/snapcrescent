import { Injectable} from '@angular/core';
import { StorageService } from '../storage.service';

@Injectable({
    providedIn: "root"
  })
export class PageDataService extends StorageService{

  private SEARCH_PAGE_DATA_KEY = 'search-page-data-';
  private PAGE_DATA_KEY = 'page-data-';

  constructor(
  ) {
    super();
   }

   setSearchPageData(name:string, params: any = {}) {
      let searchTableData:any = {};

      Object.keys(params).forEach(key => {
        searchTableData[key] = params[key]
      });

      this.setItem(this.SEARCH_PAGE_DATA_KEY + name, JSON.stringify(searchTableData));
   }

   getSearchPageData(name:string) {
    const object = this.getItem(this.SEARCH_PAGE_DATA_KEY + name);

    if(object) {
      return JSON.parse(object);
    }
  }

  setPageData(name:string, params: any = {}) {
    let searchTableData:any = {};

    if(Array.isArray(params)) {
      searchTableData = params;
    } else {
      Object.keys(params).forEach(key => {
        searchTableData[key] = params[key]
      });
    }
    

    this.setItem(this.PAGE_DATA_KEY + name, JSON.stringify(searchTableData));
 }

 getPageData(name:string) {
  const object = this.getItem(this.PAGE_DATA_KEY + name);

   if(object) {
    return JSON.parse(object);
  }
}
}