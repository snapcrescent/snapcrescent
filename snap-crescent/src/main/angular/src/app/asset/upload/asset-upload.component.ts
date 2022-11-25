import { Component, OnInit, AfterViewInit } from '@angular/core';
import { BaseComponent } from 'src/app/core/components/base.component';
import { Action } from 'src/app/core/models/action.model';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { AssetService } from 'src/app/asset/asset.service';
import { AssetType } from 'src/app/asset/asset.model';
import { HttpEventType, HttpResponse } from '@angular/common/http';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';

@Component({
    selector: 'app-asset-upload',
    templateUrl: './asset-upload.component.html',
    styleUrls:['./asset-upload.component.scss']
})
export class AssetUploadComponent extends BaseComponent implements OnInit, AfterViewInit {

    actions: Action[] = [];

    fileUploadButton:HTMLInputElement;

    fileProgress:any = [];

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

    onFileDropped(files: any, assetTypeId: number) {
        this.prepareAndSaveFiles(files, assetTypeId)
    }
    
    fileBrowseHandler(event: any, assetTypeId: number) {
        this.prepareAndSaveFiles(event.target.files, assetTypeId)
    }

    prepareAndSaveFiles(files: Array<any>, assetTypeId: number) {
        let fileList:any[] = [];
        for (const item of files) {
            fileList.push(item);
        }

        let fileBatch:any[] = [];
        for (const item of fileList) {
            fileBatch.push(item);

            if(fileBatch.length === 10 || (fileList.indexOf(item) + 1) === fileList.length) {
                this.processFiles(assetTypeId, fileBatch, 0);
            }
        }
      }
    
    processFiles(assetTypeId: number, allFiles:any[], fileIndex:any):any {
        if(fileIndex + 1 <= allFiles.length) {
            return this.savePhoto(allFiles[fileIndex], assetTypeId, this.processFiles(assetTypeId,allFiles,fileIndex + 1));
        } else {
            return true;
        }
        
    }

      savePhoto(file:any, assetTypeId: number, callback?:Function) {
        this.assetService.save(assetTypeId, file).subscribe((response:any) => {
            if(response.success) {
                if(callback !== undefined) {
                    callback();
                }
            }  
        });

    }

  

}