package com.snapcrescent.common;

import java.util.ArrayList;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.modelmapper.TypeMap;
import org.springframework.beans.factory.annotation.Autowired;

import com.snapcrescent.common.beans.BaseUiBean;
import com.snapcrescent.common.utils.BeanXSSCleaner;
import com.snapcrescent.common.utils.Constant.ResultType;

public abstract class BaseConverter<E extends BaseEntity, B extends BaseUiBean> {
	
	@Autowired
	protected ModelMapper modelMapper;

	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;

	private final Class<E> entityClass;
	private final Class<B> beanClass;
	
	public abstract E loadEntityById(Long id);
	
	public BaseConverter(Class<E> entityClass, Class<B> beanClass) {
		this.entityClass = entityClass;
		this.beanClass = beanClass;
	}
	
	protected TypeMap<E, B> getEntityToBeanMapper(String typeMapName) {
		return modelMapper.createTypeMap(entityClass, beanClass, typeMapName);
	}
	
	protected TypeMap<B, E> getBeanToEntityMapper(String typeMapName) {
		return modelMapper.createTypeMap(beanClass, entityClass, typeMapName);
	}
	
	public void populateEntityWithBean(E entity, B bean) {
		populateEntityWithBean(entity, bean, null);
	}
	
	public void populateEntityWithBean(E entity, B bean, String typeMapName) {
		
		if(typeMapName != null) {
			modelMapper.map(bean, entity, typeMapName);
		} else {
			modelMapper.map(bean, entity);
		}
		
		
	}
	
	public List<E> processCollectionUpdate(List<E> persistedChildren, List<B> transientChildren, boolean isDeepUpdate) {
		if(persistedChildren == null) {
			persistedChildren = new ArrayList<>();
		} 
		
		
		List<E> newlyAddressChildren = new ArrayList<>();
		List<E> unChangedAndUpdatedChildren = new ArrayList<>();
		List<E> removedChildren = new ArrayList<>();
		
		//Loop to Remove PersistedChildren collection
		for (E persistedChild : persistedChildren) {
			boolean persistedChildFoundInTransientList = false;
			
			if(transientChildren != null) {
				for (B transientChild : transientChildren) {
					if(persistedChild.getId().equals(transientChild.getId())) {
						persistedChildFoundInTransientList = true;
						break;
					}
				}
			}
			
			
			if(persistedChildFoundInTransientList == false) {
				removedChildren.add(persistedChild);
			}
			
		}
		
		
		//Loop to Add/Update TransientChildren in persistedChildren collection
		if(transientChildren != null) {
		for (B transientChild : transientChildren) {
			boolean transientChildFoundInPersistedList = false;
			
			for (E persistedChild : persistedChildren) {
				if(persistedChild.getId().equals(transientChild.getId())) {
					transientChildFoundInPersistedList = true;
					
					unChangedAndUpdatedChildren.add(persistedChild);
					
					if(isDeepUpdate) {
						populateEntityWithBean(persistedChild, transientChild);	
					}
					break;
				}
			}
			
			if(transientChildFoundInPersistedList == false) {
				
				if(transientChild.getId() == null) {
					newlyAddressChildren.add(getEntityFromBean(transientChild));	
				} else {
					newlyAddressChildren.add(loadEntityById(transientChild.getId()));
				}
			}
			
		}
		}
		
		persistedChildren.clear();
		persistedChildren.addAll(newlyAddressChildren);
		persistedChildren.addAll(unChangedAndUpdatedChildren);
		
		return persistedChildren;
	}

	

	public E getEntityFromBean(B bean) {
		E entity = null;
		try {
			entity = entityClass.getDeclaredConstructor().newInstance();
			populateEntityWithBean(entity, bean);
			return entity;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return entity;
	}

	public List<E> getEntitiesFromBeans(List<B> beans) {

		List<E> entities = new ArrayList<>();

		for (B bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}
	
	public List<B> getBeansFromEntities(List<E> entities, ResultType resultType) {
		return getBeansFromEntities(entities, resultType, null);
	}

	public List<B> getBeansFromEntities(List<E> entities, ResultType resultType, String typeMapName) {
		
		if(entities == null) {
			return null;
		}

		List<B> beans = new ArrayList<>();

		for (E entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType, typeMapName));
		}

		return beans;

	}
	
	public B getBeanFromEntity(E entity, ResultType resultType) {
		return getBeanFromEntity(entity, resultType, null);
	}

	public B getBeanFromEntity(E entity, ResultType resultType,  String typeMapName) {

		B bean = null;

		if(entity != null) {
			try {

				if(typeMapName != null) {
					bean = modelMapper.map(entity, beanClass, typeMapName);
				} else {
					bean = modelMapper.map(entity, beanClass);	
				}
				

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		

		return bean;
	}
}
