import { FormGroup } from "@angular/forms";
import { BreadCrumb } from "src/app/shared/breadcrumb/breadcrumb.model";

export class BaseComponent {

   
    breadCrumbs:BreadCrumb[] = []

    errorMessage:any = {
        default: {
                required: "Required field",
                min: "Required field"
            }
        };

    getErrorMessage(id: string, entityFormGroup: FormGroup) {
		const control = entityFormGroup.get(id);

    let errorMessage:any;

    if(control) {
      let errorObject = this.errorMessage[id];
      let errorMessageKey;

      if(!errorObject) {
        errorObject = this.errorMessage.default;
      }
      
      if(errorObject) {
        errorMessageKey = Object.keys(errorObject).find(key => control.errors && control.errors[key]);
      }

      if(!errorMessageKey) {
        errorMessageKey = Object.keys(this.errorMessage.default).find(key => control.errors && control.errors[key]);
      } 

      if(errorMessageKey) {
        errorMessage = errorObject[errorMessageKey];
      }
    }
				
		return errorMessage;
	}

}