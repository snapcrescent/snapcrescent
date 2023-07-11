import { Action } from "../models/action.model";
import { PageType } from "../models/page-type.model";
import { BaseComponent } from "./base.component";
import { Column, SearchTableField } from "src/app/shared/search-table/search-table.model";

export class BaseListComponent extends BaseComponent {

    pageType = PageType.SEARCH
    columns: Column[] = [];
    actions: Action[] = [];
    advancedSearchFields: SearchTableField[] = [];
    extraSearchFields: SearchTableField[] = [];

    PageType = PageType;

}