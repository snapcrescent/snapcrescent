package com.codeinsight.snap_crescent.metadata;

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
public class MetadataConverter extends BaseConverter<Metadata, UiMetadata> {

	@Autowired
	private LocationConverter locationConverter;

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
				bean.setBase64EncodedPhoto(Base64.getEncoder().encodeToString(fileService.readFileBytes(FILE_TYPE.PHOTO,entity.getPath(), entity.getInternalName())));
			}

			populateBeanWithAuditValues(bean, entity, resultType);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return bean;
	}

}
