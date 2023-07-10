import { BaseUiBean } from "../core/models/base.model";

export class User extends BaseUiBean {
  firstName: string = '';
  lastName: string = '';
  username: string = '';
  password: string = '';

  userType?:number = 0;
  
  fullName?: string = '';
}

export let UserType = {
  ADMIN: {
    id: 1,
    label: "Admin"
  },
  USER: {
    id: 2,
    label: "User"
  }
};

export let UserStatus = {
  ACTIVE: {
    id: 2,
    label: "Active"
  },
  INACTIVE: {
    id: 2,
    label: "Inactive"
  }
};