package com.codeinsight.snap_crescent.video;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.videoMetadata.VideoMetadataConverter;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailConverter;

@Component
public class VideoConverter extends BaseConverter<Video, UiVideo> {

	@Autowired
	private ThumbnailConverter thumbnailConverter;

	@Autowired
	private VideoMetadataConverter videoMetadataConverter;

	@Override
	public void populateEntityWithBean(Video entity, UiVideo bean) {

	}

	@Override
	public Video getEntityFromBean(UiVideo bean) {

		Video entity = new Video();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Video> getEntitiesFromBeans(List<UiVideo> beans) {

		List<Video> entities = new ArrayList<>();

		for (UiVideo bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiVideo> getBeansFromEntities(List<Video> entities, ResultType resultType) {

		List<UiVideo> beans = new ArrayList<>();

		for (Video entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiVideo getBeanFromEntity(Video entity, ResultType resultType) {

		UiVideo bean = new UiVideo();

		try {
			bean.setFavorite(entity.getFavorite());

			if (entity.getVideoMetadataId() != null) {
				bean.setVideoMetadataId(entity.getVideoMetadataId());
				bean.setVideoMetadata(videoMetadataConverter.getBeanFromEntity(entity.getVideoMetadata(), resultType));
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
