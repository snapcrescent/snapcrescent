package com.codeinsight.snap_crescent.thumbnail;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

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
			
			if(resultType == ResultType.SEARCH) {
				bean.setBase64EncodedThumbnail(Base64.getEncoder().encodeToString(fileService.readFileBytes(FILE_TYPE.THUMBNAIL,entity.getPath())));	
			}
			
			
			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
