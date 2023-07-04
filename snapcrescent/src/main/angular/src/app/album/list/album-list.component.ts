import { Component , AfterViewInit} from '@angular/core';
import { AlbumService } from 'src/app/album/album.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { Action } from 'src/app/core/models/action.model';
import { Album } from '../album.model';
import { BaseResponseBean } from 'src/app/core/models/base-response-bean';

@Component({
  selector: 'app-album-list',
  templateUrl: './album-list.component.html',
  styleUrls:['./album-list.component.scss']
})
export class AlbumListComponent extends BaseListComponent implements AfterViewInit{

  searchStoreName = "albums";

  override actions: Action[];

  myAlbums:Album[] =[];
  sharedWithMeAlbums:Album[] =[];
  
  constructor(
    private albumService: AlbumService,
    private alertService: AlertService
  ) {
    super();
  }

  ngOnInit() {
    this.populateAdvancedSearchFields();;
    this.populateActions();
    this.search();
  }

  ngAfterViewInit() {
    
  }


  private populateAdvancedSearchFields() {
    
  }
 

  private populateActions() {

    }

  search() {
    this.myAlbums = [];
    this.sharedWithMeAlbums = [];

    this.albumService.search({}).subscribe((response:BaseResponseBean<number, Album>) => {
      if(response.objects) {
        response.objects.forEach((album:Album) => {
          if(album.ownedByMe) {
            this.myAlbums.push(album);
          } else {
            this.sharedWithMeAlbums.push(album);
          }
        });
      }
    });
  }
}
