package com.snapcrescent.asset;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.metadata.MetadataConverter;
import com.snapcrescent.thumbnail.ThumbnailConverter;

@Component
public class AssetConverter extends BaseConverter<Asset, UiAsset> {

	@Autowired
	private ThumbnailConverter thumbnailConverter;

	@Autowired
	private MetadataConverter metadataConverter;

	@Override
	public void populateEntityWithBean(Asset entity, UiAsset bean) {

	}

	@Override
	public Asset getEntityFromBean(UiAsset bean) {

		Asset entity = new Asset();
		populateEntityWithBean(entity, bean);
		return entity;
	}

	@Override
	public List<Asset> getEntitiesFromBeans(List<UiAsset> beans) {

		List<Asset> entities = new ArrayList<>();

		for (UiAsset bean : beans) {
			entities.add(getEntityFromBean(bean));
		}

		return entities;
	}

	@Override
	public List<UiAsset> getBeansFromEntities(List<Asset> entities, ResultType resultType) {

		List<UiAsset> beans = new ArrayList<>();

		for (Asset entity : entities) {
			beans.add(getBeanFromEntity(entity, resultType));
		}

		return beans;
	}

	@Override
	public UiAsset getBeanFromEntity(Asset entity, ResultType resultType) {

		UiAsset bean = new UiAsset();

		try {
			bean.setActive(entity.getActive());
			bean.setAssetType(entity.getAssetType());
			bean.setFavorite(entity.getFavorite());

			if (entity.getMetadataId() != null) {
				bean.setMetadataId(entity.getMetadataId());
				bean.setMetadata(metadataConverter.getBeanFromEntity(entity.getMetadata(), resultType));
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
