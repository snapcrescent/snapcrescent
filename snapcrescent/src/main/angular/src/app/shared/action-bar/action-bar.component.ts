import { Component, Input } from '@angular/core';
import { Action } from 'src/app/core/models/action.model';

@Component({
  selector: 'app-action-bar',
  templateUrl: './action-bar.component.html',
  styleUrls: ['./action-bar.component.scss']
})
export class ActionComponent {

    @Input()
    position: "page" | "table";

    @Input()
    actions: Action[] = [];

    getIcon(action:Action) {
      if(typeof  action.icon === "string") {
        return action.icon;
      } else if(typeof  action.icon === "function") {
        return action.icon()
      } else {
        return "";
      }
    }
  
    getTooltip(action:Action) {
      if(typeof  action.tooltip === "string") {
        return action.tooltip;
      } else if(typeof  action.tooltip === "function") {
        return action.tooltip()
      } else {
        return "";
      }
    }
}
