import { Component, OnInit, AfterViewInit, Input, OnDestroy, Inject } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute, Router } from '@angular/router';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { AssetService } from 'src/app/asset/asset.service';
import { AlertService } from 'src/app/shared/alert/alert.service';

@Component({
  selector: 'app-asset-view',
  templateUrl: './asset-view.component.html',
  styleUrls: ['./asset-view.component.scss']
})
export class AssetViewComponent extends BaseComponent implements OnInit, AfterViewInit, OnDestroy {

  @Input()
  actions: Action[] = [];

  currentAssetId:number;
  currentAsset:Asset;

  assetIds:number[]= [];

  initialX = 0;
  initialY = 0;


  constructor(
    public dialogRef: MatDialogRef<AssetViewComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    private router: Router,
    public activatedRoute: ActivatedRoute,
    private dialog: MatDialog,
    private assetService: AssetService,
    private alertService:AlertService,
  ) {
      super();

      dialogRef.disableClose = true;
      this.currentAssetId = data.currentAssetId;
      this.assetIds = data.assetIds;
  }

  ngOnInit() {
    
  }

  ngAfterViewInit() {
  
  }

  navigateSearch() {
    this.dialogRef.close();
  }

  updateAsset() {
    this.assetService.updateMetadata(this.currentAssetId).subscribe(response => {
      this.alertService.showSuccess(`Item updated successfully`);
    });
  }

  deleteAsset() {
    this.dialog.open(DialogComponent, {
      data: {
        title: "Are you sure?",
        message: `This will delete the selected item`,
        actions: [
          { label: "CANCEL" },
          {
            label: "OK",
            type: "flat",
            onClick: () => {
              this.assetService.delete([this.currentAssetId]).subscribe(response => {
                this.alertService.showSuccess(`Item deleted successfully`);
                this.assetIds.splice(this.assetIds.indexOf(+this.currentAssetId),1);
                this.changeCurrentAssetAsset(true);
              });
            }
          }
        ]
      }
    });
  }

  changeCurrentAssetAsset(moveAhead: boolean) {

    let assetId: number = 0;

    if(moveAhead) {
      assetId = this.nextAssetId();
    } else {
      assetId = this.previousAssetId();
    }

    if(assetId > 0) {
      this.currentAssetId = assetId; 
    } else {
      this.dialogRef.close();
    }
  }

  nextAssetId() {
      const index = this.assetIds.indexOf(+this.currentAssetId);

      if(index < this.assetIds.length - 1) {
        return this.assetIds[index + 1]; 
      } else{
        return -1;
      }
  }

  previousAssetId() {
    const index = this.assetIds.indexOf(+this.currentAssetId);

    if(index > 0 ) {
      return this.assetIds[index - 1]; 
    } else{
      return -1;
    }
}

  ngOnDestroy(): void {
   
  }
  
  

}
