import { Component, OnInit, AfterViewInit } from '@angular/core';
import { Router } from '@angular/router';
import { SessionService } from 'src/app/core/services/session.service';
import { MenuGroup, MenuItem } from './side-bar.model';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.scss']
})
export class SideBarComponent implements OnInit, AfterViewInit {

  activeMenu: MenuItem;
  menuGroups: MenuGroup[] = [];

  constructor(
    private sessionService: SessionService,
    private router: Router
  ) {

  }

  ngOnInit() {



    this.menuGroups.push(
      {
        id: "photosAndVideos",
        label: '',
        menuItems: [
          {
            id: "photosAndVideos",
            icon: "image",
            label: "Photos & Videos",
            link: "/asset/list"
          }
        ]
      }
    );

    this.menuGroups.push(
      {
        id: "library",
        label: 'Library',
        menuItems: [
          {
            id: "bin",
            icon: "star",
            label: "Favorites",
            link: "/favorite"
          },
          {
            id: "bin",
            icon: "delete",
            label: "Trash",
            link: "/trash"
          }
        ]
      }
    );

  }

  ngAfterViewInit() {

    let url = window.location.href;

    if (url) {
      url = url.substring(url.indexOf("#") + 2);

      const indexOfSlash = url.indexOf("/");
      url = "/" + url.substring(0, indexOfSlash < 0 ? url.length : indexOfSlash);
    }

    this.menuGroups.forEach((menuGroup: MenuGroup) => {
      menuGroup.menuItems.forEach((item:MenuItem) => {
        if (item.link.startsWith(url)) {
          this.activeMenu = item;
        }
      });
    })
  }

  navigate(menuItem: MenuItem) {
    this.activeMenu = menuItem;
    this.router.navigate([menuItem.link]);
  }

  logout() {
    this.sessionService.logout();
    this.router.navigate(['/login']);
  }
}
