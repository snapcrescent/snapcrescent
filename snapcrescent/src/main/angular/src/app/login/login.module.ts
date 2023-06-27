import { NgModule } from '@angular/core';
import { SharedListPageModule } from '../shared/shared-list-page.module';

import { SharedModule } from '../shared/shared.module';
import { LoginRoutingModule } from './login.routing.module';
import { LoginComponent } from './login.component';

@NgModule({
  declarations: [
    LoginComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    LoginRoutingModule,
  ],
  providers: []
})
export class LoginModule { }
