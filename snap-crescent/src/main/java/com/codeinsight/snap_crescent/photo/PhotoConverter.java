package com.codeinsight.snap_crescent.photo;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadataConverter;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailConverter;

@Component
public class PhotoConverter extends BaseConverter<Photo, UiPhoto> {

	@Autowired
	private ThumbnailConverter thumbnailConverter;

	@Autowired
	private PhotoMetadataConverter photoMetadataConverter;

	@Override
	public void populateEntityWithBean(Photo entity, UiPhoto bean) {

	}

	@Override
	public Photo getEntityFromBean(UiPhoto bean) {

		Photo entity = new Photo();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Photo> getEntitiesFromBeans(List<UiPhoto> beans) {

		List<Photo> entities = new ArrayList<>();

		for (UiPhoto bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiPhoto> getBeansFromEntities(List<Photo> entities, ResultType resultType) {

		List<UiPhoto> beans = new ArrayList<>();

		for (Photo entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiPhoto getBeanFromEntity(Photo entity, ResultType resultType) {

		UiPhoto bean = new UiPhoto();

		try {
			bean.setFavorite(entity.getFavorite());

			if (entity.getPhotoMetadataId() != null) {
				bean.setPhotoMetadataId(entity.getPhotoMetadataId());
				bean.setPhotoMetadata(photoMetadataConverter.getBeanFromEntity(entity.getPhotoMetadata(), resultType));
			}

			if (entity.getThumbnailId() != null) {
				bean.setThumbnailId(entity.getThumbnailId());
				bean.setThumbnail(thumbnailConverter.getBeanFromEntity(entity.getThumbnail(), resultType));
			}

			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
