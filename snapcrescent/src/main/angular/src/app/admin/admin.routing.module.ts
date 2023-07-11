import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AuthenticationGuard } from '../core/services/auth.guard';
import { AdminComponent } from './admin.component';

const routes: Routes = [
  {
    path: "",
    redirectTo : "admin/user",
    pathMatch: 'full'
  },

  { path: 'admin',        
        component: AdminComponent,
        children: [
           {
               path: 'user',        
               loadChildren: () => import('../user/user.module').then(m => m.UserModule),
                canActivate: [AuthenticationGuard],
                data: { userType: ['ADMIN'] }
           }
       ]           

  },    

  {
    path: "user",
    loadChildren: () => import('../user/user.module').then(m => m.UserModule),
    canActivate: [AuthenticationGuard],
    data: { userType: ['ADMIN'] }
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  providers: [
    {provide: LocationStrategy, useClass: HashLocationStrategy} 
  ],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
