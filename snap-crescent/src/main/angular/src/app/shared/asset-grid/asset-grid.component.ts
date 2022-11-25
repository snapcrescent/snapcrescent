import { SelectionModel } from '@angular/cdk/collections';
import { Component,Input, SimpleChanges, OnInit, OnChanges, AfterViewInit, Inject, LOCALE_ID, Output , EventEmitter, ElementRef } from '@angular/core';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatTableDataSource } from '@angular/material/table';
import { ViewChild } from '@angular/core'
import { AssetSearchField, AssetsGroup } from './asset-grid.model';
import { Action } from 'src/app/core/models/action.model'
import { Observable } from 'rxjs';
import { Asset, AssetType } from 'src/app/asset/asset.model';
import { formatDate } from '@angular/common';
import { FormBuilder, FormGroup } from '@angular/forms';
import { PageDataService } from 'src/app/core/services/stores/page-data.service';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-asset-grid',
  templateUrl: './asset-grid.component.html',
  styleUrls: ['./asset-grid.component.scss']
})
export class AssetGridComponent implements OnInit,OnChanges, AfterViewInit {

  @Input()
  searchStoreName: string;

  @Input()
  defaultSortColumn: string = '';

  @Input()
  defaultSortDirection: "asc" | "desc" = "desc";

  @Input()
  actions: Action[] = [];

  @Input()
  search: Function;

  @Input()
  dataSource = new MatTableDataSource<Asset>([]);

  @Input()
  advancedSearchFields: Array<AssetSearchField> = [];

  @Input()
  extraSearchFields: Array<AssetSearchField> = [];
  
  @Output()
  onOpenAssetView: EventEmitter<any> = new EventEmitter<any>();
  
  assetsGroups: AssetsGroup[] = [];
  pageSizeOptions:number[] = [250,500,1000,2000];

  AssetType = AssetType;

  searchFormGroup: FormGroup = this.formBuilder.group({});

  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;

  @ViewChild('assetGridContainer') 
  private assetGridContainer: ElementRef;
  

  appBaseURL:string;
  

  constructor(
    @Inject(LOCALE_ID) public locale: string,
    private formBuilder: FormBuilder,
    private pageDataService:PageDataService
  ) {

      const parsedUrl = new URL(window.location.href);
      const baseUrl = parsedUrl.origin;
      this.appBaseURL = baseUrl.substring(0, baseUrl.lastIndexOf(":"));

  }

  ngOnInit() {
    this.initSearchForm();
  }

  ngAfterViewInit() {
    this.getStoredSearchParams();
    this.callSearch(false);
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

  private initSearchForm() {

    if(this.advancedSearchFields && this.advancedSearchFields.length > 0) {

      this.advancedSearchFields.forEach((item:AssetSearchField) => {
        this.searchFormGroup.addControl(item.key,this.formBuilder.control('', []));
      });

    }

    if(this.extraSearchFields && this.extraSearchFields.length > 0) {

      this.extraSearchFields.forEach((item:AssetSearchField) => {
        this.searchFormGroup.addControl(item.key,this.formBuilder.control(item.value, []));
      });

    }

   
  }

  getStoredSearchParams() {
    const params = this.pageDataService.getSearchPageData(this.searchStoreName);

    if(params) {
      Object.keys(params).forEach(key => {
        if(key === 'pageNumber') {
          this.paginator.pageIndex = params[key];
        } else if(key === 'resultPerPage') {
          this.paginator.pageSize = params[key];
        } else if(key === 'sortBy') {
          this.defaultSortColumn = params[key];
        } else if(key === 'sortOrder') {
         this.defaultSortDirection = params[key];
        } else {
          const control = this.searchFormGroup.get(key)
  
          if(control) {
            control.patchValue(params[key]);
          }
        }
      });
    }
    
  }

  pagingChanged(pageEvent: PageEvent) {
    this.callSearch(false);
  }

  reset() {
    this.advancedSearchFields.forEach((item:AssetSearchField) => {
      this.searchFormGroup.get(item.key)?.reset();
    });


    this.pageDataService.setPageData(this.searchStoreName);
    this.resetPaginatorPageSize();
  }

  callSearch(freshSearch:boolean) {
      let params:any = this.getSearchParams(freshSearch);
 
      this.pageDataService.setSearchPageData(this.searchStoreName, params);
      
      if(!!this.search) {
        this.search(params).subscribe((response:any) => {
          let objects:any = response.objects;
          this.dataSource = new MatTableDataSource(objects);
          this.prepareDateGroup();

          this.paginator.length = response.totalResultsCount;
          this.paginator.pageSize = response.resultCountPerPage;
          this.paginator.pageIndex = response.currentPageIndex;

          if(!freshSearch) {
            this.scrollToPreviousPosition();
          }
          
        });
      }
  }

  scrollToPreviousPosition() {
      setTimeout(() => {
        const state =  this.pageDataService.getPageData(this.searchStoreName);

          if(state) {
            this.assetGridContainer.nativeElement.scroll({
              top: state.scrollHeight,
              left: 0,
              behavior: 'smooth'
            });
          }
      }, 500);
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

  getSearchParams(freshSearch:boolean) {
    let params:any = {};

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

    this.extraSearchFields.forEach((item:AssetSearchField) => {
      const value = this.searchFormGroup.get(item.key)?.value;

      if(typeof value === 'boolean') {
        params[item.key] = value;
      } else{
        if(value) {
          params[item.key] = value;
        }
      }    
    });

    let pageNumber = 0;
    let resultPerPage = this.pageSizeOptions[0];

    if(!freshSearch && this.paginator) {
      pageNumber = this.paginator.pageIndex;
      resultPerPage = this.paginator.pageSize;
    } 

    params['pageNumber'] = pageNumber;
    params['resultPerPage'] = resultPerPage;

    params['sortBy'] = this.defaultSortColumn;
    params['sortOrder'] = this.defaultSortDirection;

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

  onThumbnailClick(assetsGroup:AssetsGroup, asset: Asset) {
    if(this.isAnyAssetSelected) {
      this.toggleAssetSelection(assetsGroup,asset)
    } else{
      this.openAssetView(asset);
    }

  }

  toggleAssetSelection(assetsGroup:AssetsGroup, asset: Asset) {
    assetsGroup.selection.toggle(asset)
  }
  
  openAssetView(asset: Asset) {

    const data = {
      currentAssetId: asset.id,
      assetIds: this.dataSource.data.map(asset=> { return asset.id })
    }

    const state:any = {};
    state['scrollHeight'] = this.assetGridContainer.nativeElement.scrollTop;

    this.pageDataService.setPageData(this.searchStoreName,state);


    this.onOpenAssetView.emit(data);
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

  getThumbnailStreamUrl(asset:Asset) {
    return this.appBaseURL + `:${environment.videoServerUrlPort}/asset/${asset.id}/thumbnail`;
  }
}
