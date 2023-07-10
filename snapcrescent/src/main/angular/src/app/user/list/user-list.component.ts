import { Component, Input, OnInit, AfterViewInit, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { SearchPageViewType, SearchTableField } from 'src/app/shared/search-table/search-table.model';
import { UserService } from '../user.service';
import { User } from '../user.model';
import { Action } from 'src/app/core/models/action.model';
import { SearchTableComponent } from 'src/app/shared/search-table/search-table.component';
import { BaseListComponent } from 'src/app/core/components/base-list.component';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent extends BaseListComponent implements OnInit, AfterViewInit {

  @Input()
  searchPageViewType: SearchPageViewType = SearchPageViewType.SEARCH;

  @Input()
  data: User[] = []

  @Input()
  override actions: Action[] = [];

  @Input()
  override extraSearchFields: SearchTableField[] = [];

  @ViewChild("usersTable", { static: false })
  usersTable: SearchTableComponent;

  constructor(
    private router: Router,
    private userService: UserService
  ) {
    super();
  }

  ngOnInit() {
    if(this.searchPageViewType === SearchPageViewType.SEARCH
      || this.searchPageViewType === SearchPageViewType.SELECTION) {
        this.populateAdvancedSearchFields();
      }
    
    this.populateTableColumns();

    if(this.searchPageViewType === SearchPageViewType.SEARCH) {
      this.populateActions();
    }
    
  }

  ngAfterViewInit() {

    if(this.searchPageViewType === SearchPageViewType.VIEW) {
        this.updateTableData(this.data);
    }
  }

  updateTableData(data:User[]) {
    this.usersTable.updateData(data);
  }

  private populateAdvancedSearchFields() {
  
    this.advancedSearchFields.push({
      key: "userType",
      label: "User Type",
      type : "dropdown",
      options : this.userService.getUserTypesAsOptions()
    });
  }

  private populateTableColumns() {
    this.columns.push({
      id: "fullName",
      label: "Name",
      class: "fw-bold",
      onClick: (element:any) => {
        this.router.navigate(['/admin/user/manage', element.id]);
      },
      fixed : true,
    });

    this.columns.push({
      id: "username",
      label: "User Name",
    });

  }

  private populateActions() {
      this.actions.push({
        id: "add",
        icon: "add",
        tooltip: "Create User",
        onClick: () => {
          this.router.navigate(['/admin/user/create']);
        }
      });
  }


  search(params:any) {
    return this.userService.search(params);
  }
}
