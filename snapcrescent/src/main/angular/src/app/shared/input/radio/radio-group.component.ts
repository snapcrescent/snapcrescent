import {
  Component,
  Self,
  Optional,
  OnInit,
  OnChanges,
  SimpleChanges,
  Input,
  Output,
  EventEmitter
} from "@angular/core";
import { NgControl, ControlValueAccessor } from "@angular/forms";
import { Option } from "src/app/core/models/option.model";

@Component({
  selector: "app-radio-group",
  templateUrl: "./radio-group.component.html",
  styleUrls: ['./radio-group.component.scss'],
})
export class RadioGroupComponent
  implements ControlValueAccessor, OnInit, OnChanges {
  constructor(
    @Self()
    @Optional()
    private ngControl: NgControl
  ) {
    if (this.ngControl) {
      this.ngControl.valueAccessor = this;
    }
  }

  @Input()
  placeholder: string;
  @Input()
  disabled = false;
  @Input()
  value:any;
  @Input()
  error: string;
  @Input()
  required = false;
  @Input()
  options: Array<Option>;
  
  @Output()
  change: EventEmitter<any> = new EventEmitter<any>();
  @Output()
  input: EventEmitter<any> = new EventEmitter<any>();

  selectedValue: string = '';

  onChange: (value:any) => {};
  onTouched: () => {};

  ngOnInit() {}

  ngOnChanges(changes: SimpleChanges) {
    if (changes?.['options'] || changes?.['value'] || changes?.['disabled']) {
      this.checkForDisabledValue();
    }
  }

  checkForDisabledValue() {

    let value = this.value;

    if(typeof value === 'boolean') {
      value = true;
    }

    if (this.disabled && value) {
      const selectedOption = this.options.find(
        (opt: Option) => opt.value === this.value
      );
      if (selectedOption) {
        this.selectedValue = selectedOption.label!;
      }
    }
  }

  changeValue(value:any) {
    this.value = value;
    if (!!this.onChange) {
      this.onChange(value);
    }
    this.change.emit(value);
  }

  writeValue(value:any) {
    this.value = value;
    // this.change.emit(value);
    this.input.emit(value);
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
