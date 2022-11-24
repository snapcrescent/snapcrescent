import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDrawer } from '@angular/material/sidenav';
import { NavigationStart, Router } from '@angular/router';
import { delay, Subscription } from 'rxjs';
import { GlobalService } from './core/services/global.service';
import { ScreenSize } from './shared/screen-size-detector/screen-size-detector.model';
import { ScreenSizeDetectorService } from './shared/screen-size-detector/screen-size-detector.service';

export let browserRefresh = false;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  loggedIn: Boolean = false;
  subscription: Subscription;

  @ViewChild("sideBarDrawer", { static: false })
  sideBarDrawer: MatDrawer;

  screenSize: ScreenSize;


  constructor(
    private router: Router,
    private globalService: GlobalService,
    private screenSizeDetectorService: ScreenSizeDetectorService) {

  }
  
  ngOnInit() {
    this.registerListeners();
  }

  registerListeners(): void {

    this.subscription = this.router.events.subscribe((event:any) => {
      if (event instanceof NavigationStart) {
        browserRefresh = !this.router.navigated;
      }
  });
    

    this.globalService.onToggleSideBarStateChange.subscribe(toggleSideBar => {
      if(toggleSideBar) {
        this.sideBarDrawer.open();
      }else{
        this.sideBarDrawer.close();
      }

    });

    this.screenSize = this.screenSizeDetectorService.getCurrentSize();
    this.adjustUIForScreen();

    this.screenSizeDetectorService.onResize
      .pipe(delay(0))
      .subscribe(x => {
        this.screenSize = x;

        this.adjustUIForScreen();
      });
  }

  adjustUIForScreen() {
    if(this.sideBarDrawer) {
      this.sideBarDrawer.close();
    }
    
  }
}
