import { Component, OnInit, AfterViewInit, OnDestroy, Inject, ViewChild, ElementRef } from '@angular/core';
import { BaseComponent } from 'src/app/core/components/base.component';
import { ActivatedRoute } from '@angular/router';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { SessionService } from 'src/app/core/services/session.service';
import { BaseResponseBean } from 'src/app/core/models/base-response-bean';
import { Observable } from 'rxjs';
import {map, startWith} from 'rxjs/operators';
import { FormControl } from '@angular/forms';
import {MatAutocompleteSelectedEvent} from '@angular/material/autocomplete';
import { User } from 'src/app/user/user.model';
import { AlbumService } from '../album.service';
import { UserService } from 'src/app/user/user.service';
import { CreateAlbumUserAssnRequest } from '../album.model';

@Component({
  selector: 'app-share-with-user',
  templateUrl: './share-with-user.component.html',
  styleUrls: ['./share-with-user.component.scss']
})
export class ShareWithUserComponent extends BaseComponent implements OnInit, AfterViewInit, OnDestroy {

  albumId:number;

  existingUsers:User[] = [];
  filteredUsers: Observable<User[]>;

  selectedUsers:User[] = [];
  
  
  userCtrl = new FormControl('');
  @ViewChild('userInput') userInput: ElementRef<HTMLInputElement>;

  constructor(
    public dialogRef: MatDialogRef<ShareWithUserComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    public activatedRoute: ActivatedRoute,
    public albumService: AlbumService,
    public userService: UserService,
    public sessionService: SessionService
  ) {
      super();
      dialogRef.disableClose = true;
      this.albumId = data.albumId;
  }

  ngOnInit() {
    let params:any =  {};
    
    this.userService.search(params).subscribe((response : BaseResponseBean<number, User>) => {
      if(response.objects) {
        let currentLoggedInUser =  response.objects.find((user:User) => user.id === this.sessionService.getAuthInfo()?.user.id);

        if(currentLoggedInUser != null) {
          response.objects.splice(response.objects.indexOf(currentLoggedInUser), 1);
        }

        this.existingUsers = response.objects;
      }
    });


    this.filteredUsers = this.userCtrl.valueChanges.pipe(
      startWith(null),
      map((user: string | null) => (user ? this._filter(user) : this.existingUsers.slice())),
    );
  }

  ngAfterViewInit() {
  
  }

  navigateSearch() {
    this.dialogRef.close();
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

  createAlbumUserAssociation() {
    let createAlbumAssetAssnRequest:CreateAlbumUserAssnRequest = {
      albumId : this.albumId,
      userIds : this.selectedUsers.map(selectedUser => selectedUser.id!)
    }

    
    this.albumService.createAlbumUserAssociation(createAlbumAssetAssnRequest).subscribe(response => {
      this.dialogRef.close();
    });
    
  }
}
