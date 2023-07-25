package com.snapcrescent.common.services;

import org.springframework.beans.factory.annotation.Autowired;

import com.snapcrescent.common.security.CoreService;
import com.snapcrescent.common.utils.BeanXSSCleaner;

public class BaseService {
	
	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;
	
	@Autowired
	protected CoreService coreService;

}
