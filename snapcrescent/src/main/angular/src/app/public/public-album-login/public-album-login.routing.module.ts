import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { PublicAlbumLoginComponent } from './public-album-login.component';

const routes: Routes = [
   { 
    path: '', 
    component: PublicAlbumLoginComponent,
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  providers: [
    {provide: LocationStrategy, useClass: HashLocationStrategy} 
  ],
  exports: [RouterModule]
})
export class PublicAlbumLoginRoutingModule { }
