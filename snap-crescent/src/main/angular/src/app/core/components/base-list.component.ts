import { Column, SearchTableField } from "src/app/shared/search-grid/search-grid.model";
import { Action } from "../models/action.model";
import { BaseComponent } from "./base.component";

export class BaseListComponent extends BaseComponent {

    columns: Column[] = [];
    actions: Action[] = [];
    advancedSearchFields: SearchTableField[] = [];
    extraSearchFields: SearchTableField[] = [];

}