import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AssetModule } from './asset/asset.module';
import { AuthenticationGuard } from './core/services/auth.guard';
import { TrashAssetModule } from './trash/trash-asset.module';
import { FavoriteAssetModule } from './favorite/favorite-asset.module';
import { AlbumModule } from './album/album.module';

const routes: Routes = [
  {
    path: "",
    redirectTo : "login",
    pathMatch: 'full'
  },
  {
    path: "login",
    loadChildren: () => import('./login/login.module').then(m => m.LoginModule)
  },
  {
    path: "asset",
    loadChildren: () => import('./asset/asset.module').then(m => AssetModule),
    canActivate: [AuthenticationGuard]
  },
  {
    path: "album",
    loadChildren: () => import('./album/album.module').then(m => AlbumModule),
    canActivate: [AuthenticationGuard]
  },
  {
    path: "admin",
    loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule),
    canActivate: [AuthenticationGuard],
    data: { userType: ['ADMIN'] }
  },
  {
    path: "favorite",
    loadChildren: () => import('./favorite/favorite-asset.module').then(m => FavoriteAssetModule),
    canActivate: [AuthenticationGuard]
  },
  {
    path: "trash",
    loadChildren: () => import('./trash/trash-asset.module').then(m => TrashAssetModule),
    canActivate: [AuthenticationGuard]
  },
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  providers: [
    {provide: LocationStrategy, useClass: HashLocationStrategy} 
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
