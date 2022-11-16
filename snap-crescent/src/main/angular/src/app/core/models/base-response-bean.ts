import { BaseResponse } from "./base-response";

export class BaseResponseBean<ID, T> extends BaseResponse {
    object?: T;
    objects?: T[] = [];
    objectId?: ID;

    totalResultsCount?: number;
    resultCountPerPage?: number;
    currentPageIndex?: number;
}