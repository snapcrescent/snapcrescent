package com.codeinsight.snap_crescent.asset;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.BaseConverter;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.metadata.MetadataConverter;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailConverter;

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
			bean.setAssetTypeName(entity.getAssetTypeEnum().getLabel());
			bean.setAssetType(entity.getAssetType());
			bean.setFavorite(entity.getFavorite());

			if (entity.getMetadataId() != null) {
				bean.setMetadataId(entity.getMetadataId());
				bean.setMetadata(metadataConverter.getBeanFromEntity(entity.getMetadata(), resultType));
				
				if(resultType == ResultType.FULL) {
					if(entity.getAssetTypeEnum() == AssetType.PHOTO) {
						//bean.getMetadata().setBase64EncodedPhoto(Base64.getEncoder().encodeToString(fileService.readFileBytes(FILE_TYPE.PHOTO,entity.getMetadata().getPath(), entity.getMetadata().getInternalName())));	
					}
				}
				
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
