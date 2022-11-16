import { Component, HostListener, Inject, OnInit, SecurityContext } from "@angular/core";
import { MAT_DIALOG_DATA, MatDialogRef } from "@angular/material/dialog";
import { Action } from "src/app/core/models/action.model";
import { DialogData } from "./dialog.model";

@Component({
  selector: "app-dialog",
  templateUrl: "./dialog.component.html"
})
export class DialogComponent implements OnInit {
  title = "";
  message = "";
  actions: Array<Action> = [];

  constructor(
    public dialogRef: MatDialogRef<DialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData = new DialogData()
  ) {
    dialogRef.disableClose = true;
    this.title = data.title!;
    this.message = data.message!;
    this.actions = data.actions!;
  }

  @HostListener("window:keyup.esc")
  onKeyUp() {
    this.dialogRef.close();
  }

  ngOnInit() {}

  click(item: Action) {
    let result;
    let preventDefault = false;

    const event = {
      target: item,
      dialog: this.dialogRef,
      preventDefault: () => {
        preventDefault = true;
      }
    };

    if (item.onClick) {
      result = item.onClick(event);
    }

    if (!preventDefault) {
      this.dialogRef.close(result);
    }
  }
}
