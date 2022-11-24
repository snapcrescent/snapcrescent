export class BaseSearchCriteria {  
  selectedIds: number[];

  searchKeyword: string;
  fromDate: Date;
  toDate: Date;

  sortBy: string;
  sortOrder: string;

  pageNumber: number;
  resultPerPage: number;
  }