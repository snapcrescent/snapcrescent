import { SelectionModel } from '@angular/cdk/collections';
import { Component,Input, ContentChildren,QueryList, SimpleChanges, OnInit, OnChanges, AfterViewInit  } from '@angular/core';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatSort, MatSortable, Sort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';
import { ViewChild } from '@angular/core'
import { Column, SearchTableField } from './search-grid.model';
import { SearchTableCellDefDirective, SearchTableFooterCellDefDirective, SearchTableHeaderCellDefDirective } from './search-grid.directive';
import { MatCheckbox } from '@angular/material/checkbox';
import { Action } from 'src/app/core/models/action.model';
import { MatExpansionPanel } from '@angular/material/expansion';
import { FormBuilder, FormGroup } from '@angular/forms';
import { Observable } from 'rxjs';
import { BreadCrumb } from '../breadcrumb/breadcrumb.model';
import { StringUtils } from 'src/app/core/utils/string-utils';
import { MatSelectChange } from '@angular/material/select';
import { Asset } from 'src/app/asset/asset.model';

@Component({
  selector: 'app-search-grid',
  templateUrl: './search-grid.component.html',
  styleUrls: ['./search-grid.component.scss']
})
export class SearchGridComponent implements OnInit,OnChanges, AfterViewInit {

  @Input()
  pageTitle: string = '';

  @Input()
  breadCrumbs:BreadCrumb[] = []

  @Input()
  quickSearchTitle: string = '';

  @Input()
  defaultSortColumn: string = '';

  @Input()
  defaultSortDirection: "asc" | "desc" = "asc";

  @Input()
  columns: Column[] = [];

  @Input()
  actions: Action[] = [];

  @Input()
  search: Function;

  @Input()
  enablePagination = true;

  @Input()
  showQuickSearch = true;

  @Input()
  enableSelection = false;
  
  @Input()
  dataSource = new MatTableDataSource<Asset>([]);

  @Input()
  advancedSearchFields: Array<SearchTableField> = [];
  
  @Input()
  extraSearchFields: Array<SearchTableField> = [];

  selection = new SelectionModel<Asset>(true, []);

  searchFormGroup: FormGroup = this.formBuilder.group({});

  pageSizeOptions:number[] = [25,50,100,200];

  @ViewChild(MatExpansionPanel) expansionPanel: MatExpansionPanel;
  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;

  constructor(
    private formBuilder: FormBuilder,
  ) {

  }

  ngOnInit() {
    this.enableSelection = this.enableSelection;
    this.initSearchForm(); 
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

  private initSearchForm() {

    this.searchFormGroup.addControl('searchKeyword',this.formBuilder.control('', []));

    if(this.advancedSearchFields && this.advancedSearchFields.length > 0) {

      this.advancedSearchFields.forEach((item:SearchTableField) => {
        this.searchFormGroup.addControl(item.key,this.formBuilder.control('', []));
      });

    }

    if(this.extraSearchFields && this.extraSearchFields.length > 0) {

      this.extraSearchFields.forEach((item:SearchTableField) => {
        this.searchFormGroup.addControl(item.key,this.formBuilder.control(item.value, []));
      });

    }
  }

  
  callQuickSearch() {
    const value:string = this.searchFormGroup.get('searchKeyword')?.value

    if(StringUtils.isEmpty(value)) {
      
    }

    this.callSearch();
  }

  pagingChanged(pageEvent: PageEvent) {
    this.callSearch();
  }

  sortingChanged(sort: Sort) {
    this.callSearch();
  }

  callSearch() {
    
      let params:any = this.getSearchParams();
  
      if(!!this.search) {
        this.search(params).subscribe((response:any) => {
          let objects:any = response.objects;
          this.dataSource = new MatTableDataSource(objects);

          this.paginator.length = response.totalResultsCount;
          this.paginator.pageSize = response.resultCountPerPage;
          this.paginator.pageIndex = response.currentPageIndex;

        });
      }
    
  }

  getSearchParams() {
    let params:any = {};

    const value = this.searchFormGroup.get('searchKeyword')?.value

    if(value) {
      params['searchKeyword'] = value;
    }

    this.advancedSearchFields.forEach((item:SearchTableField) => {
      const value = this.searchFormGroup.get(item.key)?.value;

      if(typeof value === 'boolean') {
        params[item.key] = value;
      } else{
        if(value) {
          params[item.key] = value;
        }
      }

      
    });

    this.extraSearchFields.forEach((item:SearchTableField) => {
      const value = this.searchFormGroup.get(item.key)?.value;

      if(value) {
        params[item.key] = value;
      }
    });

    let pagenumber = 0;
    let resultPerPage = this.pageSizeOptions[0];

   
    return params;
  }


  reset() {
    this.searchFormGroup.get('searchKeyword')?.reset();

    this.advancedSearchFields.forEach((item:SearchTableField) => {
      this.searchFormGroup.get(item.key)?.reset();
    });

  }

  toggleAdvancedSearch() {
    
    if(this.expansionPanel) {
      this.expansionPanel.toggle();
    }
  }

  
  isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.data.length;
    return numSelected === numRows;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle() {
    this.isAllSelected() ?
      this.selection.clear() :
      this.dataSource.data.forEach((row: Asset) => this.selection.select(row));
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(row?: Asset): string {
    if (!row) {
      return `${this.isAllSelected() ? 'Deselect' : 'Select'} all`;
    } else if(row.id) {
      return `${this.selection.isSelected(row) ? 'Deselect' : 'Select'}`;
    } else {
      return '';
    }
  }

  get paginationInfo() {
    return `Showing ${(this.paginator?.pageIndex * this.paginator?.pageSize) + 1} to ${(this.paginator?.pageIndex + 1) * this.paginator?.pageSize} of ${this.paginator?.length}`
  }

}
