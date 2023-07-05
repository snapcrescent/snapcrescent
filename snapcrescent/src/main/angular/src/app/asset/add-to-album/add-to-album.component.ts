import { Component, OnInit, AfterViewInit, Input, OnDestroy, Inject, ViewChild, ElementRef } from '@angular/core';
import { Action } from 'src/app/core/models/action.model'
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute } from '@angular/router';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Album, CreateAlbumAssetAssnRequest } from 'src/app/album/album.model';
import { AlbumService } from 'src/app/album/album.service';
import { SessionService } from 'src/app/core/services/session.service';
import { BaseResponseBean } from 'src/app/core/models/base-response-bean';
import { Observable } from 'rxjs';
import {map, startWith} from 'rxjs/operators';
import { FormControl } from '@angular/forms';
import { MatChipInputEvent } from '@angular/material/chips';
import {MatAutocompleteSelectedEvent} from '@angular/material/autocomplete';
import {COMMA, ENTER} from '@angular/cdk/keycodes';

@Component({
  selector: 'app-add-to-album',
  templateUrl: './add-to-album.component.html',
  styleUrls: ['./add-to-album.component.scss']
})
export class AddToAlbumComponent extends BaseComponent implements OnInit, AfterViewInit, OnDestroy {

  @Input()
  actions: Action[] = [];

  assetIds:number[]= [];

  existingAlbums:Album[] = [];
  filteredAlbums: Observable<Album[]>;

  selectedAlbums:Album[] = [];
  separatorKeysCodes: number[] = [ENTER, COMMA];
  
  
  albumCtrl = new FormControl('');
  @ViewChild('albumInput') albumInput: ElementRef<HTMLInputElement>;

  constructor(
    public dialogRef: MatDialogRef<AddToAlbumComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    public activatedRoute: ActivatedRoute,
    public albumService: AlbumService,
    public sessionService: SessionService
  ) {
      super();
      dialogRef.disableClose = true;
      this.assetIds = data.assetIds;
  }

  ngOnInit() {
    let params:any =  {};
    params.createdByUserId = this.sessionService.getAuthInfo()?.user.id;

    this.albumService.search(params).subscribe((response : BaseResponseBean<number, Album>) => {
      if(response.objects) {
        this.existingAlbums = response.objects;
      }
    });


    this.filteredAlbums = this.albumCtrl.valueChanges.pipe(
      startWith(null),
      map((album: string | null) => (album ? this._filter(album) : this.existingAlbums.slice())),
    );
  }

  ngAfterViewInit() {
  
  }

  navigateSearch() {
    this.dialogRef.close();
  }

  ngOnDestroy(): void {
   
  }


  add(event: MatChipInputEvent): void {
    const value = (event.value || '').trim();

    // Add our fruit
    if (value) {
      const matchingAlbum = this.existingAlbums.find((existingAlbum:Album) => existingAlbum.name === value);

      if(matchingAlbum) {
        this.selectedAlbums.push(matchingAlbum);
      } else {
        let album:Album = { name : value};
        this.selectedAlbums.push(album);
      }
    }

    // Clear the input value
    event.chipInput!.clear();

    this.albumCtrl.setValue(null);
  }

  remove(album: Album): void {
    const index = this.selectedAlbums.indexOf(album);

    if (index >= 0) {
      this.selectedAlbums.splice(index, 1);
    }
  }

  selected(event: MatAutocompleteSelectedEvent): void {

    const matchingAlbum = this.existingAlbums.find((existingAlbum:Album) => existingAlbum.name === event.option.viewValue);

    if(matchingAlbum) {
      this.selectedAlbums.push(matchingAlbum);
    }

    this.albumInput.nativeElement.value = '';
    this.albumCtrl.setValue(null);
  }

  private _filter(value: string): Album[] {
    if(value) {
      const filterValue = value.toLowerCase();
      return this.existingAlbums.filter(existingAlbum => existingAlbum.name.toLowerCase().includes(filterValue));
    } else {
      return this.existingAlbums;
    }
  }

  createAlbumAssetAssociation() {
    let createAlbumAssetAssnRequest:CreateAlbumAssetAssnRequest = {
      albums : this.selectedAlbums,
      assetIds : this.assetIds
    }

    this.albumService.createAlbumAssetAssociation(createAlbumAssetAssnRequest).subscribe(response => {
      this.dialogRef.close();
    });
  }
}
