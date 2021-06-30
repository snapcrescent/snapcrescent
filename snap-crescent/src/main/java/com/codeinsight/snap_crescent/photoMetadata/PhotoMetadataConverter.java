package com.codeinsight.snap_crescent.photoMetadata;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.location.LocationConverter;

@Component
public class PhotoMetadataConverter extends BaseConverter<PhotoMetadata, UiPhotoMetadata> {

	@Autowired
	private LocationConverter locationConverter;

	@Override
	public void populateEntityWithBean(PhotoMetadata entity, UiPhotoMetadata bean) {

	}

	@Override
	public PhotoMetadata getEntityFromBean(UiPhotoMetadata bean) {

		PhotoMetadata entity = new PhotoMetadata();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<PhotoMetadata> getEntitiesFromBeans(List<UiPhotoMetadata> beans) {

		List<PhotoMetadata> entities = new ArrayList<>();

		for (UiPhotoMetadata bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiPhotoMetadata> getBeansFromEntities(List<PhotoMetadata> entities, ResultType resultType) {

		List<UiPhotoMetadata> beans = new ArrayList<>();

		for (PhotoMetadata entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiPhotoMetadata getBeanFromEntity(PhotoMetadata entity, ResultType resultType) {

		UiPhotoMetadata bean = new UiPhotoMetadata();

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
			
			if(resultType == ResultType.FULL) {
				bean.setBase64EncodedPhoto(Base64.getEncoder().encodeToString(fileService.readFileBytes(FILE_TYPE.PHOTO,entity.getPath())));
			}

			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
