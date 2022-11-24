import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { TrashRoutingModule } from './trash-asset.routing.module';
import { SharedListPageModule } from '../shared/shared-list-page.module';

@NgModule({
  declarations: [
    
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    TrashRoutingModule,
  ],
  providers: []
})
export class TrashAssetModule { }