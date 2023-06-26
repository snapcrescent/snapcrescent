import {
  Component,
  Input,
  OnInit,
  Self,
  Optional,
  Output,
  EventEmitter,
  OnChanges,
  SimpleChanges,
  ViewChild,
  TemplateRef,
  ContentChild
} from "@angular/core";
import * as moment from "moment";
import { MatDatepicker } from "@angular/material/datepicker";
import { MatInput } from "@angular/material/input";
import { ThemePalette } from "@angular/material/core";
import { ControlValueAccessor, NgControl } from "@angular/forms";




@Component({
  selector: "app-date-time",
  templateUrl: "./date-time.component.html"
})
export class DateTimeComponent
  implements ControlValueAccessor, OnInit, OnChanges {
  @ViewChild(MatInput, { static: true })
  input: MatInput;

  @ViewChild(MatDatepicker, { static: true })
  datepicker: MatDatepicker<Date>;

  constructor(
    @Self()
    @Optional()
    public ngControl: NgControl
  ) {
    if (this.ngControl) {
      this.ngControl.valueAccessor = this;
    }
  }

  @Input()
  placeholder: string;
  @Input()
  format = "DD-MM-YYYY HH:mm";
  @Input()
  value: number;
  @Input()
  defaultValue = "";
  @Input()
  min:any;
  @Input()
  max:any;
  @Input()
  disabled = false;
  @Input()
  error: string;
  @Input()
  inputStyle:any;
  @Input()
  isRequired: boolean;
  @Output()
  change: EventEmitter<any> = new EventEmitter<any>();
  moment = moment;

  public showSpinners = true;
  public touchUi = true;
  public enableMeridian = false;
  public stepHour = 1;
  public stepMinute = 1;
  public color: ThemePalette = 'primary';

  /**
   * the datepicker input binding value
   */
  inputValue: Date;

  @ContentChild("suffix", { static: true })
  suffixRef: TemplateRef<any>;

  onChange = (value:any) => {};
  onTouched = () => {};

  ngOnInit() {

    if(this.min && (typeof this.min === "number")) {
      this.min = new Date(this.min);
    }

    if(this.max && (typeof this.max === "number")) {
      this.max = new Date(this.max);
    }

  }

  datePickerOpened() {
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes?.['error'] && this.input) {
      this.input.errorState = !!this.error;
    }

    if(this.min && (typeof this.min === "number")) {
      this.min = new Date(this.min);
    }

    if(this.max && (typeof this.max === "number")) {
      this.max = new Date(this.max);
    }
  }

  changeValue(value: string) {
    if (value == null || (typeof value === "string" && value.trim() === "")) {
      this.onChange(value);
      this.change.emit(value);
      return;
    }
    let date = moment(value);
    if (!this.disabled) {
      date = this.validate(value);
    }
    // modified here.
    this.value = date.valueOf();
    this.inputValue = date.toDate();
    this.onChange(this.value);
    this.change.emit(this.value);
  }

  writeValue(value: string) {
    this.changeValue(value);
    if (this.ngControl && this.ngControl.control) {
      this.ngControl.control.markAsPristine();
    }
  }

  /**
   * check date
   * if not a invalid date, set to now
   * if earlier than min, then set to min,
   * if later than max, then set to max,
   */
  validate(value: string): moment.Moment {
    const date = moment(value);

    // if (!date.isValid()) {
    //   date = this.moment();
    // } else if (this.min && !date.isSameOrAfter(this.min)) {
    //   date = this.moment(this.min);
    // } else if (this.max && !date.isSameOrBefore(this.max)) {
    //   date = this.moment(this.max);
    // }
    return date;
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
