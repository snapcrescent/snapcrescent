import { Action } from "src/app/core/models/action.model";

export class DialogData {
  title? = "";
  message? = "";
  actions?: Array<Action> = [];
}