import { Component, OnInit, AfterViewInit } from '@angular/core';
import { Router } from '@angular/router';
import { SessionService } from 'src/app/core/services/session.service';
import { GlobalService } from 'src/app/core/services/global.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit, AfterViewInit {

  activeMenu:any;
  menuItems:any[] = [];
  sideBarOpen = false;

  userTypeAdmin = false;
  userTypePublicAccess = false;



  constructor(
    private sessionService: SessionService,
    private globalService: GlobalService,
    private router: Router
  ) {
    
  }

  ngOnInit() {
    this.userTypeAdmin = this.sessionService.isAdminUser();
    this.userTypePublicAccess = this.sessionService.isPublicAccessUser();
  }

  ngAfterViewInit() {

    let url = window.location.href;

    if (url) {
      url = url.substring(url.indexOf("#") + 2);

      const indexOfSlash = url.indexOf("/");
      url = "/" + url.substring(0, indexOfSlash < 0 ? url.length : indexOfSlash);
    }

    this.menuItems.forEach((item:any) => {
      if (item.link.startsWith(url)) {
        this.activeMenu = item;
      }
    })
  }

  navigate(menuItem:any) {
    this.activeMenu = menuItem;
    this.router.navigate([menuItem.link]);
  }

  toggleSideBar() {
    this.sideBarOpen = !this.sideBarOpen;
    this.globalService.updateToggleSideBarState(this.sideBarOpen);
  } 

  navigateToAdminSection() {
    this.router.navigate(['/admin']);
  }

  navigateToAssetList() {
    this.router.navigate(['/asset']);
  }

  logout() {
    this.sessionService.logout();
    this.router.navigate(['/login']);
  }
}
