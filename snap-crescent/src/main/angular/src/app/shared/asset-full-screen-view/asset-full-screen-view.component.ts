import { Component, OnInit, AfterViewInit, Input, ViewChild, ElementRef } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { AssetService } from 'src/app/asset/asset.service';
import { environment } from 'src/environments/environment';
import { Router } from '@angular/router';

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
  environment = environment;
  
  @ViewChild("videoPlayer", { static: false })
  videoPlayer: ElementRef;

  constructor(
    private assetService: AssetService,
  ) {
      super();
  }

  ngOnInit() {
    this.getAsset();
  }

  ngAfterViewInit() {
  
  }

  getAsset() {
    this.assetService.read(this.currentAssetId).subscribe((response:any) => {
      this.currentAsset = response.object;
    });
  }

  getVideoURL() {
    return environment.backendUrl + `/asset/${this.currentAsset.id}/stream`;
  }

  toggleVideo() {
    this.videoPlayer.nativeElement.play();
  }
}
