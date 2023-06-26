import {
    Directive,
    Output,
    EventEmitter,
    HostBinding,
    HostListener
  } from '@angular/core';
  
  @Directive({
    selector: '[app-dnd]'
  })
  export class DragAndDropDirective {
    @HostBinding('class.fileover') fileOver: boolean;
    @Output() fileDropped = new EventEmitter<any>();
  
    // Dragover listener
    @HostListener('dragover', ['$event']) onDragOver(evt:any) {
      evt.preventDefault();
      evt.stopPropagation();
      this.fileOver = true;
    }
  
    // Dragleave listener
    @HostListener('dragleave', ['$event']) public onDragLeave(evt:any) {
      evt.preventDefault();
      evt.stopPropagation();
      this.fileOver = false;
    }
  
    // Drop listener
    @HostListener('drop', ['$event']) public ondrop(evt:any) {
      evt.preventDefault();
      evt.stopPropagation();
      this.fileOver = false;
      let files = evt.dataTransfer.files;
      if (files.length > 0) {
        this.fileDropped.emit(files);
      }
    }
  }
  