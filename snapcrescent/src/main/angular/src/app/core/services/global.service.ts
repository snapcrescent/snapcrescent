import { Injectable} from '@angular/core';
import { Subject } from 'rxjs';

@Injectable({
    providedIn: "root"
  })
export class GlobalService {

  static instance: GlobalService;

  assetIds:number[] = [];

  private toggleSideBar = new Subject<Boolean>();
  public onToggleSideBarStateChange = this.toggleSideBar.asObservable();
  
  constructor() {
    return (GlobalService.instance = GlobalService.instance || this);
  }

  setAssetIds( assetIds:number[]) {
    this.assetIds = assetIds;
  }

  getAssetIds() {
    return this.assetIds;
  }

  updateToggleSideBarState(value: Boolean):void {
    this.toggleSideBar.next(value)
  };


    
}
