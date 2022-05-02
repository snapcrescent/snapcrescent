import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';

import { HeaderComponent } from './header/header.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { URLInterceptor } from '../core/services/http/url-interceptor';




const modules = [CommonModule, HttpClientModule,FormsModule,ReactiveFormsModule, MatButtonModule, MatCardModule, MatIconModule, MatInputModule, MatProgressSpinnerModule, MatSidenavModule];
const components = [HeaderComponent, SidebarComponent];


@NgModule({
  declarations: [
    components
  ],
  exports: [...modules, ...components],
  imports: [modules],
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: URLInterceptor, multi: true }
  ],
  bootstrap: []
})
export class SharedModule { }
