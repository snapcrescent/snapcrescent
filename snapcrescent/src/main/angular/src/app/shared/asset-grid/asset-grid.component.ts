import { Component,Input, SimpleChanges, OnInit, OnChanges, AfterViewInit, Inject, LOCALE_ID, Output , EventEmitter, ElementRef, ViewChild } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { AssetGroup, AssetSearchField, Section, Segment, Tile } from './asset-grid.model';
import { Action } from 'src/app/core/models/action.model'
import { Asset, AssetTimeline, AssetType } from 'src/app/asset/asset.model';
import { formatDate } from '@angular/common';
import { FormBuilder, FormGroup } from '@angular/forms';
import { PageDataService } from 'src/app/core/services/stores/page-data.service';
import { Metadata } from 'src/app/metadata/metadata.model';
import { Observable } from 'rxjs';
import * as moment from 'moment';
import { environment } from 'src/environments/environment';
import { LoaderService } from '../loader/loader.service';
import createJustifiedLayout from 'justified-layout';
import { ScrubbableScrollbarComponent } from '../scrubbable-scrollbar/scrubbable-scrollbar.component';
import { CdkVirtualScrollViewport } from '@angular/cdk/scrolling';

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
  getTimeline: Function;

  @Input()
  dataSource = new MatTableDataSource<Asset>([]);

  @Input()
  advancedSearchFields: Array<AssetSearchField> = [];

  @Input()
  extraSearchFields: Array<AssetSearchField> = [];
  
  @Output()
  onOpenAssetView: EventEmitter<any> = new EventEmitter<any>();

  @ViewChild("sectionContainer", { static: false })
  sectionContainer: ElementRef;

  @ViewChild("virtualScrollViewport", { static: false })
  virtualScrollViewport: CdkVirtualScrollViewport;

  @ViewChild("scrubbableScrollbarComponent", { static: false })
  scrubbableScrollbarComponent: ScrubbableScrollbarComponent;

  sectionContainerWidth = 0;
  sections:Section[] = []
  activeSection:Section;
  sectionHeights : number[] = [];
  
  pageSizeOptions:number[] = [250,500,1000,2000];

  AssetType = AssetType;

  searchFormGroup: FormGroup = this.formBuilder.group({});
  
