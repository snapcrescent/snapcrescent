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

export class AssetGroup {
  date : string;
  assets : Asset[] = [];
}

export class Section {
  id: string; 
  monthYear : Date;
  height : number;
  assetCount : number;
  searchInProgress: boolean = false;
  segments : Segment[];

  constructor(
    monthYear : Date,
    assetCount : number,
    height : number
    ) {
      this.id = monthYear.getTime().toString();
      this.monthYear = monthYear;
      this.assetCount = assetCount;
      this.height = height;
      this.segments = [];
  }

  clone(monthYear:Date) {
    return new Section(
      monthYear,
      this.assetCount,
      this.height
    )
  }
}

export class Segment {
  date : string;
  tiles : Tile[] = [];
  selection  : SelectionModel<Asset>;

  height: number;

  constructor(
    date : string,
    tiles : Tile[] = [],

    height : number
  ) {
    this.date = date;
    this.tiles = tiles;
    this.selection = new SelectionModel<Asset>(true, []);

    this.height = height;
  }
}

export class Tile {
  asset: Asset;

  width: number;
  height: number;
  top : number;
  left : number;

  constructor(
    asset: Asset,
    width: number,
    height: number,
    top : number,
    left : number
  ) {
    this.asset = asset;
    this.width = width;
    this.height = height;
    this.top = top;
    this.left = left;
  }

  static createFromBox(box: any, asset: Asset) {
    return new Tile(asset, box.width,box.height,box.top, box.left);
  }
}