import { Injectable } from "@angular/core";
import {
  HttpRequest,
  HttpHandler,
  HttpInterceptor
} from "@angular/common/http";
import { finalize } from "rxjs/operators";
import { LoaderService } from "src/app/shared/loader/loader.service";

@Injectable()
export class LoadingInterceptor implements HttpInterceptor {
  constructor(private loaderService: LoaderService) {}

  intercept(req: HttpRequest<any>, next: HttpHandler) {
    const loading = req.headers.get('loading') !== "false";
    if (loading) {
      this.loaderService.add();
    }
    return next.handle(req).pipe(
      finalize(() => {
        if (loading) {
          this.loaderService.subtract();
        }
      })
    );
  }
}
