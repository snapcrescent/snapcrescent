import { Injector, NgModule } from '@angular/core';
import { SharedModule } from '../../shared/shared.module';
import { SharedListPageModule } from '../../shared/shared-list-page.module';
import { PublicAlbumLoginRoutingModule } from './public-album-login.routing.module';
import { PublicAlbumLoginComponent } from './public-album-login.component';
export let AppInjector: Injector;
declare global{
  interface Navigator{
     msSaveBlob:(blob: Blob,fileName:string) => boolean
     }
  }

@NgModule({
  declarations: [
    PublicAlbumLoginComponent
  ],
  imports: [
    SharedModule,
    SharedListPageModule,
    PublicAlbumLoginRoutingModule,
  ],
  providers: [],
  bootstrap: []
})
export class PublicAlbumLoginModule { }
