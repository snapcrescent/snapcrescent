import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent implements OnInit{

  menuItems: any[] = [];

  ngOnInit() {
    this.menuItems.push(
      {
        icon:"",
        label:"Photos",
        link:"/home/employee/list",
      });

    this.menuItems.push(
        {
          icon:"",
          label:"Videos",
          link:"/home/pay-slip/generate",
        });  
  }

}
