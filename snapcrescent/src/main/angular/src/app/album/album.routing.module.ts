import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AlbumListComponent } from './list/album-list.component';

const routes: Routes = [
  {
    path: "",
    redirectTo : "list",
    pathMatch: 'full'
  },

  {
    path: "list",
    component: AlbumListComponent,
  }
  
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AlbumRoutingModule { }
