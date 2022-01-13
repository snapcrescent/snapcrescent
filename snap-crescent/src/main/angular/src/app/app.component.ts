import { Component, OnInit } from '@angular/core';
import { SessionService } from './core/services/session-service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  loggedIn: boolean = false;
  redirectingToLogin: boolean = false;
  redirectingToHome: boolean = false;

  constructor(private sessionService: SessionService) {

  }
  
  ngOnInit() {
    this.registerListeners();
  }

  registerListeners(): void {
    this.sessionService.onloggedInStateChange.subscribe(loggedIn => {
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
