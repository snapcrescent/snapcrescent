import { Component, OnInit, AfterViewInit, Input, OnDestroy } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { Asset } from 'src/app/asset/asset.model';
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute, Router } from '@angular/router';
import { PageDataService } from 'src/app/core/services/stores/page-data.service';
import { MatDialog } from '@angular/material/dialog';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { AssetService } from '../asset.service';
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
    private router: Router,
    public activatedRoute: ActivatedRoute,
    private pageDataService:PageDataService,
    private dialog: MatDialog,
    private assetService: AssetService,
    private alertService:AlertService
  ) {
      super();
      this.currentAssetId = this.activatedRoute.snapshot.params['id'];
      this.assetIds = this.pageDataService.getPageData('app-asset-view');
  }

  ngOnInit() {
    this.router.routeReuseStrategy.shouldReuseRoute = () => false;
  }

  ngAfterViewInit() {
  
  }

  navigateToAssetSearch() {
    this.router.navigate(['/asset/list/']);
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
                this.nextAsset();
              });
            }
          }
        ]
      }
    });
  }

  nextAsset() {

    const index = this.assetIds.indexOf(+this.currentAssetId);

    if(index < this.assetIds.length - 1) {
      this.currentAssetId = this.assetIds[index + 1]; 
      this.navigateToAssetView();
    }
  }

  previousAsset() {
    const index = this.assetIds.indexOf(+this.currentAssetId);

    if(index > 0) {
      this.currentAssetId = this.assetIds[index - 1]; 
      this.navigateToAssetView();
    }
  }

  navigateToAssetView() {
    this.router.navigate(['/asset/view/' + this.currentAssetId, {replaceUrl: true}]);
  }

  ngOnDestroy(): void {
   
  }
  
  

}
