package com.snapcrescent.asset;

import java.util.List;
import java.util.UUID;

import org.modelmapper.Converter;
import org.modelmapper.TypeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;
import com.snapcrescent.common.utils.Constant.DbEnum;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.ModelMapperUtils;
import com.snapcrescent.metadata.MetadataConverter;
import com.snapcrescent.thumbnail.ThumbnailConverter;

@Component
public class AssetConverter extends BaseConverter<Asset, UiAsset> {
	
	@Autowired
	private AssetRepository assetRepository;

	@Autowired
	private ThumbnailConverter thumbnailConverter;

	@Autowired
	private MetadataConverter metadataConverter;
	
	public AssetConverter() {
		super(Asset.class, UiAsset.class);
	}
	
	@Override
	public Asset loadEntityById(Long id) {
		return assetRepository.loadById(id);
	}

	@Override
	public List<UiAsset> getBeansFromEntities(List<Asset> entities, ResultType resultType) {
		return super.getBeansFromEntities(entities,resultType,  createTypeMap(resultType));
	}

	@Override
	public UiAsset getBeanFromEntity(Asset entity, ResultType resultType) {
		

		UiAsset bean = super.getBeanFromEntity(entity, resultType, createTypeMap(resultType)); 
		
		if (entity.getMetadataId() != null) {
			bean.setMetadataId(entity.getMetadataId());
			bean.setMetadata(metadataConverter.getBeanFromEntity(entity.getMetadata(), resultType));
		}

		if (entity.getThumbnailId() != null) {
			bean.setThumbnailId(entity.getThumbnailId());
			bean.setThumbnail(thumbnailConverter.getBeanFromEntity(entity.getThumbnail(), resultType));
		}
		
		return bean;
	}
	
		private String createTypeMap(ResultType resultType) {
		
		String typeMapName = UUID.randomUUID().toString();
		TypeMap<Asset, UiAsset> typeMap = getEntityToBeanMapper(typeMapName);
		
		Converter<DbEnum, String> enumConvertor = ModelMapperUtils.getDbEnumConvertor();
		typeMap.addMappings(mapper -> mapper.using(enumConvertor).map(Asset::getAssetTypeEnum, UiAsset::setAssetTypeName));
		
		return typeMapName;	
	}

}
