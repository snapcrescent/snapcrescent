import { Component , AfterViewInit} from '@angular/core';
import { AlbumService } from 'src/app/album/album.service';
import { BaseListComponent } from 'src/app/core/components/base-list.component';
import { AlertService } from 'src/app/shared/alert/alert.service';
import { Action } from 'src/app/core/models/action.model';
import { Album } from '../album.model';
import { BaseResponseBean } from 'src/app/core/models/base-response-bean';
import { environment } from 'src/environments/environment';
import { Router } from '@angular/router';

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
    private router: Router,
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

          album.albumThumbnail.url =  `${environment.backendUrl}/thumbnail/${album.albumThumbnail.token}/stream`;

          if(album.ownedByMe) {
            this.myAlbums.push(album);
          } else {
            this.sharedWithMeAlbums.push(album);
          }
        });
      }
    });
  }

  onAlbumClick(album:Album) {
    this.router.navigate(['/album/view', album.id]);
  }
}
