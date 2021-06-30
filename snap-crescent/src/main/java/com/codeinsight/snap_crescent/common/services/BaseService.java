package com.codeinsight.snap_crescent.common.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;
import com.codeinsight.snap_crescent.common.utils.BeanXSSCleaner;

public class BaseService {

	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;

	protected Pageable getPageableFromSearchCriteria(BaseSearchCriteria searchCriteria) {
		Sort sort = Sort.by(searchCriteria.getSortOrder(), searchCriteria.getSortBy());
		Pageable pageable = PageRequest.of(searchCriteria.getPageNumber(),
				searchCriteria.getResultPerPage(), sort);
		
		return pageable;
	}

}
