package com.codeinsight.snap_crescent.metadata;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

@Component
public class MetadataConverter extends BaseConverter<Metadata, UiMetadata> {

	@Override
	public void populateEntityWithBean(Metadata entity, UiMetadata bean) {

	}

	@Override
	public Metadata getEntityFromBean(UiMetadata bean) {

		Metadata entity = new Metadata();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Metadata> getEntitiesFromBeans(List<UiMetadata> beans) {

		List<Metadata> entities = new ArrayList<>();

		for (UiMetadata bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiMetadata> getBeansFromEntities(List<Metadata> entities, ResultType resultType) {

		List<UiMetadata> beans = new ArrayList<>();

		for (Metadata entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiMetadata getBeanFromEntity(Metadata entity, ResultType resultType) {

		UiMetadata bean = new UiMetadata();

		try {
			bean.setName(entity.getName());
			bean.setMimeType(entity.getMimeType());
			bean.setInternalName(entity.getInternalName());
			bean.setSize(entity.getSize());
			
			if (resultType == ResultType.FULL || resultType == ResultType.SEARCH) {
				bean.setCreationDateTime(entity.getCreationDateTime());
			}

			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
