import { Injectable} from '@angular/core';

@Injectable({
    providedIn: "root"
  })
export class StorageService {

  constructor() {
    
  }

  setItem(key:string, value:string) {
    localStorage.setItem(key, value);
  }

  getItem(key:string) {
    return localStorage.getItem(key);
  }

  removeItem(key:string) {
    localStorage.removeItem(key);
  }

  removeAll() {
    localStorage.clear();
  }
}
