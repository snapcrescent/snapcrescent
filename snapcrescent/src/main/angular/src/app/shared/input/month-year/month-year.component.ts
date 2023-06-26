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
import { DateAdapter, MAT_DATE_FORMATS, MAT_DATE_LOCALE } from "@angular/material/core";
import { MAT_MOMENT_DATE_ADAPTER_OPTIONS, MomentDateAdapter } from "@angular/material-moment-adapter";
import { ControlValueAccessor, NgControl } from "@angular/forms";


export const DATE_FORMAT = {
  parse: {
    dateInput: 'MM/YYYY',
  },
  display: {
    dateInput: 'MM/YYYY',
    monthYearLabel: 'MMM YYYY',
    dateA11yLabel: 'LL',
    monthYearA11yLabel: 'MMMM YYYY',
  },
};

@Component({
  selector: "app-month-year",
  templateUrl: "./month-year.component.html",
  providers: [
    {
      provide: DateAdapter,
      useClass: MomentDateAdapter,
      deps: [MAT_DATE_LOCALE, MAT_MOMENT_DATE_ADAPTER_OPTIONS]
    },
    {
      provide: MAT_DATE_FORMATS,
      useValue: DATE_FORMAT
    }
  ]
})
export class MonthYearComponent
  implements ControlValueAccessor, OnInit, OnChanges {
  @ViewChild(MatInput, { static: false })
  input: MatInput;

  @ViewChild(MatDatepicker, { static: false })
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
  format = "MM/YYYY";
  @Input()
  mode: "start" | "end" = "start";
  @Input()
  value: number;
  @Input()
  defaultValue = "";
  @Input()
  min: Date;
  @Input()
  max: Date;
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
  /**
   * the datepicker input binding value
   */
  inputValue:any;

  @ContentChild("suffix", { static: true })
  suffixRef: TemplateRef<any>;

  onChange = (value:any) => {};
  onTouched = () => {};

  ngOnInit() {}

  datePickerOpened() {

  }

  setMonthAndYear(event: any) {
    this.writeValue(event);
    this.datepicker.close();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes?.['error'] && this.input) {
      this.input.errorState = !!this.error;
    }
  }

  changeValue(value: string) {
    if (value == null || (typeof value === "string" && value.trim() === "")) {
      this.value = 0;
      this.inputValue = null;
      this.onChange(value);
      this.change.emit(value);
      return;
    }
    let date = moment(value);
    if (!this.disabled) {
      date = this.validate(value);
    }

    if (this.mode === 'start') {
      date = moment(value).startOf("month");
    } else if (this.mode === 'end') {
      date = moment(value).endOf("month");
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
