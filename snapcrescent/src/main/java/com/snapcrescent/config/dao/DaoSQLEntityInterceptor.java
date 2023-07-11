package com.snapcrescent.config.dao;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Date;

import org.hibernate.CallbackException;
import org.hibernate.Interceptor;
import org.hibernate.type.Type;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.security.AppUser;
import com.snapcrescent.common.security.CoreService;


@Component
public class DaoSQLEntityInterceptor implements Interceptor {
	
	/**
     * Called when new objects are saved.
     */
	@Autowired
	private ApplicationContext context;
	
	
	@Override
    public boolean onSave(Object object, Serializable id, Object[] newValues, String[] properties, Type[] types) throws CallbackException {
		boolean retChangedState = false;
		
    	if (object instanceof BaseEntity) {
    		
    		BaseEntity entity = ((BaseEntity) object);
    		
    		CoreService coreService = context.getBean(CoreService.class);
    		AppUser appUser = coreService.getAppUser();
			Date now = new Date();
			
			if(entity.getCreatedByUserId() == null) {
				
				if(appUser != null) {
					setValue(newValues, properties, "createdByUserId", appUser.getId());	
				} 
			}
			
			if(entity.getCreationDateTime() == null) {
				setValue(newValues, properties, "creationDateTime", now);
			}
			
			setValue(newValues, properties, "lastModifiedDateTime", now);
			
			retChangedState = true;
		}
		
		return retChangedState;
    }
	
	/**
	 * Called when existing objects are modified.
	 */
	@Override
    public boolean onFlushDirty(Object entity, Serializable id, Object[] newValues, Object[] oldValues, String[] properties, Type[] types) throws CallbackException {
    	boolean retChangedState = false;
    	
    	if (entity instanceof BaseEntity) {
    		
			setValue(newValues, properties, "lastModifiedDateTime", new Date());
			
			retChangedState = true;
		}

        return retChangedState;
    }


	
    
	private void setValue(Object[] currentState, String[] propertyNames,
			String propertyToSet, Object value) {
		int index = Arrays.asList(propertyNames).indexOf(propertyToSet);
		if (index >= 0) {
			currentState[index] = value;
		}
	}
}
