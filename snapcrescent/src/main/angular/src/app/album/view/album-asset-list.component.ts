import { Component , ViewChild, AfterViewInit} from '@angular/core';
import { AssetListComponent } from 'src/app/asset/list/asset-list.component';
import { ActivatedRoute } from '@angular/router';
import { BaseAssetGridComponent } from 'src/app/core/components/base-asset-grid.component';
import { AlbumService } from '../album.service';
import { Album } from '../album.model';
import { AlertService } from 'src/app/shared/alert/alert.service';

@Component({
  selector: 'app-album-asset-list',
  templateUrl: './album-asset-list.component.html',
  styleUrls:['./album-asset-list.component.scss']
})
export class AlbumAssetListComponent extends BaseAssetGridComponent implements AfterViewInit{

  searchStoreName = "album-assets"

  albumId: number;
  album:Album;

  @ViewChild("assetListComponent", { static: false })
  assetListComponent: AssetListComponent;

  constructor(
    private activatedRoute: ActivatedRoute,
    private albumService:AlbumService,
    private alertService:AlertService,
  ) {
    super();
    this.albumId = this.activatedRoute.snapshot.params['albumId']
  }

  ngOnInit() {
    this.getByIdLite();
    this.populateAdvancedSearchFields();;
    this.populateActions();
  }

  ngAfterViewInit() {

  }

   getByIdLite() {
    this.albumService.readLite(this.albumId).subscribe((response) => {
        this.album = response.object!;
    });
  }


  private populateAdvancedSearchFields() {
    
    this.extraSearchFields.push({
      key: "albumId",
      label: "album",
      type : "text",
      value: this.albumId
    });
  }
 

  private populateActions() {
    this.actions.push({
      id: "makeCover",
      icon: "wallpaper",
      tooltip: "Set as album cover",
      hidden: () => {
        let hidden = true;
        if(this.album && this.album.ownedByMe && this.assetListComponent && this.assetListComponent && this.assetListComponent.assetGridComponent.selectedAssets.length == 1) {
          hidden = false;
        }
        return hidden;
      },
      onClick: () => {
        this.updateAlbumCover(this.assetListComponent.assetGridComponent.selectedAssets[0].thumbnail.id!);
      }
    });
  }

  private updateAlbumCover(albumThumbnailId:number) {

    this.albumService.read(this.albumId).subscribe((response) => {
      let album = response.object!;

      album.albumThumbnailId = albumThumbnailId;

      this.albumService.update(this.albumId, album).subscribe(response => {
        this.alertService.showSuccess("Album cover updated");
      });
    });

    

  }
}
