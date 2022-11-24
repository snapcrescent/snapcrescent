import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AssetListComponent } from './list/asset-list.component';
import { AssetUploadComponent } from './upload/asset-upload.component';
import { AssetViewComponent } from './view/asset-view.component';

const routes: Routes = [
  {
    path: "",
    redirectTo : "list",
    pathMatch: 'full'
  },

  {
    path: "list",
    component: AssetListComponent,
  },  

  {
    path: "upload",
    component: AssetUploadComponent
  },  

  {
    path: "view/:id",
    component: AssetViewComponent,
  },
  
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AssetRoutingModule { }
