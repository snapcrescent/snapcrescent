import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { TrashAssetListComponent } from './list/trash-asset-list.component';

const routes: Routes = [
  {
    path: "",
    redirectTo : "list",
    pathMatch: 'full'
  },

  {
    path: "list",
    component: TrashAssetListComponent,
  },    
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class TrashRoutingModule { }
