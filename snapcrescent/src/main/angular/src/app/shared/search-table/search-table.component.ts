import { SelectionModel } from '@angular/cdk/collections';
import { Component,Input, ContentChildren,QueryList, SimpleChanges, OnInit, OnChanges, AfterViewInit, EventEmitter, Output  } from '@angular/core';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { MatSort, MatSortable, Sort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';
import { ViewChild } from '@angular/core'
import { BaseUiBean } from 'src/app/core/models/base.model';
import { Column, SearchPageViewType, SearchTableField } from './search-table.model';
import { SearchTableCellDefDirective, SearchTableFooterCellDefDirective, SearchTableHeaderCellDefDirective } from './search-table.directive';
import { MatCheckbox } from '@angular/material/checkbox';
import { Action } from 'src/app/core/models/action.model';
import { MatExpansionPanel } from '@angular/material/expansion';
import { FormBuilder, FormGroup } from '@angular/forms';
import { Observable } from 'rxjs';
import { BreadCrumb } from '../breadcrumb/breadcrumb.model';
import { StringUtils } from 'src/app/core/utils/string-utils';
import { MatSelectChange } from '@angular/material/select';

@Component({
  selector: 'app-search-table',
  templateUrl: './search-table.component.html',
  styleUrls: ['./search-table.component.scss']
})
export class SearchTableComponent implements OnInit,OnChanges, AfterViewInit {

  SearchPageViewType = SearchPageViewType;

  @Input()
	searchPageViewType: SearchPageViewType = SearchPageViewType.SEARCH;

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
  dataSource = new MatTableDataSource<BaseUiBean>([]);

  @Input()
  advancedSearchFields: Array<SearchTableField> = [];
  
  @Input()
  extraSearchFields: Array<SearchTableField> = [];

  @Output()
  onSelectionChange:EventEmitter<boolean> = new EventEmitter<boolean>();

  selection = new SelectionModel<BaseUiBean>(true, []);

  searchFormGroup: FormGroup = this.formBuilder.group({});

  pageSizeOptions:number[] = [25,50,100,200];

  @ViewChild(MatSort, { static: true }) sort: MatSort;
  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;
  @ViewChild("tableCheckbox") private tableCheckbox: MatCheckbox;
  @ViewChild(MatExpansionPanel) expansionPanel: MatExpansionPanel;

  @ContentChildren(SearchTableCellDefDirective, { descendants: true })
  cellDefs: QueryList<SearchTableCellDefDirective>;
  @ContentChildren(SearchTableHeaderCellDefDirective, { descendants: true })
  headerCellDefs: QueryList<SearchTableHeaderCellDefDirective>;
  @ContentChildren(SearchTableFooterCellDefDirective, { descendants: true })
  footerCellDefs: QueryList<SearchTableFooterCellDefDirective>;

  get standardDateColumnIds() {
    return ["startDate", "endDate"]
  }

  get displayedColumns() {
    return [
      ...(this.enableSelection ? ["select"] : []),
      ...this.visibleColumns.map(item => item.id),
      ...(["more"])
    ];
  }

  constructor(
    private formBuilder: FormBuilder,
  ) {

  }

  ngOnInit() {
    this.enableSelection = this.enableSelection || this.searchPageViewType === SearchPageViewType.SELECTION || this.searchPageViewType === SearchPageViewType.VIEW;
    this.initSearchForm();
    this.sort.sort(<MatSortable>({ id: this.defaultSortColumn, start: this.defaultSortDirection }));
    
  }

  ngAfterViewInit() {
    
  }

  ngOnChanges(changes: SimpleChanges) {

    if (changes['advancedSearchFields']) {
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

  pagingChanged(pageEvent: PageEvent) {
    this.callSearch();
  }

  sortingChanged(sort: Sort) {
    this.callSearch();
  }

  callQuickSearch() {
    const value:string = this.searchFormGroup.get('searchKeyword')?.value

    if(StringUtils.isEmpty(value)) {
      this.resetPaginatorPageSize();
    }

    this.callSearch();
  }

  callSearch() {
    
    if(this.searchPageViewType !== SearchPageViewType.VIEW) {
      
      let params:any = this.getSearchParams();
  
      if(!!this.search) {
        this.search(params).subscribe((response:any) => {
          let objects:any = response.objects;
          this.dataSource = new MatTableDataSource(objects);

          this.paginator.length = response.totalResultsCount;
          this.paginator.pageSize = response.resultCountPerPage;
          this.paginator.pageIndex = response.currentPageIndex;

          //this.dataSource.paginator = this.paginator;
          this.dataSource.sort = this.sort;
        });
      }
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

    if(this.paginator) {
      pagenumber = this.paginator.pageIndex;
      resultPerPage = this.paginator.pageSize;
    } 

    params['pagenumber'] = pagenumber;
    params['resultPerPage'] = resultPerPage;

    params['sortBy'] = this.sort.active;
    params['sortOrder'] = this.sort.direction;

    return params;
  }


  reset() {
    this.searchFormGroup.get('searchKeyword')?.reset();

    this.advancedSearchFields.forEach((item:SearchTableField) => {
      this.searchFormGroup.get(item.key)?.reset();
    });

    this.resetPaginatorPageSize();
  }

  resetPaginatorPageSize() {
    this.paginator._changePageSize(this.pageSizeOptions[0]);
  }

  updateData(data:any) {
    this.dataSource.paginator = this.paginator;
    
    this.dataSource.data = data || [];

    const selected = this.selection.selected;
    this.selection.clear();
    this.selection.select(
      ...this.dataSource.data.filter(item =>
        selected.find(
          selected_item =>
            JSON.stringify(item) === JSON.stringify(selected_item)
        )
      )
    );
  }

  cellDef(key: string) {
    return this.cellDefs.find(item => item.cellDef === key);
  }

  headerCellDef(key: string) {
    return this.headerCellDefs.find(item => item.headerCellDef === key);
  }

  footerCellDef(key: string) {
    return this.footerCellDefs.find(item => item.footerCellDef === key);
  }

  toggleAdvancedSearch() {
    
    if(this.expansionPanel) {
      this.expansionPanel.toggle();
    }
  }

  get paginationInfo() {
    return `Showing ${(this.paginator?.pageIndex * this.paginator?.pageSize) + 1} to ${(this.paginator?.pageIndex + 1) * this.paginator?.pageSize} of ${this.paginator?.length}`
  }



  isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.data.length;
    return numSelected === numRows;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle() {
    this.triggerOnSelectionChangeEvent();
    this.isAllSelected() ?
      this.selection.clear() :
      this.dataSource.data.forEach((row: BaseUiBean) => this.selection.select(row));
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(row?: BaseUiBean): string {
    if (!row) {
      return `${this.isAllSelected() ? 'Deselect' : 'Select'} all`;
    } else if(row.id) {
      return `${this.selection.isSelected(row) ? 'Deselect' : 'Select'}`;
    } else {
      return '';
    }
  }

  triggerOnSelectionChangeEvent() {
    this.onSelectionChange.emit(this.selection.isEmpty());
  }

  get visibleColumnIds() {
    return this.visibleColumns.map(item => item.id);
  }

  get visibleColumns() {
    return this.columns.filter(item => !item.hidden);
  }

  visibleColumnsChange(event: MatSelectChange) {
    const selected = event.value as Array<string>;
    
    this.columns.map(item => {
      item.hidden = !selected.includes(item.id);
    });

    const index = this.columns.findIndex(item => item.id === this.sort.active);
    if (index >= 0) {
      const next = [
        ...this.columns.slice(index),
        ...this.columns.slice(0, index)
      ].find(item => !item.hidden);
      if (next && next.id !== this.sort.active) {
        this.sort.sort({
          id: next.id,
          start: this.sort.direction as any,
          disableClear: false
        });

      }
    }
  }
}
