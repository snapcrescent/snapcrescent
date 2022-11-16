import { Component, OnInit, AfterViewInit } from '@angular/core';
import { BaseComponent } from 'src/app/core/components/base.component';
import { Action } from 'src/app/core/models/action.model';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetService } from 'src/app/asset/asset.service';
import { AssetType } from 'src/app/asset/asset.model';
import { HttpEventType, HttpResponse } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
    selector: 'app-image-upload',
    templateUrl: './image-upload.component.html',
    styleUrls:['./image-upload.component.scss']
})
export class ImageUploadComponent extends BaseComponent implements OnInit, AfterViewInit {

    actions: Action[] = [];

    fileUploadButton:HTMLInputElement;

    fileProgress:any = [];

    constructor(
        private assetService: AssetService,
        private router: Router,
        private alertService: AlertService
    ) {
        super();

    }

    ngOnInit() {
        this.populateBreadCrumbs();
        this.populatePageMetaData();
        this.populateChildMetaData();
    }

    private populateBreadCrumbs() {
        this.breadCrumbs.length = 0;
        this.breadCrumbs.push({
            label: "Search Images",
            onClick: () => {
                this.router.navigate([`/image/list`]);
            }
        })

        this.breadCrumbs.push({
            label: "Upload Images",
            onClick: () => {

            }
        })
    }

    private populatePageMetaData() {

        
    }

    private populateChildMetaData() {

    }

    ngAfterViewInit() {
        this.fileUploadButton = document.querySelector("#fileUploadButton")!;
    }

    openFileSelectionWindow() {
        if(this.fileUploadButton) {
            this.fileUploadButton.click();
          }
    }

    onFileDropped(files: any) {
        this.prepareAndSaveFiles(files)
    }
    
    fileBrowseHandler(event: any) {
        this.prepareAndSaveFiles(event.target.files)
    }

    prepareAndSaveFiles(files: Array<any>) {
        const fileList = [];
        for (const item of files) {
            this.save(item);
        }
      }

    save(file:any) {

        this.assetService.save(AssetType.PHOTO.id, file).subscribe(
            {
                next: (response: any) => {
                    if (response.type === HttpEventType.UploadProgress) {
                        Math.round(100 * response.loaded / response.total!);
                      } else if (response instanceof HttpResponse) {
                        
                      }
                },
                error: (error) => {
                    this.alertService.showError(error.message);
                  }
            }
        );

    }

  

}
