package com.snapcrescent.common.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.snapcrescent.common.security.CoreService;
import com.snapcrescent.common.utils.BeanXSSCleaner;

public class BaseService {
	
	protected static final Logger logger = LoggerFactory.getLogger(BaseService.class);

	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;
	
	@Autowired
	protected CoreService coreService;

}
