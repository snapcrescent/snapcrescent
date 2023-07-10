import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDrawer } from '@angular/material/sidenav';
import { NavigationStart, Router } from '@angular/router';
import { Subscription } from 'rxjs';

export let browserRefresh = false;

@Component({
  selector: 'app-admin',
  templateUrl: './admin.component.html',
  styleUrls: ['./admin.component.scss']
})
export class AdminComponent implements OnInit {

  loggedIn: Boolean = false;
  redirectingToLogin: Boolean = false;
  redirectingToHome: Boolean = false;

  subscription: Subscription;

  @ViewChild("sideBarDrawer", { static: false })
  sideBarDrawer: MatDrawer;

  constructor(
    private router: Router) {

  }

  ngOnInit() {
    this.registerListeners();
  }

  registerListeners(): void {

    this.subscription = this.router.events.subscribe((event: any) => {
      if (event instanceof NavigationStart) {
        browserRefresh = !this.router.navigated;
      }
    });

  }
}
