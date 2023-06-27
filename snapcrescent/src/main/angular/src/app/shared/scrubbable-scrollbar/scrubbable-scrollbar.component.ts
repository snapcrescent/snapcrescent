import { Component, OnInit, AfterViewInit, Input, OnChanges, SimpleChanges, Inject, LOCALE_ID, Output, EventEmitter } from '@angular/core';
import { Section } from '../asset-grid/asset-grid.model';
import { TimeLine } from './scrubbable-scrollbar.model';
import { formatDate } from '@angular/common';
import moment from 'moment';

@Component({
  selector: 'app-scrubbable-scrollbar',
  templateUrl: './scrubbable-scrollbar.component.html',
  styleUrls: ['./scrubbable-scrollbar.component.scss']
})
export class ScrubbableScrollbarComponent implements OnInit, OnChanges, AfterViewInit {

  @Input()
  activeSection: Section;

  @Output()
  activeSectionChange: EventEmitter<any> = new EventEmitter<any>();

  monthYearSections : Section[] = [];
  activeTimelineItem: TimeLine;
  timelineItems:TimeLine[]= [];

  constructor(
    @Inject(LOCALE_ID) public locale: string
  ) {

  }

  ngOnInit() {
    
  }

  ngAfterViewInit() {

   
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes?.['activeSection'] && this.activeSection) {
      const label = this.getHoverText(this.activeSection.monthYear);

      let timelineItem = this.timelineItems.find((timelineItem:TimeLine) => timelineItem.hoverText === label)

      if(timelineItem) {
        this.navigate(timelineItem);
      }
    }
  }

  populateTimeline(sections: Section[]) {
    this.timelineItems = [];
    if(sections) {

      sections.forEach((section:Section) => {         
        let clonedSection = section.clone(new Date(moment(section.monthYear).startOf("month").valueOf()));
        
        if(!this.monthYearSections.find(monthYearSection => monthYearSection.id === clonedSection.id)){
          this.monthYearSections.push(clonedSection);
        }
      });

      let monthYearsWithAssets: string[] = this.monthYearSections.map(monthYearSection => monthYearSection.id);
      let yearsWithAssets: number[] = this.monthYearSections.map(monthYearSection => monthYearSection.monthYear.getFullYear());
      yearsWithAssets = yearsWithAssets.filter((v, i, a) => a.indexOf(v) === i);

      for(const yearWithAssets of yearsWithAssets) {

        let latestMonth = 11;
        let oldestMonth = 0;

        if(yearWithAssets == yearsWithAssets[0]) {
          latestMonth = this.monthYearSections[0].monthYear.getMonth();
        } 

        if(yearWithAssets == yearsWithAssets[yearsWithAssets.length - 1]) {
          oldestMonth = this.monthYearSections[this.monthYearSections.length - 1].monthYear.getMonth();
        }

        for(let monthIndex = latestMonth; monthIndex >= oldestMonth ; monthIndex--) {
            const monthYear = moment().month(monthIndex).year(yearWithAssets).startOf("month").valueOf().toString();

            const indexInMonthYearsWithAssets = monthYearsWithAssets.indexOf(monthYear);

            let timelineItem: TimeLine = new TimeLine();

            if(indexInMonthYearsWithAssets > -1 || monthIndex == 0) {

              let monthYear = new Date(moment().month(monthIndex).year(yearWithAssets).valueOf());
              
              if(indexInMonthYearsWithAssets > -1) {
                const section = this.monthYearSections[indexInMonthYearsWithAssets];
                monthYear = section.monthYear;
                timelineItem.isRealItem = true;  
              } 
              
              timelineItem.month = monthYear.getMonth();
              timelineItem.year = monthYear.getFullYear();
              timelineItem.monthYear = monthYear;
              timelineItem.hoverText = this.getHoverText(monthYear); 
            
            } 

            this.timelineItems.push(timelineItem);
        }
      }
    }
  }

  navigate(timelineItem: TimeLine, changedByUser = false) {

    this.timelineItems.forEach(timelineItem => timelineItem.isActive = false);
    
    timelineItem.isActive = true;
    this.activeTimelineItem = timelineItem;

    if(changedByUser) {
      let activeSection
      if(this.activeTimelineItem.isRealItem) {
        activeSection = this.monthYearSections.find(monthYearSection => monthYearSection.monthYear === this.activeTimelineItem.monthYear)
      } else {
        activeSection = this.monthYearSections.filter(sectionItem => sectionItem.monthYear.getFullYear() == this.activeTimelineItem.year)[0];
      }

      this.activeSectionChange.emit(activeSection);
    }
  }

  getHoverText(monthYear:Date) {
    return moment().month(monthYear.getMonth()).year(monthYear.getFullYear()).format("MMM yyyy");
  }
}
