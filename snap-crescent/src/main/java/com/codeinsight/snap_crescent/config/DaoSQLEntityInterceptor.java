package com.codeinsight.snap_crescent.config;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Date;

import org.hibernate.CallbackException;
import org.hibernate.EmptyInterceptor;
import org.hibernate.type.Type;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseEntity;


@Component
public class DaoSQLEntityInterceptor extends EmptyInterceptor {
	
	private static final long serialVersionUID = 2874782982927327631L;
	
	/**
     * Called when new objects are saved.
     */
    public boolean onSave(Object entity, Serializable id, Object[] newValues, String[] properties, Type[] types) throws CallbackException {
		boolean retChangedState = false;
		
    	if (entity instanceof BaseEntity) {
			
			Date now = new Date();
			
			setValue(newValues, properties, "createdById", 1L);
			
			if(((BaseEntity) entity).getCreationDatetime() == null) {
				setValue(newValues, properties, "creationDatetime", now);
			}
		    
		    setValue(newValues, properties, "lastModifiedById", 1L);
		    setValue(newValues, properties, "lastModifiedDatetime", now);
			
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
			setValue(newValues, properties, "lastModifiedDatetime", new Date());
			
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
