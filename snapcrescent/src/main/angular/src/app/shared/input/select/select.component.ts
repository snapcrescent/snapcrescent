import {
  Component,
  Self,
  Optional,
  OnInit,
  OnChanges,
  SimpleChanges,
  Input,
  Output,
  EventEmitter,
  ViewChild,
  ElementRef
} from "@angular/core";
import { NgControl, ControlValueAccessor } from "@angular/forms";
import { MatInput } from "@angular/material/input";
import { MatSelect, MatSelectChange } from "@angular/material/select";
import { Option } from "src/app/core/models/option.model";

@Component({
  selector: "app-select",
  templateUrl: "./select.component.html",
})
export class SelectComponent
  implements ControlValueAccessor, OnInit, OnChanges {
  constructor(
    @Self()
    @Optional()
    public ngControl: NgControl,
    public elementRef: ElementRef
  ) {
    if (this.ngControl) {
      this.ngControl.valueAccessor = this;
    }
  }

  get viewValue() {
    const selected = this.select.selected;

    return selected
      ? (Array.isArray(selected) ? selected : [selected])
        .map(item => item.viewValue)
        .join("\n")
      : "";
  }

  @Input()
  placeholder: string;
  @Input()
  isRequired: boolean;
  @Input()
  disabled: boolean;
  @Input()
  options:any = [];
  @Input()
  value:any;
  @Input()
  error: string;
  
  @Output()
  change: EventEmitter<any> = new EventEmitter<any>();
  
  @ViewChild(MatSelect, { static: true })
  select: MatSelect;

  @ViewChild(MatInput, { static: true })
  input: MatInput;

  onChange = (value:any) => { };
  onTouched = () => { };
  ngOnInit() { }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes?.['options']) {
      this.amend();
    }

    if (changes?.['error']) {
      this.select.errorState = !!this.error;
    }

    if (changes?.['autoSelect']) {
      if (
        this.options
        && this.options.length
        && this.options.length === 1
        && changes?.['autoSelect'].currentValue === true
      ) {
        this.changeValue(this.options[0].value);
      }
    }
  }

  onSelectionChange(change: MatSelectChange) {
    this.changeValue(change.value);
  }

  changeValue(value:any) {
    
    if (this.value !== value) {
      this.value = value;
      this.amend();
      this.onChange(value);

      this.change.emit(value);

    }
  }

  writeValue(value:any) {
    this.changeValue(value);
    if (this.ngControl && this.ngControl.control) {
      this.ngControl.control.markAsPristine();
    }
  }

  amend() {
    const found = (this.options || []).find(
     (item:any) => JSON.stringify(item.value) === JSON.stringify(this.value)
    );
    if (found) {
      this.value = found.value;
    }
  }

  registerOnChange(fn:any) {
    this.onChange = fn;
  }

  registerOnTouched(fn:any) {
    this.onTouched = fn;
  }

  setDisabledState(disabled: boolean) {
    this.disabled = disabled;
  }
}
