import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login.component';

const routes: Routes = [
  {
    path: "login",
    component: LoginComponent,
  },
  {
    path: "home",
    component: HomeComponent,
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
