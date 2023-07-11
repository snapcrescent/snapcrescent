import { Component, ViewChild, AfterViewInit, Input } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { AssetService } from 'src/app/asset/asset.service';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetGridComponent } from 'src/app/shared/asset-grid/asset-grid.component';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { AssetSearchField } from 'src/app/shared/asset-grid/asset-grid.model';
import { Action } from 'src/app/core/models/action.model';
import { PageType } from 'src/app/core/models/page-type.model';
import { AssetViewComponent } from '../view/asset-view.component';
import { Asset } from '../asset.model';
import { AddToAlbumComponent } from '../add-to-album/add-to-album.component';
import { BaseAssetGridComponent } from 'src/app/core/components/base-asset-grid.component';

@Component({
  selector: 'app-asset-list',
  templateUrl: './asset-list.component.html',
  styleUrls: ['./asset-list.component.scss']
})
export class AssetListComponent extends BaseAssetGridComponent implements AfterViewInit {

  @Input()
  override pageType = PageType.SEARCH;

  @Input()
  searchStoreName = "assets"

  @Input()
  override extraSearchFields: AssetSearchField[];

  @Input()
  override actions: Action[];

  @ViewChild("assetGridComponent", { static: false })
  assetGridComponent: AssetGridComponent;

 constructor(
    private router: Router,
    private assetService: AssetService,
    private dialog: MatDialog,
    private alertService: AlertService
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
    this.advancedSearchFields.push({
      key: "fromDate",
      label: "From Date",
      dateMode: "start",
      type: "monthYear"
    });

    this.advancedSearchFields.push({
      key: "toDate",
      label: "To Date",
      dateMode: "end",
      type: "monthYear"
    });

    this.advancedSearchFields.push({
      key: "assetType",
      label: "Type",
      type: "dropdown",
      options: this.assetService.getAssetTypesAsOptions()
    });

    this.extraSearchFields.push({
      key: "resultType",
      label: "Result Type",
      type: "text",
      value: "SEARCH"
    });
  }


  private populateActions() {

    if (this.pageType === PageType.SEARCH) {
      this.actions.push({
        id: "upload",
        icon: "upload",
        tooltip: "Upload Photos and Videos",
        hidden: () => {
          let hidden = false;
          if (this.assetGridComponent && this.assetGridComponent.isAnyAssetSelected) {
            hidden = true;
          }
          return hidden;
        },
        onClick: () => {
          this.router.navigate(['/asset/upload']);
        }
      });

      this.actions.push({
        id: "addToAlbum",
        icon: "add",
        tooltip: "Add to album",
        hidden: () => {
          let hidden = true;
          if (this.assetGridComponent && this.assetGridComponent.isAnyAssetSelected) {
            hidden = false;
          }
          return hidden;
        },
        onClick: () => {
            this.openAddToAlbumDialog();
        }
      });

      this.actions.push({
        id: "favorite",
        icon: "star",
        styleClass: "orange",
        tooltip: "Favorite",
        hidden: () => {
          let hidden = true;
          if (this.assetGridComponent && this.assetGridComponent.isAnyAssetSelected) {
            hidden = false
          }
          return hidden;
        },
        onClick: () => {

          const assetIds = this.assetGridComponent.selectedAssets.filter((asset: Asset) => (asset.id && !asset.favorite)).map((asset: any) => {
            return asset.id
          });

          if (assetIds && assetIds.length) {
            this.assetService.pushToFavorite(assetIds).subscribe(response => {
              this.alertService.showSuccess(`${assetIds.length} Item${assetIds.length > 1 ? 's' : ''} added to favorite`);
            });
          } else {
            this.alertService.showSuccess(`0 added to favorite`);
          }
        }
      });

      this.actions.push({
        id: "delete",
        icon: "delete",
        styleClass: "red",
        tooltip: "Delete",
        hidden: () => {
          let hidden = true;
          if (this.assetGridComponent && this.assetGridComponent.isAnyAssetSelected) {
            hidden = false
          }
          return hidden;
        },
        onClick: () => {
          this.dialog.open(DialogComponent, {
            data: {
              title: "Are you sure?",
              message: `This will delete the selected item${this.assetGridComponent.selectedAssets.length > 1 ? 's' : ''}`,
              actions: [
                { label: "CANCEL" },
                {
                  label: "OK",
                  type: "flat",
                  onClick: () => {
                    const assetIds = this.assetGridComponent.selectedAssets.map((asset: any) => {
                      return asset.id
                    });

                    this.assetService.pushToInactive(assetIds).subscribe(response => {
                      this.alertService.showSuccess(`${assetIds.length} Item${assetIds.length > 1 ? 's' : ''} deleted successfully`);
                      this.assetGridComponent.refresh();
                    });
                  }
                }
              ]
            }
          });
        }
      });
    }

  }

  search(params: any) {
    return this.assetService.search(params);
  }

  getTimeline(params: any) {
    return this.assetService.getAssetTimeline(params);
  }

  openAssetView(event: any) {
    const currentAssetId = event.currentAssetId;
    const assetIds = event.assetIds;

    this.dialog.open(AssetViewComponent, {
      width: "100vw",
      maxWidth: "100vw",
      panelClass: "app-asset-view",
      data: {
        currentAssetId: currentAssetId,
        assetIds: assetIds
      }
    });
  }

  openAddToAlbumDialog() {
    
    this.dialog.open(AddToAlbumComponent, {
      width: "50vw",
      data: {
        assetIds: this.assetGridComponent.selectedAssets.map((selectedAsset:Asset) => selectedAsset.id)
      }
    });
  }
}
