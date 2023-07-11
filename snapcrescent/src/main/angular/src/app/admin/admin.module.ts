import { Injector, NgModule } from '@angular/core';
import { SharedModule } from '../shared/shared.module';
import { SharedListPageModule } from '../shared/shared-list-page.module';
import { AdminComponent } from './admin.component';
import { AdminRoutingModule } from './admin.routing.module';
export let AppInjector: Injector;
declare global{
  interface Navigator{
     msSaveBlob:(blob: Blob,fileName:string) => boolean
     }
  }

@NgModule({
  declarations: [
    AdminComponent,
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    AdminRoutingModule,
  ],
  providers: [],
  bootstrap: [AdminComponent]
})
export class AdminModule { }
