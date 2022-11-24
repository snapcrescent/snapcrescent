import { NgModule } from '@angular/core';
import { SharedListPageModule } from '../shared/shared-list-page.module';

import { SharedModule } from '../shared/shared.module';
import { AssetRoutingModule } from './asset.routing.module';
import { AssetListComponent } from './list/asset-list.component';
import { AssetUploadComponent } from './upload/asset-upload.component';
import { AssetViewComponent } from './view/asset-view.component';

@NgModule({
  declarations: [
    AssetViewComponent,
    AssetUploadComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    AssetRoutingModule,
  ],
  providers: []
})
export class AssetModule { }