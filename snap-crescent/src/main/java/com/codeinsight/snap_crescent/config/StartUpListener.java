package com.codeinsight.snap_crescent.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.services.StartUpOperationsService;

@Component
public class StartUpListener{
	
	private Boolean processed = false;
	
	@Autowired
 	private StartUpOperationsService startUpOperationsService;
	
	@EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
      
		if(processed == false)
		{
			startUpOperationsService.performPostStartUpOperations();
		}
		processed = true;
    }	
}
