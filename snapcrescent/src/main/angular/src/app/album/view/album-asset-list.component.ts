import { Component , ViewChild, AfterViewInit} from '@angular/core';
import { AssetService } from 'src/app/asset/asset.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetListComponent } from 'src/app/asset/list/asset-list.component';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-album-asset-list',
  templateUrl: './album-asset-list.component.html',
  styleUrls:['./album-asset-list.component.scss']
})
export class AlbumAssetListComponent extends BaseListComponent implements AfterViewInit{

  searchStoreName = "album-assets"

  albumId: number;

  @ViewChild("assetListComponent", { static: false })
  assetListComponent: AssetListComponent;

  constructor(
    private assetService: AssetService,
    private alertService: AlertService,
    private activatedRoute: ActivatedRoute,
  ) {
    super();
    this.albumId = this.activatedRoute.snapshot.params['albumId']
  }

  ngOnInit() {
    this.populateAdvancedSearchFields();;
    this.populateActions();
  }

  ngAfterViewInit() {

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
    
  }
}
