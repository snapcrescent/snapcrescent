import {
  Component,
  OnInit,
  Self,
  Optional,
  Input,
  Output,
  EventEmitter,
  SimpleChanges,
  ViewChild,
  OnChanges,
  ContentChild,
  TemplateRef
} from "@angular/core";
import { ControlValueAccessor, NgControl } from "@angular/forms";
import { MatInput } from "@angular/material/input";

@Component({
  selector: "app-text",
  templateUrl: "./text.component.html"
})
export class TextComponent implements ControlValueAccessor, OnInit, OnChanges {
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
  defaultValue = "";
  @Input()
  value:any;
  @Input()
  minlength: number;
  @Input()
  maxlength: number;
  @Input()
  disabled: boolean;
  @Input()
  error: string;
  @Input()
  type:
    | "input"
    | "number"
    | "password"
    | "textArea" = "input";
  @Input()
  decimal = 0;
  @Input()
  range: string;
  @Input()
  floatLabel: "auto" | "always" | "never" = "auto";
  @Input()
  underline: "auto" | "always" | "never" = "auto";
  @Input()
  removeLineBreaks = true;
  @Input()
  handleZeroValue = false;
  @Input()
  regExp: string;
  @Input()
  isRequired: boolean;
  @Input()
  textAreaSize = 1;

  @Output()
  blur = new EventEmitter<any>();
  @Output()
  input: EventEmitter<any> = new EventEmitter<any>();
  @Output()
  change: EventEmitter<any> = new EventEmitter<any>();

  @ViewChild(MatInput, { static: true })
  matInput: MatInput;

  @ContentChild("suffix", { static: true })
  suffixRef: TemplateRef<any>;

  originalValue:any;

  onChangeCallback = (value:any) => {};
  onTouchedCallback = () => {};

  ngOnInit() {
    this.originalValue = this.value;

    if (this.type === "number" && this.ngControl && this.handleZeroValue) {
      if (this.ngControl.value === 0) {
        this.value = String(this.value);
      } else {
        this.ngControl?.valueChanges?.subscribe(value => {
          if (value === 0) {
            this.value = String(this.value);
          }
        });
      }
    }
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes?.['error'] && this.matInput) {
      this.matInput.errorState = !!this.error;
    }
  }

  onInput(event:any) {
    const value = event.target.value;
    this.changeValue(value);
    this.input.emit(value);
  }

  onChange(event:any) {
    let value = event.target.value;
    if (
      (value !== null || value !== undefined || value !== "") &&
      typeof value === "string"
    ) {
      value = value.trim();
    }

    this.changeValue(value);
    this.change.emit(this.value);
  }

  onBlur() {
    this.blur.emit(this.value);
    this.onTouchedCallback();
  }

  writeValue(value:any) {
    this.originalValue = value;
    this.changeValue(value);
    this.input.emit(value);
  }

  changeValue(value:any) {
    this.value = value;
    this.onChangeCallback(value);
    if (this.value === this.originalValue) {
      if (this.ngControl && this.ngControl.control) {
        this.ngControl.control.markAsPristine();
      }
    }
  }

  registerOnChange(fn:any) {
    this.onChangeCallback = fn;
  }

  registerOnTouched(fn:any) {
    this.onTouchedCallback = fn;
  }

  setDisabledState(disabled: boolean) {
    this.disabled = disabled;
  }
}
