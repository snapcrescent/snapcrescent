package com.snapcrescent.thumbnail;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;
import com.snapcrescent.common.utils.Constant.ResultType;

@Component
public class ThumbnailConverter extends BaseConverter<Thumbnail, UiThumbnail>{
	
	@Override
	public void populateEntityWithBean(Thumbnail entity, UiThumbnail bean) {
		
	}

	@Override
	public Thumbnail getEntityFromBean(UiThumbnail bean) {

		Thumbnail entity = new Thumbnail();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Thumbnail> getEntitiesFromBeans(List<UiThumbnail> beans) {

		List<Thumbnail> entities = new ArrayList<>();

		for (UiThumbnail bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiThumbnail> getBeansFromEntities(List<Thumbnail> entities, ResultType resultType) {

		List<UiThumbnail> beans = new ArrayList<>();

		for (Thumbnail entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiThumbnail getBeanFromEntity(Thumbnail entity, ResultType resultType) {

		UiThumbnail bean = new UiThumbnail();

		try {
			bean.setName(entity.getName());
			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
