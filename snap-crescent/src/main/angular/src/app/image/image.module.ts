import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { ImageRoutingModule } from './image.routing.module';
import { ImageListComponent } from './list/image-list.component';
import { ImageUploadComponent } from './upload/image-upload.component';

@NgModule({
  declarations: [
    ImageListComponent,
    ImageUploadComponent
  ],
  imports: [
    SharedModule,
    ImageRoutingModule,
  ],
  providers: []
})
export class ImageModule { }