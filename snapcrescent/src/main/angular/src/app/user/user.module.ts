import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { UserRoutingModule } from './user.routing.module';
import { UserCreateEditComponent } from './create-edit/user-create-edit.component';
import { SharedListPageModule } from '../shared/shared-list-page.module';

@NgModule({
  declarations: [
    UserCreateEditComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    UserRoutingModule,
  ],
  providers: []
})
export class UserModule { }
