import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { SharedListPageModule } from '../shared/shared-list-page.module';
import { FavoriteRoutingModule } from './favorite-asset.routing.module';

@NgModule({
  declarations: [
    
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    FavoriteRoutingModule,
  ],
  providers: []
})
export class FavoriteAssetModule { }