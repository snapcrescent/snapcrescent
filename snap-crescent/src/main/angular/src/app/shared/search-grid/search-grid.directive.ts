import { Input, Directive, TemplateRef } from "@angular/core";

@Directive({ selector: "[cellDef]" })
export class SearchTableCellDefDirective {
  @Input()
  cellDef: string;
  constructor(public ref: TemplateRef<any>) {}
}

@Directive({ selector: "[headerCellDef]" })
export class SearchTableHeaderCellDefDirective {
  @Input()
  headerCellDef: string;
  constructor(public ref: TemplateRef<any>) {}
}

@Directive({ selector: "[footerCellDef]" })
export class SearchTableFooterCellDefDirective {
  @Input()
  footerCellDef: string;
  constructor(public ref: TemplateRef<any>) {}
}