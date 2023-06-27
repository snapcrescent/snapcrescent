import { Component, OnInit, AfterViewInit } from '@angular/core';
import { BaseComponent } from 'src/app/core/components/base.component';
import { Action } from 'src/app/core/models/action.model';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetService } from 'src/app/asset/asset.service';
import { AssetType } from 'src/app/asset/asset.model';
import { HttpEventType } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
    selector: 'app-asset-upload',
    templateUrl: './asset-upload.component.html',
    styleUrls:['./asset-upload.component.scss']
})
export class AssetUploadComponent extends BaseComponent implements OnInit, AfterViewInit {

    actions: Action[] = [];

    fileUploadButton:HTMLInputElement;

    fileUploadProgress:number = 0;

    AssetType = AssetType;    

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
            label: "Search Assets",
            onClick: () => {
                this.router.navigate([`/asset/list`]);
            }
        })

        this.breadCrumbs.push({
            label: "Upload Assets",
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
        let fileList:any[] = [];
        
        for (const item of files) {
            fileList.push(item);
        }

        return this.savePhoto(fileList);
      }

      savePhoto(files:File[]) {
        this.assetService.save(files).subscribe((response:any) => {
            if(response.type === HttpEventType.UploadProgress) {
                this.fileUploadProgress = Math.round(100 * response.loaded / response.total);

                if(this.fileUploadProgress == 100) {
                    this.alertService.showSuccess(`Asset${files.length > 1 ? 's':''} uploaded successfully, processing metadata`);
                }
            } else if (response.type === HttpEventType.Response) { 
                this.fileUploadProgress = 0;
                this.alertService.showSuccess(`Asset${files.length > 1 ? 's':''} uploaded successfully`);
            } 
        });

    }

  

}
