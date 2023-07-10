import { NgModule } from '@angular/core';
import { SharedListPageModule } from '../shared/shared-list-page.module';

import { SharedModule } from '../shared/shared.module';
import { AlbumRoutingModule } from './album.routing.module';
import { ShareWithUserComponent } from './share-with-user/share-with-user.component';

@NgModule({
  declarations: [
    ShareWithUserComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    AlbumRoutingModule,
  ],
  providers: []
})
export class AlbumModule { }