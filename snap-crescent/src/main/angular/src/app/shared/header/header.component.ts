import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { SessionService } from 'src/app/core/services/session-service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {

  constructor(
    private sessionService: SessionService,
    private router: Router
    ) {

  }

  logout() {
    this.sessionService.logout();
    this.router.navigate(['/login']);
    

    
  }
}
