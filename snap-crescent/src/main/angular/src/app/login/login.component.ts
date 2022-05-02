import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UserLoginRequest } from '../core/models/user-login-request';
import { AuthService } from '../core/services/auth-service';
import { SessionService } from '../core/services/session-service';


@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit{

  redirectingToHome: boolean = false;

  form = new FormGroup({
    username: new FormControl('', [Validators.required]),
    password: new FormControl('', Validators.required)
  });

  constructor(
    private sessionService: SessionService,
    private authService: AuthService,
    private router: Router
    ) {

  }

  ngOnInit() {
    
  }

  get userLoginRequest(){
    return this.form.getRawValue() as UserLoginRequest;
  }

  login() {
    this.authService.login(this.userLoginRequest).subscribe(response => {
    this.redirectingToHome = true;
    
      setTimeout(()=>{
        this.sessionService.login();
        this.router.navigate(['/home']);
      }, 800);
    })
    

    
    
    
  }

  
  
}
