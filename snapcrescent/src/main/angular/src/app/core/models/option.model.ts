export class Option {
  value:any;
  label: string;
  disabled?: boolean;
  rawValue?:any;
  ngStyle?:any;
  hidden?: boolean;
  index?: number;
  isSelected?: boolean;

  constructor(
    value:any,
    label: string,
    disabled?: boolean,
    rawValue?:any,
    ngStyle?:any,
    hidden?: boolean,
    index?: number,
    isSelected?: boolean
  ) {
    this.value = value;
    this.label = label;
    this.disabled = disabled;
    this.rawValue = rawValue;
    this.ngStyle = ngStyle;
    this.hidden = hidden;
    this.index = index;
    this.isSelected = isSelected;
  }
}
