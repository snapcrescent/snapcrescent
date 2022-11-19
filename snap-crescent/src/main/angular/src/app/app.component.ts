import { Component, OnInit } from '@angular/core';
import { NavigationStart, Router } from '@angular/router';
import { Subscription } from 'rxjs';
import { SessionService } from './core/services/session-service';

export let browserRefresh = false;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  loggedIn: Boolean = false;
  redirectingToLogin: Boolean = false;
  redirectingToHome: Boolean = false;

  subscription: Subscription;

  constructor(
    private router: Router,
    private sessionService: SessionService) {

  }
  
  ngOnInit() {
    this.registerListeners();
    this.sessionService.getLoginState();
  }

  registerListeners(): void {

    this.subscription = this.router.events.subscribe((event:any) => {
      if (event instanceof NavigationStart) {
        browserRefresh = !this.router.navigated;
      }
  });
    

    this.sessionService.onLoggedInStateChange.subscribe(loggedIn => {
      this.redirectingToHome = loggedIn; 
      this.redirectingToLogin = !loggedIn;

      if(loggedIn) {
        this.loggedIn = loggedIn;
      } else {
        setTimeout(()=>{
          this.loggedIn = loggedIn;
        }, 800);
      }
      
    })
  }
}
