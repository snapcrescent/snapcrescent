import { Option } from "src/app/core/models/option.model";
import { Observable } from 'rxjs';
import { Asset } from "src/app/asset/asset.model";
import { SelectionModel } from "@angular/cdk/collections";

export class Column {
  id: string = '';
  label: string = '';
  class?: string = '';
  onClick? :Function = () => {};
  hidden? : boolean = false;
  fixed ?: boolean = false;
  headerStyle?: { [key: string]: string };
  cellStyle?: Function;
}

export class AssetSearchField {
  key: string;
  label: string;
  value?:any;
  options?: Array<Option> | Observable<Array<Option>>;
  multiple?: boolean;
  dateMode? : "start" | "end" = "start";
  type:
     "text"
    | "date"
    | "monthYear"
    | "dropdown";
    
}

export class AssetsGroup {
  date : string;
  assets : Asset[] = [];
  selection  : SelectionModel<Asset>;
}


