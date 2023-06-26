import { Component, Input, OnInit } from '@angular/core';
import { BreadCrumb } from './breadcrumb.model';

@Component({
  selector: 'app-breadcrumb',
  templateUrl: './breadcrumb.component.html',
  styleUrls: ['./breadcrumb.component.scss']
})
export class BreadcrumbComponent implements OnInit{

  @Input()
  breadCrumbs:BreadCrumb[] = []

  ngOnInit() {
  }

}
