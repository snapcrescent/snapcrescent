import { NgModule } from '@angular/core';
import { AssetListComponent } from '../asset/list/asset-list.component';
import { TrashAssetListComponent } from '../trash/list/trash-asset-list.component';
import { SharedModule } from './shared.module';
import { FavoriteAssetListComponent } from '../favorite/list/favorite-asset-list.component';


const modules = [
  SharedModule,
];

const components:any = [
  AssetListComponent,
  TrashAssetListComponent,
  FavoriteAssetListComponent
];


@NgModule({
  declarations: [
    components
  ],
  exports: [...modules, ...components],
  imports: [...modules],
  providers: [
    
  ],
  bootstrap: []
})
export class SharedListPageModule { }
