import { NgModule } from '@angular/core';
import { SharedListPageModule } from '../shared/shared-list-page.module';

import { SharedModule } from '../shared/shared.module';
import { AssetRoutingModule } from './asset.routing.module';
import { AssetUploadComponent } from './upload/asset-upload.component';
import { AssetViewComponent } from './view/asset-view.component';
import { AddToAlbumComponent } from './add-to-album/add-to-album.component';

@NgModule({
  declarations: [
    AssetViewComponent,
    AssetUploadComponent,
    AddToAlbumComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    AssetRoutingModule,
  ],
  providers: []
})
export class AssetModule { }