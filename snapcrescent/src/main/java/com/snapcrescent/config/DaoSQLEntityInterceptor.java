package com.snapcrescent.config;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Date;

import org.hibernate.CallbackException;
import org.hibernate.Interceptor;
import org.hibernate.type.Type;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseEntity;


@Component
public class DaoSQLEntityInterceptor implements Interceptor {
	
	/**
     * Called when new objects are saved.
     */
    public boolean onSave(Object entity, Serializable id, Object[] newValues, String[] properties, Type[] types) throws CallbackException {
		boolean retChangedState = false;
		
    	if (entity instanceof BaseEntity) {
			
			Date now = new Date();
			
			setValue(newValues, properties, "createdById", 1L);
			
			if(((BaseEntity) entity).getCreationDateTime() == null) {
				setValue(newValues, properties, "creationDateTime", now);
			}
		    
		    setValue(newValues, properties, "lastModifiedById", 1L);
		    setValue(newValues, properties, "lastModifiedDateTime", now);
			
			retChangedState = true;
		}
		
		return retChangedState;
    }
	
	/**
	 * Called when existing objects are modified.
	 */
    public boolean onFlushDirty(Object entity, Serializable id, Object[] newValues, Object[] oldValues, String[] properties, Type[] types) throws CallbackException {
    	boolean retChangedState = false;
    	
    	if (entity instanceof BaseEntity) {
    		
			setValue(newValues, properties, "lastModifiedById", 1L);
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
