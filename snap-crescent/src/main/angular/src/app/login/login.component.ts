import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { SessionService } from '../core/services/session-service';


@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit{

  particlesOptions:any = {
    "background": {
      "color": {
        "value": "#15c57e"
      },
      "position": "50% 50%",
      "repeat": "no-repeat",
      "size": "cover"
    },
    "fullScreen": {
      "zIndex": 0
    },
    "interactivity": {
      "events": {
        "onClick": {
          "enable": true,
          "mode": "repulse"
        },
        "onHover": {
          "enable": true,
          "mode": "bubble"
        }
      },
      "modes": {
        "bubble": {
          "distance": 400,
          "duration": 0.3,
          "opacity": 1,
          "size": 4
        },
        "grab": {
          "distance": 400,
          "links": {
            "opacity": 0.5
          }
        }
      }
    },
    "particles": {
      "links": {
        "color": {
          "value": "#ffffff"
        },
        "distance": 500,
        "opacity": 0.4,
        "width": 2
      },
      "move": {
        "attract": {
          "rotate": {
            "x": 600,
            "y": 1200
          }
        },
        "direction": "bottom",
        "enable": true,
        "path": {},
        "outModes": {
          "bottom": "out",
          "left": "out",
          "right": "out",
          "top": "out"
        },
        "spin": {}
      },
      "number": {
        "density": {
          "enable": true
        },
        "value": 400
      },
      "opacity": {
        "random": {
          "enable": true
        },
        "value": {
          "min": 0.1,
          "max": 0.5
        },
        "animation": {
          "speed": 1,
          "minimumValue": 0.1
        }
      },
      "size": {
        "random": {
          "enable": true
        },
        "value": {
          "min": 1,
          "max": 10
        },
        "animation": {
          "speed": 40,
          "minimumValue": 0.1
        }
      }
    }
  };

  redirectingToHome: boolean = false;

  constructor(
    private sessionService: SessionService,
    private router: Router
    ) {

  }

  ngOnInit() {
    
  }

  login() {
    this.redirectingToHome = true;

    setTimeout(()=>{
      this.sessionService.login();
      this.router.navigate(['/home']);
    }, 800);
    
    
  }

  
  
}
