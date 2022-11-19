import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { AssetRoutingModule } from './asset.routing.module';
import { AssetListComponent } from './list/asset-list.component';
import { AssetUploadComponent } from './upload/asset-upload.component';

@NgModule({
  declarations: [
    AssetListComponent,
    AssetUploadComponent
  ],
  imports: [
    SharedModule,
    AssetRoutingModule,
  ],
  providers: []
})
export class AssetModule { }