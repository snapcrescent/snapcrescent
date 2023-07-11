import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { UserCreateEditComponent } from './create-edit/user-create-edit.component';
import { UserListComponent } from './list/user-list.component';

const routes: Routes = [
  {
    path: "",
    redirectTo : "list",
    pathMatch: 'full'
  },

  {
    path: "list",
    component: UserListComponent,
  },  

  {
    path: "create",
    component: UserCreateEditComponent,
  },  

  {
    path: "manage/:id",
    component: UserCreateEditComponent,
  },  
  
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UserRoutingModule { }
