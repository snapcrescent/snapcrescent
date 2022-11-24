import { Component, OnInit, AfterViewInit } from '@angular/core';
import { Router } from '@angular/router';
import { SessionService } from 'src/app/core/services/session.service';

@Component({
  selector: 'app-side-bar',
  templateUrl: './side-bar.component.html',
  styleUrls: ['./side-bar.component.scss']
})
export class SideBarComponent implements OnInit, AfterViewInit {

  activeMenu: any;
  menuItems: any[] = [];

  constructor(
    private sessionService: SessionService,
    private router: Router
  ) {

  }

  ngOnInit() {

    this.menuItems.push({
      id: "photosAndVideos",
      icon: "image",
      label: "Photos & Videos",
      link : "/asset/list"
    });

    this.menuItems.push({
      id: "bin",
      icon: "delete",
      label: "Bin",
      link : "/trash"
    });

  }

  ngAfterViewInit() {

    let url = window.location.href;

    if (url) {
      url = url.substring(url.indexOf("#") + 2);

      const indexOfSlash = url.indexOf("/");
      url = "/" + url.substring(0, indexOfSlash < 0 ? url.length : indexOfSlash);
    }

    this.menuItems.forEach((item: any) => {
      if (item.link.startsWith(url)) {
        this.activeMenu = item;
      }
    })
  }

  navigate(menuItem: any) {
    this.activeMenu = menuItem;
    this.router.navigate([menuItem.link]);
  }

  logout() {
    this.sessionService.logout();
    this.router.navigate(['/login']);
  }
}
