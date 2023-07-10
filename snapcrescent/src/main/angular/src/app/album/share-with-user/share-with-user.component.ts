import { Component, OnInit, AfterViewInit, OnDestroy, Inject, ViewChild, ElementRef } from '@angular/core';
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute } from '@angular/router';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { SessionService } from 'src/app/core/services/session.service';
import { BaseResponseBean } from 'src/app/core/models/base-response-bean';
import { Observable } from 'rxjs';
import {map, startWith} from 'rxjs/operators';
import { FormBuilder, FormControl } from '@angular/forms';
import {MatAutocompleteSelectedEvent} from '@angular/material/autocomplete';
import { User } from 'src/app/user/user.model';
import { AlbumService } from '../album.service';
import { UserService } from 'src/app/user/user.service';
import { Album } from '../album.model';
import { Option } from 'src/app/core/models/option.model';

@Component({
  selector: 'app-share-with-user',
  templateUrl: './share-with-user.component.html',
  styleUrls: ['./share-with-user.component.scss']
})
export class ShareWithUserComponent extends BaseComponent implements OnInit, AfterViewInit, OnDestroy {

  PLACEHOLDER_PASSWORD = 'PLACEHOLDER';

  albumId:number;

  existingUsers:User[] = [];
  filteredUsers: Observable<User[]>;
  selectedUsers:User[] = [];
  currentLoggedInUser: User;

  publicAccessOptions :Option[] = [];

  originalPublicAccess : boolean = false;
  publicAccessLink : string;
  
  userCtrl = new FormControl('');
  @ViewChild('userInput') userInput: ElementRef<HTMLInputElement>;

  entityFormGroup = this.formBuilder.group(new Album());

  constructor(
    public dialogRef: MatDialogRef<ShareWithUserComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    public activatedRoute: ActivatedRoute,
    public albumService: AlbumService,
    public userService: UserService,
    public sessionService: SessionService,
    private formBuilder: FormBuilder,
  ) {
      super();
      dialogRef.disableClose = true;
      this.albumId = data.albumId;
  }

  get entity(): Album {
    return this.entityFormGroup.getRawValue() as unknown as Album;
  }

  ngOnInit() {
    this.getById();
    this.publicAccessOptions = this.albumService.getYesAndNoOptions();
    this.publicAccessLink = this.generatePublicAccessLink();
  }

  generatePublicAccessLink() {
    let url = window.location.href;

    if (url) {
      url = url.substring(0, url.indexOf("#") + 2);

      url = url + 'sharing/album/' + this.albumId;
    }

    return url;
  }

  getById() {
    this.albumService.read(this.albumId).subscribe((response) => {
        let album: Album = response.object!;
        this.originalPublicAccess = album.publicAccess!;

        if(this.originalPublicAccess == true) {
          album.newPassword = this.PLACEHOLDER_PASSWORD;
        }
        this.entityFormGroup.patchValue(album);
        this.getUsers();
    });
  }

  getUsers() {
    let params:any =  {};
    
    this.userService.search(params).subscribe((response : BaseResponseBean<number, User>) => {
      if(response.objects) {
        this.currentLoggedInUser =  response.objects.find((user:User) => user.id === this.sessionService.getAuthInfo()?.user.id)!;

        if(this.currentLoggedInUser != null) {
          response.objects.splice(response.objects.indexOf(this.currentLoggedInUser), 1);
        }

        this.existingUsers = response.objects;

        if(this.entity && this.entity.users) {
            this.entity.users.forEach((user:User) => {
              const alreadySharedWithUser = this.existingUsers.find((existingUser:User) => existingUser.id === user.id);

              if(alreadySharedWithUser) {
                this.selectedUsers.push(alreadySharedWithUser);
              }
            });
        }
      }
    });


    this.filteredUsers = this.userCtrl.valueChanges.pipe(
      startWith(null),
      map((user: string | null) => (user ? this._filter(user) : this.existingUsers.slice())),
    );
  }

  ngAfterViewInit() {
    
  }

  ngOnDestroy(): void {
   
  }


  remove(user: User): void {
    const index = this.selectedUsers.indexOf(user);

    if (index >= 0) {
      this.selectedUsers.splice(index, 1);
    }
  }

  selected(event: MatAutocompleteSelectedEvent): void {

    const userIndex = this.selectedUsers.indexOf(event.option.value);

    if(userIndex < 0) {
      this.selectedUsers.push(event.option.value);
    }

    this.userInput.nativeElement.value = '';
    this.userCtrl.setValue(null);
  }

  private _filter(value: string): User[] {
    if(value && typeof value === "string") {
      const filterValue = value.toLowerCase();
      return this.existingUsers.filter(existingUser => existingUser.firstName.toLowerCase().includes(filterValue));
    } else {
      return this.existingUsers;
    }
  }

  updateAlbum() {
    let album = this.entity;
    album.users = this.selectedUsers;
    album.users.push(this.currentLoggedInUser);
    
    if(album.newPassword === this.PLACEHOLDER_PASSWORD
      || album.publicAccess === false) {
      album.newPassword = undefined;
    }
    
    this.albumService.update(this.albumId, album).subscribe(response => {
      this.dialogRef.close({
        changed: true
      });
    });
    
  }
}
