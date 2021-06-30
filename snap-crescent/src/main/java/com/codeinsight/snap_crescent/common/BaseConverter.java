package com.codeinsight.snap_crescent.common;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.codeinsight.snap_crescent.common.utils.BeanXSSCleaner;
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

public abstract class BaseConverter<E, B> {

	public abstract void populateEntityWithBean(E entity, B bean);

	public abstract E getEntityFromBean(B bean);

	public abstract List<E> getEntitiesFromBeans(List<B> beans);

	public abstract List<B> getBeansFromEntities(List<E> entities, ResultType resultType);

	public abstract B getBeanFromEntity(E entity, ResultType resultType);

	@Autowired
	protected BeanXSSCleaner beanXSSCleaner;
	
	@Autowired
	protected FileService fileService;
	
	
	public List<B> getBeansFromEntities(List<E> entities, ResultType... resultType) {
		if (resultType != null && resultType.length > 0) {
			return getBeansFromEntities(entities, resultType[0]);
		} else {
			return getBeansFromEntities(entities, ResultType.FULL);
		}
	}

	public B getBeanFromEntity(E entity, ResultType... resultType) {

		if (resultType != null && resultType.length > 0) {
			return getBeanFromEntity(entity, resultType[0]);
		} else {
			return getBeanFromEntity(entity, ResultType.FULL);
		}
	}

	public void populateBeanWithAuditValues(BaseUiBean bean, BaseEntity entity, ResultType resultType) {

		beanXSSCleaner.cleanBean(bean);
		
		bean.setId(entity.getId());
		bean.setActive(entity.getActive());
		bean.setVersion(entity.getVersion());


		if (resultType == ResultType.FULL || resultType == ResultType.SEARCH) {
			bean.setCreationDatetime(entity.getCreationDatetime());
		}

		if (resultType == ResultType.FULL || resultType == ResultType.SEARCH) {
			bean.setLastModifiedDatetime(entity.getLastModifiedDatetime());
		}
		
	}
}
