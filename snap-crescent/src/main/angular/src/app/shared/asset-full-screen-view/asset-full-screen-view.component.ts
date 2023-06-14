import { Component, OnInit, AfterViewInit, Input, ViewChild, ElementRef } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { AssetService } from 'src/app/asset/asset.service';
import { environment } from 'src/environments/environment';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-asset-full-screen-view',
  templateUrl: './asset-full-screen-view.component.html',
  styleUrls: ['./asset-full-screen-view.component.scss']
})
export class AssetFullScreenViewComponent extends BaseComponent implements OnInit, AfterViewInit {

  @Input()
  actions: Action[] = [];

  @Input()
  currentAssetId:number;
  
  @Input()
  assetIds:number[]= [];

  currentAsset:Asset;

  AssetType = AssetType;
  
  @ViewChild("videoPlayer")
  videoPlayer: ElementRef;

  mimeCodec = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'

  constructor(
    private assetService: AssetService,
    private httpClient: HttpClient
    
  ) {
      super();
  }

  ngOnInit() {
    
  }

  ngAfterViewInit() {
    this.getAsset();
  }

  

  getAsset() {
    this.assetService.read(this.currentAssetId).subscribe((response:any) => {
      this.currentAsset = response.object;
      
      
      if(this.currentAsset.assetType === AssetType.PHOTO.id) {
        this.currentAsset.url = `/asset/${this.currentAsset.token}/stream`;
      } else if (this.currentAsset.assetType === AssetType.VIDEO.id) {
         this.currentAsset.url = `${environment.backendUrl}/asset/${this.currentAsset.token}/stream`;
       }
    });
  }
}
