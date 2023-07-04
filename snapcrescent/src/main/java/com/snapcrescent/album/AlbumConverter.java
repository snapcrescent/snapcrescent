package com.snapcrescent.album;

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

@Component
public class AlbumConverter extends BaseConverter<Album, UiAlbum> {

	@Autowired
	private AlbumRepository albumRepository;
	
	public AlbumConverter() {
		super(Album.class, UiAlbum.class);
	}
	
	@Override
	public Album loadEntityById(Long id) {
		return albumRepository.loadById(id);
	}
	
	@Override
	public List<UiAlbum> getBeansFromEntities(List<Album> entities, ResultType resultType) {
		return super.getBeansFromEntities(entities,resultType,  createTypeMap(resultType));
	}

	@Override
	public UiAlbum getBeanFromEntity(Album entity, ResultType resultType) {
		return super.getBeanFromEntity(entity, resultType, createTypeMap(resultType)); 		
	}
	
		private String createTypeMap(ResultType resultType) {
		
		String typeMapName = UUID.randomUUID().toString();
		TypeMap<Album, UiAlbum> typeMap = getEntityToBeanMapper(typeMapName);
		
		Converter<DbEnum, String> enumConvertor = ModelMapperUtils.getDbEnumConvertor();
		typeMap.addMappings(mapper -> mapper.using(enumConvertor).map(Album::getAlbumTypeEnum, UiAlbum::setAlbumTypeName));
		
		return typeMapName;	
	}

}
