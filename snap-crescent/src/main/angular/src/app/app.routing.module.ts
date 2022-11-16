import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AuthenticationGuard } from './core/services/auth.guard';
import { ImageModule } from './image/image.module';
import { VideoModule } from './video/video.module';

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
    path: "image",
    loadChildren: () => import('./image/image.module').then(m => ImageModule),
    canActivate: [AuthenticationGuard]
  },
  {
    path: "video",
    loadChildren: () => import('./video/video.module').then(m => VideoModule),
    canActivate: [AuthenticationGuard]
  }
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  providers: [
    {provide: LocationStrategy, useClass: HashLocationStrategy} 
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
