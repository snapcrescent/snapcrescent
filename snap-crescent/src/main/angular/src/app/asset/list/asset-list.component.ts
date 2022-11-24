import { Component , ViewChild, AfterViewInit, Input} from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { AssetService } from 'src/app/asset/asset.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetGridComponent } from 'src/app/shared/asset-grid/asset-grid.component';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { AssetSearchField } from 'src/app/shared/asset-grid/asset-grid.model';
import { Action } from 'src/app/core/models/action.model';
import { PageType } from 'src/app/core/models/page-type.model';
import { PageDataService } from 'src/app/core/services/stores/page-data.service';

@Component({
  selector: 'app-asset-list',
  templateUrl: './asset-list.component.html',
  styleUrls:['./asset-list.component.scss']
})
export class AssetListComponent extends BaseListComponent implements AfterViewInit{

  @Input()
  pageType = PageType.SEARCH;

  @Input()
  searchStoreName = "assets"

  @Input()
  extraSearchFields: AssetSearchField[];

  @Input()
  actions: Action[];

  @ViewChild("assetGridComponent", { static: false })
  assetGridComponent: AssetGridComponent;

  constructor(
    private router: Router,
    private assetService: AssetService,
    private dialog: MatDialog,
    private alertService: AlertService,
    private pageDataService:PageDataService
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
      dateMode : "start",
      type : "monthYear"
    });

    this.advancedSearchFields.push({
      key: "toDate",
      label: "To Date",
      dateMode : "end",
      type : "monthYear"
    });

    this.advancedSearchFields.push({
      key: "assetType",
      label: "Type",
      type : "dropdown",
      options : this.assetService.getAssetTypesAsOptions()
    });

    this.advancedSearchFields.push({
      key: "favorite",
      label: "Favorite",
      type : "dropdown",
      options : this.assetService.getYesAndNoOptions()
    });

    this.extraSearchFields.push({
      key: "resultType",
      label: "Result Type",
      type : "text",
      value: "SEARCH"
    });
  }
 

  private populateActions() {

    if(this.pageType === PageType.SEARCH) {
      this.actions.push({
        id: "upload",
        icon: "upload",
        tooltip: "Upload Asset(s)",
        onClick: () => {
          this.router.navigate(['/asset/upload']);
        }
      });
  
      this.actions.push({
        id: "delete",
        icon: "delete",
        styleClass : "red",
        tooltip: "Delete",
        hidden: () =>  { 
          let hidden = true;
          if(this.assetGridComponent && this.assetGridComponent.isAnyAssetSelected) {
              hidden = false
          }
          return hidden;
        },
        onClick: () => {
          this.dialog.open(DialogComponent, {
            data: {
              title: "Are you sure?",
              message: `This will delete the selected item${this.assetGridComponent.selectedAssets.length > 1 ? 's':''}`,
              actions: [
                { label: "CANCEL" },
                {
                  label: "OK",
                  type: "flat",
                  onClick: () => {
                    const assetIds = this.assetGridComponent.selectedAssets.map((asset:any) => 
                    {
                      return asset.id
                    });
  
                    this.assetService.delete(assetIds).subscribe(response => {
                      this.alertService.showSuccess(`Item${this.assetGridComponent.selectedAssets.length > 1 ? 's':''} deleted successfully`);
                      this.assetGridComponent.callSearch();
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

  search(params:any) {
    return this.assetService.search(params);
  }

  openAssetView(event:any) {
    const currentAssetId = event.currentAssetId;
    const assetIds = event.assetIds;
    this.pageDataService.setPageData('app-asset-view',assetIds);
    this.router.navigate(['/asset/view/' + currentAssetId]);
  }
}
