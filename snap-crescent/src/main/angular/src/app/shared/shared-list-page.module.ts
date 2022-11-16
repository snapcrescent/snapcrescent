import { NgModule } from '@angular/core';
import { SharedModule } from './shared.module';


const modules = [
  SharedModule
];

const components:any = [];


@NgModule({
  declarations: [
    components
  ],
  exports: [...modules, ...components],
  imports: [...modules],
  providers: [
    
  ],
  bootstrap: []
})
export class SharedListPageModule { }
