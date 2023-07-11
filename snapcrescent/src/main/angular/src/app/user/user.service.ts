import { HttpClient } from '@angular/common/http';
import { Injectable} from '@angular/core';
import { BaseResponseBean } from '../core/models/base-response-bean';
import { Observable, of } from "rxjs";
import { BaseService } from '../core/services/base.service';
import { User, UserType } from './user.model';
import { Option } from '../core/models/option.model';
import { ObjectError } from '../core/models/validation-model';

@Injectable({
    providedIn: "root"
  })
export class UserService extends BaseService {

  override sortMapping:any = {
    fullName: "user.firstName",
    firstName: "user.firstName",
    userStatusName: "user.userStatus",
  };

  constructor(
    private httpClient: HttpClient
  ) { 
    super();
  }

  private entityUrl = '/user';

  search(params:any): Observable<BaseResponseBean<number, User>> {
    return this.httpClient.get(this.entityUrl,super.getSearchParameters(params));
  }

  read(id: number): Observable<BaseResponseBean<number, User>> {
    return this.httpClient.get(this.entityUrl + '/' + id);
  }

  readLite(id: number): Observable<BaseResponseBean<number, User>> {
    return this.httpClient.get(this.entityUrl + '/' + id + '/lite');
  }

  save(entity: User): Observable<BaseResponseBean<number, User>> {
    return this.httpClient.post(this.entityUrl, this.preparePayload(entity));
  }

  update(id: number,entity: User): Observable<BaseResponseBean<number, User>> {
    return this.httpClient.put(this.entityUrl + '/' + id,this.preparePayload(entity));
  }

  validate(entity: User): Observable<BaseResponseBean<number, ObjectError>> {
    return this.httpClient.post(this.entityUrl + '/validate', this.preparePayload(entity));
  }

  delete(id: number) {
    return this.httpClient.delete(this.entityUrl + '/' + id);
  }

  resetPassword(id: number, entity:User): Observable<BaseResponseBean<number, Boolean>> {
    return this.httpClient.put(this.entityUrl + '/' + id + "/reset-password",entity);
  }

  preparePayload(entity: User) {
        return entity;
  }

  getUserTypesAsOptions(): Observable<Option[]> {
    const userTypeOptions: Option[] = [];

    for (const [key, value] of Object.entries(UserType)) {
      userTypeOptions.push({
        value:value.id,
        label:value.label,
        rawValue:value
      });

  }

    return of(userTypeOptions);
}
  

 
}