constructor(
    @Inject(LOCALE_ID) public locale: string,
    private formBuilder: FormBuilder,
    private loaderService: LoaderService,
    private pageDataService:PageDataService
  ) {

  }

  ngOnInit() {
    this.initSearchForm();
  }

  ngAfterViewInit() {
    this.sectionContainerWidth = this.sectionContainer.nativeElement.offsetWidth;
    this.callGetTimeline();
  }

  ngOnChanges(changes: SimpleChanges) {

    if (changes?.['advancedSearchFields']) {
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

  reset() {
    this.advancedSearchFields.forEach((item:AssetSearchField) => {
      this.searchFormGroup.get(item.key)?.reset();
    });
    this.pageDataService.setPageData(this.searchStoreName);
  }

  callGetTimeline() {
    let params:any = this.getSearchParams();
    this.pageDataService.setSearchPageData(this.searchStoreName, params);
      
    if(!!this.getTimeline) {
      this.getTimeline(params).subscribe((response:any) => {
        this.sections = [];
        let objects:AssetTimeline[] = response.objects;
        
        let transientSections:Section[] = [];
        for(const object of objects) {
          const dataDate = new Date(object.creationDateTime!);
          const unwrappedWidth = (3 / 2) * object.count * 150 * (7 / 10);
          const rows = Math.ceil(unwrappedWidth / this.sectionContainerWidth);
          const height = rows * 150;

          this.sectionHeights.push(height);

          transientSections.push(new Section(dataDate,object.count, height ));
        }

        this.sections = transientSections;
        this.scrubbableScrollbarComponent.populateTimeline(this.sections);
      });
    }
  }

  onVisibleSectionChange(indexes:number[]) {

    if(indexes && indexes[0] > -1) {
     const startIndex = indexes[0];
     const endIndex = indexes[1];

     const mid = Math.round((endIndex + startIndex) /2);

     this.activeSection = this.sections[mid];
      for(let i = startIndex; i <= endIndex; i++) {
        if(this.sections[i]) {
          this.callSearch(this.sections[i]);
        }
      }
    }
  }

  onActiveSectionChange(activeSection:Section) {
    if(activeSection) {
      const section = this.sections.find(sectionItem => sectionItem.monthYear.getFullYear() == activeSection.monthYear.getFullYear() && sectionItem.monthYear.getMonth() == activeSection.monthYear.getMonth());
    
      if(section) {
        this.virtualScrollViewport.scrollToIndex(this.sections.indexOf(section));
        this.callSearch(section);
      }
    }
    
  }

  refresh() {
    
  }

  callSearch(section:Section) {
    if((!section.segments || (section.segments && section.segments.length === 0)) && section.searchInProgress == false) {
      let params:any = this.getSearchParams(section);
 
      this.pageDataService.setSearchPageData(this.searchStoreName, params);
      
      if(!!this.search) {
        section.searchInProgress = true;
        this.loaderService.setOverrideSpinner(true);

        this.search(params).subscribe((response:any) => {
          let objects:any = response.objects;
          this.dataSource = new MatTableDataSource(objects);
          this.prepareDateGroup(section);
          section.searchInProgress = false;

          this.loaderService.setOverrideSpinner(false);
        });
      }
    }
  }
  
 

  prepareDateGroup(section:Section) {

    let assetGroups: AssetGroup[] = [];

    this.dataSource.data.forEach((asset:Asset, index: number)=> {

      const dataDate = new Date(asset.metadata.creationDateTime!);
      const dateDateString = formatDate(dataDate, 'EEEE, MMMM d, y' ,this.locale);

      let assetGroup = assetGroups.find(assetGroup => assetGroup.date === dateDateString);

      if(!assetGroup) {
        assetGroup = new AssetGroup();
        assetGroup.date = dateDateString;
        assetGroup.assets = [];

        assetGroups.push(assetGroup);
      }

      asset.thumbnail.url =  `${environment.backendUrl}/thumbnail/${asset.thumbnail.token}/stream`;

      assetGroup.assets.push(asset);
    });


    let segments:Segment[] = [];

    assetGroups.forEach((assetGroup:AssetGroup)=> {

      let aspectRatios = assetGroup.assets.map((asset:Asset) => 
      { 
        const metadata:Metadata = asset.metadata;
        let height = metadata.height ;
        let width = metadata.width ;

        if(metadata.orientation == 6 || metadata.orientation == 8) {
          height = metadata.width ;
          width = metadata.height ;
        }
        
        return Math.ceil((width/height) * (10 ** 2)) / (10 ** 2);
      });

      const geometry: any = createJustifiedLayout(aspectRatios, {
        containerWidth: this.sectionContainerWidth,
        targetRowHeight: 150,
        boxSpacing : 5
      });
  
      geometry.boxes.forEach((box:any) => {
        box.top = box.top + 30;
      });

      let tiles:Tile[] = assetGroup.assets.map((asset:Asset, index:number) => 
      { 
        return Tile.createFromBox(geometry.boxes[index],asset);
      });

      segments.push(new Segment(assetGroup.date, tiles, geometry.containerHeight));
    });

    section.segments = segments;

    this.sections = [...this.sections];

    setTimeout(() => { 
      const sectionDOMElement = document.getElementById(section.id);

      if(sectionDOMElement) {
        section.height = sectionDOMElement.offsetHeight;

        this.sectionHeights = this.sections.map((section:Section) => { return section.height });
      }
    },2000);
  }

  getSearchParams(section?:Section) {
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

    if(section) {
      params['fromDate'] = moment(section.monthYear).startOf("day").valueOf();
      params['toDate'] = moment(section.monthYear).endOf("day").valueOf();
    }

    params['sortBy'] = this.defaultSortColumn;
    params['sortOrder'] = this.defaultSortDirection;

    return params;
  }

  get isAnyAssetSelected() {
    return this.selectedAssets.length > 0;
  }

  get selectedAssets() {
    const selectedAssets:Asset[] = [];

    this.sections.forEach((section:Section) => {
      if(section.segments) {
        section.segments.forEach(segment => {
          selectedAssets.push(...segment.selection.selected);
        });
      }
    });

    return selectedAssets;
  }

  
  isAllSelected(segment:Segment) {
    const numSelected = segment.selection.selected.length;
    const numRows = segment.tiles.length;
    return numSelected === numRows;
  }

  /** Selects all assets if they are not all selected; otherwise clear selection. */
  masterToggleGroup(segment:Segment) {
    this.isAllSelected(segment) ?
    segment.selection.clear() :
    segment.tiles.forEach((tile: Tile) => segment.selection.select(tile.asset));
  }

  onThumbnailClick(segment:Segment, asset: Asset) {
    if(this.isAnyAssetSelected) {
      this.toggleAssetSelection(segment,asset)
    } else{
      this.openAssetView(asset);
    }

  }

  toggleAssetSelection(segment:Segment, asset: Asset) {
    segment.selection.toggle(asset)
  }
  
  openAssetView(asset: Asset) {

    const data = {
      currentAssetId: asset.id,
      assetIds: this.sections.map((section:Section) => { 
              return section.segments.map(
                      (segment:Segment) => {
                        return segment.tiles.map((tile:Tile) => 
                          {
                            return tile.asset.id
                          }).flat();
                      }).flat();
                }).flat()        
    }

    this.onOpenAssetView.emit(data);
  }

  /** The label for the checkbox on the passed row */
  assetCheckboxLabel(segment:Segment, asset: Asset): string {
      return `${segment.selection.isSelected(asset) ? 'Deselect' : 'Select'}`;
  }

  groupCheckboxLabel(segment:Segment): string {
      return `${this.isAllSelected(segment) ? 'Deselect' : 'Select'} all`;
  }
}
