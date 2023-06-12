import { Component, OnInit, AfterViewInit, Input, ViewChild, ElementRef } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { AssetService } from 'src/app/asset/asset.service';
import { environment } from 'src/environments/environment';

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

  mimeCodec = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'

  constructor(
    private assetService: AssetService,
    
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

      if(this.currentAsset.assetType === AssetType.VIDEO.id) {
        //this.streamVideoAsset();
      }
    });
  }

  streamVideoAsset() {
    if (
      "MediaSource" in window &&
      MediaSource.isTypeSupported(this.mimeCodec)
    ) {
      const mediaSource = new MediaSource();
      (this.videoPlayer.nativeElement as HTMLVideoElement).src = URL.createObjectURL(
        mediaSource
      );
      mediaSource.addEventListener("sourceopen", () =>
        this.sourceOpen(mediaSource)
      );
    } else {
      console.error("Unsupported MIME type or codec: ", this.mimeCodec);
    }
  }

  sourceOpen(mediaSource: MediaSource) {
    const sourceBuffer = mediaSource.addSourceBuffer(this.mimeCodec);
      return this.assetService.stream( this.currentAssetId)
        .subscribe((blob:any) => {
          sourceBuffer.addEventListener("updateend", () => {
            mediaSource.endOfStream();
            //this.videoPlayer.nativeElement.play();
          });
          
          blob.arrayBuffer().then((x:any) => sourceBuffer.appendBuffer(x));
        });
  }


  getAssetStreamUrl() {
       return `${environment.backendUrl}/asset/${this.currentAsset.id}/stream`;     
  }
}
