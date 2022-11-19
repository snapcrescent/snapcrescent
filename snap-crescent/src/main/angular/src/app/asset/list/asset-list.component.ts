import { Component , ViewChild, AfterViewInit} from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { MatButton } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatExpansionPanel } from '@angular/material/expansion';
import { Router } from '@angular/router';
import { AssetService } from 'src/app/asset/asset.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetGridComponent } from 'src/app/shared/asset-grid/asset-grid.component';
import { AssetSearchField } from 'src/app/shared/asset-grid/asset-grid.model';
import { DialogComponent } from 'src/app/shared/dialog/dialog.component';
import { ScreenSize } from 'src/app/shared/screen-size-detector/screen-size-detector.model';
import { ScreenSizeDetectorService } from 'src/app/shared/screen-size-detector/screen-size-detector.service';
import { delay } from 'rxjs/operators';

@Component({
  selector: 'app-asset-list',
  templateUrl: './asset-list.component.html'
})
export class AssetListComponent extends BaseListComponent implements AfterViewInit{

  searchFormGroup: FormGroup = this.formBuilder.group({});

  @ViewChild("assetGridComponent", { static: false })
  assetGridComponent: AssetGridComponent;

  @ViewChild(MatExpansionPanel) expansionPanel: MatExpansionPanel;

  screenSize: ScreenSize;

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private assetService: AssetService,
    private dialog: MatDialog,
    private alertService: AlertService,
    private screenSizeDetectorService: ScreenSizeDetectorService
  ) {
    super();
  }

  ngOnInit() {
    this.populateAdvancedSearchFields();;
    this.populateActions();
    this.initSearchForm();
  }

  ngAfterViewInit() {

    this.screenSize = this.screenSizeDetectorService.getCurrentSize();
    this.adjustUIForScreen();

    this.screenSizeDetectorService.onResize$
      .pipe(delay(0))
      .subscribe(x => {
        this.screenSize = x;

        this.adjustUIForScreen();
      });
  }

  private adjustUIForScreen() {
    if(this.screenSize === ScreenSize.XS 
      || this.screenSize === ScreenSize.SM
      || this.screenSize === ScreenSize.MD) {
      this.expansionPanel.close();
    }
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

    this.advancedSearchFields.push({
      key: "active",
      label: "Show Deleted",
      type : "dropdown",
      options : this.assetService.getInvertedYesAndNoOptions()
    });
    
  }
 

  private populateActions() {
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

  
  private initSearchForm() {

    if(this.advancedSearchFields && this.advancedSearchFields.length > 0) {

      this.advancedSearchFields.forEach((item:AssetSearchField) => {
        this.searchFormGroup.addControl(item.key,this.formBuilder.control('', []));
      });

    }
  }

  toggleAdvancedSearch() {
    
    if(this.expansionPanel) {
      this.expansionPanel.toggle();
    }
  }

  search(params:any) {

    this.advancedSearchFields.forEach((item:AssetSearchField) => {
      const value = this.searchFormGroup.get(item.key)?.value;

      if(typeof value === 'boolean') {
        params[item.key] = value;
      } else{
        if(value) {
          params[item.key] = value;
        }
      }      
    });

    params.resultType="SEARCH";
    params.sortBy="creationDate";
    params.sortOrder="desc";

    return this.assetService.search(params);
  }

  reset() {
    this.advancedSearchFields.forEach((item:AssetSearchField) => {
      this.searchFormGroup.get(item.key)?.reset();
    });

    this.assetGridComponent.resetPaginatorPageSize();
  }
}
