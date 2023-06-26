import { Component, OnInit, AfterViewInit, Input, OnChanges, SimpleChanges } from '@angular/core';
import { Router } from '@angular/router';
import { Section } from '../asset-grid/asset-grid.model';

@Component({
  selector: 'app-scrubbable-scrollbar',
  templateUrl: './scrubbable-scrollbar.component.html',
  styleUrls: ['./scrubbable-scrollbar.component.scss']
})
export class ScrubbableScrollbarComponent implements OnInit, OnChanges, AfterViewInit {

  activeTimelineItem: any;

  @Input()
  sections: Section[] = [];

  timelineItems:any[]= [];

  constructor(
    private router: Router
  ) {

  }

  ngOnInit() {
    this.populateTimeline();
  }

  ngAfterViewInit() {

   
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes?.['sections']) {
      this.populateTimeline();
    }
  }

  populateTimeline() {
    this.timelineItems = [];
    if(this.sections) {
      this.sections.forEach((section:Section) => { 
        this.timelineItems.push({label: section.monthYear});
      });
    }
  }

  navigate(menuItem: any) {
    this.activeTimelineItem = menuItem;
    this.router.navigate([menuItem.link]);
  }
}
