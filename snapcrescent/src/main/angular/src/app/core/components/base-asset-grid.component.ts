import { AssetSearchField, Column } from "src/app/shared/asset-grid/asset-grid.model";
import { Action } from "../models/action.model";
import { PageType } from "../models/page-type.model";
import { BaseComponent } from "./base.component";

export class BaseAssetGridComponent extends BaseComponent {

    pageType = PageType.SEARCH
    columns: Column[] = [];
    actions: Action[] = [];
    advancedSearchFields: AssetSearchField[] = [];
    extraSearchFields: AssetSearchField[] = [];

    PageType = PageType;

}