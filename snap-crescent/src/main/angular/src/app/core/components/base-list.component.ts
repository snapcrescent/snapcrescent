import { AssetSearchField, Column } from "src/app/shared/asset-grid/asset-grid.model";
import { Action } from "../models/action.model";
import { BaseComponent } from "./base.component";

export class BaseListComponent extends BaseComponent {

    columns: Column[] = [];
    actions: Action[] = [];
    advancedSearchFields: AssetSearchField[] = [];
    extraSearchFields: AssetSearchField[] = [];

}