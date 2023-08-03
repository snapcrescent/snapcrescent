import { Component, OnInit, AfterViewInit, Input, ViewChild, ElementRef, OnChanges, SimpleChanges } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { AssetService } from 'src/app/asset/asset.service';
import { environment } from 'src/environments/environment';
declare var pannellum: any;

@Component({
  selector: 'app-asset-full-screen-view',
  templateUrl: './asset-full-screen-view.component.html',
  styleUrls: ['./asset-full-screen-view.component.scss']
})
export class AssetFullScreenViewComponent extends BaseComponent implements OnInit, AfterViewInit, OnChanges {

  @Input()
  actions: Action[] = [];

  @Input()
  currentAssetId: number;

  @Input()
  assetIds: number[] = [];

  isPanorama : boolean = false;

  currentAsset: Asset;

  AssetType = AssetType;

  @ViewChild("videoPlayer")
  videoPlayer: ElementRef;

  mimeCodec = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'

  constructor(
    private assetService: AssetService

  ) {
    super();
  }

  ngOnInit() {

  }

  ngAfterViewInit() {
    this.getAsset();
  }

  ngOnChanges(changes: SimpleChanges) {

    if (changes?.['currentAssetId']) {
      if(this.currentAssetId != changes?.['currentAssetId'].previousValue) {
        this.getAsset();
      }
    }

  }



  getAsset() {
    this.assetService.read(this.currentAssetId).subscribe((response: any) => {
      let newAsset: Asset = response.object;

      if (newAsset.assetType === AssetType.PHOTO.id) {
        newAsset.url = `/asset/${newAsset.token}/stream`;
      } else if (newAsset.assetType === AssetType.VIDEO.id) {
        newAsset.url = `${environment.backendUrl}/asset/${newAsset.token}/stream`;
      }

      this.isPanorama = (newAsset.metadata.width / newAsset.metadata.height) >= 2
      this.currentAsset = newAsset;

      if(this.isPanorama) {
        setTimeout(function(){
          pannellum.viewer('panoramaContainer', {
            "type": "equirectangular",
            "autoLoad": true,
            "autoRotate": -1,
            "preview": true,
            "panorama": `${environment.backendUrl}${newAsset.url}`
          })
        }, 1000);
      }
      
    });
  }
}
