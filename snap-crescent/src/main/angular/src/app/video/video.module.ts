import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { VideoRoutingModule } from './video.routing.module';
import { VideoListComponent } from './list/video-list.component';
import { VideoUploadComponent } from './upload/video-upload.component';

@NgModule({
  declarations: [
    VideoListComponent,
    VideoUploadComponent
  ],
  imports: [
    SharedModule,
    VideoRoutingModule,
  ],
  providers: []
})
export class VideoModule { }