import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatTableModule } from '@angular/material/table';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatRadioModule } from '@angular/material/radio';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatChipsModule } from '@angular/material/chips';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { NgxMatDatetimePickerModule } from '@angular-material-components/datetime-picker';
import { NgxMatTimepickerModule } from '@angular-material-components/datetime-picker';
import { NgxMatNativeDateModule } from '@angular-material-components/datetime-picker';
import { ClipboardModule } from 'ngx-clipboard';

import { HeaderComponent } from './header/header.component';
import { URLInterceptor } from '../core/services/http/url-interceptor';
import { HeaderInterceptor } from '../core/services/http/header-interceptor';
import { AssetGridComponent } from './asset-grid/asset-grid.component';

import { DateTimeComponent } from './input/date-time/date-time.component';
import { AlertComponent } from './alert/alert.component';
import { TextComponent } from './input/text/text.component';
import { RadioGroupComponent } from './input/radio/radio-group.component';
import { SelectComponent } from './input/select/select.component';
import { LoaderComponent } from './loader/loader.component';
import { LoadingInterceptor } from '../core/services/http/loading-interceptor';
import { ActionComponent } from './action-bar/action-bar.component';
import { DateComponent } from './input/date/date.component';
import { MatDialogModule } from '@angular/material/dialog';
import { DialogComponent } from './dialog/dialog.component';
import { ErrorInterceptor } from '../core/services/http/error-interceptor';
import { BreadcrumbComponent } from './breadcrumb/breadcrumb.component';
import { AuthorizationGuard } from '../core/services/auth.guard';
import { DragAndDropDirective } from '../core/directives/drag-and-drop.directive';
import { MonthYearComponent } from './input/month-year/month-year.component';
import { ScreenSizeDetectorComponent } from './screen-size-detector/screen-size-detector.component';


const modules = [
  CommonModule,
  RouterModule,
  HttpClientModule,
  FormsModule,
  ReactiveFormsModule,
  ClipboardModule,
  NgxMatDatetimePickerModule,
  NgxMatTimepickerModule,
  NgxMatNativeDateModule,
  MatButtonModule,
  MatCardModule,
  MatIconModule,
  MatInputModule,
  MatProgressSpinnerModule,
  MatSidenavModule,
  MatTableModule,
  MatCheckboxModule,
  MatPaginatorModule,
  MatSortModule,
  MatTooltipModule,
  MatDatepickerModule,
  MatNativeDateModule,
  MatRadioModule,
  MatSnackBarModule,
  MatSelectModule,
  MatExpansionModule,
  MatDialogModule,
  MatProgressBarModule,
  MatChipsModule,
  MatListModule,
  MatMenuModule
];

const components = [
  HeaderComponent,
  ScreenSizeDetectorComponent,
  AssetGridComponent,
  TextComponent,
  DateComponent,
  DateTimeComponent,
  MonthYearComponent,
  AlertComponent,
  RadioGroupComponent,
  SelectComponent,
  LoaderComponent,
  ActionComponent,
  DialogComponent,
  BreadcrumbComponent,
  DragAndDropDirective
];


@NgModule({
  declarations: [
    components
  ],
  exports: [...modules, ...components],
  imports: [...modules],
  providers: [
    AuthorizationGuard,
    { provide: HTTP_INTERCEPTORS, useClass: URLInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: HeaderInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: LoadingInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true }

  ],
  bootstrap: []
})
export class SharedModule { }
