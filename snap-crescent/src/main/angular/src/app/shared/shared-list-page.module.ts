import { NgModule } from '@angular/core';
import { AssetListComponent } from '../asset/list/asset-list.component';
import { TrashAssetListComponent } from '../trash/list/trash-asset-list.component';
import { SharedModule } from './shared.module';


const modules = [
  SharedModule,
];

const components:any = [
  AssetListComponent,
  TrashAssetListComponent
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
