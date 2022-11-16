import { Option } from "src/app/core/models/option.model";
import { Observable } from 'rxjs';

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

export class SearchTableField {
  key: string;
  label: string;
  value?:any;
  options?: Array<Option> | Observable<Array<Option>>;
  multiple?: boolean;
  type:
     "text"
    | "date"
    | "dropdown";
    
}