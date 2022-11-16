import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { AssetService } from 'src/app/asset/asset.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';

@Component({
  selector: 'app-image-list',
  templateUrl: './image-list.component.html'
})
export class ImageListComponent extends BaseListComponent{

  constructor(
    private router: Router,
    private assetService: AssetService,
  ) {
    super();
  }

  ngOnInit() {

    this.populateAdvancedSearchFields();
    this.populateTableColumns();
    this.populateActions();
  }

  private populateAdvancedSearchFields() {
    this.advancedSearchFields.push({
      key: "fromDate",
      label: "Start Date",
      type : "date"
    });

    this.advancedSearchFields.push({
      key: "toDate",
      label: "End Date",
      type : "date"
    });
  }

  private populateTableColumns() {
    this.columns.push({
      id: "name",
      label: "Name",
      class: "fw-bold",
      onClick: (element:Asset) => {
        this.router.navigate(['/contest/manage', element.id]);
      },
      fixed : true,
    });

    this.columns.push({
      id: "startDate",
      label: "Start Date"
    });

    this.columns.push({
      id: "endDate",
      label: "End Date"
    });

    this.columns.push({
      id: "contestStatusName",
      label: "Status"
    });
  }

  private populateActions() {
    this.actions.push({
      id: "upload",
      icon: "upload",
      tooltip: "Upload Image(s)",
      onClick: () => {
        this.router.navigate(['/image/upload']);
      }
    });
  }

  


  search(params:any) {
    params.resultType="SEARCH";
    params.sortBy="creationDate";
    params.sortOrder="desc";
    params.assetType=AssetType.PHOTO.id;
    return this.assetService.search(params);
  }
}
