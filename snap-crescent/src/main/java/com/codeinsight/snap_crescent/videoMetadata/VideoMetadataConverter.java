package com.codeinsight.snap_crescent.videoMetadata;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.location.LocationConverter;

@Component
public class VideoMetadataConverter extends BaseConverter<VideoMetadata, UiVideoMetadata> {

	@Autowired
	private LocationConverter locationConverter;

	@Override
	public void populateEntityWithBean(VideoMetadata entity, UiVideoMetadata bean) {

	}

	@Override
	public VideoMetadata getEntityFromBean(UiVideoMetadata bean) {

		VideoMetadata entity = new VideoMetadata();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<VideoMetadata> getEntitiesFromBeans(List<UiVideoMetadata> beans) {

		List<VideoMetadata> entities = new ArrayList<>();

		for (UiVideoMetadata bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiVideoMetadata> getBeansFromEntities(List<VideoMetadata> entities, ResultType resultType) {

		List<UiVideoMetadata> beans = new ArrayList<>();

		for (VideoMetadata entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiVideoMetadata getBeanFromEntity(VideoMetadata entity, ResultType resultType) {

		UiVideoMetadata bean = new UiVideoMetadata();

		try {
			bean.setName(entity.getName());
			bean.setSize(entity.getSize());
			bean.setFileTypeName(entity.getFileTypeName());
			bean.setFileTypeLongName(entity.getFileTypeLongName());
			bean.setMimeType(entity.getMimeType());
			bean.setFileExtension(entity.getFileExtension());
			bean.setModel(entity.getModel());
			bean.setHeight(entity.getHeight());
			bean.setWidth(entity.getWidth());
			bean.setOrientation(entity.getOrientation());
			bean.setFstop(entity.getFstop());

			if (entity.getLocationId() != null) {
				bean.setLocationId(entity.getLocationId());
				bean.setLocation(locationConverter.getBeanFromEntity(entity.getLocation(), resultType));
			}
			
			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
