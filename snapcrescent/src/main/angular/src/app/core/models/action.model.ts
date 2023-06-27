export class Action {
    id: string = '';
    icon: string | Function = () => {};
    iconClass? :Function = () => {};
    type? :  "flat" | "stroked" | "default" = "default"
    styleClass? : string = '';
    label?: string = '';
    
    tooltip: string | Function = () => {};
    disabled? :Function = () => {}; 
    hidden? :Function = () => {}; 
    onClick :Function = () => {};
  }