import { Component , ViewChild, AfterViewInit} from '@angular/core';
import { AssetService } from 'src/app/asset/asset.service';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetListComponent } from 'src/app/asset/list/asset-list.component';
import { BaseAssetGridComponent } from 'src/app/core/components/base-asset-grid.component';

@Component({
  selector: 'app-favorite-asset-list',
  templateUrl: './favorite-asset-list.component.html',
  styleUrls:['./favorite-asset-list.component.scss']
})
export class FavoriteAssetListComponent extends BaseAssetGridComponent implements AfterViewInit{

  searchStoreName = "favorite-assets"

  @ViewChild("assetListComponent", { static: false })
  assetListComponent: AssetListComponent;

  constructor(
    private assetService: AssetService,
    private alertService: AlertService,
  ) {
    super();
  }

  ngOnInit() {
    this.populateAdvancedSearchFields();;
    this.populateActions();
  }

  ngAfterViewInit() {

  }


  private populateAdvancedSearchFields() {
    
    this.extraSearchFields.push({
      key: "favorite",
      label: "favorite",
      type : "text",
      value: "true"
    });
  }
 

  private populateActions() {
    this.actions.push({
      id: "restore",
      icon: "star_half",
      styleClass : "primary",
      tooltip: "Remove from favorite",
      hidden: () =>  { 
        let hidden = true;
        if(this.assetListComponent && this.assetListComponent && this.assetListComponent.assetGridComponent.isAnyAssetSelected) {
            hidden = false
        }
        return hidden;
      },
      onClick: () => {
        const assetIds = this.assetListComponent.assetGridComponent.selectedAssets.map((asset:any) => 
          {
            return asset.id
          });

          this.assetService.popFromFavorite(assetIds).subscribe(response => {
            this.alertService.showSuccess(`${assetIds.length} Item${assetIds.length > 1 ? 's':''} remove from favorite successfully`);
            this.assetListComponent.assetGridComponent.refresh();
          });
      }
    });
  }
}
