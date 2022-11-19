import { SelectionModel } from '@angular/cdk/collections';
import { Component,Input, SimpleChanges, OnInit, OnChanges, AfterViewInit, Inject, LOCALE_ID  } from '@angular/core';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { ViewChild } from '@angular/core'
import { AssetSearchField, AssetsGroup } from './asset-grid.model';
import { Action } from 'src/app/core/models/action.model'
import { Observable } from 'rxjs';
import { BreadCrumb } from '../breadcrumb/breadcrumb.model';
import { Asset } from 'src/app/asset/asset.model';
import { formatDate } from '@angular/common';

@Component({
  selector: 'app-asset-grid',
  templateUrl: './asset-grid.component.html',
  styleUrls: ['./asset-grid.component.scss']
})
export class AssetGridComponent implements OnInit,OnChanges, AfterViewInit {

  @Input()
  breadCrumbs:BreadCrumb[] = []

  @Input()
  defaultSortColumn: string = '';

  @Input()
  defaultSortDirection: "asc" | "desc" = "asc";

  @Input()
  actions: Action[] = [];

  @Input()
  search: Function;

  @Input()
  enablePagination = true;

  @Input()
  enableSelection = false;

  @Input()
  dataSource = new MatTableDataSource<Asset>([]);

  @Input()
  advancedSearchFields: Array<AssetSearchField> = [];
  
  assetsGroups: AssetsGroup[] = [];

 

  pageSizeOptions:number[] = [240,360, 480];

  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;

  

  constructor(
    @Inject(LOCALE_ID) public locale: string,
  ) {

  }

  ngOnInit() {
    this.enableSelection = this.enableSelection;
    this.callSearch();
  }

  ngAfterViewInit() {
  }

  ngOnChanges(changes: SimpleChanges) {

    if (changes.advancedSearchFields) {
      this.advancedSearchFields.map((item, index) => {
        if (item.options instanceof Observable) {
          const options$ = item.options;
          item.options = [];
          options$.subscribe(options => {
            item.options = options;
          });
        }
      });
    }

  }

  pagingChanged(pageEvent: PageEvent) {
    this.callSearch();
  }

  callSearch() {
      let params:any = this.getSearchParams();
  
      if(!!this.search) {
        this.search(params).subscribe((response:any) => {
          let objects:any = response.objects;
          this.dataSource = new MatTableDataSource(objects);
          this.prepareDateGroup();

          this.paginator.length = response.totalResultsCount;
          this.paginator.pageSize = response.resultCountPerPage;
          this.paginator.pageIndex = response.currentPageIndex;

        });
      }
    
  }

  prepareDateGroup() {

    this.assetsGroups = [];

    this.dataSource.data.forEach((asset:Asset)=> {

      const dataDate = new Date(asset.metadata.creationDatetime!);
      const dateDateString = formatDate(dataDate, 'EEEE, MMMM d, y' ,this.locale);
      
      let assetsGroup = this.assetsGroups.find(assetsGroup => assetsGroup.date === dateDateString);

      if(!assetsGroup) {
        assetsGroup = {date : dateDateString,assets: [], selection: new SelectionModel<Asset>(true, [])};
        this.assetsGroups.push(assetsGroup);
      }

      assetsGroup.assets.push(asset)

    });
  }

  getSearchParams() {
    let params:any = {};

    let pageNumber = 0;
    let resultPerPage = this.pageSizeOptions[0];

    if(this.paginator) {
      pageNumber = this.paginator.pageIndex;
      resultPerPage = this.paginator.pageSize;
    } 

    params['pageNumber'] = pageNumber;
    params['resultPerPage'] = resultPerPage;

    return params;
  }

  get isAnyAssetSelected() {
    return this.selectedAssets.length > 0;
  }

  get selectedAssets() {
    const selectedAssets:Asset[] = [];

    this.assetsGroups.forEach(assetsGroup => {
      selectedAssets.push(...assetsGroup.selection.selected);
    })

    return selectedAssets;
  }

  
  isAllSelected(assetsGroup:AssetsGroup) {
    const numSelected = assetsGroup.selection.selected.length;
    const numRows = assetsGroup.assets.length;
    return numSelected === numRows;
  }

  /** Selects all assets if they are not all selected; otherwise clear selection. */
  masterToggleGroup(assetsGroup:AssetsGroup) {
    this.isAllSelected(assetsGroup) ?
    assetsGroup.selection.clear() :
    assetsGroup.assets.forEach((row: Asset) => assetsGroup.selection.select(row));
  }

  toggleAsset(assetsGroup:AssetsGroup, asset: Asset) {
    assetsGroup.selection.toggle(asset)
  }

  /** The label for the checkbox on the passed row */
  assetCheckboxLabel(assetsGroup:AssetsGroup, asset: Asset): string {
      return `${assetsGroup.selection.isSelected(asset) ? 'Deselect' : 'Select'}`;
  }

  groupCheckboxLabel(assetsGroup:AssetsGroup): string {
      return `${this.isAllSelected(assetsGroup) ? 'Deselect' : 'Select'} all`;
  }

  resetPaginatorPageSize() {
    this.paginator._changePageSize(this.pageSizeOptions[0]);
  }
}
