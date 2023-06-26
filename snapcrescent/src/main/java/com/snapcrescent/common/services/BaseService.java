package com.snapcrescent.common.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import com.snapcrescent.common.beans.BaseSearchCriteria;
import com.snapcrescent.common.utils.BeanXSSCleaner;

public class BaseService {
	
	protected static final Logger logger = LoggerFactory.getLogger(BaseService.class);

	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;

	protected Pageable getPageableFromSearchCriteria(BaseSearchCriteria searchCriteria) {
		Sort sort = Sort.by(searchCriteria.getSortOrder(), searchCriteria.getSortBy());
		Pageable pageable = PageRequest.of(searchCriteria.getPageNumber(),
				searchCriteria.getResultPerPage(), sort);
		
		return pageable;
	}

}
