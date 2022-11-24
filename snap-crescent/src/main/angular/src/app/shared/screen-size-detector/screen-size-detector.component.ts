import { Component, ElementRef, AfterViewInit, HostListener } from '@angular/core';
import { ScreenSize } from './screen-size-detector.model';
import { ScreenSizeDetectorService } from './screen-size-detector.service';

@Component({
  selector: 'app-screen-size-detector',
  templateUrl: './screen-size-detector.component.html',
  styleUrls:['./screen-size-detector.component.scss']
})
export class ScreenSizeDetectorComponent implements AfterViewInit {
  prefix = 'is-';
  sizes = [
    {
      id: ScreenSize.XS, name: 'xs',
      css: `d-block d-sm-none`
    },
    {
      id: ScreenSize.SM, name: 'sm',
      css: `d-none d-sm-block d-md-none`
    },
    {
      id: ScreenSize.MD, name: 'md',
      css: `d-none d-md-block d-lg-none`
    },
    {
      id: ScreenSize.LG, name: 'lg',
      css: `d-none d-lg-block d-xl-none`
    },
    {
      id: ScreenSize.XL, name: 'xl',
      css: `d-none d-xl-block`
    },
  ];

  constructor(private elementRef: ElementRef, private screenSizeDetectorService: ScreenSizeDetectorService) { }

  @HostListener("window:resize", [])
  private onResize() {
    this.detectScreenSize();
  }

  ngAfterViewInit() {
    this.detectScreenSize();
  }

  private detectScreenSize() {
    const currentSize = this.sizes.find(x => {
      const el = this.elementRef.nativeElement.querySelector(`.${this.prefix}${x.id}`);
      const isVisible = window.getComputedStyle(el).display != 'none';

      return isVisible;
    });

    this.screenSizeDetectorService.resize(currentSize!.id);
  }

}