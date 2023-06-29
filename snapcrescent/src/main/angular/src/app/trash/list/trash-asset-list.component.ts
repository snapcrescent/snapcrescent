import { Component , ViewChild, AfterViewInit} from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { AssetService } from 'src/app/asset/asset.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { AssetListComponent } from 'src/app/asset/list/asset-list.component';

@Component({
  selector: 'app-trash-asset-list',
  templateUrl: './trash-asset-list.component.html',
  styleUrls:['./trash-asset-list.component.scss']
})
export class TrashAssetListComponent extends BaseListComponent implements AfterViewInit{

  searchStoreName = "trash-assets"

  @ViewChild("assetListComponent", { static: false })
  assetListComponent: AssetListComponent;

  constructor(
    private assetService: AssetService,
    private dialog: MatDialog,
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
      key: "active",
      label: "active",
      type : "text",
      value: "false"
    });
  }
 

  private populateActions() {

    this.actions.push({
      id: "restore",
      icon: "restore_from_trash",
      styleClass : "primary",
      tooltip: "Restore",
      hidden: () =>  { 
        let hidden = true;
        if(this.assetListComponent && this.assetListComponent && this.assetListComponent.assetGridComponent.isAnyAssetSelected) {
            hidden = false
        }
        return hidden;
      },
      onClick: () => {
        this.dialog.open(DialogComponent, {
          data: {
            title: "Are you sure?",
            message: `This will restore the selected item${this.assetListComponent.assetGridComponent.selectedAssets.length > 1 ? 's':''}`,
            actions: [
              { label: "CANCEL" },
              {
                label: "OK",
                type: "flat",
                onClick: () => {
                  const assetIds = this.assetListComponent.assetGridComponent.selectedAssets.map((asset:any) => 
                  {
                    return asset.id
                  });

                  this.assetService.popFromInactive(assetIds).subscribe(response => {
                    this.alertService.showSuccess(`${assetIds.length} Item${assetIds.length > 1 ? 's':''} restored successfully`);
                    this.assetListComponent.assetGridComponent.refresh();
                  });
                }
              }
            ]
          }
        });
      }
    });

    this.actions.push({
      id: "delete",
      icon: "delete_forever",
      styleClass : "red",
      tooltip: "Delete Permanently",
      hidden: () =>  { 
        let hidden = true;
        if(this.assetListComponent && this.assetListComponent.assetGridComponent && this.assetListComponent.assetGridComponent.isAnyAssetSelected) {
            hidden = false
        }
        return hidden;
      },
      onClick: () => {
        this.dialog.open(DialogComponent, {
          data: {
            title: "Are you sure?",
            message: `This will permanently delete the selected item${this.assetListComponent.assetGridComponent.selectedAssets.length > 1 ? 's':''}`,
            actions: [
              { label: "CANCEL" },
              {
                label: "OK",
                type: "flat",
                onClick: () => {
                  const assetIds = this.assetListComponent.assetGridComponent.selectedAssets.map((asset:any) => 
                  {
                    return asset.id
                  });

                  this.assetService.deletePermanently(assetIds).subscribe(response => {
                    this.alertService.showSuccess(`${assetIds.length} Item${assetIds.length > 1 ? 's':''} permanently deleted successfully`);
                    //this.assetListComponent.assetGridComponent.callSearch();
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
