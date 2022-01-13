import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';


import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';

import { NgParticlesModule } from "ng-particles";

import { HeaderComponent } from './header/header.component';
import { SidebarComponent } from './sidebar/sidebar.component';




const modules = [CommonModule, MatButtonModule, MatCardModule, MatIconModule, MatInputModule, MatProgressSpinnerModule, MatSidenavModule, NgParticlesModule];
const components = [HeaderComponent, SidebarComponent];


@NgModule({
  declarations: [
    components
  ],
  exports: [...modules, ...components],
  imports: [modules],
  providers: [],
  bootstrap: []
})
export class SharedModule { }
